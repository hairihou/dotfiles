#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# ///
"""Decision log database operations.

Usage:
  ./db.py detail <id>
  ./db.py init
  ./db.py insert <date> <repository> <topic> <chosen> <alternatives> <reasoning>
  ./db.py search [--from DATE] [--match KEYWORD] [--repo REPO] [--to DATE]
  ./db.py summary [--limit N]
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


def detail(conn, args):
    print_rows(conn, "SELECT * FROM decisions WHERE id = ?", (args.id,))


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
    if args.from_date:
        conditions.append("d.date >= ?")
        params.append(args.from_date)
    if args.match:
        conditions.append("decisions_fts MATCH ?")
        params.append(args.match)
    if args.repo:
        conditions.append("d.repository = ?")
        params.append(args.repo)
    if args.to:
        conditions.append("d.date <= ?")
        params.append(args.to)
    where = f"WHERE {' AND '.join(conditions)}" if conditions else ""
    if args.match:
        sql = f"SELECT d.* FROM decisions d JOIN decisions_fts f ON d.id = f.rowid {where} ORDER BY d.date DESC"
    else:
        sql = f"SELECT d.* FROM decisions d {where} ORDER BY d.date DESC"
    print_rows(conn, sql, params)


def summary(conn, args):
    total = conn.execute("SELECT COUNT(*) FROM decisions").fetchone()[0]
    if total == 0:
        print("No decisions recorded yet.")
        return
    repos = conn.execute(
        "SELECT repository, COUNT(*) as cnt FROM decisions GROUP BY repository ORDER BY cnt DESC"
    ).fetchall()
    recent = conn.execute(
        "SELECT date, repository, topic FROM decisions ORDER BY date DESC, id DESC LIMIT ?",
        (args.limit,),
    ).fetchall()
    print(f"Total: {total} decisions across {len(repos)} repos")
    print(f"Repos: {', '.join(f'{r[0]}({r[1]})' for r in repos)}")
    print("Recent:")
    for row in recent:
        print(f"  {row[0]} {row[1]}: {row[2]}")


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
    p_detail = sub.add_parser("detail", help="Show full detail for a decision")
    p_detail.add_argument("id", type=int, help="Decision ID")
    sub.add_parser("init", help="Initialize the database")
    p_insert = sub.add_parser("insert", help="Record a new decision")
    p_insert.add_argument("date", help="Decision date (YYYYMMDD)")
    p_insert.add_argument("repository", help="Repository name")
    p_insert.add_argument("topic", help="Short kebab-case label")
    p_insert.add_argument("chosen", help="Chosen approach")
    p_insert.add_argument("alternatives", help="Other options considered")
    p_insert.add_argument("reasoning", help="Why this was chosen")
    p_search = sub.add_parser("search", help="Search past decisions")
    p_search.add_argument("--from", dest="from_date", help="Start date (YYYYMMDD)")
    p_search.add_argument("--match", help="Full-text search keyword")
    p_search.add_argument("--repo", help="Filter by repository name")
    p_search.add_argument("--to", help="End date (YYYYMMDD)")
    p_summary = sub.add_parser("summary", help="Show decision summary")
    p_summary.add_argument(
        "--limit", type=int, default=5, help="Number of recent decisions to show"
    )
    p_update = sub.add_parser("update-outcome", help="Update outcome of a decision")
    p_update.add_argument("id", type=int, help="Decision ID")
    p_update.add_argument("outcome", help="Result description")
    args = parser.parse_args()
    conn = get_connection()
    try:
        {
            "detail": lambda: detail(conn, args),
            "init": lambda: init_db(conn),
            "insert": lambda: insert(conn, args),
            "search": lambda: search(conn, args),
            "summary": lambda: summary(conn, args),
            "update-outcome": lambda: update_outcome(conn, args),
        }[args.command]()
    finally:
        conn.close()


if __name__ == "__main__":
    main()
