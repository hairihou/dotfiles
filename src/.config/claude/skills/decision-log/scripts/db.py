#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# ///
"""Decision log database operations.

Usage:
  ./db.py init
  ./db.py insert <date> <repository> <topic> <chosen> <alternatives> <reasoning>
  ./db.py search [--repo REPO] [--from DATE] [--to DATE] [--match KEYWORD]
  ./db.py detail <id>
  ./db.py update-outcome <id> <outcome>
"""

import argparse
import os
import sqlite3

DB_DIR = os.path.expanduser("~/.local/share/claude")
DB_PATH = os.path.join(DB_DIR, "claude.db")

INIT_SQL = """
CREATE TABLE IF NOT EXISTS decisions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  repository TEXT NOT NULL,
  topic TEXT NOT NULL,
  chosen TEXT NOT NULL,
  alternatives TEXT,
  reasoning TEXT NOT NULL,
  outcome TEXT
);
CREATE INDEX IF NOT EXISTS idx_decisions_date ON decisions(date);
CREATE INDEX IF NOT EXISTS idx_decisions_repo ON decisions(repository);
CREATE VIRTUAL TABLE IF NOT EXISTS decisions_fts USING fts5(
  topic, chosen, alternatives, reasoning, outcome,
  content='decisions',
  content_rowid='id'
);
CREATE TRIGGER IF NOT EXISTS decisions_ai AFTER INSERT ON decisions BEGIN
  INSERT INTO decisions_fts(rowid, topic, chosen, alternatives, reasoning, outcome)
  VALUES (new.id, new.topic, new.chosen, new.alternatives, new.reasoning, new.outcome);
END;
CREATE TRIGGER IF NOT EXISTS decisions_ad AFTER DELETE ON decisions BEGIN
  INSERT INTO decisions_fts(decisions_fts, rowid, topic, chosen, alternatives, reasoning, outcome)
  VALUES ('delete', old.id, old.topic, old.chosen, old.alternatives, old.reasoning, old.outcome);
END;
CREATE TRIGGER IF NOT EXISTS decisions_au AFTER UPDATE ON decisions BEGIN
  INSERT INTO decisions_fts(decisions_fts, rowid, topic, chosen, alternatives, reasoning, outcome)
  VALUES ('delete', old.id, old.topic, old.chosen, old.alternatives, old.reasoning, old.outcome);
  INSERT INTO decisions_fts(rowid, topic, chosen, alternatives, reasoning, outcome)
  VALUES (new.id, new.topic, new.chosen, new.alternatives, new.reasoning, new.outcome);
END;
"""

COLUMNS = [
    "id",
    "date",
    "repository",
    "topic",
    "chosen",
    "alternatives",
    "reasoning",
    "outcome",
]


def get_connection():
    os.makedirs(DB_DIR, exist_ok=True)
    return sqlite3.connect(DB_PATH)


def init_db(conn):
    conn.executescript(INIT_SQL)
    print("OK")


def insert(conn, args):
    conn.execute(
        "INSERT INTO decisions (date, repository, topic, chosen, alternatives, reasoning) VALUES (?, ?, ?, ?, ?, ?)",
        (
            args.date,
            args.repository,
            args.topic,
            args.chosen,
            args.alternatives,
            args.reasoning,
        ),
    )
    conn.commit()
    row_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
    print_rows(conn, "SELECT * FROM decisions WHERE id = ?", (row_id,))


def search(conn, args):
    conditions = []
    params = []
    if args.repo:
        conditions.append("d.repository = ?")
        params.append(args.repo)
    if args.from_date:
        conditions.append("d.date >= ?")
        params.append(args.from_date)
    if args.to:
        conditions.append("d.date <= ?")
        params.append(args.to)
    if args.match:
        conditions.append("decisions_fts MATCH ?")
        params.append(args.match)
        where = f"WHERE {' AND '.join(conditions)}" if conditions else ""
        sql = f"SELECT d.* FROM decisions d JOIN decisions_fts f ON d.id = f.rowid {where} ORDER BY d.date DESC"
    else:
        where = f"WHERE {' AND '.join(conditions)}" if conditions else ""
        sql = f"SELECT d.* FROM decisions d {where} ORDER BY d.date DESC"
    print_rows(conn, sql, params)


def detail(conn, args):
    print_rows(conn, "SELECT * FROM decisions WHERE id = ?", (args.id,))


def update_outcome(conn, args):
    conn.execute(
        "UPDATE decisions SET outcome = ? WHERE id = ?", (args.outcome, args.id)
    )
    conn.commit()
    print_rows(conn, "SELECT * FROM decisions WHERE id = ?", (args.id,))


def print_rows(conn, sql, params=()):
    rows = conn.execute(sql, params).fetchall()
    if not rows:
        print("No results.")
        return
    widths = [
        max(len(str(col)), max(len(str(row[i])) for row in rows))
        for i, col in enumerate(COLUMNS)
    ]
    header = "  ".join(col.ljust(widths[i]) for i, col in enumerate(COLUMNS))
    sep = "  ".join("-" * widths[i] for i in range(len(COLUMNS)))
    print(header)
    print(sep)
    for row in rows:
        print(
            "  ".join(
                str(val if val is not None else "").ljust(widths[i])
                for i, val in enumerate(row)
            )
        )


def main():
    parser = argparse.ArgumentParser(description="Decision log database operations")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("init")
    p_insert = sub.add_parser("insert")
    p_insert.add_argument("date")
    p_insert.add_argument("repository")
    p_insert.add_argument("topic")
    p_insert.add_argument("chosen")
    p_insert.add_argument("alternatives")
    p_insert.add_argument("reasoning")
    p_search = sub.add_parser("search")
    p_search.add_argument("--repo")
    p_search.add_argument("--from", dest="from_date")
    p_search.add_argument("--to")
    p_search.add_argument("--match")
    p_detail = sub.add_parser("detail")
    p_detail.add_argument("id", type=int)
    p_update = sub.add_parser("update-outcome")
    p_update.add_argument("id", type=int)
    p_update.add_argument("outcome")
    args = parser.parse_args()
    conn = get_connection()
    try:
        {
            "init": lambda: init_db(conn),
            "insert": lambda: insert(conn, args),
            "search": lambda: search(conn, args),
            "detail": lambda: detail(conn, args),
            "update-outcome": lambda: update_outcome(conn, args),
        }[args.command]()
    finally:
        conn.close()


if __name__ == "__main__":
    main()
