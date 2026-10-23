---
name: source-trace
description: Trace each claim back to its primary source (spec, official doc, source code, paper, or the originator's own record) and answer with verbatim quotes and the path followed to reach them. Use when the user asks for the primary source, original, citation, or evidence behind something ("一次情報", "出典", "原典", "元ネタ", "ソースは？", "裏取りして"), or when a claim found in a blog, summary, or AI answer needs to be checked against where it came from. Not for opinions, or for facts the user only wants answered without provenance.
argument-hint: '<question or claim to trace>'
allowed-tools: Bash, Grep, Read, WebFetch, WebSearch
---

# Source Trace

Answer only from primary sources, quoted verbatim, with the path from the first lead to the origin. A secondary source is a lead to follow, never evidence.

Target: $ARGUMENTS. If empty, the claim under discussion.

Script: `${CLAUDE_SKILL_DIR}/scripts/source.py` (executable; `find`, `refs`, `cites`, `text`; run without arguments for usage).

## Flow

1. **List the claims** the answer needs, 1 to 6. For a verification request, the claim itself. Keep at least one in the request's own wording and conditions (version, platform, population); a claim that drops them gets backed by a source that answers a different question.
2. **Collect leads** with WebSearch, even when the primary's identifier is already known: what the user needs checked is what circulates, and without a lead read there is nothing real to compare the primary against. Every hit is a lead, whatever its authority. A discrepancy cites a lead page fetched with `text` and grep-confirmed to state the differing version (URL plus line). A search-result summary is a model's rewrite, not what the page says: a lead seen only there, or a generalization like "many sites", is not a discrepancy.
3. **Trace each lead back** until the source that originated the claim. Primary is per claim: a paper is primary for its own experiment and secondary for what it cites from others.

   | Claim about                  | Primary                                                                                                                  | How to reach it                                                                                                                                                                                                                                 |
   | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   | Standard / protocol          | RFC, WHATWG, W3C, ECMA, IETF drafts                                                                                      | spec section anchor; an RFC's current status (`status`, `obsoleted_by`, `updated_by`) is in `text https://www.rfc-editor.org/rfc/rfcNNNN.json` (the `/info/` page returns only the body); errata at `https://www.rfc-editor.org/errata/rfcNNNN` |
   | Software behavior            | official doc for the version in question; source code at a tagged commit; the PR, issue, or changelog that introduced it | `external-repo` skill for code; release notes for when it changed                                                                                                                                                                               |
   | Research finding             | the paper itself                                                                                                         | `find <doi\|title>`, then the OA PDF, arXiv, or author page. `refs` when the paper attributes the claim to an earlier work (follow it); `cites` to find later corrections, replications, rebuttals                                              |
   | Statistic / survey           | the publisher's report or dataset                                                                                        | follow the number, not the news article quoting it                                                                                                                                                                                              |
   | Statement by a person or org | their own post, talk recording, press release                                                                            | search the distinctive phrase; dead links via `https://web.archive.org/`                                                                                                                                                                        |

   A lead without a citation: search a distinctive phrase or number from it. Record the version or date the primary applies to; docs for the latest release can contradict the user's version.

4. **Verify verbatim.** `source.py text <url> > <scratchpad>/<name>.txt`, then `grep -n` the sentence. WebFetch returns a model's rewrite of the page, so a quote copied from it can be wording the source never used: use WebFetch to locate, never to quote. When `text` fails (JavaScript-only page, login, scanned PDF), mark the claim unverified rather than quoting from memory or a rewrite.
5. **Stop** when every claim has a primary quote checked in step 4 (supporting or contrary), or is marked unreached with the reason.

## Answer

Every claim gets every field below, even when a field repeats the previous claim's; a reader checking one claim should not have to look at another.

- **Claim** and status. The claim is the proposition as it circulates or as the user worded it, and the status says what the primary does to that proposition: `verified` (states it), `contradicted` (states otherwise; the quote is the contrary text), `secondary only` (no primary read, but a lead fetched with `text` states it; name that lead), `not found` (nothing fetched states it; a search-result summary does not count). One status per claim: a claim whose parts would get different statuses is split into separate claims. A correction is never tagged `verified` under the wording it corrects. The status is judged against the part of the primary actually read, named in the note (`full text`, `abstract`, `metadata`): metadata settles only bibliographic claims (title, authors, year, venue), an abstract settles only what it states, and anything beyond that part stays `secondary only`. Optionally follow with a short note
- **Quote**: verbatim in the original language; a translation, if added, labeled as one
- **Source**: type (`spec` / `official` / `code` / `paper` / `first-hand`), title, author or org, date or version, and the URL a reader would open, with the narrowest anchor (`#section-N`, page, line, commit). The raw-text URL fetched for checking is not that URL. A page with no anchor for the quoted part (a registry, an index, an unsectioned page) gets the line number in the fetched text instead, so every Source points below the document level
- **Path**: lead → … → primary, one line
- **Discrepancy**: where the leads differ from the primary (misquote, older version, rounded number, narrowed scope, the "source" not saying it at all). Report even small ones; this is often the finding the user needed

Then list unreached primaries (paywall, login, removed) with URL and why each matters. The user opens those in their own browser; never log in or create accounts.

Write conclusions only where a quote supports them. Where claims conflict across primaries, show both quotes and do not pick a winner.
