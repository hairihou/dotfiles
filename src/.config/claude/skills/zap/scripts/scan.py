#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# ///
import subprocess
import sys
import time
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("Usage: scan.py <baseline|full> <url>")
    mode, url = sys.argv[1], sys.argv[2]
    zap_script = {"baseline": "zap-baseline.py", "full": "zap-full-scan.py"}.get(mode)
    if zap_script is None:
        print(f"Unknown mode: {mode} (expected baseline|full)", file=sys.stderr)
        sys.exit(64)

    ts = time.strftime("%Y%m%d-%H%M%S")
    out_dir = Path("zap") / ts
    out_dir.mkdir(parents=True, exist_ok=True)

    rc = subprocess.run(
        [
            "docker", "run", "--rm", "-t",
            "-v", f"{out_dir.resolve()}:/zap/wrk:rw",
            "ghcr.io/zaproxy/zaproxy:stable",
            zap_script, "-t", url, "-r", "report.html", "-J", "report.json",
        ],
    ).returncode

    # ZAP exit: 0=clean, 1=alerts found, 2=error. Treat 0/1 as success.
    if rc <= 1:
        print(f"OK ({rc}) -> {out_dir}")
        sys.exit(0)
    print(f"FAIL ({rc})", file=sys.stderr)
    sys.exit(rc)


if __name__ == "__main__":
    main()
