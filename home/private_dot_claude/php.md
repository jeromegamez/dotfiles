# PHP Guidelines

## Project Detection & Rules

Load additional instructions based on project type:

- **Laravel**: Apply `~/.claude/laravel.md` (Laravel takes priority)


## Core Principles
- Use dependency injection over static methods
- Keep methods under 20 lines with single responsibility
- Use repository pattern and value objects for complex domains

## Conventions

### PHP Standards
- Follow PSR-1, PSR-2, PSR-12, and PER standards
- Follow PSR-4 autoloading conventions
- Use camelCase for internal strings
- Short nullable syntax: `?string` not `string|null`
- Always specify `void` return types
- Use strict typing: `declare(strict_types=1);`

### Class Structure
- Use typed properties over docblocks
- Use constructor property promotion when all properties can be promoted
- One trait per line

### Type Declarations & Docblocks
- Use typed properties over docblocks
- Specify return types including `void`
- Short nullable syntax: `?Type` not `Type|null`
- Document iterables with generics: `/** @return Collection<int, User> */`
- Prefer PHPStan annotations over runtime checks

#### Docblock Rules
- Skip docblocks for fully type-hinted methods (unless description needed)
- **Always import classnames** - never use fully qualified names in docblocks
- Use one-line format when possible: `/** @var string */`
- Put most common type first in unions: `/** @var Collection|SomeWeirdCollection */`
- Add docblocks only for parameters that need it
- Specify key/value types for iterables: `@param array<array-key, MyObject> $items`
- Use array shapes for fixed keys (one key per line):
  ```php
  /** @return array{
     first: SomeClass,
     second: SomeClass
  } */
  ```

### Control Flow
- **Happy path last**: Handle errors first, success last
- **Avoid else**: Use early returns over nested conditions
- **Separate conditions**: Multiple if statements over compound conditions
- **Always use curly brackets** even for single statements
- **Ternary operators**: Multi-line unless very short

```php
// Happy path last
if ($falsyCondition) {
    return null;
}

// Short ternary
$var = $isFoo ? 'foo' : 'bar';

// Multi-line ternary
$result = $object instanceof MyObject
    ? $object->property
    : 'A default value';
```


## Best Practices

### Tools Integration
- Use `vendor/bin/rector` for automated refactoring (ignore output)
- Use `vendor/bin/php-cs-fixer` for code style formatting (ignore output)
- Run Rector first, then PHP CS Fixer
- Run `vendor/bin/phpstan` for static analysis before completion
