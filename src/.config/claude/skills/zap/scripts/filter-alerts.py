#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# ///
"""Filter a ZAP report.json to High/Medium alerts and emit compact JSON.

Usage: filter-alerts.py <path-to-report.json>

Reads the raw report (potentially tens of MB) and prints a compact list of
alerts on stdout, each carrying its instances. ZAP encodes `riskcode` as a
string — `int()` cast is required, otherwise a naive `>= 2` comparison
silently drops every alert.
"""

import json
import sys


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit("Usage: filter-alerts.py <report.json>")
    with open(sys.argv[1]) as f:
        data = json.load(f)
    out = []
    for site in data.get("site", []):
        for alert in site.get("alerts", []):
            try:
                rc = int(alert.get("riskcode", 0))
            except (TypeError, ValueError):
                rc = 0
            if rc < 2:
                continue
            out.append({
                "name": alert.get("name", ""),
                "riskdesc": alert.get("riskdesc", ""),
                "cweid": alert.get("cweid", ""),
                "wascid": alert.get("wascid", ""),
                "solution": alert.get("solution", ""),
                "reference": alert.get("reference", ""),
                "instances": [
                    {k: i.get(k, "") for k in ("uri", "method", "param", "attack", "evidence")}
                    for i in alert.get("instances", [])
                ],
            })
    print(json.dumps(out, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
