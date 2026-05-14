---
name: add-external-skills
description: Install a SKILL.md authored in an external Git repository by cloning via ghq and symlinking the skill directory into Claude's user skills dir. Use when adding a third-party skill the user does not own. Not for authoring local skills (those live in this dotfiles repo) or for one-off code reads (use external-repo for that).
allowed-tools: Bash, Read
---

# Add External Skills

A third-party skill bundle is a Git repo containing one or more `SKILL.md` files. To make it usable from Claude Code, the SKILL.md needs to be reachable from `$CLAUDE_CONFIG_DIR/skills/<skill-name>/`. The convention here is: clone the upstream repo to ghq, then symlink the skill directory.

## Flow

1. Identify the upstream repo and the path of each SKILL.md to install (a bundle may host many).
2. Resolve / fetch the repo via [[external-repo]] — leaves it at `$(ghq root)/<host>/<owner>/<name>` and keeps it on the default branch.
3. For each skill, link the directory containing its `SKILL.md` into the user skills dir:
   ```sh
   ln -s "$(ghq root)/<host>/<owner>/<name>/<path-to-skill-dir>" "$CLAUDE_CONFIG_DIR/skills/<skill-name>"
   ```
   `<skill-name>` defaults to the value of the upstream `name:` frontmatter — use that unless it collides with an existing entry.
4. Verify the symlink resolves (`ls -L "$CLAUDE_CONFIG_DIR/skills/<skill-name>/SKILL.md"`).

## Boundaries

- Local skills authored in this dotfiles repo: `src/.claude/skills/<name>/`, deployed by `linkup` — out of scope.
- Upstream updates: re-run [[external-repo]] (fast-forward the clone). Do not edit files under the symlink target — that would mutate the ghq clone.
- Removal: `rm "$CLAUDE_CONFIG_DIR/skills/<skill-name>"`. The ghq clone stays for other consumers; delete it manually if no longer wanted.
