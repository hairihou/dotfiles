---
name: imagegen
description: >-
  Generate or edit image assets via Codex — icons, banners,
  illustrations, sprites, placeholder art. Use when the user explicitly asks to
  create or edit an image, since Claude Code cannot generate images itself.
  Consumes Codex usage.
argument-hint: '<prompt> [-o <output path>] [-i <source image>] [--size <WxH>]'
allowed-tools: Bash
---

# imagegen

Generate or edit an image via Codex's built-in image generation. Claude Code cannot generate images itself; this delegates the generation to `codex exec` and places the result at a target path.

Runtime: `${CLAUDE_SKILL_DIR}/scripts/imagegen.py` — it runs Codex, finds the generated PNG, and copies it to the output path. Do not reimplement this inline.

## How to run

1. Parse `$ARGUMENTS` into:
   - the **prompt** (free text describing the image)
   - `-o <path>` — output path (optional; default `./<slug>.png` in cwd)
   - `-i <path>` — source image to edit (optional, repeatable; for "edit/modify this image" requests)
   - `--size <WxH>` — exact output size (optional; e.g. `256x256`). Codex's image generation ignores sizes named in the prompt, so pass this when the size must be exact.
2. Call the runtime, passing the prompt as a single quoted argument:

   `python ${CLAUDE_SKILL_DIR}/scripts/imagegen.py "<prompt>" [-o <path>] [-i <path> ...] [--size <WxH>]`

3. On success the runtime prints the absolute output path. Report that path. Do **not** auto-open it with `open` — only do so if the user asks to view it.

## Failure handling

- Non-zero exit whose message mentions login/auth → tell the user to run `!codex login`, then retry.
- "No image was generated" → surface the runtime's message. Do not claim success.
