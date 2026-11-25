---
name: html-plan
description: Present a plan or architecture as a self-contained interactive HTML page.
disable-model-invocation: true
---

Turn a plan, rollout, or architecture into a focused, scannable HTML artifact with diagrams and interactive disclosure where they clarify the work.

## Structure and traceability

Preserve the source plan's scope, ordering, commitments, and terminology.

Include only the sections the material supports (for example: phases or sequence, architecture or flows, owners and dependencies, risks, acceptance checks, open questions). Separate accepted decisions from assumptions and open questions. Leave out invented timelines, progress bars, or dashboard metrics.

- Use tables for exact mappings, comparisons, or repeated fields.
- Keep prose readable; avoid wrapping every paragraph in a card.
- Add diagrams only where spatial or sequential structure beats prose. Choose the model that fits the relationship (topology, sequence, process, state, hierarchy, timeline, or matrix) and the simplest rendering method (HTML/CSS or SVG).
- Keep controls (tabs, collapsibles, filters, steppers) keyboard-operable and compatible with `prefers-reduced-motion`.

## Delivery by harness

- **T3 Code** (when `html_preview` and `html_render` are available):
  1. Build one self-contained HTML document using T3's theme CSS variables (`--background`, `--foreground`, `--muted`, `--card`, `--border`, `--primary`, `--accent`, `--warning`, `--success`, `--destructive`, `--chart-1`..`--chart-6`, `--radius`, `--font-sans`, `--font-mono`). Leave `html`, `body`, and the outer wrapper transparent with no outer card, border, side padding, `vh` units, or `height: 100%`.
  2. Verify with `html_preview` and fix any layout, clipping, label-overlap, or console issues.
  3. Present inline with `html_render` using the returned `contentHeight`.
- **GitHub Copilot and other harnesses**:
  1. Write one responsive, self-contained `.html` file with inline CSS/JS and `prefers-color-scheme` light/dark support to `$TMPDIR` (never inside the repo unless asked).
  2. Verify layout at wide and narrow widths when browser tools are available.
  3. Return the absolute file path.

## Completion check

Before finishing, verify that every source commitment remains in order, diagrams and labels do not collide or overflow, and all interactive states work. Briefly note any structural assumptions introduced.
