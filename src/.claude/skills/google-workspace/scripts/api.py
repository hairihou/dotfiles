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
import json
import mimetypes
import os
import re
import stat
import sys
import tempfile
import uuid
from pathlib import Path
from typing import NoReturn
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from google.auth.transport.requests import AuthorizedSession, Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from requests import Response

CONFIG_DIR = Path.home() / ".config" / "google-workspace"
CLIENT_SECRET = CONFIG_DIR / "client_secret.json"
TOKEN = CONFIG_DIR / "token.json"
SCOPES = [
    "https://www.googleapis.com/auth/calendar",
    "https://www.googleapis.com/auth/documents",
    "https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/forms.body",
    "https://www.googleapis.com/auth/forms.responses.readonly",
    "https://www.googleapis.com/auth/presentations",
    "https://www.googleapis.com/auth/spreadsheets",
]
RELOGIN = "Ask the user to run /google-workspace login."
TIMEOUT = (10, 60)
SPILL_THRESHOLD = 20_000
SPILL_HEAD = 1_000
ERROR_HEAD = 600


def fail(message: str) -> NoReturn:
    print(message, file=sys.stderr)
    sys.exit(1)


def save(creds: Credentials) -> None:
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    tmp = TOKEN.with_suffix(f".{os.getpid()}.tmp")
    tmp.touch(mode=0o600)
    tmp.write_text(creds.to_json())
    tmp.replace(TOKEN)


def login() -> None:
    if not CLIENT_SECRET.is_file():
        fail(f"OAuth client not found: {CLIENT_SECRET}")
    flow = InstalledAppFlow.from_client_secrets_file(str(CLIENT_SECRET), SCOPES)
    save(flow.run_local_server(port=0))
    print(f"Saved token: {TOKEN}")


def load() -> Credentials:
    if not TOKEN.is_file():
        fail(f"Not logged in. {RELOGIN}")
    creds = Credentials.from_authorized_user_file(str(TOKEN))
    if not creds.has_scopes(SCOPES):
        fail(f"Token lacks required scopes. {RELOGIN}")
    if not creds.valid:
        creds.refresh(Request())
        save(creds)
    return creds


def with_query(url: str, **params: str) -> str:
    parts = urlsplit(url)
    query = dict(parse_qsl(parts.query, keep_blank_values=True)) | params
    return urlunsplit(parts._replace(query=urlencode(query, safe="(),/*")))


def read_stdin() -> bytes | None:
    if sys.stdin.isatty():
        return None
    return sys.stdin.buffer.read() or None


def upload_body(path: Path, metadata: bytes | None) -> tuple[bytes, str]:
    if not path.is_file():
        fail(f"Upload file not found: {path}")
    media_type = mimetypes.guess_type(path)[0] or "application/octet-stream"
    data = path.read_bytes()
    if metadata is None:
        return data, media_type
    boundary = uuid.uuid4().hex
    body = b"".join(
        [
            f"--{boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n".encode(),
            metadata,
            f"\r\n--{boundary}\r\nContent-Type: {media_type}\r\n\r\n".encode(),
            data,
            f"\r\n--{boundary}--\r\n".encode(),
        ]
    )
    return body, f"multipart/related; boundary={boundary}"


def send(
    session: AuthorizedSession,
    method: str,
    url: str,
    body: bytes | None = None,
    content_type: str | None = None,
) -> Response:
    response = session.request(
        method,
        url,
        data=body,
        headers={"Content-Type": content_type} if content_type else None,
        timeout=TIMEOUT,
    )
    if not response.ok:
        print(f"HTTP {response.status_code} {method} {url}", file=sys.stderr)
        text = response.content.decode(errors="replace")
        if "html" in response.headers.get("Content-Type", ""):
            title = re.search(r"<title>(.*?)</title>", text, re.DOTALL)
            fail(title.group(1) if title else "(HTML error page)")
        fail(text if len(text) <= ERROR_HEAD else text[:ERROR_HEAD] + " ...[truncated]")
    return response


def fetch_all(session: AuthorizedSession, url: str) -> bytes:
    fields = dict(parse_qsl(urlsplit(url).query)).get("fields")
    if fields and fields != "*" and "nextPageToken" not in fields:
        url = with_query(url, fields=f"{fields},nextPageToken")
    merged: dict = {}
    token = None
    while True:
        page = send(
            session, "GET", with_query(url, pageToken=token) if token else url
        ).json()
        token = page.pop("nextPageToken", None)
        for key, value in page.items():
            if isinstance(value, list):
                merged.setdefault(key, []).extend(value)
            else:
                merged[key] = value
        if not token:
            return json.dumps(merged, ensure_ascii=False, indent=2).encode()


def emit(content: bytes, content_type: str, output: Path | None) -> None:
    if output:
        output.write_bytes(content)
        print(f"Saved {len(content)} bytes to {output}")
        return
    try:
        text = content.decode()
    except UnicodeDecodeError:
        fail(
            f"Binary response ({content_type}, {len(content)} bytes). Save it with -o <file>."
        )
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
    parser.add_argument(
        "--all", action="store_true", help="follow nextPageToken and merge list fields"
    )
    parser.add_argument(
        "--upload", type=Path, help="file to send as media; stdin JSON becomes metadata"
    )
    args = parser.parse_args()
    if args.method == "login":
        login()
        return
    if not args.url:
        parser.error("url is required")
    method = args.method.upper()
    if args.all and method != "GET":
        parser.error("--all requires GET")
    if args.upload and method not in ("POST", "PATCH", "PUT"):
        parser.error("--upload requires POST, PATCH, or PUT")
    session = AuthorizedSession(load())
    if args.all:
        emit(fetch_all(session, args.url), "application/json", args.output)
        return
    body, content_type = None, None
    if args.upload:
        body, content_type = upload_body(args.upload, read_stdin())
    elif method not in ("GET", "DELETE"):
        body = read_stdin()
        content_type = "application/json" if body else None
    response = send(session, method, args.url, body, content_type)
    emit(response.content, response.headers.get("Content-Type", ""), args.output)


if __name__ == "__main__":
    main()
