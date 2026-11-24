---
name: review-loop
description: Run a multi-round review loop with a second agent or session until both converge or hit the round cap.
disable-model-invocation: true
---

Coordinate a structured review loop with a second agent or session until both sides agree on every material point, or the round cap is reached.

## Parameters

Infer from the user's prompt; ask only if the target or scope is unclear.

- **Scope**: uncommitted changes, branch diff against base, specific commits, or a plan/document.
- **Reviewer**: a named existing session/thread, or a fresh review agent (prefer a different model when available).
- **Focus**: correctness, regressions, and maintainability unless the user specifies another focus.
- **Max rounds**: 3 by default.

## Loop

For each round (1 to max rounds):

1. **Send the exact review input.** Share the current scope, user requirements, and (after round 1) what changed since the last round plus any disputed points with reasoning. Never ask the reviewer to guess what changed.
2. **Evaluate every finding independently.** For each finding from the reviewer:
   - **Agree**: apply the fix locally (or update the plan).
   - **Disagree**: state the concrete reason with file/line or design evidence. Do not fold just to reach agreement, and do not dismiss valid points defensively.
3. **Check stopping condition.**
   - **Converged**: reviewer has no remaining material findings and both sides agree on any resolved points. Stop and summarize the outcome.
   - **Findings fixed or points still disputed**: start the next round with the updated state and open disagreements only.

## Round cap and escalation

If disagreements remain after the max round, stop immediately. Do not loop again or silently pick a winner. Present each unresolved point to the user with:

- the reviewer's position,
- your position and evidence,
- the concrete decision needed.
