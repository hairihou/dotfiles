#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# ///
"""Decision log database operations.

Usage:
  ./db.py detail <id>
  ./db.py init
  ./db.py insert <date> <repository> <topic> <chosen> <alternatives> <reasoning>
         [--consequences CONS] [--confidence LEVEL] [--reevaluate-when COND]
  ./db.py search [--from DATE] [--match KEYWORD] [--repo REPO] [--status STATUS] [--to DATE]
  ./db.py summary [--limit N]
  ./db.py supersede <id> <date> <repository> <topic> <chosen> <alternatives> <reasoning>
         [--consequences CONS] [--confidence LEVEL] [--reevaluate-when COND]
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
  outcome TEXT,
  consequences TEXT,
  confidence TEXT,
  reevaluate_when TEXT,
  status TEXT NOT NULL DEFAULT 'accepted',
  superseded_by INTEGER REFERENCES decisions(id)
);
CREATE INDEX IF NOT EXISTS idx_decisions_date ON decisions(date);
CREATE INDEX IF NOT EXISTS idx_decisions_repo ON decisions(repository);
"""

FTS_SQL = """
DROP TRIGGER IF EXISTS decisions_ai;
DROP TRIGGER IF EXISTS decisions_ad;
DROP TRIGGER IF EXISTS decisions_au;
DROP TABLE IF EXISTS decisions_fts;
CREATE VIRTUAL TABLE IF NOT EXISTS decisions_fts USING fts5(
  topic, chosen, alternatives, reasoning, outcome, consequences,
  content='decisions',
  content_rowid='id'
);
INSERT INTO decisions_fts(rowid, topic, chosen, alternatives, reasoning, outcome, consequences)
  SELECT id, topic, chosen, alternatives, reasoning, outcome, consequences FROM decisions;
CREATE TRIGGER IF NOT EXISTS decisions_ai AFTER INSERT ON decisions BEGIN
  INSERT INTO decisions_fts(rowid, topic, chosen, alternatives, reasoning, outcome, consequences)
  VALUES (new.id, new.topic, new.chosen, new.alternatives, new.reasoning, new.outcome, new.consequences);
END;
CREATE TRIGGER IF NOT EXISTS decisions_ad AFTER DELETE ON decisions BEGIN
  INSERT INTO decisions_fts(decisions_fts, rowid, topic, chosen, alternatives, reasoning, outcome, consequences)
  VALUES ('delete', old.id, old.topic, old.chosen, old.alternatives, old.reasoning, old.outcome, old.consequences);
END;
CREATE TRIGGER IF NOT EXISTS decisions_au AFTER UPDATE ON decisions BEGIN
  INSERT INTO decisions_fts(decisions_fts, rowid, topic, chosen, alternatives, reasoning, outcome, consequences)
  VALUES ('delete', old.id, old.topic, old.chosen, old.alternatives, old.reasoning, old.outcome, old.consequences);
  INSERT INTO decisions_fts(rowid, topic, chosen, alternatives, reasoning, outcome, consequences)
  VALUES (new.id, new.topic, new.chosen, new.alternatives, new.reasoning, new.outcome, new.consequences);
END;
"""

MIGRATE_COLUMNS = {
    "consequences": "TEXT",
    "confidence": "TEXT",
    "reevaluate_when": "TEXT",
    "status": "TEXT NOT NULL DEFAULT 'accepted'",
    "superseded_by": "INTEGER REFERENCES decisions(id)",
}

LIST_COLUMNS = ["id", "date", "repository", "topic", "chosen", "status"]
ALL_COLUMNS = [
    "id",
    "date",
    "repository",
    "topic",
    "chosen",
    "alternatives",
    "reasoning",
    "outcome",
    "consequences",
    "confidence",
    "reevaluate_when",
    "status",
    "superseded_by",
]


def get_connection():
    os.makedirs(DB_DIR, exist_ok=True)
    return sqlite3.connect(DB_PATH)


def _get_existing_columns(conn):
    return {row[1] for row in conn.execute("PRAGMA table_info(decisions)").fetchall()}


def _migrate(conn):
    existing = _get_existing_columns(conn)
    for col, typedef in MIGRATE_COLUMNS.items():
        if col not in existing:
            conn.execute(f"ALTER TABLE decisions ADD COLUMN {col} {typedef}")
    conn.commit()


def detail(conn, args):
    row = conn.execute("SELECT * FROM decisions WHERE id = ?", (args.id,)).fetchone()
    if not row:
        print("No results.")
        return
    for col, val in zip(ALL_COLUMNS, row):
        if val is not None and val != "":
            print(f"{col}: {val}")


def init_db(conn):
    conn.executescript(INIT_SQL)
    _migrate(conn)
    conn.executescript(FTS_SQL)
    print("OK")


def insert(conn, args):
    conn.execute(
        "INSERT INTO decisions (date, repository, topic, chosen, alternatives, reasoning, consequences, confidence, reevaluate_when)"
        " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        (
            args.date,
            args.repository,
            args.topic,
            args.chosen,
            args.alternatives,
            args.reasoning,
            args.consequences,
            args.confidence,
            args.reevaluate_when,
        ),
    )
    conn.commit()
    row_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
    detail(conn, argparse.Namespace(id=row_id))


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
    if args.status:
        conditions.append("d.status = ?")
        params.append(args.status)
    if args.to:
        conditions.append("d.date <= ?")
        params.append(args.to)
    where = f"WHERE {' AND '.join(conditions)}" if conditions else ""
    if args.match:
        sql = f"SELECT d.id, d.date, d.repository, d.topic, d.chosen, d.status FROM decisions d JOIN decisions_fts f ON d.id = f.rowid {where} ORDER BY d.date DESC"
    else:
        sql = f"SELECT d.id, d.date, d.repository, d.topic, d.chosen, d.status FROM decisions d {where} ORDER BY d.date DESC"
    _print_table(sql, params, conn)


def summary(conn, args):
    total = conn.execute("SELECT COUNT(*) FROM decisions").fetchone()[0]
    if total == 0:
        print("No decisions recorded yet.")
        return
    repos = conn.execute(
        "SELECT repository, COUNT(*) as cnt FROM decisions GROUP BY repository ORDER BY cnt DESC"
    ).fetchall()
    recent = conn.execute(
        "SELECT date, repository, topic, status FROM decisions ORDER BY date DESC, id DESC LIMIT ?",
        (args.limit,),
    ).fetchall()
    print(f"Total: {total} decisions across {len(repos)} repos")
    print(f"Repos: {', '.join(f'{r[0]}({r[1]})' for r in repos)}")
    print("Recent:")
    for row in recent:
        status_mark = " [superseded]" if row[3] == "superseded" else ""
        print(f"  {row[0]} {row[1]}: {row[2]}{status_mark}")


def supersede(conn, args):
    old = conn.execute(
        "SELECT id, status FROM decisions WHERE id = ?", (args.id,)
    ).fetchone()
    if not old:
        print(f"Error: decision #{args.id} not found.")
        return
    if old[1] == "superseded":
        print(f"Warning: decision #{args.id} is already superseded.")
    conn.execute(
        "INSERT INTO decisions (date, repository, topic, chosen, alternatives, reasoning, consequences, confidence, reevaluate_when)"
        " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        (
            args.date,
            args.repository,
            args.topic,
            args.chosen,
            args.alternatives,
            args.reasoning,
            args.consequences,
            args.confidence,
            args.reevaluate_when,
        ),
    )
    new_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
    conn.execute(
        "UPDATE decisions SET status = 'superseded', superseded_by = ? WHERE id = ?",
        (new_id, args.id),
    )
    conn.commit()
    print(f"Decision #{args.id} superseded by #{new_id}:")
    detail(conn, argparse.Namespace(id=new_id))


def update_outcome(conn, args):
    conn.execute(
        "UPDATE decisions SET outcome = ? WHERE id = ?", (args.outcome, args.id)
    )
    conn.commit()
    detail(conn, argparse.Namespace(id=args.id))


def _print_table(sql, params, conn):
    rows = conn.execute(sql, params).fetchall()
    if not rows:
        print("No results.")
        return
    widths = [
        max(len(str(col)), max(len(str(row[i])) for row in rows))
        for i, col in enumerate(LIST_COLUMNS)
    ]
    header = "  ".join(col.ljust(widths[i]) for i, col in enumerate(LIST_COLUMNS))
    sep = "  ".join("-" * widths[i] for i in range(len(LIST_COLUMNS)))
    print(header)
    print(sep)
    for row in rows:
        print(
            "  ".join(
                str(val if val is not None else "").ljust(widths[i])
                for i, val in enumerate(row)
            )
        )


def _add_insert_args(parser):
    parser.add_argument("date", help="Decision date (YYYYMMDD)")
    parser.add_argument("repository", help="Repository name")
    parser.add_argument("topic", help="Short kebab-case label")
    parser.add_argument("chosen", help="Chosen approach")
    parser.add_argument("alternatives", help="Other options considered")
    parser.add_argument("reasoning", help="Why this was chosen")
    parser.add_argument("--consequences", help="Expected consequences/impact")
    parser.add_argument(
        "--confidence", choices=["high", "medium", "low"], help="Confidence level"
    )
    parser.add_argument(
        "--reevaluate-when",
        dest="reevaluate_when",
        help="Condition to trigger reevaluation",
    )


def main():
    parser = argparse.ArgumentParser(description="Decision log database operations")
    sub = parser.add_subparsers(dest="command", required=True)
    p_detail = sub.add_parser("detail", help="Show full detail for a decision")
    p_detail.add_argument("id", type=int, help="Decision ID")
    sub.add_parser("init", help="Initialize the database")
    p_insert = sub.add_parser("insert", help="Record a new decision")
    _add_insert_args(p_insert)
    p_search = sub.add_parser("search", help="Search past decisions")
    p_search.add_argument("--from", dest="from_date", help="Start date (YYYYMMDD)")
    p_search.add_argument("--match", help="Full-text search keyword")
    p_search.add_argument("--repo", help="Filter by repository name")
    p_search.add_argument(
        "--status", choices=["accepted", "superseded"], help="Filter by status"
    )
    p_search.add_argument("--to", help="End date (YYYYMMDD)")
    p_summary = sub.add_parser("summary", help="Show decision summary")
    p_summary.add_argument(
        "--limit", type=int, default=5, help="Number of recent decisions to show"
    )
    p_supersede = sub.add_parser("supersede", help="Supersede an existing decision")
    p_supersede.add_argument("id", type=int, help="ID of the decision to supersede")
    _add_insert_args(p_supersede)
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
            "supersede": lambda: supersede(conn, args),
            "update-outcome": lambda: update_outcome(conn, args),
        }[args.command]()
    finally:
        conn.close()


if __name__ == "__main__":
    main()
