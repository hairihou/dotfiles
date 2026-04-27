---
name: zap
description: Use when the user has authorization to run a runtime security scan against a live web app they own or have written permission to test — sanity-checking AI-generated code (vibe coding), pre-deploy verification, or audits after auth / form / endpoint changes. Do NOT use for static SAST, dependency CVE scans, non-web targets, or any third-party asset without authorization.
argument-hint: <target-url> [full]
allowed-tools: Bash, Read, Write
---

# ZAP Security Scan

Wrap the official ZAP Docker image (`ghcr.io/zaproxy/zaproxy:stable`) to scan a running web app, then synthesize fix prompts for High/Medium alerts modeled on ZAP 2.17's "Generate Fix Prompt" feature (GUI-only upstream).

Scripts: `${CLAUDE_SKILL_DIR}/scripts/scan.sh`, `${CLAUDE_SKILL_DIR}/scripts/filter-alerts.py`

## Context

- Docker reachable: !`docker info >/dev/null 2>&1 && echo yes || echo no`
- Working dir: !`pwd`
- Existing reports: !`ls -1t zap 2>/dev/null | head -3 || echo "(none yet)"`

## Preflight

If the Context block above shows `Docker reachable: no`, stop and tell the user to start their Docker runtime before proceeding. Do not run `scan.sh`. Do not assume a specific runtime (Docker Desktop, OrbStack, colima, Rancher Desktop, ...) — the user picks one, and `docker info` succeeding is the only signal that matters.

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
| 3 | Pick scan type | Default `baseline` (passive, ~5-10 min). Use `full` only if the user passed `full` as the second argument |
| 4 | Run scan | `bash ${CLAUDE_SKILL_DIR}/scripts/scan.sh <baseline\|full> <url>` — the script handles `mkdir`, `docker run`, and exit-code normalization. Image auto-pulls on first run |
| 5 | Locate run dir | The scan script prints `OK (<rc>) -> zap/<TS>` on success. Re-derive on later calls with `ls -1t zap \| head -1` — Bash tool calls do NOT share env vars |
| 6 | Filter alerts | `python ${CLAUDE_SKILL_DIR}/scripts/filter-alerts.py zap/<TS>/report.json` — emits compact JSON of High/Medium alerts to stdout. Never Read the raw `report.json`; it can be tens of MB |
| 7 | Emit fix prompts | One section per alert, with a per-instance subsection inside it. Alert-level `solution` / `reference` / `cweid` go in the section header once; do not repeat them under each instance |
| 8 | Summarize | Counts per severity, link to `report.html`, list the prompts ready to feed an LLM |

## Full scan caveats (opt-in only — second arg `full`)

Active scan: sends attack payloads, runs 30-60+ min, can leave test data in DBs. Re-confirm authorization before proceeding even if the baseline already ran on the same target.

## Generate Fix Prompt template

For each filtered alert, emit one section. Repeat the per-instance block for every entry in `instances`. The alert-level `solution` / `reference` / `cweid` annotations stay in the section header — do not duplicate them under each instance.

```markdown
## [<riskdesc>] <alert.name>

- **CWE:** <alert.cweid> · **WASC:** <alert.wascid>
- **Remediation guidance (ZAP):** <alert.solution>
- **Reference:** <alert.reference>

### Instance: <instance.uri>

- **Method / Param:** <instance.method> · `<instance.param>`
- **Attack payload:** `<instance.attack>`
- **Evidence:** `<instance.evidence>`

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
| `docker: command not found` | No Docker runtime installed / `docker` CLI not in PATH | Tell the user; let them choose a runtime (Docker Desktop, OrbStack, colima, ...) |
| `Cannot connect to the Docker daemon` | Daemon not running | Tell the user to start whichever runtime they use; verify with `docker info` |
| Container can reach the internet but not the target | `localhost` resolves inside the container, not the host | Use `host.docker.internal` for host-bound dev servers |
| `report.json` missing after scan | Volume mount path mismatch (typically `$TS` lost across Bash calls when not using `scan.sh`) | Use `${CLAUDE_SKILL_DIR}/scripts/scan.sh` instead of inline `docker run` |
| Filter returns zero alerts even though report has High/Medium | `riskcode` compared as string, not int | Use `${CLAUDE_SKILL_DIR}/scripts/filter-alerts.py` (it casts), do not roll your own |
| All alerts are Informational | Target is auth-gated and ZAP only saw the login page | Out of scope for this skill; pre-authenticated scans need a ZAP context file |
| Scan hangs past expected duration | Target rate-limits ZAP, or full scan is just slow | Baseline cap ~10 min, full ~60 min — kill the container and rerun with a smaller target scope |
