---
name: memory
description: Read, write, update, or prune cross-session memory notes stored in ~/Code/home-repo/memory/. Use when the user asks to remember something, recall past context, check memory, or forget/update a saved note.
---

Cross-session notes live in `~/Code/home-repo/memory/`.

- `MEMORY.md` is the index: one short line per topic file (`- [topic.md](topic.md) - brief summary`).
- Each topic gets its own small Markdown file (`<topic>.md`).

## First-time setup

If `~/Code/home-repo/memory/MEMORY.md` does not exist:
1. Ask the user to confirm creating `~/Code/home-repo` (or a different path).
2. If `~/Code/home-repo` does not exist, create it, run `git init`, and add a minimal `AGENTS.md` and `CLAUDE.md` (`@AGENTS.md`).
3. Create `memory/MEMORY.md` with `# Memory Index`.

## Recall

1. Read `~/Code/home-repo/memory/MEMORY.md` first.
2. Open only the topic file(s) relevant to the current question. Never bulk-read the whole directory.

## Remember / Update

1. Read `~/Code/home-repo/memory/MEMORY.md` first to avoid duplicates.
2. Put the note in an existing topic file if one fits; otherwise create `<topic>.md` and add a one-line pointer to `MEMORY.md`.
3. Keep entries concise, factual, and dated (`YYYY-MM-DD`). Update or replace superseded facts instead of appending contradictions.
4. Never store secrets, tokens, or credentials. Prefer a repo's `AGENTS.md` for repo-specific coding rules.
5. Do not auto-commit changes in `~/Code/home-repo` unless asked.

## Forget / Prune

Remove the outdated entry. If a topic file becomes empty, delete it and remove its line from `MEMORY.md`.
