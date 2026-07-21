---
name: review-prep
description: Prepare a human reviewer to review someone else's pull request — machine-check verbalizable perspectives with subagents, then hand over a self-contained HTML briefing separating what is safe to skim from what needs the human's design judgment. Strictly read-only against GitHub. Use when the user will themselves review someone else's PR — assigned as reviewer, or asking where to start reading before passing judgment. Not for fully automated review that ends with AI findings, and not for responding to feedback on the user's own PR.
argument-hint: "PR number or URL"
---

# Review Prep

This skill does not replace review; it splits the work the way it should be split. Perspectives that have been verbalized get applied by AI with mechanical consistency; the human spends their limited attention on judgment — design choices, trade-offs, and product intent no checklist covers.

## Principles

- Strictly read-only against GitHub: no comments, reviews, or labels. Comment drafts live only in the local briefing.
- Reviewer subagents get a clean brief: the diff, the acceptance criteria (from the linked issue, if any), and one perspective. Never pass existing review comments into them — that creates confirmation bias. Dedup against existing comments afterwards, in the main agent.
- If the project maintains a verbalized review-perspective file (accumulated checklists, missed-finding notes), pass it to the reviewers as the canonical perspective set instead of inventing one; never fork a second copy.

## Workflow

### 1. Fetch PR Context

```sh
gh pr view <PR> --json number,title,body,url,author,baseRefName,files,additions,deletions,statusCheckRollup
gh pr view <PR> --json comments,reviews          # existing findings, for dedup only
gh api repos/<owner>/<repo>/pulls/<PR>/comments  # inline comments
gh pr diff <PR>
```

Read the linked issue for acceptance criteria and background. If CI is failing, flag it at the top of the briefing.

### 2. Background Research

Parallel read-only subagents, conclusions only: one for existing patterns and conventions in the touched area, one for the specs/docs governing the touched feature. Skip for small PRs (roughly under ~100 changed lines).

### 3. Machine-Check Layer

Parallel review-only subagents, one per perspective, each with a clean brief — separate lenses catch what a single merged reviewer misses:

- spec: does the change satisfy the acceptance criteria and follow existing patterns.
- risk: bugs, type mismatches, runtime errors, security, accessibility, performance.
- completeness (only for user-facing feature changes): facets the issue never spelled out but the product obviously needs — empty/error/loading states, i18n.

Output contract for every reviewer: tag each finding `confidence: high` (provable from the diff and the perspective) or `low` (depends on runtime conditions, unclear reproduction, or spec interpretation).

### 4. Judgment-Area Extraction

One more read-only subagent, orthogonal to step 3 — not another bug hunt:

1. Design map: responsibilities, dependency direction, and data flow of the changed modules, in 5 lines or fewer.
2. Judgment areas: the places where the author chose something — a new abstraction, a deliberate deviation from an existing pattern, an error-handling behavior, a performance/readability trade. One line each on what was chosen and what it was traded against. Do not evaluate whether the choice is good — that is the human's job.
3. Per-spot lens: for each major changed file, one line on how to read it (e.g. "trace the authorization boundary", "walk the error paths only", "compare against the existing X pattern"). One lens per spot — a spot needing three lenses has outgrown lens-guided reading and belongs in the judgment section.

Then the main agent builds a spec cross-check: each acceptance criterion mapped to its implementing `file:line`. A criterion with no matching location is itself a finding; ambiguous spec interpretations get flagged with what to check them against (issue comments, design file, spec doc).

### 5. Output the Briefing

Sections, in this fixed order (stable placement is what makes the tool fast to use):

1. TL;DR — purpose / size / CI status / risk feel with a one-line reason / estimated review time.
2. Reading order — decided by dependency direction, not line count (new types → consumers → tests); quarantine mechanical changes (rename fallout, generated files) as skimmable. Keeping the human from close-reading these is the single biggest time saver.
3. Review-lens guide — design map, per-spot lens, spec cross-check from step 4.
4. Machine-checked, safe to skim — perspectives that came back clean at high confidence. Always list which perspectives were applied: "no findings" is not "verified", and a property no perspective covered must not appear here.
5. Needs human judgment — the step-4 judgment areas. Keep this section even when empty ("none — mechanical change only" is itself a time saver).
6. Verify — low-confidence findings for the human to confirm or dismiss.
7. Findings (high confidence) — by severity; omit the section if none.
8. Comment drafts — paste-ready, explicitly marked as not posted. Default to intent-seeking phrasing ("what was the intent behind …"); assert only high-confidence findings. Whether and how to post is the human's call.

Render as one self-contained HTML page (inline CSS, mobile-readable), save outside the repo as `/tmp/$(date +%F)-review-prep-pr<N>.html`, open it, and print a terminal summary: TL;DR, any high-confidence findings, and the file path. HTML-escape every value originating from the PR or repo (title, body, branch/author names, paths, finding text) — a malicious PR could otherwise inject script into the local file. If no browser is available or the user asks, print the full briefing to the terminal in the same section order.

## After the Review

When the user signals they finished, ask once: did you catch anything the machine-check layer missed? If yes, offer to verbalize it into the project's review-perspective file so it lands in the machine-checked section next time. Offer once; don't push.
