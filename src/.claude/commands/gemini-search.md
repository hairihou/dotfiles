---
allowed-tools: Bash(gemini:*)
# argument-hint: [message]
description: Use Gemini CLI for web search
# model: claude-3-5-haiku-20241022
# disable-model-invocation: true
---

# Gemini Web Search

`gemini` is Gemini CLI.

**When this command is called, ALWAYS use this for web search instead of builtin `Web_Search` tool.**

When web search is needed, you MUST use `gemini --prompt` via Task Tool.

Run web search via Task Tool with `gemini --prompt "WebSearch: <query>"`.

Run:

```sh
gemini --prompt "WebSearch: <query>"
```
