# Terraform Guidelines

## Core Standards
- Use snake_case for resource names
- Group related resources in logical modules
- Always include `required_providers` block with version constraints
- Use data sources instead of hardcoded values
- Include meaningful descriptions for variables and outputs
- Use locals for computed values and complex expressions

## Module Structure
- `main.tf` - resource definitions
- `variables.tf` - input variables
- `outputs.tf` - outputs
- `versions.tf` - provider versions and Terraform version requirements

## Deployment Safety
- Always validate plans before suggesting apply
- Check for environment-specific variables
- Verify resource dependencies and state implications
- Consider security implications of changes
- Test in development environment first
