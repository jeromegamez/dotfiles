---
name: modernize
description: Evaluate a stale PR against the current base branch and rebase it locally without pushing.
disable-model-invocation: true
---

Modernize the idea, not just the branch. A conflict-free rebase does not prove a PR still belongs.

## Guardrails

- Keep all mutations local: never push, force-push, merge, close, change the base branch, or post PR comments.
- Treat existing working tree changes as user-owned; use a disposable worktree when the current checkout is dirty or on other work.

## Steps

1. **Establish the PR's intent.**
   Resolve the PR (URL, state, base, head, head SHA, author, checks, reviews, linked issues, and full diff). Fetch the latest remote base and PR head, record the merge base, and state the smallest coherent goal the PR was trying to achieve before judging its implementation.

2. **Check what changed on the base branch.**
   Inspect commits on the base branch since the merge base, plus merged or open PRs that touch the same area. Look beyond line overlaps:
   - Has the problem already been solved?
   - Did APIs, schemas, dependencies, or architectural boundaries change?
   - Was the target code deleted, moved, or intentionally simplified?
   - Would landing this restore old behavior or create two ways to do the same thing?
   - Is the remaining benefit still worth the maintenance cost?

3. **Choose a disposition before rebasing.**
   - **MODERNIZE**: goal is still useful and the implementation shape still fits. Proceed to step 4.
   - **REWORK**: goal is still useful, but a rebase would preserve the wrong design. Outline the smallest credible rewrite and stop.
   - **CLOSE**: superseded, obsolete, or no longer worth its cost. Cite concrete evidence and stop without rebasing.

4. **Rebase locally (`MODERNIZE` only).**
   - Check out a local branch (or disposable worktree) at the recorded PR head.
   - Rebase onto the freshly fetched base branch, resolving conflicts to preserve PR intent under the base branch's current invariants. If a conflict reveals a design mismatch, stop and reconsider the disposition.
   - Compare pre- and post-rebase commits with `git range-diff` and inspect the final diff to confirm no intentional behavior was dropped and no landed base change was reverted.
   - Run focused checks for the touched area, distinguishing real failures from pre-existing or environment issues.
   - Leave the rebased branch local for user review.

## Report

Lead with `MODERNIZE`, `REWORK`, or `CLOSE` and the reason. Follow with:

- meaningful base-branch changes since divergence;
- conceptual conflicts found (or confirmation that none were found);
- local branch or worktree path and `range-diff` summary (if rebased);
- checks run and their results, noting anything unverified;
- the remaining decision for the user (and, if ready to update remotely, the `--force-with-lease=<branch>:<expected-sha>` push command for them to run or approve).

Separate observed facts from judgment.
