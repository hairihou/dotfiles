#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.15"
# ///
import argparse
import json
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "src/.config"
FILES = {
    "ghostty/themes/nocturne": "dark",
    "ghostty/themes/nocturne-light": "light",
    "tmux/themes/nocturne.conf": "dark",
    "tmux/themes/nocturne-light.conf": "light",
    "nvim/lua/config/colorscheme.lua": None,
    "zed/themes/nocturne.json": None,
}
HEX = re.compile(r"#[0-9a-fA-F]{6}")
KEEP = {"#000000"}

NEUTRAL_HUE = {"dark": 262.0, "light": 85.0}
# OKLCH lightness and chroma per gray step
NEUTRAL = {
    "dark": {
        "50": (0.965, 0.004),
        "100": (0.930, 0.006),
        "200": (0.890, 0.008),
        "300": (0.840, 0.012),
        "400": (0.715, 0.018),
        "500": (0.560, 0.022),
        "600": (0.455, 0.026),
        "700": (0.375, 0.030),
        "800": (0.285, 0.033),
        "900": (0.215, 0.034),
        "950": (0.150, 0.030),
    },
    "light": {
        "50": (0.972, 0.016),
        "100": (0.942, 0.018),
        "200": (0.905, 0.019),
        "300": (0.850, 0.018),
        "400": (0.705, 0.016),
        "500": (0.515, 0.015),
        "600": (0.450, 0.015),
        "700": (0.385, 0.016),
        "800": (0.305, 0.016),
        "900": (0.240, 0.015),
        "950": (0.175, 0.012),
    },
}
HUES = {
    "rose": 15,
    "pink": 352,
    "fuchsia": 325,
    "purple": 302,
    "indigo": 278,
    "blue": 258,
    "sky": 232,
    "cyan": 210,
    "teal": 185,
    "emerald": 160,
    "gold": 85,
}
# tone: (max chroma, min contrast against the mode background), shared by every hue
TONES = {
    "dark": {
        "300": (0.095, 11.0),
        "400": (0.125, 8.0),
        "500": (0.15, 5.0),
        "600": (0.15, 3.4),
    },
    "light": {
        "600": (0.16, 6.2),
        "700": (0.17, 6.8),
        "800": (0.15, 8.8),
        "900": (0.12, 11.0),
    },
}
# light "300" slots are background tints (search, highlights): fixed (L, C, hue)
LIGHT_TINTS = {"gold300": (0.90, 0.10, 88.0), "purple300": (0.87, 0.06, 302.0)}
ANSI_HUES = ("rose", "emerald", "gold", "blue", "purple", "cyan")
ANSI_TONES = {"dark": ("400", "300"), "light": ("700", "800")}
ANSI_GRAYS = {
    "dark": ("800", "300", "400", "white"),
    "light": ("800", "600", "500", "700"),
}

SRGB_LINEAR_CUTOFF = 0.0031308
SRGB_ENCODED_CUTOFF = 0.04045
GAMUT_EPS = 1e-4
BISECT_STEPS = 40


def oklch_to_linear(
    lightness: float, chroma: float, hue: float
) -> tuple[float, float, float]:
    a = chroma * math.cos(math.radians(hue))
    b = chroma * math.sin(math.radians(hue))
    l_ = (lightness + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m_ = (lightness - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s_ = (lightness - 0.0894841775 * a - 1.2914855480 * b) ** 3
    return (
        4.0767416621 * l_ - 3.3077115913 * m_ + 0.2309699292 * s_,
        -1.2684380046 * l_ + 2.6097574011 * m_ - 0.3413193965 * s_,
        -0.0041960863 * l_ - 0.7034186147 * m_ + 1.7076147010 * s_,
    )


def in_gamut(rgb: tuple[float, float, float]) -> bool:
    return all(-GAMUT_EPS <= x <= 1 + GAMUT_EPS for x in rgb)


def encode(x: float) -> int:
    x = min(1.0, max(0.0, x))
    v = 12.92 * x if x <= SRGB_LINEAR_CUTOFF else 1.055 * x ** (1 / 2.4) - 0.055
    return round(v * 255)


def to_hex(lightness: float, chroma: float, hue: float) -> str:
    if not in_gamut(oklch_to_linear(lightness, chroma, hue)):
        lo, hi = 0.0, chroma
        for _ in range(BISECT_STEPS):
            mid = (lo + hi) / 2
            lo, hi = (
                (mid, hi)
                if in_gamut(oklch_to_linear(lightness, mid, hue))
                else (lo, mid)
            )
        chroma = lo
    return "#" + "".join(
        f"{encode(x):02x}" for x in oklch_to_linear(lightness, chroma, hue)
    )


def luminance(hx: str) -> float:
    c = [int(hx[i : i + 2], 16) / 255 for i in (1, 3, 5)]
    c = [
        x / 12.92 if x <= SRGB_ENCODED_CUTOFF else ((x + 0.055) / 1.055) ** 2.4
        for x in c
    ]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def contrast(a: str, b: str) -> float:
    x, y = luminance(a), luminance(b)
    return (max(x, y) + 0.05) / (min(x, y) + 0.05)


def max_chroma(lightness: float, hue: float) -> float:
    lo, hi = 0.0, 0.4
    for _ in range(BISECT_STEPS):
        mid = (lo + hi) / 2
        lo, hi = (
            (mid, hi) if in_gamut(oklch_to_linear(lightness, mid, hue)) else (lo, mid)
        )
    return lo


def tone(cap: float, target: float, bg: str, *, dark: bool) -> dict[str, str]:
    """One OKLCH lightness and chroma for all hues, the closest to bg meeting target."""

    def colors(lightness: float) -> dict[str, str]:
        chroma = min(cap, *(max_chroma(lightness, h) for h in HUES.values()))
        return {fam: to_hex(lightness, chroma, h) for fam, h in HUES.items()}

    lo, hi = (0.4, 1.0) if dark else (0.15, 0.75)
    for _ in range(BISECT_STEPS):
        mid = (lo + hi) / 2
        ok = min(contrast(hx, bg) for hx in colors(mid).values()) >= target
        if ok == dark:
            hi = mid
        else:
            lo = mid
    return colors(hi if dark else lo)


def build(mode: str) -> dict[str, str]:
    hue = NEUTRAL_HUE[mode]
    steps = NEUTRAL[mode]
    slots = {f"gray{s}": to_hex(lt, c, hue) for s, (lt, c) in steps.items()}
    slots["white"] = to_hex(0.985, 0.003, hue)
    dark = mode == "dark"
    bg = slots["gray900" if dark else "gray50"]
    for step, (cap, target) in TONES[mode].items():
        for fam, hx in tone(cap, target, bg, dark=dark).items():
            slots[f"{fam}{step}"] = hx
    if not dark:
        slots.update({k: to_hex(*v) for k, v in LIGHT_TINTS.items()})
    return slots


def ansi(mode: str, slots: dict[str, str]) -> list[str]:
    black, white, bright_black, bright_white = (
        slots[g if g == "white" else f"gray{g}"] for g in ANSI_GRAYS[mode]
    )
    normal, bright = ANSI_TONES[mode]
    return [
        black,
        *(slots[f"{h}{normal}"] for h in ANSI_HUES),
        white,
        bright_black,
        *(slots[f"{h}{bright}"] for h in ANSI_HUES),
        bright_white,
    ]


def palettes() -> dict[str, dict[str, str]]:
    out = {}
    for mode in ("dark", "light"):
        slots = build(mode)
        seen: dict[str, str] = {}
        for name, hx in slots.items():
            if hx in seen:
                sys.exit(
                    f"{mode}: {name} and {seen[hx]} share {hx}; remap is ambiguous"
                )
            seen[hx] = name
        out[mode] = slots
    return out


def sections(rel: str, text: str) -> list[tuple[str, str]]:
    """Split a file into (mode, chunk) parts."""
    mode = FILES[rel]
    if mode:
        return [(mode, text)]
    if rel.endswith(".json"):
        parts = re.split(
            r'(?=^\s*"name": "[^"]+",\n\s*"appearance")', text, flags=re.MULTILINE
        )
        return [
            ("light" if '"appearance": "light"' in p[:200] else "dark", p)
            for p in parts
        ]
    head, light = text.split("  light = {", 1)
    return [("dark", head), ("light", "  light = {" + light)]


def unknown(pal: dict[str, dict[str, str]]) -> list[str]:
    problems = []
    for rel in FILES:
        for mode, chunk in sections(rel, (ROOT / rel).read_text()):
            known = set(pal[mode].values()) | KEEP
            problems += [
                f"{rel}: {mode} {h}"
                for h in sorted({h.lower() for h in HEX.findall(chunk)} - known)
            ]
    return problems


def apply(old: dict[str, dict[str, str]], new: dict[str, dict[str, str]]) -> None:
    for rel in FILES:
        path = ROOT / rel
        out = []
        for mode, chunk in sections(rel, path.read_text()):
            rev = {hx: name for name, hx in old[mode].items()}

            def sub(
                m: re.Match[str],
                rel: str = rel,
                mode: str = mode,
                rev: dict[str, str] = rev,
            ) -> str:
                hx = m[0].lower()
                if hx in KEEP:
                    return hx
                if hx not in rev:
                    sys.exit(f"{rel}: {hx} is not in the baseline {mode} palette")
                return new[mode][rev[hx]]

            out.append(HEX.sub(sub, chunk))
        path.write_text("".join(out))


def report(pal: dict[str, dict[str, str]]) -> None:
    for mode, slots in pal.items():
        bg = slots["gray900" if mode == "dark" else "gray50"]
        print(f"== {mode} (bg {bg})")
        for i, hx in enumerate(ansi(mode, slots)):
            print(f"  ansi {i:>2} {hx} {contrast(hx, bg):5.2f}")
        for name, hx in slots.items():
            print(f"  {name:<12} {hx} {contrast(hx, bg):5.2f}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Nocturne theme palette (OKLCH). "
        "Without options, print each slot's contrast against the background.",
        epilog="To change the palette: save --json, edit the parameters, "
        "then run --apply with the saved file.",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--check",
        action="store_true",
        help="fail if a theme file uses a color outside the palette",
    )
    group.add_argument("--json", action="store_true", help="print the palette as JSON")
    group.add_argument(
        "--apply",
        metavar="BASELINE",
        type=Path,
        help="remap theme files from a saved --json palette",
    )
    args = parser.parse_args()
    pal = palettes()
    if args.json:
        print(json.dumps(pal, indent=2))
    elif args.check:
        if problems := unknown(pal):
            sys.exit("\n".join(["colors outside the palette:", *problems]))
    elif args.apply:
        apply(json.loads(args.apply.read_text()), pal)
    else:
        report(pal)


main()
