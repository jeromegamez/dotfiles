---
name: release
description: "Cut a new release for a personal or beste repository: update CHANGELOG.md, commit, push, wait for CI if triggered, create and push an annotated tag, and publish a GitHub release from the changelog section."
---

# Release

Cut a new release for a personal or `beste` repository.

## Pre-flight

1. Verify the target repo is on its target release branch (e.g. the default branch such as `main` or a version branch like `5.x`), has a clean working tree, and is up to date with `origin/<branch>`.
2. Read `CHANGELOG.md` and inspect the `## Unreleased` section. Stop if `## Unreleased` is empty.
3. Confirm the target version `x.y.z` and the exact release notes (the `## Unreleased` body) with the user before making any commits, tags, or releases. The `beste` GitHub organization enforces immutable releases, so mistakes cannot be edited or deleted after publishing.

## Steps

1. **Update `CHANGELOG.md`**: insert `## x.y.z - YYYY-MM-DD` (today's UTC/local date) below `## Unreleased`, keeping `## Unreleased` at the top with a blank line between them.
2. **Commit**:
   ```bash
   git add CHANGELOG.md
   git commit -m "Release x.y.z"
   ```
3. **Push**:
   ```bash
   git push origin HEAD
   ```
4. **Wait for CI (if triggered)**: check `gh run list --commit "$(git rev-parse HEAD)" --limit 5`. If a workflow run started for the release commit, wait for it to succeed (`gh run watch`) before tagging. If no workflow was triggered (e.g. `paths:` filters exclude `CHANGELOG.md`), continue.
5. **Create and push annotated tag**:
   ```bash
   git tag -a x.y.z -m "Release x.y.z"
   git push origin x.y.z
   ```
6. **Publish GitHub release**: use the exact changelog section body (never `--generate-notes`):
   ```bash
   gh release create x.y.z --title "x.y.z" --notes "<changelog section body>"
   ```
7. Report the published release URL.
