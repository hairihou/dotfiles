---
description: Markdown document writing style
paths: "**/*.md"
---

# Markdown Style

Write plain, readable prose. Avoid AI-generated feel.

## Rules

- Use `**bold**` sparingly — only for genuinely critical terms, not for decoration
- No emojis
- Prefer flowing prose over bullet lists when the content is sequential or narrative
- Do not over-structure with excessive headings for short content
- Avoid preamble patterns like "Here is an overview of X:" followed by a bullet list
- Tables only when data is truly tabular, not as a formatting gimmick

## Exceptions

This rule does NOT apply to documents whose primary audience is an LLM, not a human reader. These include:

- CLAUDE.md, AGENTS.md
- .claude/rules/\*_/_.md
- Skill definition files (\*.md with YAML frontmatter containing `name:` / `description:`)

Such documents may use structural emphasis, bullet lists, and `**bold**` freely for functional clarity.
