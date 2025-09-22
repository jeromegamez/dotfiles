# Terraform Guidelines

## Project Detection & Rules

Load additional instructions based on project type:

- **Terragrunt**: Apply `~/.claude/terragrunt.md` (Terragrunt takes priority)

## Core Principles
- Infrastructure as Code: All infrastructure should be version-controlled and reproducible
- Immutable infrastructure: Replace rather than modify resources when possible
- Use snake_case for resource names and consistent naming conventions
- Group related resources in logical modules for reusability
- Always include meaningful descriptions for variables and outputs

## Conventions

### Module Structure
- `main.tf` - primary resource definitions
- `variables.tf` - input variables with descriptions and validation
- `outputs.tf` - output values for module consumers
- `versions.tf` - provider versions and Terraform version requirements
- `locals.tf` - local values for computed expressions (optional)

### Naming Conventions
- **Resources**: snake_case (`aws_s3_bucket.data_lake`)
- **Variables**: snake_case with descriptive names (`database_instance_class`)
- **Outputs**: snake_case describing what is returned (`vpc_id`, `database_endpoint`)
- **Tags**: PascalCase for consistency with AWS conventions

### Code Organization
```terraform
# versions.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# variables.tf
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# locals.tf
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
```

## Best Practices

### State Management
- Use remote state backends (S3 + DynamoDB for locking)
- Never commit state files to version control
- Use separate state files for different environments
- Enable state file encryption and versioning

### Resource Management
- Use data sources instead of hardcoded values
- Implement proper resource dependencies with explicit `depends_on` when needed
- Use lifecycle rules to prevent accidental resource destruction
- Tag all resources consistently for cost tracking and management
- Create `moved` blocks when renaming resources

### Security
- Store sensitive values in encrypted parameter stores or secrets managers
- Use least-privilege IAM policies
- Enable logging and monitoring for infrastructure changes
- Scan Terraform code for security issues before deployment

### Module Development
- Create reusable modules for common patterns
- Version your modules and use semantic versioning
- Include comprehensive examples and documentation
- Use variable validation to catch errors early

### Variable Management
```terraform
# Good: Descriptive with validation
variable "database_instance_class" {
  description = "RDS instance class for the database"
  type        = string
  default     = "db.t3.micro"
  
  validation {
    condition = can(regex("^db\\.", var.database_instance_class))
    error_message = "Database instance class must start with 'db.'."
  }
}

# Good: Complex types with clear structure
variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public           = bool
  }))
}
```

## Deployment Safety

### Pre-deployment Checks
- Always run `terraform plan` and review changes carefully
- Validate configuration with `terraform validate`
- Use `terraform fmt` to ensure consistent formatting
- Check for security issues with tools like `tfsec` or `checkov`

### Environment Management
- Use workspaces or separate directories for different environments
- Implement approval processes for production changes
- Use CI/CD pipelines for consistent deployments
- Maintain separate variable files for each environment

### Error Prevention
- Use `prevent_destroy` lifecycle rule for critical resources
- Implement proper backup strategies before major changes
- Test changes in development environment first
- Use `import` to bring existing resources under Terraform management

## Recommended MCPs
- **Serena**: Excellent for navigating large terraform codebases, understanding module dependencies, and semantic code analysis across HCL files
- **Sequential Thinking**: Helpful for multi-environment deployments and debugging terraform state issues

## Quick Reference

### Common Commands
```bash
# Initialize and plan
terraform init
terraform plan -var-file="environments/prod.tfvars"

# Apply with approval
terraform apply -var-file="environments/prod.tfvars"

# Validate and format
terraform validate
terraform fmt -recursive

# State management
terraform state list
terraform import aws_instance.example i-1234567890abcdef0

# Workspace management
terraform workspace new production
terraform workspace select production
```

### File Structure
```
project/
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── modules/
│   ├── vpc/
│   ├── database/
│   └── compute/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── terraform.tfvars.example
```

### Resource Lifecycle
```terraform
resource "aws_instance" "example" {
  # ... configuration ...
  
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [ami]
    create_before_destroy = true
  }
  
  tags = local.common_tags
}
