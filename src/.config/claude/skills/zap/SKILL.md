---
name: zap
description: Run an OWASP ZAP scan against a running web app via Docker and turn the JSON report into Generate-Fix-Prompt-style remediation prompts. Use when the user wants a runtime security check on a live web app — sanity-checking AI-generated code (vibe coding), pre-deploy verification, or audits after auth / form / new-endpoint changes. Do NOT use for static SAST, dependency CVE scans, or non-web targets.
argument-hint: <target-url> [full]
allowed-tools: Bash, Read, Write
---

# ZAP Security Scan

Wrap the official ZAP Docker image (`ghcr.io/zaproxy/zaproxy:stable`) to scan a running web app, then synthesize fix prompts for High/Medium alerts modeled on ZAP 2.17's "Generate Fix Prompt" feature (GUI-only upstream).

## Context

- Docker reachable: !`docker info >/dev/null 2>&1 && echo yes || echo no`
- Working dir: !`pwd`
- Existing reports: !`ls -1t zap 2>/dev/null | head -3 || echo "(none yet)"`

## Authorization gate (run BEFORE any scan)

Before invoking Docker, confirm both:

1. The target is owned by the user, or runs on user-authorized infrastructure (own dev / staging / sandbox / authorized production)
2. For non-`localhost` / non-`127.0.0.1` targets, the user has explicit written permission to scan

If either is unclear, stop and ask. Even baseline (passive) scans crawl aggressively and can trip rate limits or WAFs; full (active) scans send real attack payloads. Scanning third-party assets without authorization may violate computer-fraud laws.

## Workflow

| Step | Action | Details |
|------|--------|---------|
| 1 | Authorize | Per gate above |
| 2 | Resolve target | If host is `localhost` / `127.0.0.1`, swap to `host.docker.internal` so the container can reach the host |
| 3 | Pick scan type | Default `baseline` (passive, ~5-10 min). Use `full` only if user passed `full` as the second argument |
| 4 | Make output dir | `mkdir -p zap/<YYYYMMDD-HHMMSS>` |
| 5 | Run scan | See command blocks below; image auto-pulls on first run (~265 MB) |
| 6 | Parse alerts | Read `report.json`, take `site[].alerts[]` with `riskcode >= 2` (High/Medium) |
| 7 | Emit fix prompts | One block per filtered alert (template below); group by alert name when an alert has multiple `instances` |
| 8 | Summarize | Counts per severity, link to `report.html`, list any prompts ready to feed an LLM |

## Baseline scan (default)

```sh
TS="$(date +%Y%m%d-%H%M%S)"
mkdir -p "zap/${TS}"
docker run --rm -t \
  -v "$(pwd)/zap/${TS}:/zap/wrk:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t "<url>" -r report.html -J report.json
```

Exit codes from `zap-baseline.py`: `0` clean, `1` warn (alerts present), `2` fail (errors). Treat `1` as success-with-findings, not failure.

## Full scan (opt-in only — second arg `full`)

Active scan: sends attack payloads, runs 30-60+ min, can leave test data in DBs. Re-confirm authorization before proceeding even if the baseline already ran on the same target.

```sh
docker run --rm -t \
  -v "$(pwd)/zap/${TS}:/zap/wrk:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py -t "<url>" -r report.html -J report.json
```

## Filtering alerts

The JSON has shape `{ "site": [ { "alerts": [ { riskcode, name, instances: [...], solution, reference, cweid, ... } ] } ] }`. Filter to High/Medium with:

```sh
jq '[.site[].alerts[] | select((.riskcode|tonumber) >= 2)]' "zap/${TS}/report.json"
```

If `jq` is unavailable, read `report.json` with the Read tool and filter inline. Each alert may have multiple `instances` (different URIs/params); emit one prompt per instance, but reuse the alert-level `solution` / `reference` / `cweid` across instances of the same alert.

## Generate Fix Prompt template

For each High/Medium instance, emit:

```markdown
### [<riskdesc>] <alert.name>

- **URL:** <instance.uri>
- **Method / Param:** <instance.method> · `<instance.param>`
- **Attack payload:** `<instance.attack>`
- **Evidence:** `<instance.evidence>`
- **CWE:** <alert.cweid> · **WASC:** <alert.wascid>

**Prompt for an LLM:**

> A ZAP scan flagged a `<alert.name>` issue (CWE-<cweid>) on `<instance.uri>`. The parameter `<instance.param>` accepted the payload `<instance.attack>` and the response contained `<instance.evidence>`.
>
> ZAP's remediation guidance: <alert.solution>
>
> Locate the route handler, template, or query that processes `<instance.param>` for this URL. Apply a fix consistent with the guidance above. Reference: <alert.reference>. After the change, explain in one sentence why the fix closes the vulnerability without rejecting valid input.
```

Empty fields (`param`, `attack`, `evidence`) are common for passive findings — substitute `(n/a)` rather than omitting the line.

## After scan

- Direct the user at `zap/<ts>/report.html` for the visual report and `report.json` as the source of truth
- Do not auto-open the HTML; print the absolute path so the user opens it when ready

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| `docker: command not found` | Docker not installed / not in PATH | Install Docker Desktop or `colima` |
| `Cannot connect to the Docker daemon` | Daemon not running | Start Docker Desktop or run `colima start` |
| Container can reach the internet but not the target | `localhost` resolves inside the container, not the host | Use `host.docker.internal` for host-bound dev servers |
| `report.json` missing after scan | Volume mount path mismatch | Verify `-v "$(pwd)/zap/${TS}:/zap/wrk:rw"` and that the host dir was created before `docker run` |
| All alerts are Informational | Target is auth-gated and ZAP only saw the login page | Out of scope for this skill; pre-authenticated scans need a ZAP context file |
| Scan hangs past expected duration | Target rate-limits ZAP, or full scan is just slow | Baseline cap ~10 min, full ~60 min — kill the container and rerun with a smaller target scope |
