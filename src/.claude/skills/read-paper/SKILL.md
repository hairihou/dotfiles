---
name: read-paper
description: Fetch and read an academic paper from a URL (arXiv, ar5iv, ACL Anthology, OpenReview, bioRxiv/medRxiv, or a direct PDF) and summarize it. Use when the user pastes a paper URL or DOI and wants its contents read, explained, or summarized — not for general web pages or docs (use WebFetch).
argument-hint: '<paper-url>'
allowed-tools: Bash, WebFetch, Read
---

# Read Paper

Resolve a paper URL to its most readable form, fetch the full text, and summarize.

## Flow

1. **Resolve candidates** — `python ${CLAUDE_SKILL_DIR}/scripts/resolve.py "<url>"`.
   Output is one `method<TAB>url<TAB>note` per line, best first (HTML before PDF).
2. **Fetch the body** — try candidates top-down, stop at the first that yields real content:
   - `html` → `WebFetch`. Treat a paywall, stub, or "no HTML available" page as a miss and fall through to the next candidate.
   - `pdf` → download to the scratchpad, then `Read` it:
     `curl -fsSL -o "$SCRATCH/paper.pdf" "<url>"` (the session scratchpad dir).
     `Read` supports `pages`; for a long paper read `1-20` first, then ranges on demand.
3. **Read in priority order**, not front-to-back: title + abstract → contributions/conclusion → figure & table captions → method/experiments deep-dive only where it matters.
4. **Summarize** in the language of the conversation, concise, identifiers and technical terms kept verbatim:
   - one-line gist
   - problem it tackles
   - approach / key idea
   - results (with the concrete numbers that matter)
   - limitations / open questions
   - relevance to what the user is working on (skip if unknown)

## Notes

- Figures/images in a PDF are not readable as text; rely on captions and surrounding prose, and say so if a figure is load-bearing.
- If every candidate fails (paywall, removed, bad id), report which URLs were tried rather than guessing the contents.
