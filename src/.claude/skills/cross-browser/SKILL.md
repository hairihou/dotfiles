---
name: cross-browser
description: Use when verifying page rendering or behavior in Safari (WebKit), Firefox, or across multiple browser engines. agent-browser is Chromium-only via CDP; these checks require playwright-cli. Not for Chromium-only verification — use agent-browser there.
---

# Cross-Browser

agent-browser drives Chrome/Chromium over CDP and cannot launch other engines. For WebKit (closest proxy for Safari) or Firefox, use playwright-cli:

```sh
playwright-cli open --browser=webkit https://example.com
playwright-cli snapshot
playwright-cli screenshot
playwright-cli close
```

- `--browser=webkit | firefox | chrome | msedge`
- Browser binaries download on demand; if launch fails, run `playwright install webkit` (or `firefox`)
- Compare engines side by side with named sessions: `playwright-cli -s=wk open --browser=webkit <url>` / `playwright-cli -s=ff open --browser=firefox <url>`, then `-s=<name>` on every subsequent command
- WebKit is the Safari engine but not Safari itself — macOS-specific chrome (form controls, scrollbars, font rendering) can still differ; flag findings as WebKit-level, not Safari-confirmed
