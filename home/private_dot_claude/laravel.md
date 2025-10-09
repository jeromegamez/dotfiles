# Laravel Guidelines

## Core Principles
**Follow Laravel conventions first.** Use Laravel's documented approach unless you have clear justification to deviate.

*Note: This file contains Laravel-specific overrides. For general PHP guidelines, see `php.md`.*

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


## Best Practices

### Laravel-Specific Formatting
- Use string interpolation in Blade: `{{ $user->name }}`
- Blade directives: no spaces after `@`: `@if($condition)`
- Method chaining: one method per line for Eloquent queries

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

### Blade Templates
- Indent with 4 spaces
- No spaces after control structures: `@if($condition)`
- Use `__()` function over `@lang`
- Component naming: kebab-case (`<x-user-card />`)

### Authorization
- Policies use camelCase: `Gate::define('editPost', ...)`
- Use CRUD words, but `view` instead of `show`

## API Design
- Plural resource names: `/errors`
- Use kebab-case: `/error-occurrences`
- Limit deep nesting:
  ```
  /error-occurrences/1
  /errors/1/occurrences
  ```

## Laravel-Specific File Structure
- **Controllers**: `PostsController` (plural + Controller)
- **Models**: `User` (singular)
- **Views**: `openSource.blade.php` (camelCase)
- **Jobs**: `CreateUser` (action-based)
- **Events**: `UserRegistered` (past tense)
- **Listeners**: `SendInvitationListener` (action + Listener)
- **Commands**: `PublishScheduledPostsCommand` (action + Command)
- **Mailables**: `AccountActivatedMail` (purpose + Mail)
- **Resources**: `UsersResource` (plural + Resource)
- **Migrations**: Only write `up()` methods, no `down()` methods

## Laravel-Specific Testing
- Use Feature tests for HTTP endpoints
- Use Unit tests for isolated logic
- Use `RefreshDatabase` trait for database tests
