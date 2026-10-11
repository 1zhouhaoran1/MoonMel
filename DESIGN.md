---
name: MoonMel
description: Warm ivory audio instrumentation with charcoal type and vermilion identity.
colors:
  primary: "#b63a25"
  primary-hover: "#98301e"
  ivory-ground: "#f1eee7"
  charcoal-ink: "#24211d"
  muted-ink: "#6f675e"
  field-surface: "#f8f5f0"
  fine-rule: "#d4cdc1"
  selected-surface: "#e7d6c8"
  selected-ink: "#932d1c"
  comparison-surface: "#eadfd1"
  comparison-ink: "#762d1b"
  code-surface: "#e9e3d8"
  code-ink: "#852915"
  plot-ground: "#121211"
typography:
  display:
    fontFamily: "Manrope Variable, Microsoft YaHei, sans-serif"
    fontSize: "clamp(1.65rem, 3.4vw, 2.9rem)"
    fontWeight: 500
    lineHeight: 1.3
    letterSpacing: "-0.035em"
  title:
    fontFamily: "Manrope Variable, Microsoft YaHei, sans-serif"
    fontSize: "1.2rem"
    fontWeight: 600
    lineHeight: 1.65
  body:
    fontFamily: "Manrope Variable, Microsoft YaHei, sans-serif"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.65
  label:
    fontFamily: "Manrope Variable, Microsoft YaHei, sans-serif"
    fontSize: "12px"
    fontWeight: 400
    lineHeight: 1.65
  measurement:
    fontFamily: "ui-monospace, Consolas, monospace"
    fontSize: "11px"
    fontWeight: 400
    lineHeight: 1.65
rounded:
  control: "4px"
spacing:
  compact: "8px"
  inline: "12px"
  field: "16px"
  group: "24px"
  section-mobile: "64px"
  section-desktop: "100px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.ivory-ground}"
    rounded: "{rounded.control}"
    padding: "8px 12px"
    height: "42px"
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
    textColor: "{colors.ivory-ground}"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.charcoal-ink}"
    rounded: "{rounded.control}"
    padding: "8px 12px"
    height: "42px"
  view-selected:
    backgroundColor: "{colors.selected-surface}"
    textColor: "{colors.selected-ink}"
    rounded: "{rounded.control}"
    padding: "5px 13px"
    height: "36px"
  select-field:
    backgroundColor: "{colors.field-surface}"
    textColor: "{colors.charcoal-ink}"
    rounded: "{rounded.control}"
    padding: "8px 12px"
    height: "42px"
    width: "100%"
  section-navigation:
    textColor: "{colors.charcoal-ink}"
  text-link:
    textColor: "{colors.primary}"
    padding: "0 0 5px"
  code-panel:
    backgroundColor: "{colors.code-surface}"
    textColor: "{colors.code-ink}"
    padding: "24px"
  plot-surface:
    backgroundColor: "{colors.plot-ground}"
    width: "100%"
---

# Design System: MoonMel

<p align="center"><img src="docs/banner.png" alt="MoonMel acoustic-bar and crescent identity" width="960" /></p>
<p align="center">Warm ivory instrumentation for inspectable audio features.</p>
<p align="center"><a href="DESIGN_zh.md">中文</a> · <a href="README.md#run-from-source">Run from source</a> · <a href="docs/en/API_SPECIFICATION.md">API</a> · <a href="docs/en/ARCHITECTURE.md">Architecture</a></p>

## Overview

**Creative North Star: "The Acoustic Bench"**

MoonMel combines a warm printed identity with a precise audio workbench. Ivory is the continuous page ground; charcoal carries reading and vermilion identifies actions, emphasis and the acoustic-bar/crescent emblem. The custom wordmark lives in the canonical artwork. The interface uses restrained typography, open sections and fine rules so the actual analysis remains easy to inspect.

The dark spectrum is an operational data surface within this light brand. Heat, axes, frame values and numerical tables explain computed results rather than decorate the page. Motion is limited to short button color transitions and anchor scrolling, with a reduced-motion override. This document records the implemented system; the playground's particular composition belongs in its [surface brief](.impeccable/surfaces/playground.md).

**Key Characteristics:**
- Warm ivory ground, charcoal reading color and one vermilion brand accent.
- Canonical acoustic-bar/crescent emblem and custom raster wordmark.
- Open sections, fine dividers and minimally rounded controls.
- Dark, unsmoothed data heatmaps with explicit units and frame readouts.
- Local measurements and scoped evidence presented beside their limits.

## Colors

The palette is warm and matte; data intensity adds a sequential warm scale without creating a second brand accent. The frontmatter is the normative token list, extracted from [the current stylesheet](playground/src/style.css).

### Primary

Vermilion identifies the recalculation action, text links, selected emphasis, verification summary and focus outlines. Deep vermilion supplies the primary button's hover state. Selected-view ink is a darker vermilion on a warm selected surface; the final review recorded text contrast of (5.64:1) for that specific pair.

### Neutral

Ivory ground is the page background; charcoal ink is the default text. Muted ink supports labels, captions and measurements. Field surface separates native controls gently, and fine rule divides regions. Selected surface, comparison surface and code surface provide local tonal distinctions. Comparison ink and code ink are warm reading colors for those regions. Plot ground is reserved for the spectrum canvas.

The CSS variable names are historical: `--ink` supplies ivory and `--paper` supplies charcoal. Preserve their actual assignments when reading or extending the current code; the descriptive frontmatter names clarify their roles. The unused studio/accent palette and Inter/JetBrains stacks in `tailwind.config.js` are not the visible system.

**The Data Color Rule.** Heatmap color represents the current matrix and its displayed range. The implemented five stops run from dark charcoal through warm red and amber to pale ivory; Log-Mel and STFT use a relative dB span (80 dB), while MFCC uses its observed coefficient range. Constant silence stays dark. Sidecar tonal ramps are synthesized preview aids, not additional shipped color tokens or the heatmap scale.

## Typography

**Display and Body Font:** locally bundled Manrope Variable, with Microsoft YaHei and sans-serif fallbacks. Chinese glyphs depend on the available fallback; do not claim that Manrope supplies them.

**Measurement Font:** system monospace, with Consolas and monospace fallbacks. No separate mono font download is used.

**Character:** compact, quiet interface type beside an expressive artwork wordmark. The raster wordmark is not a font to recreate with the body stack.

### Hierarchy

Display typography serves comparison and evidence section headings. The laboratory heading is deliberately smaller (22px) with tighter tracking (-0.025em). Title typography serves the developer entry. Body typography supplies reading copy, while the intro statement is larger (20px desktop; 17px at the intermediate breakpoint). Labels identify native fields; small measurements use tabular numerals. Code uses monospace (12px / 1.9); axis captions use smaller monospace (10px).

**The Measurement Type Rule.** Use monospace for code, dimensions, parameters and measured values; keep narrative text and navigation in the sans-serif stack.

## Layout

The desktop reading container is capped at (1240px), with total horizontal inset (80px). At viewport widths up to (900px), total inset becomes (40px); up to (640px), it becomes (32px). Repeated spacing values are captured in frontmatter; these are extracted values, not a new CSS token API.

The system favors continuous sections and aligned columns over nested cards. The implemented desktop lab pairs a narrow control rail (245px; 210px at the intermediate breakpoint) with a flexible result area. On mobile, the result area is visually placed before the controls, and the parameter grid becomes three columns. The HTML retains the form before the results; this visual reorder does not change keyboard or assistive-technology reading order.

The comparison table retains its minimum width (930px) inside horizontal overflow. A visible scroll cue appears at widths up to (900px), and the comparison region is keyboard-focusable. Evidence and developer content collapse to one column on mobile. Keep captions, units, caveats and downloads associated with the result they describe.

**The Result First Rule.** In the playground's mobile lab, preserve the implemented result-before-controls visual order so the computed artifact remains visible before detailed configuration.

## Elevation & Depth

The interface uses no box shadows. Depth comes from ivory, gently lighter fields, warm selected or code surfaces, thin rules and the dark data canvas. The banner is blended into the page with multiply; its raster material character belongs to the artwork rather than a UI elevation effect.

**The Flat Instrument Rule.** Keep controls and data regions flat; show interaction through color, borders and the visible focus outline instead of floating elevation.

## Shapes

Controls have gently eased corners using the single control radius. Tables, section boundaries, code panels and data canvases remain rectangular. Dividers and control borders are fine (1px). The capsule-like acoustic bars and crescent are canonical identity geometry; they do not imply pill-shaped navigation or controls.

Canonical artwork is [docs/banner.png](docs/banner.png) and [docs/logo.png](docs/logo.png). The playground displays [brand-banner.webp](playground/public/brand-banner.webp) and its public PNG logo. Preserve artwork proportions: the banner source is (1672 × 941), and the header emblem is displayed at (36 × 36). Use the provided custom wordmark rather than retyping it as an approximation.

## Components

### Buttons

Compact, lightly rounded actions. Primary recalculation uses vermilion and ivory; secondary playback, microphone and export actions use transparent ground and a fine border. Standard controls have minimum height (42px); exports are smaller (34px). Hover changes the fill and border, with color transitions (.18s). Focus uses a vermilion outline (2px) offset (4px). Disabled actions reduce opacity (.45) and lose their hover fill; playback and export become available only after a current result.

### Feature view switch

Log-Mel, STFT and MFCC are grouped buttons, not decorative chips. The selected button has warm fill and darker vermilion ink, with `aria-pressed` communicating state. Buttons use minimum height (36px). Switching views redraws an already computed result; changing the signal or analysis parameters requests a new analysis.

### Inputs / Fields

Native selects use a lightly raised tone, fine border and the shared control radius. File input retains the browser's chooser with a styled selector button; keep it a recognizable upload control. Synthetic rate and duration are disabled for WAV and microphone sources. Source identity is shown with duration and sample rate. WAV loading has a distinct input revision, so analysis changes during decoding do not silently lose the selected file. Error text is adjacent to the controls and exposed through an alert region.

### Navigation

Small text links go directly to the laboratory, comparison and evidence. The brand emblem and readable MoonMel name anchor the header; the custom wordmark remains in the banner. On mobile the main navigation wraps to its own row. The source link keeps a fine underline, while content action links use vermilion and a restrained bottom rule. A keyboard-revealed skip link leads to the laboratory. There is no active-section scroll tracking.

### Containers and code panel

Open sections are the default container. The control/result boundary and developer entry are delineated by rules; the code example is a flat warm inset with monospace text and horizontal overflow. The emphasized MoonMel comparison column uses a warm surface and deeper text while keeping competitor columns visible through scrolling. There is no reusable marketing-card system in the current page.

### Audio plots and evidence

The spectrum is a rectangular canvas with crisp matrix cells, low frequencies below and time increasing to the right. Canvas height steps from (330px) to (290px) to (230px) across the implemented breakpoints. Pointer movement or left/right keys selects a frame for the textual readout. Waveform and optional filterbank plots come from the same actual input/analysis. The canvas's accessible name, descriptions and frame readout complement the image; no comprehensive accessibility certification is implied.

The UI identifies execution as MoonBit-generated JavaScript in a Web Worker. WASM and native are library build targets. Displayed computation time is a current-device worker measurement including conversion/serialization work inside the measured span; it excludes end-to-end rendering and does not rank competitors. The reference table renders the checked-in report: eight deterministic configurations, aligned reflect padding, periodic Hann, float64 Slaney and orthogonal DCT-II. Full Mel/Log-Mel/MFCC matrices are compared; STFT covers up to 64 explicitly indexed bins per frame. These results do not establish whole-library equivalence with librosa, Meyda or Essentia.js.

Documentation was cross-checked against source, canonical artwork and the final desktop (1440 × 2925) and mobile (390 × 4097) captures in `.impeccable/review/`. The review handoff reports five resolved findings: WAV load identity, dark silence, mobile result order, table scroll cue and selected-view contrast. Its scoped verdict is ship; that verdict is not a claim of universal browser coverage, performance leadership or external validation of every feature.

The companion [.impeccable/design.json](.impeccable/design.json) uses schemaVersion 2. It carries extension metadata, eight self-contained component previews and this document's narrative; frontmatter retains ownership of token primitives. Preview labels and palette strips are illustrative component samples, not measured audio output.

## Do's and Don'ts

### Do:
- **Do** preserve the canonical acoustic-bar/crescent artwork and custom wordmark.
- **Do** use ivory for the overall page and dark charcoal for the operational spectrum.
- **Do** keep units, source identity, frame readouts and evidence limits beside their results.
- **Do** preserve visible focus, the mobile table scroll cue and selected-view contrast.
- **Do** describe the current browser engine as generated JavaScript in a Web Worker.

### Don't:
- **Don't** replace the visible system with the unused dark studio theme from Tailwind configuration.
- **Don't** add decorative card stacks or shadows to the current open, flat instrumentation.
- **Don't** brighten constant silence into apparent signal energy.
- **Don't** turn eight scoped reference configurations into a whole-library equivalence claim.
- **Don't** invent competitor speed, size or quality rankings from local execution time.
