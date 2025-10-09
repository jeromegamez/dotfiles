# Claude Instructions

## Project Detection & Rules

Load additional instructions based on project type:

- **PHP**: Apply `~/.claude/php.md`
- **Laravel**: Apply `~/.claude/laravel.md` (takes priority over PHP)
- **Node.js/JavaScript**: Apply `~/.claude/nodejs.md`
- **Python**: Apply `~/.claude/python.md`
- **Terraform**: Apply `~/.claude/terraform.md`
- **Docker**: Apply `~/.claude/docker.md` when working with containers

## Available Commands

The `/commands/` and `/agents/` directories contain specialized command files and AI agents for specific tasks:

- **Development**: `implement.md`, `refactor.md`, `fix-imports.md`, `format.md`
- **Testing**: `test.md`, `review.md`, `security-scan.md`, `predict-issues.md`
- **Documentation**: `docs.md`, `explain-like-senior.md`, `understand.md`
- **Project Management**: `scaffold.md`, `cleanproject.md`, `make-it-pretty.md`
- **Todo Management**: `create-todos.md`, `find-todos.md`, `fix-todos.md`, `todos-to-issues.md`
- **Session Management**: `session-start.md`, `session-end.md`
- **Utilities**: `commit.md`, `contributing.md`, `remove-comments.md`, `undo.md`

### Detection Patterns
- **PHP**: `.php` files or `composer.json` file
- **Laravel**: `artisan` file or `composer.json` with `laravel/framework`
- **Node.js/JavaScript**: `package.json`, `.js`, `.ts`, `.jsx`, `.tsx` files
- **Python**: `.py` files, `requirements.txt`, `pyproject.toml`, or `setup.py`
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
1. **Laravel** (most specific) - overrides PHP rules
2. **Docker** - when containerization is primary focus
3. **Language-specific** (PHP, Node.js, etc.)
4. **Infrastructure** (Terraform) - when infrastructure is primary focus

## MCP Recommendations
- **Sequential Thinking**: Use for complex multi-step analysis, hypothesis testing, and iterative problem-solving
- **Context7**: Excellent for up-to-date library documentation and code examples
- **AWS Knowledge**: Essential for AWS service documentation and best practices
- **Terraform/Terraform-AWS**: Critical for infrastructure-as-code development and AWS resource management
- **Serena**: Semantic code analysis for large, structured codebases (>50 files)
  - ⚠️ **Use sparingly** - computational overhead
  - ⚠️ **Not recommended** for small projects or scratch development
  - Best for: Complex refactoring, multi-language projects, large codebases

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

## Serena MCP Setup & Detection

### When to Recommend Serena
Suggest Serena when the project has:
- **Large codebase**: >50 files across multiple directories
- **Complex structure**: Multiple modules, packages, or components
- **Multi-language**: JavaScript/TypeScript + Python/PHP, etc.
- **Refactoring needs**: Symbol-level changes across many files
- **Legacy code**: Understanding existing large codebases

### When NOT to Recommend Serena
Avoid suggesting Serena for:
- **Small projects**: <20 files or simple scripts
- **Scratch development**: Building new projects from zero
- **Single-file tasks**: Editing individual files
- **Simple debugging**: Basic fixes or small changes

### Detection Method
Check if Serena is available by looking for it in the user's MCP configuration or by asking the user directly.

### Installation Instructions
If Serena is not available, provide these installation option:

```bash
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)
```

### Configuration Notes
- Serena requires language servers for full functionality
- Can be customized with contexts and modes
- Works best with established codebases that have clear structure

## Never do
- Modify git config or user credentials
- Use emojis in commits, PRs, or git-related content
- Add Claude attribution to commit messages or PRs
