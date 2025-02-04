Use the naming pattern `<prefix>-<environment>-<location>-<service>-<suffix>` for name variables in root workspaces.
Add detailed variable validation rules.
Utilize format and other Hashicorp functions where applicable. Do not write strings with interpolation.
Store secrets in Azure Key Vault when creating resources with secrets.
Group Terraform resources by service or logical component for clarity.
Include mandatory tags: environment, projectName, businessUnit, owner, and costCenter.
Use locals to define common values and tag maps consistently.
Document non-obvious logic with inline comments; avoid commenting trivial details.
Provide usage examples in `README.md` for different deployment scenarios.
Suggest role management for resources where applicable.
Suggest logging diagnostisc for resources where applicable.
Ensure documentation is up-to-date and accurate in edition to providing a generous set of details.
Provide suggestions for improving code in question where able.
