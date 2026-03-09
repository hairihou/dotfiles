---
name: rules-optimizer
description: Create and optimize .claude/rules/*.md files for repository-specific coding conventions. Use when asked to create, optimize, or review rules, when a pattern keeps recurring that Claude gets wrong, or when codifying a convention. Not for editing CLAUDE.md — edit that file directly.
argument-hint: [rule-file-or-pattern]
allowed-tools: Edit, Glob, Read, Write
---

# Rules Optimizer

## Context

- Existing rules: !`ls .claude/rules/**/*.md .claude/rules/*.md 2>/dev/null`

Target: $ARGUMENTS (if not specified, optimize all existing rules)

Create and optimize `.claude/rules/*.md` files. Best practices: `${CLAUDE_SKILL_DIR}/references/best-practices.md`

## Workflow

1. Read existing rule file and best practices reference
2. Identify: redundancy, missing examples, excessive length
3. Compress to essentials with 1 example per rule
4. Ensure paths pattern is appropriate
5. Output optimized version
