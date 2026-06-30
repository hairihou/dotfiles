#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# ///
"""Resolve a paper URL into an ordered list of fetch candidates.

Output: one candidate per line as `<method>\t<url>\t<note>`, best first.
  method=html  -> readable full text; fetch with WebFetch
  method=pdf   -> download with curl, then Read (supports page ranges)
HTML is preferred over PDF (better structure, far cheaper tokens).
"""
import re
import sys
from urllib.parse import urlparse, parse_qs


def emit(rows):
    for method, url, note in rows:
        print(f"{method}\t{url}\t{note}")


def arxiv_id(s):
    m = re.search(r"(\d{4}\.\d{4,5})(v\d+)?", s)
    return m.group(0) if m else None


def resolve(raw):
    url = raw.strip()
    p = urlparse(url)
    host = p.netloc.lower()
    path = p.path

    # arXiv (abs / pdf / html / ar5iv) -> arXiv HTML, then ar5iv, then PDF
    if "arxiv.org" in host or "ar5iv" in host:
        aid = arxiv_id(path) or arxiv_id(url)
        if aid:
            return [
                ("html", f"https://arxiv.org/html/{aid}", "arXiv HTML (recent papers only)"),
                ("html", f"https://ar5iv.labs.arxiv.org/html/{aid}", "ar5iv HTML mirror"),
                ("pdf", f"https://arxiv.org/pdf/{aid}", "arXiv PDF fallback"),
            ]

    # OpenReview
    if "openreview.net" in host:
        oid = (parse_qs(p.query).get("id") or [None])[0]
        if oid:
            return [("pdf", f"https://openreview.net/pdf?id={oid}", "OpenReview PDF")]

    # ACL Anthology -> landing page has abstract; PDF for full text
    if "aclanthology.org" in host:
        base = re.sub(r"\.pdf$", "", path).rstrip("/")
        return [
            ("html", f"https://aclanthology.org{base}", "ACL landing (abstract + metadata)"),
            ("pdf", f"https://aclanthology.org{base}.pdf", "ACL PDF (full text)"),
        ]

    # bioRxiv / medRxiv -> .full (HTML), .full.pdf (PDF)
    if "biorxiv.org" in host or "medrxiv.org" in host:
        base = re.sub(r"\.full(\.pdf)?$", "", url).rstrip("/")
        return [
            ("html", f"{base}.full", "bioRxiv/medRxiv full-text HTML"),
            ("pdf", f"{base}.full.pdf", "bioRxiv/medRxiv PDF"),
        ]

    # Direct PDF
    if path.lower().endswith(".pdf"):
        return [("pdf", url, "direct PDF")]

    # Unknown source: try as HTML, then as PDF
    return [
        ("html", url, "unknown source; try HTML"),
        ("pdf", url, "unknown source; try as PDF if HTML is unreadable"),
    ]


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: resolve.py <paper-url>")
    emit(resolve(sys.argv[1]))


if __name__ == "__main__":
    main()
