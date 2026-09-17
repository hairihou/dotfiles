#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# dependencies = [
#   "google-auth[requests]>=2.58.0",
#   "google-auth-oauthlib>=1.4.1",
# ]
# ///
"""Google Workspace REST API client with OAuth token management."""

import argparse
import os
import stat
import sys
import tempfile
from pathlib import Path

from google.auth.transport.requests import AuthorizedSession, Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow

CONFIG_DIR = Path.home() / ".config" / "google-workspace"
CLIENT_SECRET = CONFIG_DIR / "client_secret.json"
TOKEN = CONFIG_DIR / "token.json"
SCOPES = [
    "https://www.googleapis.com/auth/documents",
    "https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/forms.body",
    "https://www.googleapis.com/auth/forms.responses.readonly",
    "https://www.googleapis.com/auth/presentations",
    "https://www.googleapis.com/auth/spreadsheets",
]
SPILL_THRESHOLD = 20_000
SPILL_HEAD = 1_000


def fail(message: str) -> None:
    print(message, file=sys.stderr)
    sys.exit(1)


def save(creds: Credentials) -> None:
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    TOKEN.touch(mode=0o600, exist_ok=True)
    TOKEN.write_text(creds.to_json())


def login() -> None:
    if not CLIENT_SECRET.is_file():
        fail(f"OAuth client not found: {CLIENT_SECRET}")
    flow = InstalledAppFlow.from_client_secrets_file(str(CLIENT_SECRET), SCOPES)
    save(flow.run_local_server(port=0))
    print(f"Saved token: {TOKEN}")


def load() -> Credentials:
    if not TOKEN.is_file():
        fail("Not logged in. Ask the user to run /google-workspace login.")
    creds = Credentials.from_authorized_user_file(str(TOKEN))
    if not creds.has_scopes(SCOPES):
        fail(
            "Token lacks required scopes. Ask the user to run /google-workspace login."
        )
    if not creds.valid:
        creds.refresh(Request())
        save(creds)
    return creds


def request(method: str, url: str, output: Path | None) -> None:
    body = None
    if method not in ("GET", "DELETE") and not sys.stdin.isatty():
        body = sys.stdin.buffer.read() or None
    response = AuthorizedSession(load()).request(
        method,
        url,
        data=body,
        headers={"Content-Type": "application/json"} if body else None,
    )
    text = response.content.decode()
    if not response.ok:
        print(f"HTTP {response.status_code} {method} {url}", file=sys.stderr)
        fail(text)
    if output:
        output.write_text(text)
        return
    piped = stat.S_ISFIFO(os.fstat(sys.stdout.fileno()).st_mode)
    if piped or len(text) <= SPILL_THRESHOLD:
        print(text)
        return
    with tempfile.NamedTemporaryFile("w", delete=False) as f:
        f.write(text)
    print(f"Response ({len(text)} chars) saved to {f.name}. Head:")
    print(text[:SPILL_HEAD])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "method", help="login, or an HTTP method (GET, POST, PATCH, PUT, DELETE)"
    )
    parser.add_argument("url", nargs="?")
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()
    if args.method == "login":
        login()
        return
    if not args.url:
        parser.error("url is required")
    request(args.method.upper(), args.url, args.output)


if __name__ == "__main__":
    main()
