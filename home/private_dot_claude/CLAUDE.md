# Claude Instructions

## Project Detection & Rules

Load additional instructions based on project type:

- **PHP**: Apply `~/.claude/php.md`
- **Terraform**: Apply `~/.claude/terraform.md`
- **Docker**: Apply `~/.claude/docker.md` when working with containers

## Available Commands

The `/commands/` directory contains specialized command files for specific tasks:

- **Development**: `implement.md`, `refactor.md`, `fix-imports.md`, `format.md`
- **Testing**: `test.md`, `review.md`, `security-scan.md`, `predict-issues.md`
- **Documentation**: `docs.md`, `explain-like-senior.md`, `understand.md`
- **Project Management**: `scaffold.md`, `cleanproject.md`, `make-it-pretty.md`
- **Todo Management**: `create-todos.md`, `find-todos.md`, `fix-todos.md`, `todos-to-issues.md`
- **Session Management**: `session-start.md`, `session-end.md`
- **Utilities**: `commit.md`, `contributing.md`, `remove-comments.md`, `undo.md`

### Detection Patterns
- **Laravel**: `artisan` file or `composer.json` with `laravel/framework`
- **Node.js**: `package.json` file
- **Terraform**: `.tf` files
- **Docker**: `Dockerfile`, `compose.yml`, or `docker-compose.yml`

## Core Principles
- Question suggestions critically - ask "why" and consider alternatives before implementing suggestions
- Choose clarity over cleverness - prefer readable, maintainable code over complex one-liners
- Edit existing files rather than creating new ones
- Only create documentation when explicitly requested
- Follow project's `.editorconfig` settings when available

### Project Type Precedence
When multiple project types are detected, apply rules in this order:
1. **Laravel** (most specific) - overrides PHP rules
2. **Docker** - when containerization is primary focus
3. **Language-specific** (PHP, Node.js, etc.)
4. **Infrastructure** (Terraform) - when infrastructure is primary focus

## Response Guidelines
- Use `<thinking>` only for complex problem-solving
- Respond naturally to casual conversation
- Don't over-analyze simple statements

## Tool Usage Guidelines
- **Text Search**: Always use `rg` (ripgrep) instead of `grep` for better performance
- **File Operations**: Use `ls`, `cat`, `cd` for basic file system operations
- **Code Search**: Prefer Grep tool over direct `rg` commands when available

## Never do
- Modify git config or user credentials
- Use emojis in commits, PRs, or git-related content
