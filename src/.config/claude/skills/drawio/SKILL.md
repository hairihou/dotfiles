---
name: drawio
description: Use when user asks to create a draw.io diagram (.drawio file), mentions draw.io / drawio / drawoi explicitly, or requests a flowchart, architecture diagram, ER diagram, sequence diagram, class diagram, or network diagram with PNG/SVG/PDF export intent. Do NOT use for Figma mockups, generic UI wireframes without diagram intent, Mermaid syntax (```mermaid blocks), PlantUML, or ASCII art diagrams.
---

<!-- Source: https://github.com/jgraph/drawio-mcp/blob/main/skill-cli/drawio/SKILL.md (macOS-only adaptation) -->

# Draw.io Diagram Skill

Generate draw.io diagrams as native `.drawio` files. Optionally export to PNG, SVG, or PDF with the diagram XML embedded (so the exported file remains editable in draw.io).

## How to create a diagram

1. **Generate draw.io XML** in mxGraphModel format for the requested diagram (follow the Critical rules below)
2. **Write the XML** to a `.drawio` file in the current working directory using the Write tool
3. **Post-process edge routing** (optional): If `npx @drawio/postprocess` is available, run it on the `.drawio` file to optimize edge routing (simplify waypoints, fix edge-vertex collisions, straighten approach angles). Skip silently if not available — do not install it or ask the user about it
4. **If the user requested an export format** (png, svg, pdf), export with the draw.io CLI (see below) using `--embed-diagram`. Then verify the export succeeded BEFORE deleting the source `.drawio`:
   - CLI exit code must be `0`
   - Output file must exist and be non-empty: `[ -s <output> ]`
   - If either check fails, keep the source `.drawio`, report the CLI stderr to the user, and stop — do not proceed to step 5
   - If the CLI binary itself is not found, keep the `.drawio` file and tell the user to install via `brew install --cask drawio`, or open the `.drawio` file directly
5. **Open the result** with `open <file>`. If `open` exits non-zero, print the absolute file path so the user can open it manually

## Choosing the output format

Check the user's request for a format preference. Examples:

- `/drawio create a flowchart` → `flowchart.drawio`
- `/drawio png flowchart for login` → `login-flow.drawio.png`
- `/drawio svg: ER diagram` → `er-diagram.drawio.svg`
- `/drawio pdf architecture overview` → `architecture-overview.drawio.pdf`

If no format is mentioned, just write the `.drawio` file and open it in draw.io. The user can always ask to export later.

### Supported export formats

| Format | Embed XML | Notes |
|--------|-----------|-------|
| `png` | Yes (`-e`) | Viewable everywhere, editable in draw.io |
| `svg` | Yes (`-e`) | Scalable, editable in draw.io |
| `pdf` | Yes (`-e`) | Printable, editable in draw.io |
| `jpg` | No | Lossy, no embedded XML support |

PNG, SVG, and PDF all support `--embed-diagram` — the exported file contains the full diagram XML, so opening it in draw.io recovers the editable diagram.

## draw.io CLI

The draw.io desktop app on macOS includes a command-line interface for exporting:

```sh
/Applications/draw.io.app/Contents/MacOS/draw.io
```

### Export command

```sh
/Applications/draw.io.app/Contents/MacOS/draw.io -x -f <format> -e -b 10 -o <output> <input.drawio>
```

Key flags:
- `-x` / `--export`: export mode
- `-f` / `--format`: output format (png, svg, pdf, jpg)
- `-e` / `--embed-diagram`: embed diagram XML in the output (PNG, SVG, PDF only)
- `-o` / `--output`: output file path
- `-b` / `--border`: border width around diagram (default: 0)
- `-t` / `--transparent`: transparent background (PNG only)
- `-s` / `--scale`: scale the diagram size
- `--width` / `--height`: fit into specified dimensions (preserves aspect ratio)
- `-a` / `--all-pages`: export all pages (PDF only)
- `-p` / `--page-index`: select a specific page (1-based)

### Opening the result

```sh
open <file>
```

## File naming

- Use a descriptive filename based on the diagram content (e.g., `login-flow`, `database-schema`)
- Use lowercase with hyphens for multi-word names
- For export, use double extensions: `name.drawio.png`, `name.drawio.svg`, `name.drawio.pdf` — this signals the file contains embedded diagram XML
- After a successful export, delete the intermediate `.drawio` file — the exported file contains the full diagram

## XML format

A `.drawio` file is native mxGraphModel XML. Always generate XML directly — Mermaid and CSV formats require server-side conversion and cannot be saved as native files.

### Critical rules (apply to ALL diagram XML)

Read these BEFORE generating any XML. Violations cause parse errors, blank diagrams, or invisible edges.

- **NEVER include XML comments (`<!-- -->`) in output.** They waste tokens, can cause parse errors, and serve no purpose in diagram XML
- Escape special characters in attribute values: `&amp;`, `&lt;`, `&gt;`, `&quot;`
- Use a unique `id` value for every `mxCell`
- Every edge `mxCell` MUST contain a child `<mxGeometry relative="1" as="geometry"/>` — self-closing edge cells do not render
- Cell `id="0"` is the root layer; cell `id="1"` is the default parent; all diagram elements use `parent="1"` unless using multiple layers
- Do NOT add `<Array as="points">` waypoints or `exitX`/`exitY`/`entryX`/`entryY` overrides — draw.io routes edges automatically via ELK. Sequence diagrams are the only exception (vertical position carries time-order semantics)

### Grid and sizing

Use this rigid grid for placement. Pick `(col, row)` per node — never compute pixel positions in prose.

- Column x = `col * 180 + 40`  (col 0 = 40, col 1 = 220, col 2 = 400, ...)
- Row y = `row * 120 + 40`     (row 0 = 40, row 1 = 160, row 2 = 280, ...)
- Default sizes: rectangle `140×60`, ellipse `120×60`, diamond `140×80`, cylinder `100×70`, lifeline `100×300`

### Basic structure

```xml
<mxGraphModel adaptiveColors="auto">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
  </root>
</mxGraphModel>
```

Add diagram cells inside `<root>` with `parent="1"`.

### Templates

These complete templates cover the most common diagram types. Use as-is — change labels, add nodes following the same patterns. For shapes/styles outside these templates, see `## XML reference` below.

#### Flowchart (3 nodes, 2 edges)

Edge style: `endArrow=classic;html=1;` (orthogonal routing handled automatically).

```xml
<mxGraphModel adaptiveColors="auto">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <mxCell id="2" value="Start" style="ellipse;whiteSpace=wrap;html=1;" vertex="1" parent="1">
      <mxGeometry x="40" y="40" width="120" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="3" value="Process" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1">
      <mxGeometry x="40" y="160" width="140" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="4" value="End" style="ellipse;whiteSpace=wrap;html=1;" vertex="1" parent="1">
      <mxGeometry x="40" y="280" width="120" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="5" style="endArrow=classic;html=1;" edge="1" parent="1" source="2" target="3">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="6" style="endArrow=classic;html=1;" edge="1" parent="1" source="3" target="4">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
  </root>
</mxGraphModel>
```

#### Sequence diagram (2 lifelines, request + response)

Lifeline shape: `shape=umlLifeline;perimeter=lifelinePerimeter;size=16` (size = header height). Message edge style: small arrowheads (`endSize=6;startSize=6`); response is dashed (`dashed=1`). `exitY`/`entryY` are required here — vertical position encodes message order in time.

```xml
<mxGraphModel adaptiveColors="auto">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <mxCell id="2" value="User" style="shape=umlLifeline;perimeter=lifelinePerimeter;whiteSpace=wrap;html=1;size=16;" vertex="1" parent="1">
      <mxGeometry x="40" y="40" width="100" height="300" as="geometry"/>
    </mxCell>
    <mxCell id="3" value="Server" style="shape=umlLifeline;perimeter=lifelinePerimeter;whiteSpace=wrap;html=1;size=16;" vertex="1" parent="1">
      <mxGeometry x="220" y="40" width="100" height="300" as="geometry"/>
    </mxCell>
    <mxCell id="4" value="request" style="endArrow=classic;html=1;endSize=6;startSize=6;exitX=1;exitY=0.3;entryX=0;entryY=0.3;" edge="1" parent="1" source="2" target="3">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
    <mxCell id="5" value="response" style="endArrow=classic;html=1;endSize=6;startSize=6;dashed=1;exitX=0;exitY=0.6;entryX=1;entryY=0.6;" edge="1" parent="1" source="3" target="2">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
  </root>
</mxGraphModel>
```

#### ER diagram (2 entities, 1 relationship)

Edge style: `edgeStyle=entityRelationEdgeStyle` (perpendicular stubs at both ends). Cardinality notation: `endArrow=ERmany` / `startArrow=ERone` (also: `ERoneToMany`, `ERmandOne`, `ERzeroToOne`, `ERzeroToMany`).

```xml
<mxGraphModel adaptiveColors="auto">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <mxCell id="2" value="User" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
      <mxGeometry x="40" y="40" width="140" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="3" value="Order" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
      <mxGeometry x="220" y="40" width="140" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="4" value="places (1..*)" style="edgeStyle=entityRelationEdgeStyle;html=1;endArrow=ERmany;startArrow=ERone;" edge="1" parent="1" source="2" target="3">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
  </root>
</mxGraphModel>
```

## XML reference

Load `references/xml-reference.md` (relative to this skill file) ONLY when the diagram needs:

- Swimlanes, pools, containers, or nested layers
- Industry-specific shape libraries: AWS / Azure / GCP cloud icons, Cisco network shapes, P&ID valves/instruments, Kubernetes, BPMN task variants, electrical/circuit symbols
- Class diagram with attribute/method compartments, state diagram with composite states, activity diagram with forks/joins
- Dark mode color tuning, tags, metadata, or multi-page diagrams
- Custom edge routing beyond the default ELK router

For all other cases, the templates above plus the Critical rules cover what you need. Loading the full reference (485 lines) for a simple diagram wastes context.

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| draw.io CLI not found | Desktop app not installed at `/Applications/draw.io.app` | Keep the `.drawio` file and tell the user to install via `brew install --cask drawio`, or open the file manually |
| Export produces empty/corrupt file | Invalid XML (e.g. unescaped special characters) | Re-check the Critical rules section; ensure attribute values escape `&`, `<`, `>`, `"` |
| Diagram opens but looks blank | Missing root cells `id="0"` and `id="1"` | Ensure the basic mxGraphModel structure is complete |
| Edges not rendering | Edge mxCell is self-closing (no child mxGeometry element) | Every edge must have `<mxGeometry relative="1" as="geometry"/>` as a child element |
| Sequence messages stack at the same height | Missing `exitY`/`entryY` on message edges | Add `exitY` / `entryY` (0.0 = top, 1.0 = bottom) to each message edge to encode time order |
| File won't open after export | Incorrect file path or missing file association | Print the absolute file path so the user can open it manually |
