# Azure Terraform Development Guidelines

## Code Structure
- Use consistent file naming: `main.tf`, `variables.tf`, `outputs.tf`, `provider.tf`, `locals.tf`
- Organize resources by Azure service or component
- Implement resource grouping by lifecycle and dependencies
- Use modules for reusable components

## Naming Conventions
- Resources: `<prefix>-<environment>-<location>-<service>-<suffix>`
  - prefix: org or project identifier (e.g., 'az', 'contoso')
  - environment: dev, qa, uat, prod
  - location: Azure region shortcode (e.g., 'eus2')
  - service: Azure service shortname (e.g., 'vnet', 'kv', 'vwan')
  - suffix: optional identifier (e.g., '01', 'primary')
- Variables: descriptive, lowercase with underscores
- Modules: terraform-azurerm-<service>
- Tags: follow Azure CAF tagging standards
  - environment
  - projectName
  - businessUnit
  - owner
  - costCenter

## Best Practices
- Pin azurerm provider version
- Use data sources for existing Azure resources
- Implement backend configuration for state management
- Add detailed variable validation rules
- Use locals for naming conventions and tag maps
- Follow Microsoft CAF naming standards
- Implement proper dependencies using depends_on

## Security
- Use Azure RBAC and Managed Identities
- Store secrets in Azure Key Vault
- Implement network security groups with proper rules
- Use Azure Private Endpoints where possible
- Follow Azure security baseline

## Documentation
- Add meaningful comments for complex logic
- Document all variables with type, description and example
- Include module usage examples in README
- Document outputs and their purpose
- Maintain versions in CHANGELOG.md
- Add prereqs and requirements section

## Testing
- Test with terraform plan
- Validate against different environments
- Use terratest for integration testing
- Implement pre-commit hooks for format and validation
- Test module with different input combinations
