---
name: repo-status
description: "Fetch and render a status overview of all unarchived, non-fork repositories across beste and jeromegamez (CI, open PRs, issues, Dependabot alerts, unreleased commits, activity)."
---

# Repo Status

Generate a status overview of all unarchived, non-fork repositories across `beste` and `jeromegamez`.

## Run

Fetch live data via GraphQL and render it to a temporary HTML file (never commit generated HTML to git):

```bash
node ~/.agents/skills/repo-status/scripts/fetch-status.mjs | node ~/.agents/skills/repo-status/scripts/render-html.mjs > /tmp/repo-status.html
```

Pass owner names to `fetch-status.mjs` to override the default (`beste jeromegamez`).

## Display

- When `html_preview` and `html_render` are available, preview `/tmp/repo-status.html` with `html_preview` to get `contentHeight`, then display it inline with `html_render`.
- Otherwise, summarize the JSON output in the terminal (or tell the user they can open `/tmp/repo-status.html`).
- Never commit `/tmp/repo-status.html` or any generated report to git.
- For full security triage (advisories, code scanning, secret scanning), defer to the `security-audit` skill.
