<!-- BEGIN_TF_DOCS -->
<!-- TOC -->
<!-- /TOC -->

# Azure DevOps Agent Container Module

This Terraform module provides a framework for deploying self-hosted Azure DevOps agents using Azure Container Instances. It simplifies the deployment of containerized build agents, ensuring they are secure, scalable, and integrated with Azure Container Registry.

## Purpose

The module's main objective is to streamline the provisioning of containerized Azure DevOps agents, making it easy to deploy and manage custom build agents that run in Azure Container Instances. This enables teams to run their CI/CD pipelines in a controlled, isolated environment with specific tooling requirements.

## Key Capabilities

- **Azure Container Registry Integration**  
  Automatically creates or uses an existing Azure Container Registry, builds container images, and manages access credentials.

- **Configurable Container Groups**  
  Deploy multiple container groups with different configurations, supporting various build environments (.NET, Java, etc.).

- **Private Network Integration**  
  Deploy agents into existing virtual networks for enhanced security and access to private resources.

- **Monitoring and Logging**  
  Integration with Azure Monitor and Log Analytics for comprehensive container insights and troubleshooting.

## Implementation Details

The module implements a secure approach to container deployment. Each container group runs in a private subnet and uses managed identities for accessing Azure Container Registry. Container images are built and stored in ACR, ensuring consistent and reliable agent deployments.

### Architecture Overview

The module deploys container groups into your virtual network, allowing them to access both internal resources and Azure DevOps services. Each container group can host multiple containers, enabling you to run different types of build agents based on your needs.

### Best Practices

When deploying agents, consider:
- Using separate container groups for different build requirements
- Implementing proper network segmentation
- Managing secrets through secure environment variables
- Monitoring agent performance and scaling as needed
- Regular updates of base images and tooling

## Diagnostic Settings

Container insights are routed to Log Analytics, providing visibility into:
- Container health and performance
- Agent connection status
- Build job execution
- Network connectivity issues

## Known Limitations

- Container groups must be deployed into subnets with the Microsoft.ContainerInstance/containerGroups delegation
- Azure Container Registry Basic SKU is used by default
- Windows containers require specific subnet configurations
- Container groups are limited to the resources specified during creation

## Usage Example

```hcl
module "ado_agents" {
  source = "github.com/example/terraform-azurerm-azure-devops-agent"

  resource_group_name      = "rg-ado-agents"
  location                = "eastus"
  container_registry_name = "acrdevops"
  container_groups = {
    "dotnet" = {
      name                = "dotnet-agents"
      resource_group_name = "rg-ado-agents"
      location           = "eastus"
      subnet_id          = "/subscriptions/.../subnets/agents"
      containers = [
        {
          name            = "dotnet-agent"
          image           = "dotnet-agent"
          tag             = "latest"
          dockerfile_path = "./Dockerfile.dotnet"
          cpu             = 2
          memory          = 4
          ports          = []
          environment_variables = {
            AZP_POOL = "Default"
          }
        }
      ]
    }
  }

  log_analytics_workspace_id  = "/subscriptions/.../workspaces/law"
  log_analytics_workspace_key = "workspace-key"
}
```

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement_terraform) (>=1.5.0, <2.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) (>= 4.12.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) (>= 4.12.0)

- <a name="provider_null"></a> [null](#provider_null)

- <a name="provider_time"></a> [time](#provider_time)

## Resources

The following resources are used by this module:

- [azurerm_container_group.cg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) (resource)
- [azurerm_role_assignment.acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.acr_pull_ca](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [null_resource.build_and_push_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
- [time_sleep.timer](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_container_group_name"></a> [container_group_name](#input_container_group_name)

Description: Name of the container group

Type: `string`

### <a name="input_container_registry_name"></a> [container_registry_name](#input_container_registry_name)

Description: The name of the container registry.

Type: `string`

### <a name="input_containers"></a> [containers](#input_containers)

Description: List of containers to deploy in the container group

Type:

```hcl
list(object({
    name            = string
    image           = string
    tag             = string
    dockerfile_path = string
    cpu             = number
    memory          = number
    ports = optional(list(object({
      port     = number
      protocol = string
    })), [])
    environment_variables        = optional(map(string), {})
    secure_environment_variables = optional(map(string), {})
  }))
```

### <a name="input_location"></a> [location](#input_location)

Description: The Azure region where the container registry will be deployed.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log_analytics_workspace_id](#input_log_analytics_workspace_id)

Description: The ID of the Log Analytics workspace to send diagnostics data

Type: `string`

### <a name="input_log_analytics_workspace_key"></a> [log_analytics_workspace_key](#input_log_analytics_workspace_key)

Description: The shared key of the Log Analytics workspace

Type: `string`

### <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)

Description: The name of the resource group in which to create the container registry.

Type: `string`

### <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id)

Description: The ID of the subnet where the container group will be placed

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_agent_version"></a> [agent_version](#input_agent_version)

Description: Version of the Azure DevOps agent to install

Type: `string`

Default: `"4.251.0"`

### <a name="input_create_registry"></a> [create_registry](#input_create_registry)

Description: Boolean flag to create the container registry.

Type: `bool`

Default: `true`

### <a name="input_exposed_ports"></a> [exposed_ports](#input_exposed_ports)

Description: List of ports to expose on the container group

Type:

```hcl
list(object({
    port     = number
    protocol = string
  }))
```

Default: `[]`

### <a name="input_os_type"></a> [os_type](#input_os_type)

Description: OS type for the container group

Type: `string`

Default: `"Linux"`

### <a name="input_powershell"></a> [powershell](#input_powershell)

Description: Boolean flag to use PowerShell for commands, defaults to Bash

Type: `bool`

Default: `false`

### <a name="input_target_arch"></a> [target_arch](#input_target_arch)

Description: Architecture of the agent to install

Type: `string`

Default: `"linux-x64"`

## Outputs

The following outputs are exported:

### <a name="output_container_group"></a> [container_group](#output_container_group)

Description: The ID of the Container Group
<!-- END_TF_DOCS -->