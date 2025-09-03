# Laravel Guidelines

## Core Principles
**Follow Laravel conventions first.** Use Laravel's documented approach unless you have clear justification to deviate.

## Conventions

### Routes
- URLs: kebab-case (`/open-source`)
- Route names: camelCase (`->name('openSource')`)
- Parameters: camelCase (`{userId}`)
- Use tuple notation: `[Controller::class, 'method']`

### Controllers
- Plural resource names (`PostsController`)
- Stick to CRUD methods (`index`, `create`, `store`, `show`, `edit`, `update`, `destroy`)
- Extract new controllers for non-CRUD actions
- Always use Form Requests instead of generic `Request` class

### Configuration
- Files: kebab-case (`pdf-generator.php`)
- Keys: snake_case (`chrome_path`)
- Add service configs to `config/services.php` (don't create new files)
- Use `config()` helper; avoid `env()` outside config files

### Artisan Commands
- Names: kebab-case (`delete-old-records`)
- Always provide feedback (`$this->comment('All ok!')`)
- Show progress for loops, summary at end
- Output BEFORE processing (easier debugging):
  ```php
  $items->each(function(Item $item) {
      $this->info("Processing item {$item->id}...");
      $this->processItem($item);
  });
  
  $this->comment("Processed {$items->count()} items.");
  ```

## Recommended MCPs
- **Serena**: Excellent for navigating large Laravel applications, understanding Eloquent relationships, analyzing controller/service dependencies, and semantic PHP code analysis
- **Sequential Thinking**: Perfect for complex application architecture decisions and debugging multi-step processes

## Best Practices

### Formatting

### Strings
- Use string interpolation over concatenation

### Enums
- Use PascalCase for enum values

### Comments
- Avoid comments - write expressive code instead
- When needed: `// Single line` or `/* Multi-line */`
- Refactor comments into descriptive function names

### Whitespace
- Add blank lines between statements for readability
- Exception: sequences of equivalent single-line operations
- No extra empty lines between `{}` brackets
- Let code "breathe" - avoid cramped formatting

## Validation
- Use array notation for multiple rules:
  ```php
  public function rules() {
      return [
          'email' => ['required', 'email'],
      ];
  }
  ```
- Custom validation rules use snake_case: `organisation_type`

## Templates & Views

### Blade
- Indent with 4 spaces
- No spaces after control structures: `@if($condition)`

### Authorization
- Policies use camelCase: `Gate::define('editPost', ...)`
- Use CRUD words, but `view` instead of `show`

### Translations
- Use `__()` function over `@lang`

## API Design
- Plural resource names: `/errors`
- Use kebab-case: `/error-occurrences`
- Limit deep nesting:
  ```
  /error-occurrences/1
  /errors/1/occurrences
  ```

## Testing
- Keep test classes in same file when possible
- Use descriptive test method names
- Follow arrange-act-assert pattern

## Quick Reference

### Naming Conventions
- **Classes**: PascalCase (`UserController`, `OrderStatus`)
- **Methods/Variables**: camelCase (`getUserName`, `$firstName`) 
- **Routes**: kebab-case (`/open-source`)
- **Config files**: kebab-case (`pdf-generator.php`)
- **Config keys**: snake_case (`chrome_path`)
- **Commands**: kebab-case (`delete-old-records`)

### File Structure
- **Controllers**: `PostsController` (plural + Controller)
- **Views**: `openSource.blade.php` (camelCase)
- **Jobs**: `CreateUser` (action-based)
- **Events**: `UserRegistered` (past tense)
- **Listeners**: `SendInvitationMailListener` (action + Listener)
- **Commands**: `PublishScheduledPostsCommand` (action + Command)
- **Mailables**: `AccountActivatedMail` (purpose + Mail)
- **Resources**: `UsersResource` (plural + Resource)
- **Enums**: `OrderStatus` (descriptive, no prefix)

### Migrations
- Only write `up()` methods, no `down()` methods

### Code Quality Checklist
- Use typed properties over docblocks
- Prefer early returns over nested if/else
- Use constructor property promotion when possible
- Avoid `else` statements
- Use string interpolation over concatenation
- Always use curly braces for control structures
