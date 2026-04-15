---
description: Markdown document writing style
paths: "**/*.md"
---

# Markdown Style

Write plain, readable prose. Avoid AI-generated feel.

## Formatting

- Use `**bold**` only as a label at the start of a list item (`- **Key:** value`) or table cell
  - Do not use bold for emphasis inside prose — rewrite the sentence so the important part carries itself
  - Do not bold evaluative words ("important", "note", "warning", "point"); state the consequence in plain text instead
- Use `*italic*` only for the first mention of a term being defined, or for titles of works
- No emojis
- Prefer flowing prose over bullet lists when the content is sequential or narrative
- Do not over-structure with excessive headings for short content
- Avoid preamble patterns like "Here is an overview of X:" followed by a bullet list
- Tables only when data is truly tabular, not as a formatting gimmick
- Fenced code blocks for shell commands: use `sh`, not `bash`

Bad:

```md
**Install the CLI** first, then **run the init command**. The **config file** will be created automatically.
```

Good:

```md
Install the CLI, then run the init command. The config file is created automatically.

- **Speed:** fast startup
- **Safety:** no destructive ops
```

## Language

Every sentence must carry information the reader did not already have. Apply these tests:

- **Assessment is not information.** Calling something "important", "critical", or "significant" tells the reader your judgment, not the fact behind it. State the consequence instead.
  - Bad: "This is a significant breaking change."
  - Good: "This removes the `getUser()` method that 12 callsites depend on."
- **Claims need sourced or unsourced status.** When asserting validity from a domain (accessibility, security, performance, etc.), cite the specific standard or spec. If no authoritative source exists, state that the claim is based on general practice, not a formal standard.
- **Hedging without a condition is noise.** Qualifiers like "generally", "in most cases", or "it depends" are only useful when followed by the actual conditions.
  - Bad: "This may cause issues in some cases."
  - Good: "This fails when the input contains non-ASCII characters."
- **Do not restate.** If you already said it, do not say it again in different words. No summary paragraphs that add nothing new.
- **One point, one sentence.** If a point fits in one sentence, do not stretch it.
- **Use standard English terms.** When the English form is the established technical term, use it as-is instead of translating (e.g., Bundler, Container, Runtime).

## Exceptions

The Language and prose-style rules (bold, bullet lists, headings) do not apply to documents whose primary audience is an LLM:

- CLAUDE.md
- Rule files
- Subagent definitions
- Skill definition files (`.md` with YAML frontmatter containing `name:` / `description:`)

The Formatting section (code block language tags, etc.) applies to all markdown files without exception.
