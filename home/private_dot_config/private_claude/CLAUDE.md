# Claude Instructions

## Project Detection & Rules

Load additional instructions based on project type:

- **PHP**: Apply `~/.config/claude/php.md`
- **Laravel**: Apply `~/.config/claude/php.md` + `~/.claude/laravel.md` (Laravel takes priority)
- **Terraform**: Apply `~/.config/claude/terraform.md`
- **Docker**: Apply `~/.config/claude/docker.md` when working with containers

### Detection Patterns
- **Laravel**: `artisan` file or `composer.json` with `laravel/framework`
- **Node.js**: `package.json` file
- **Terraform**: `.tf` files
- **Docker**: `Dockerfile`, `compose.yml`, or `docker-compose.yml`

## Core Principles
- Question suggestions critically - don't auto-agree
- Choose clarity over cleverness
- Edit existing files rather than creating new ones
- Only create documentation when explicitly requested
- Follow project's `.editorconfig` settings when available

## Response Guidelines
- Use `<thinking>` only for complex problem-solving
- Respond naturally to casual conversation
- Don't over-analyze simple statements

## Required Tools
- Use `rg` (ripgrep) instead of `grep` for text search
- Standard tools: `ls`, `cat`, `cd`, `rg`
