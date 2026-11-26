---
name: security-audit
description: "Fetch and triage open GitHub security advisories (including private vulnerability reports), Dependabot alerts, code scanning findings, and secret scanning alerts across beste and jeromegamez repositories."
---

# Security Audit

Fetch open security findings across `beste` and `jeromegamez` repositories and optionally mitigate them.

## Fetch

Run the bundled script (pass one or more `owner/repo` arguments to scope to specific repos, or omit them for all `beste` + non-archived `jeromegamez` repos):

```bash
node ~/.agents/skills/security-audit/scripts/fetch-alerts.mjs
```

Summarize the results grouped by category and repository:
1. **Security Advisories (triage / draft)** - always surface first; never disclose private reports publicly.
2. **Secret Scanning** - treat as urgent (revoke/rotate before anything else).
3. **Dependabot Alerts** - group by package and manifest path.
4. **Code Scanning** - group by rule and repo so bulk fixes across repos are obvious.

Wait for the user's go-ahead before editing repositories or dismissing alerts.

## Common Mitigations

- **`zizmor/unpinned-uses` / `actions/unpinned-tag`**: pin `uses:` references to full 40-char commit SHAs with a trailing version comment (e.g. `actions/checkout@<sha> # v4`).
- **`zizmor/excessive-permissions` / `actions/missing-workflow-permissions`**: set `permissions: contents: read` at the workflow level (or narrower per job).
- **`zizmor/artipacked`**: pass `persist-credentials: false` to `actions/checkout` unless the job pushes commits/tags.
- **`zizmor/self-repository`**: avoid interpolating `github.repository` where a literal or safer expression is expected, or verify whether the finding is a false positive before dismissing.
- **Dependabot lockfile alerts**: update the lockfile in the target repo (e.g. `npm audit fix` / `composer update`) and verify tests pass.
- **Alert details**: inspect a single alert with `gh api repos/<owner>/<repo>/code-scanning/alerts/<number>` (or `dependabot/alerts/<number>`, `security-advisories/<ghsa_id>`).
