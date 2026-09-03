---
name: cross-browser
description: Use when verifying page rendering or behavior in a non-Chromium engine — Safari/WebKit (desktop or iPhone) or Firefox — or comparing engines side by side. Not for Chromium; agent-browser covers that.
---

# Cross-Browser

agent-browser drives Chromium. Every other engine goes to the playwright-cli skill: `--browser=webkit | firefox` on `open`, `--device "iphone 15"` (or `--mobile`) for a phone-sized WebKit, and named sessions (`-s=`) to compare engines side by side.

- Engine binaries are separate downloads and WebKit is usually absent; playwright-cli has no install subcommand and `playwright` is not on PATH, so run `npx playwright install webkit` when launch fails
- Engine differences do not surface in the a11y snapshot (chromium and firefox can be byte-identical on the same page); compare `screenshot` output or computed styles instead
- WebKit is the Safari engine but not Safari itself, and `--device` only emulates a phone — platform chrome (form controls, scrollbars, font rendering) still differs; flag findings as WebKit-level, not Safari-confirmed
- Neither CLI has a documented path to real Safari: agent-browser's `-p ios` provider ships no setup docs and needs an iOS device, and macOS `safaridriver` has no driver here
