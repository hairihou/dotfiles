# CLAUDE.md

## Code Style

- No comments for self-evident operations
- No unnecessary blank lines
- Comment only: complex logic, business rules, non-obvious behavior

---

## Language

- Respond in Japanese
- Exceptions: code, commands, URLs, proper nouns, official documentation quotes

---

## Python Environment

- Always use `uv run` for Python execution
- Use `uv add` for package installation
- Use `uvx` for one-off tool execution
- Never use: python3, pip3, pip install

---

## Skills

- If you are Claude, always ignore the skill `commands-frontmatter-adapter` (do not load or use it).
