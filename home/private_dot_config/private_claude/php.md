# PHP Guidelines

## Core Principles
- Use strict typing: `declare(strict_types=1);`
- Follow PSR-4 autoloading conventions
- Use typed properties, return types, and parameters
- Prefer early returns over nested conditionals
- Use dependency injection over static methods
- Keep methods under 20 lines with single responsibility
- Use repository pattern and value objects for complex domains
- Prefer PHPStan annotations over runtime checks

## Tools Integration
- Use `vendor/bin/rector` for automated refactoring (ignore output)
- Use `vendor/bin/php-cs-fixer` for code style formatting (ignore output)
- Run Rector first, then PHP CS Fixer
- Run `vendor/bin/phpstan` for static analysis before completion
