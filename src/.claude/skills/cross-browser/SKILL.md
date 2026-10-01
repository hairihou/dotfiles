---
name: cross-browser
description: Check how a page renders or behaves outside Chromium (WebKit as the Safari and iPhone stand-in, Firefox, or real iOS Safari on a simulator) and compare browsers side by side. Use when layout, styling, or interaction may differ between browsers, whether the user reports something broken or different only in Safari, Firefox, or on an iPhone, asks whether a page works across browsers, or a change relies on CSS or JS with uneven browser support. Takes precedence over agent-browser here, which drives Chromium only. Not for checks that only need Chrome.
---

# Cross-Browser

Non-Chromium engines go through the playwright-cli skill: `--browser=webkit | firefox` on `open` picks the engine, `--device` or `--mobile` makes it phone-sized, and named sessions (`-s=`) run engines side by side.

- Engine binaries ship separately and WebKit is usually missing. When launch fails, run `playwright-cli install-browser webkit` (or `firefox`), not `playwright install`, which fetches a revision the bundled playwright-core does not expect
- The a11y snapshot comes out identical across engines, form controls included, so it cannot show engine differences; compare `screenshot` output or `eval "getComputedStyle(el)"`
- `--device` sets viewport and touch, never the engine: phone-sized WebKit needs `--browser=webkit --device "iPhone 15"`. Device names are case-sensitive and an unknown one is silently ignored (`"iphone 15"`, the spelling `--help` shows, included), so confirm with `eval "innerWidth + ' ' + ('ontouchstart' in window)"` after opening
- WebKit is not Safari: platform chrome (form controls, scrollbars, font rendering) still differs, so report findings as WebKit-level, not Safari-confirmed
- Real Safari is reachable only as iOS Safari on a Simulator, via agent-browser's `-p ios` provider (needs Xcode and Appium; check `xcrun simctl list` and `command -v appium` before promising it). Desktop Safari is unreachable: playwright-cli `--browser` accepts chrome, firefox, webkit, msedge only, and neither CLI drives `/usr/bin/safaridriver`
