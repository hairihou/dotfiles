---
name: add-skill
description: Install third-party SKILL.md files discovered in an external Git repo into the user skills dir.
argument-hint: <github-repo-url>
disable-model-invocation: true
allowed-tools: Bash
---

# Add Skill

Given `$ARGUMENTS` (a GitHub URL — either a bare repo or a subdirectory via
`…/tree/<branch>/<path>`), fetch the repo and install each `SKILL.md` found
within into `$CLAUDE_CONFIG_DIR/skills/<name>/` via symlink.

## Why this approach

The built-in installers don't cover this case:

- `/plugin`: only registered marketplaces; arbitrary GitHub repos are out of scope.
- `apm`: claims `$CLAUDE_CONFIG_DIR/skills/` exclusively and its cleanup pass
  deletes entries it didn't install — incompatible with dotfiles symlinks.
- `npx skills`: fails at startup under this repo's `.npmrc`.

ghq + symlink keeps upstream a `git pull` away and leaves dotfiles in charge
of the skills directory.

## Flow

1. Parse `$ARGUMENTS` into `<host>/<owner>/<repo>` and an optional in-repo subpath
   (only present when the URL is a `…/tree/<branch>/<path>` form).
2. Resolve the local clone path:
   ```sh
   repo_path=$(ghq list --full-path --exact <host>/<owner>/<repo>)
   [ -z "$repo_path" ] && ghq get <owner>/<repo> && repo_path=$(ghq list --full-path --exact <host>/<owner>/<repo>)
   ```
   For non-github.com hosts, pass the full URL to `ghq get`. If `ghq get` fails, stop — do not fall back.
3. Discover skills under the relevant scope:
   ```sh
   find "$(ghq root)/<host>/<owner>/<repo>/<subpath>" -name SKILL.md
   ```
   - 0 hits: report the empty result and stop.
   - 1 hit: proceed with that one.
   - 2+ hits: list them (with each skill's `name:` frontmatter) and ask which
     to install. Allow selecting multiple.
4. For each selected `SKILL.md`, symlink the directory that contains it:
   ```sh
   ln -s "<dir-containing-SKILL.md>" "$CLAUDE_CONFIG_DIR/skills/<skill-name>"
   ```
   `<skill-name>` defaults to the upstream `name:` frontmatter. On collision
   with an existing entry, prefix with the owner: `<owner>-<name>`.
5. Verify each symlink: `test -f "$CLAUDE_CONFIG_DIR/skills/<skill-name>/SKILL.md"`.

## Boundaries

- Locally authored skills: `src/.claude/skills/<name>/`, deployed by `linkup`. Out of scope.
- Updates: invoke the `external-repo` skill manually to re-sync the ghq clone. Do not edit files under
  the symlink target — that mutates the ghq clone.
- Removal: `rm "$CLAUDE_CONFIG_DIR/skills/<skill-name>"`. The ghq clone stays
  for other consumers; delete it manually if no longer needed.
