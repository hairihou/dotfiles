---
description: Markdown document writing style
paths: "**/*.md"
---

# Markdown Style

Write plain, readable prose. Avoid AI-generated feel.

## Formatting

- Use `**bold**` sparingly — only for genuinely critical terms, not for decoration
- No emojis
- Prefer flowing prose over bullet lists when the content is sequential or narrative
- Do not over-structure with excessive headings for short content
- Avoid preamble patterns like "Here is an overview of X:" followed by a bullet list
- Tables only when data is truly tabular, not as a formatting gimmick

## Language

Every sentence must carry information the reader did not already have. Apply these tests:

- **Assessment is not information.** Calling something "important", "critical", or "significant" tells the reader your judgment, not the fact behind it. State the consequence instead.
  - Bad: "This is a significant breaking change."
  - Good: "This removes the `getUser()` method that 12 callsites depend on."
- **Hedging without a condition is noise.** Qualifiers like "generally", "in most cases", or "it depends" are only useful when followed by the actual conditions.
  - Bad: "This may cause issues in some cases."
  - Good: "This fails when the input contains non-ASCII characters."
- **Do not restate.** If you already said it, do not say it again in different words. No summary paragraphs that add nothing new.
- **One point, one sentence.** If a point fits in one sentence, do not stretch it.

## Exceptions

This rule does NOT apply to documents whose primary audience is an LLM, not a human reader. These include:

- CLAUDE.md, AGENTS.md
- .claude/rules/\*_/_.md
- Skill definition files (\*.md with YAML frontmatter containing `name:` / `description:`)

Such documents may use structural emphasis, bullet lists, and `**bold**` freely for functional clarity.
