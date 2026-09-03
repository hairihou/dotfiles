---
name: cross-browser
description: Use when verifying page rendering or behavior in a non-Chromium engine — Safari/WebKit (desktop or iPhone) or Firefox — or comparing engines side by side. Not for Chromium; agent-browser covers that.
---

# Cross-Browser

agent-browser drives Chromium. Every other engine goes to the playwright-cli skill: `--browser=webkit | firefox` on `open` picks the engine, `--device` or `--mobile` makes it phone-sized, and named sessions (`-s=`) compare engines side by side.

- Engine binaries are separate downloads and WebKit is usually absent; run `playwright-cli install-browser webkit` when launch fails — it pins the browser revision the bundled playwright-core expects, whereas a standalone `playwright install` fetches its own version's revision instead
- Engine differences do not surface in the a11y snapshot — Playwright computes it from the DOM with its own injected script, not the native a11y tree, so chromium, firefox and webkit come out byte-identical on the same page, form controls included; compare `screenshot` output or computed styles (`eval "getComputedStyle(el)"`, which does differ per engine) instead
- `--device` sets viewport and touch only, never the engine, so a phone-sized WebKit needs `--browser=webkit --device "iPhone 15"`. Device names are case-sensitive and an unknown one is dropped in silence — `"iphone 15"` (the spelling in `--help`) no-ops exactly like a bogus name — so confirm with `eval "innerWidth + ' ' + ('ontouchstart' in window)"` after opening
- WebKit is the Safari engine but not Safari itself, and `--device` only emulates a phone — platform chrome (form controls, scrollbars, font rendering) still differs; flag findings as WebKit-level, not Safari-confirmed
- Real Safari means agent-browser's `-p ios` provider, which drives Safari on an iOS Simulator and needs Xcode plus Appium — check `xcrun simctl list` and `command -v appium` before promising it. Desktop Safari has no path: playwright-cli `--browser` takes chrome, firefox, webkit, msedge only, and neither CLI speaks to `/usr/bin/safaridriver`
