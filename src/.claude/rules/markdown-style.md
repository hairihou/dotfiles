---
paths: ['**/*.md']
---

# Markdown Style

## Formatting

- No bold, neither for emphasis nor as a label (`- **Key:** value`). Rewrite the sentence so the important part carries itself, or move key-value content into a table
- Use `*italic*` only for the first mention of a term being defined, or for titles of works
- No em dash (`—`). Split the sentence, or use a comma, colon, or parentheses
  - A rule about the character itself may name it
- No emojis
- Prefer flowing prose over bullet lists when the content is sequential or narrative
- Tables only when data is truly tabular, not as a formatting gimmick
- Fenced code blocks for shell commands: use `sh`, not `bash`

## Headings

- Use headings only in a document that has more than one section; a single-section document carries none, however long it runs
  - A standalone line introducing the block below it (`Rules:`, `Provide:`) is a heading in other syntax. Promote it to a real heading or drop it. A label whose value sits on the same line (`Topic: {{topic}}`) is a field, not a section
- Name a heading for what its section is, not for what the section contains
- H1 is the file or directory name in canonical case (`skeptic.md` → `# Skeptic`, `skills/pr/` → `# PR`); never open at H2
  - A file whose content is embedded inside another document opens below H1, since that document supplies it
- Title Case for English headings (`# Markdown Style`, `## Configuration Files`)
- Preserve canonical case for brand or product names. Do not force Title Case (`npm`, `ESLint`, `ZAP`, `iOS`, `macOS`, `Draw.io`)
- Omit category suffixes from an H1 (`Skill`, `Tool`, `Rules`, `Security Scan`). The filename, directory, and `name` frontmatter already convey the kind

## Language

Every sentence must carry information the reader did not already have. Apply these tests:

- State the consequence, not an assessment. Calling something "important", "critical", or "significant" tells the reader your judgment, not the fact behind it.
  - Bad: "This is a significant breaking change."
  - Good: "This removes the `getUser()` method that 12 call sites depend on."
- Mark each domain claim as sourced or unsourced. When asserting validity from a domain (accessibility, security, performance, etc.), cite the specific standard or spec. If no authoritative source exists, state that the claim is based on general practice, not a formal standard.
- Hedge only with the condition attached. Qualifiers like "generally", "in most cases", or "it depends" are noise unless followed by the actual conditions.
  - Bad: "This may cause issues in some cases."
  - Good: "This fails when the input contains non-ASCII characters."
- Do not restate what you already said, in different words or in a summary paragraph that adds nothing new.
- Skip preamble, such as "Here is an overview of X:" followed by a bullet list. Start with the content itself.
- When the English form is the established technical term, use it as-is instead of translating (e.g., Bundler, Container, Runtime).

## Exceptions

The Language section and the prose-style aspect of Formatting (bullets-vs-prose) do not apply to documents whose primary audience is an LLM:

- CLAUDE.md
- Rule files
- Subagent definitions
- Skill files (`skills/**/*.md`)

The Headings section and the rest of Formatting (bold, code block language tags, em dashes, emojis, italic, tables) apply to every markdown file; no document type is exempt.
