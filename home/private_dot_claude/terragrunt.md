# Terragrunt Guidelines

## Core Principles
- DRY (Don't Repeat Yourself): Use Terragrunt to eliminate code duplication across environments
- Keep your Terraform code DRY and use Terragrunt for environment-specific configurations
- Use hierarchical configuration inheritance from parent to child directories
- Centralize backend configuration and provider requirements
- Follow consistent directory structure across all environments

## Conventions

### Directory Structure
```
project/
├── infrastructure/
│   ├── root.hcl                # Root configuration
│   ├── environments/
│   ├── dev/
│   │   ├── terragrunt.hcl      # Environment config
│   │   ├── vpc/
│   │   │   └── terragrunt.hcl  # Component config
│   │   └── database/
│   │       └── terragrunt.hcl
│   ├── staging/
│   │   └── ...
│   └── prod/
│       └── ...
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── database/
        └── ...
```

### Configuration Hierarchy
- **Root root.hcl**: Global settings, backend config, provider versions
- **Environment terragrunt.hcl**: Environment-specific variables and settings
- **Component terragrunt.hcl**: Module-specific configuration and dependencies

### Naming Conventions
- **Directories**: kebab-case (`web-servers`, `load-balancers`)
- **Variables**: snake_case following Terraform conventions
- **Environments**: lowercase (`dev`, `staging`, `prod`)
- **Configuration files**: `root.hcl` for root, `terragrunt.hcl` for components

### File Organization
```hcl
# infrastructure/root.hcl
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "my-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# Multi-cloud provider generation
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Add other cloud providers as needed:
    # azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
    # google  = { source = "hashicorp/google", version = "~> 4.0" }
    # Example third-party providers:
    # mongodbatlas = { source = "mongodb/mongodbatlas", version = "~> 1.0" }
  }
}

# Configure primary cloud provider
provider "aws" {
  region = var.region
}

# Configure additional providers as needed
EOF
}
```

## Recommended MCPs
- **Serena**: Excellent for navigating complex terragrunt hierarchies, understanding module relationships across environments, and semantic analysis of HCL configurations
- **Sequential Thinking**: Essential for debugging terragrunt dependency chains and planning infrastructure rollouts

## Best Practices

### Configuration Management
- Use `include` blocks to inherit parent configurations
- Use `dependency` blocks for cross-component dependencies
- Store sensitive values in AWS Parameter Store or similar
- Use `locals` for computed values within Terragrunt configs
- Avoid duplicating configuration across environments

### Dependency Management
```hcl
# Component depending on VPC
dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id = "vpc-12345"
    private_subnet_ids = ["subnet-12345", "subnet-67890"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
}
```

### Environment Configuration
```hcl
# environments/prod/terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "prod"
  region      = "eu-central-1"
}

inputs = {
  environment                = local.environment
  region                    = local.region
  instance_count            = 3
  enable_monitoring         = true
  backup_retention_days     = 30
}
```

### Module References
- Always use versioned modules with Git tags
- Use relative paths for local modules
- Pin module versions in production environments
- Use `source` with Git URLs and ref parameters

```hcl
terraform {
  source = "git::https://github.com/myorg/terraform-modules.git//vpc?ref=v2.1.0"
  # Or for local modules:
  # source = "../../../modules/vpc"
}
```

### Input Management
- Use environment-specific input files
- Leverage `locals` for computed values
- Use `find_in_parent_folders()` for configuration discovery
- Implement proper variable validation in underlying Terraform modules

### Hook Integration
```hcl
terraform {
  before_hook "tflint" {
    commands = ["plan", "apply"]
    execute  = ["tflint"]
  }
  
  after_hook "notify" {
    commands     = ["apply"]
    execute      = ["echo", "Deployment completed for ${get_env("USER", "unknown")}"]
    run_on_error = false
  }
}
```

## Deployment Safety

### Pre-deployment Validation
- Always run `terragrunt plan-all` to see changes across all components
- Use `terragrunt validate-all` to check configuration syntax
- Implement approval workflows for production changes
- Use dependency graphs to understand change impact

### Environment Isolation
- Use separate AWS accounts or regions for different environments
- Implement proper IAM boundaries between environments
- Use different state buckets for each environment
- Test changes in development environments first

### Error Recovery
- Use `--terragrunt-ignore-dependency-errors` cautiously
- Implement proper backup strategies for state files
- Use `terragrunt state` commands for state management
- Keep module versions consistent across environments

### Secrets Management
```hcl
# Use AWS Parameter Store
inputs = {
  database_password = get_aws_ssm_parameter("/myapp/prod/db/password", "eu-central-1")
  api_keys = {
    external_service = get_aws_ssm_parameter("/myapp/prod/external/secret", "eu-central-1")
  }
}

# Use environment variables for non-sensitive config
inputs = {
  environment = get_env("ENVIRONMENT", "dev")
  debug_mode  = get_env("DEBUG", "false") == "true"
}
```

## Quick Reference

### Common Commands
```bash
# Initialize and plan all components
terragrunt init
terragrunt plan-all

# Apply specific component
cd environments/prod/vpc
terragrunt apply

# Apply all components with dependencies
terragrunt apply-all

# Validate all configurations
terragrunt validate-all

# Format all files
terragrunt hclfmt

# View dependency graph
terragrunt graph-dependencies | dot -Tpng > deps.png

# Destroy (careful!)
terragrunt destroy-all
```

### Configuration Patterns
```hcl
# Component terragrunt.hcl template
include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../modules/component-name"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region   = "eu-central-1"
}

dependency "prerequisite" {
  config_path = "../prerequisite"
}

inputs = merge(
  local.env_vars.inputs,
  {
    component_specific_var = "value"
    dependency_output     = dependency.prerequisite.outputs.some_value
  }
)
```

### Directory Layout Best Practices
- Group by environment first, then by component
- Keep related components in the same directory level
- Use consistent naming across all environments
- Separate infrastructure and application components
- Use shared modules directory for reusable Terraform code

### Debugging Tips
- Use `--terragrunt-log-level debug` for detailed logging
- Use `--terragrunt-debug` for even more verbose output
- Check dependency order with `terragrunt graph-dependencies`
- Use `terragrunt output-all` to see all outputs
- Use `terragrunt show-all` to see current state across components