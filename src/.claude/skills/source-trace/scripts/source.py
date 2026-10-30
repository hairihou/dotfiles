#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "pypdf>=6.21.2",
# ]
# ///
"""Trace papers through OpenAlex and extract page text for verbatim quote checks.

Usage:
    source.py find <doi|title>              candidates (title search returns up to 5)
    source.py refs <id|doi> [-n 20]         works this paper cites
    source.py cites <id|doi> [-n 20]        works citing this paper, most cited first
    source.py text <url>                    page or PDF body as plain text lines

Rows are tab-separated: year, cited_by, openalex_id, title, doi, oa_pdf_url.
"""

import argparse
import io
import ipaddress
import json
import re
import socket
import sys
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from typing import IO, TYPE_CHECKING, override

from pypdf import PdfReader
from pypdf.errors import PdfReadError

if TYPE_CHECKING:
    from http.client import HTTPMessage

API = "https://api.openalex.org"
FIELDS = "id,display_name,publication_year,cited_by_count,doi,best_oa_location"
WORK_ID = re.compile(r"W\d+")
META_CHARSET = re.compile(rb"""<meta[^>]+charset=["']?([\w-]+)""", re.IGNORECASE)
UA = {"User-Agent": "source-trace"}
MAX_BYTES = 50_000_000


class UnsupportedSchemeError(ValueError):
    def __init__(self, url: str) -> None:
        super().__init__(f"only http(s) URLs are fetched: {clean(url)}")


class NonPublicAddressError(ValueError):
    def __init__(self, ip: object, host: str) -> None:
        super().__init__(f"refusing non-public address {ip} for {clean(host)}")


class ResponseTooLargeError(ValueError):
    def __init__(self) -> None:
        super().__init__(f"response exceeds {MAX_BYTES:,} bytes")


def check_public(url: str) -> None:
    parts = urllib.parse.urlsplit(url)
    if parts.scheme not in {"http", "https"} or not parts.hostname:
        raise UnsupportedSchemeError(url)
    for *_, addr in socket.getaddrinfo(parts.hostname, parts.port or 443):
        ip = ipaddress.ip_address(addr[0])
        if not ip.is_global:
            raise NonPublicAddressError(ip, parts.hostname)


class PublicRedirectHandler(urllib.request.HTTPRedirectHandler):
    @override
    def redirect_request(
        self,
        req: urllib.request.Request,
        fp: IO[bytes],
        code: int,
        msg: str,
        headers: HTTPMessage,
        newurl: str,
    ) -> urllib.request.Request | None:
        check_public(newurl)
        return super().redirect_request(req, fp, code, msg, headers, newurl)


OPENER = urllib.request.build_opener(PublicRedirectHandler)


def fetch(url: str) -> tuple[bytes, str, str | None]:
    # urllib encodes the request line as ASCII, so a pasted URL with Japanese or
    # other non-ASCII characters fails.
    url = urllib.parse.quote(url, safe=":/?#[]@!$&'()*+,;=%~")
    check_public(url)
    req = urllib.request.Request(url, headers=UA)  # noqa: S310
    with OPENER.open(req, timeout=60) as res:
        body = res.read(MAX_BYTES + 1)
        if len(body) > MAX_BYTES:
            raise ResponseTooLargeError
        return body, res.headers.get_content_type(), res.headers.get_content_charset()


def api(path: str, **params: str | int) -> dict:
    body, *_ = fetch(f"{API}{path}?{urllib.parse.urlencode(params)}")
    return json.loads(body)


def clean(value: object) -> str:
    # Titles come from third parties; tabs, newlines, or bidi controls would break
    # the row format.
    return re.sub(
        r"[\s\x00-\x1f\x7f-\x9f\u200b\u200e\u200f\u202a-\u202e\u2066-\u2069\ufeff]+",
        " ",
        str(value or ""),
    ).strip()


def row(work: dict) -> str:
    oa = (work.get("best_oa_location") or {}).get("pdf_url")
    wid = (work.get("id") or "").rsplit("/", 1)[-1]
    fields = (
        work.get("publication_year"),
        work.get("cited_by_count"),
        wid,
        work.get("display_name"),
        work.get("doi"),
        oa,
    )
    return "\t".join(clean(f) for f in fields)


def search_title(title: str) -> list[dict]:
    words = title.replace(",", " ").replace(":", " ").split()
    if not words:
        return []
    return api(
        "/works",
        filter="title.search:" + " ".join(words),
        sort="cited_by_count:desc",
        **{"per-page": 5},
        select=FIELDS,
    )["results"]


def resolve(key: str) -> dict:
    wid = key.rstrip("/").rsplit("/", 1)[-1]
    if WORK_ID.fullmatch(wid):
        return api(f"/works/{wid}", select=FIELDS)
    if key.startswith("10.") or "doi.org/" in key:
        doi = urllib.parse.unquote(key.rsplit("doi.org/", maxsplit=1)[-1])
        if any(part in {".", ".."} for part in doi.split("/")):
            sys.exit(f"invalid DOI: {clean(key)}")
        return api(f"/works/doi:{urllib.parse.quote(doi, safe='/')}", select=FIELDS)
    hits = search_title(key)
    if not hits:
        sys.exit(f"not found: {clean(key)}")
    return hits[0]


class TextExtractor(HTMLParser):
    BLOCK = frozenset(
        {
            "p",
            "div",
            "li",
            "br",
            "tr",
            "td",
            "th",
            "table",
            "ul",
            "ol",
            "h1",
            "h2",
            "h3",
            "h4",
            "h5",
            "h6",
            "pre",
            "blockquote",
            "section",
            "article",
            "main",
            "header",
            "footer",
            "nav",
            "aside",
            "figcaption",
            "dd",
            "dt",
        }
    )
    SKIP = frozenset({"script", "style", "noscript", "svg", "template"})

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []
        self.skipping = 0

    @override
    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag in self.SKIP:
            self.skipping += 1
        elif tag in self.BLOCK:
            self.parts.append("\n")

    @override
    def handle_endtag(self, tag: str) -> None:
        if tag in self.SKIP and self.skipping:
            self.skipping -= 1
        elif tag in self.BLOCK:
            self.parts.append("\n")

    @override
    def handle_data(self, data: str) -> None:
        if not self.skipping:
            self.parts.append(data)


def text(url: str) -> str:
    body, ctype, charset = fetch(url)
    if ctype == "application/pdf" or body.startswith(b"%PDF"):
        pages = PdfReader(io.BytesIO(body)).pages
        return "\n".join(page.extract_text() or "" for page in pages)
    if not charset and "html" in ctype and (meta := META_CHARSET.search(body[:4096])):
        charset = meta.group(1).decode("ascii")
    try:
        decoded = body.decode(charset or "utf-8", errors="replace")
    except LookupError:
        decoded = body.decode("utf-8", errors="replace")
    if "html" not in ctype:
        return decoded
    parser = TextExtractor()
    parser.feed(decoded)
    lines = (
        re.sub(r"[ \t\u00a0]+", " ", line).strip()
        for line in "".join(parser.parts).splitlines()
    )
    return "\n".join(line for line in lines if line)


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("cmd", choices=["find", "refs", "cites", "text"])
    parser.add_argument("key", nargs="+")
    parser.add_argument(
        "-n", type=int, default=20, choices=range(1, 201), metavar="1-200"
    )
    args = parser.parse_args()
    key = " ".join(args.key)

    try:
        if args.cmd == "text":
            print(text(key))
        elif args.cmd == "find":
            is_id = (
                WORK_ID.fullmatch(key.rstrip("/").rsplit("/", 1)[-1])
                or key.startswith("10.")
                or "doi.org/" in key
            )
            hits = [resolve(key)] if is_id else search_title(key)
            if not hits:
                print(
                    f"no candidates: {clean(key)}"
                    " (retry with the DOI or fewer title words)"
                )
            for work in hits:
                print(row(work))
        else:
            wid = (resolve(key).get("id") or "").rsplit("/", 1)[-1]
            flt = f"cited_by:{wid}" if args.cmd == "refs" else f"cites:{wid}"
            res = api(
                "/works",
                filter=flt,
                sort="cited_by_count:desc",
                **{"per-page": args.n},
                select=FIELDS,
            )
            total = clean(res["meta"]["count"])
            print(f"# {args.cmd} {wid}: top {len(res['results'])} of {total}")
            for work in res["results"]:
                print(row(work))
    except (OSError, ValueError, PdfReadError) as e:
        sys.exit(f"error: {e}")


if __name__ == "__main__":
    main()
