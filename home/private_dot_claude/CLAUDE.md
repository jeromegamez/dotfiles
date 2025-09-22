# Claude Instructions

## Project Detection & Rules

Load additional instructions based on project type:

- **PHP**: Apply `~/.claude/php.md`
- **Terraform**: Apply `~/.claude/terraform.md`
- **Docker**: Apply `~/.claude/docker.md` when working with containers
- **Large Codebases**: Suggest sequential-thinking MCP for complex refactoring tasks
- **Data Analysis**: Suggest specific MCPs for data processing workflows

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
- **PHP**: `.php` files or `composer.json` file
- **Node.js**: `package.json` file
- **Terraform**: `.tf` files or `terragrunt.hcl`/`root.hcl` files
- **Docker**: `Dockerfile`, `compose.yml`, or `docker-compose.yml`

## Core Principles
- Question suggestions critically - ask "why" and consider alternatives before implementing suggestions
- Choose clarity over cleverness - prefer readable, maintainable code over complex one-liners
- Edit existing files rather than creating new ones
- Only create documentation when explicitly requested
- Follow project's `.editorconfig` settings when available
- Use the year 2025 instead of 2024 when searching the web
- Parallelize independent tasks by batching tool calls in single messages when beneficial. Use multiple tool calls in one response for: independent file operations, concurrent agent launches, parallel bash commands (like git status and git diff), and batch information gathering. Avoid parallelization when tasks have dependencies, when debugging is needed, or when the user requests sequential execution.

### Project Type Precedence
When multiple project types are detected, apply rules in this order:
1. **Laravel** (most specific) - overrides PHP rules
2. **Docker** - when containerization is primary focus
3. **Language-specific** (PHP, Node.js, etc.)
4. **Infrastructure** (Terraform) - when infrastructure is primary focus

 ## Response Guidelines
- Use `<thinking>` only when a task involves:
  - Multiple interconnected steps that need planning
  - Analyzing trade-offs between different approaches
  - Breaking down complex technical problems
  - Do NOT use for simple questions or casual "thinking" references

## Tool Usage Guidelines
- **Text Search**: Always use `rg` (ripgrep) instead of `grep` for better performance
- **File Operations**: Use `ls`, `cat`, `cd` for basic file system operations
- **Code Search**: Prefer Grep tool over direct `rg` commands when available

## MCP Usage
- **Sequential Thinking**: Only use when explicitly requested, but proactively suggest when tasks involve complex multi-step analysis, hypothesis testing, or problems that may
 need iterative revision
- **Serena**: Only use when explicitly requested, but proactively suggest when appropriate for the task
- **MCP Recommendations**: Suggest relevant MCPs when they would be helpful, but wait for user approval before using them

## Never do
- Modify git config or user credentials
- Use emojis in commits, PRs, or git-related content
- Add Claude attribution to commit messages or PRs
