terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-ado-agent"
  location = "East US"
}

module "vnet" {
  source = "github.com/mbraunwart/terraform-azurerm-networking.git"

  providers = {
    azurerm        = azurerm
    azurerm.shared = azurerm
    azurerm.prod   = azurerm
  }

  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  environment           = "sandbox"
  vnet_name             = "vnet-ado-agent"
  vnet_address_prefixes = ["10.0.0.0/16"] # Updated to proper CIDR block

  subnets = [
    {
      name             = "subnet-ado-agent"
      address_prefixes = ["10.0.1.0/24"] # Updated to proper CIDR block
      delegation = {
        name = "subnet-ado-agent-delegation"
        service_delegation = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  ]

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-ado-agent"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

locals {
  containers = {
    dotnet = {
      name            = "dotnet-ado-agent",
      subnet_id       = module.vnet.subnets["subnet-ado-agent"].id
      create_registry = true
      exposed_ports = [
        {
          port     = 443
          protocol = "TCP"
        }
      ]
      containers = [
        {
          name           = "dotnet-ado-agent"
          image          = "dotnet-ado-agent"
          tag            = "1.0"
          dockerfile_type = "dotnet"
          cpu            = 2.0
          memory         = 4
          ports = [
            {
              port     = 443
              protocol = "TCP"
            }
          ]
          secure_environment_variables = {
            AZP_TOKEN      = var.ado_pat
            AZP_URL        = "https://dev.azure.com/mrb-insight"
            AZP_POOL       = "container_pool"
            AZP_AGENT_NAME = "dotnet-ado-agent"
          }
        }
      ]
    },
    java = {
      name      = "java-ado-agent",
      subnet_id = module.vnet.subnets["subnet-ado-agent"].id
      exposed_ports = [
        {
          port     = 443
          protocol = "TCP"
        }
      ]
      containers = [
        {
          name           = "java-ado-agent"
          image          = "java-ado-agent"
          tag            = "1.0"
          dockerfile_type = "java"
          cpu            = 2.0
          memory         = 4
          ports = [
            {
              port     = 443
              protocol = "TCP"
            }
          ]
          secure_environment_variables = {
            AZP_TOKEN      = var.ado_pat
            AZP_URL        = "https://dev.azure.com/mrb-insight"
            AZP_POOL       = "container_pool"
            AZP_AGENT_NAME = "java-ado-agent"
          }
        }
      ]
    },
    # Example with custom Dockerfile
    custom = {
      name      = "custom-ado-agent",
      subnet_id = module.vnet.subnets["subnet-ado-agent"].id
      exposed_ports = [
        {
          port     = 443
          protocol = "TCP"
        }
      ]
      containers = [
        {
          name                   = "custom-ado-agent"
          image                  = "custom-ado-agent"
          tag                    = "1.0"
          custom_dockerfile_path = "./Dockerfile.custom_java"
          cpu                   = 2.0
          memory                = 4
          ports = [
            {
              port     = 443
              protocol = "TCP"
            }
          ]
          secure_environment_variables = {
            AZP_TOKEN      = var.ado_pat
            AZP_URL        = "https://dev.azure.com/mrb-insight"
            AZP_POOL       = "container_pool"
            AZP_AGENT_NAME = "custom-ado-agent"
          }
        }
      ]
    },
    terraform = {
      name      = "terraform-ado-agent",
      subnet_id = module.vnet.subnets["subnet-ado-agent"].id
      exposed_ports = [
        {
          port     = 443
          protocol = "TCP"
        }
      ]
      containers = [
        {
          name           = "terraform-ado-agent"
          image          = "terraform-ado-agent"
          tag            = "1.0"
          dockerfile_type = "terraform"
          cpu            = 2.0
          memory         = 4
          ports = [
            {
              port     = 443
              protocol = "TCP"
            }
          ]
          secure_environment_variables = {
            AZP_TOKEN      = var.ado_pat
            AZP_URL        = "https://dev.azure.com/mrb-insight"
            AZP_POOL       = "container_pool"
            AZP_AGENT_NAME = "terraform-ado-agent"
          }
        }
      ]
    },
    python = {
      name      = "python-ado-agent",
      subnet_id = module.vnet.subnets["subnet-ado-agent"].id
      exposed_ports = [
        {
          port     = 443
          protocol = "TCP"
        }
      ]
      containers = [
        {
          name           = "python-ado-agent"
          image          = "python-ado-agent"
          tag            = "1.0"
          dockerfile_type = "python"
          cpu            = 2.0
          memory         = 4
          ports = [
            {
              port     = 443
              protocol = "TCP"
            }
          ]
          secure_environment_variables = {
            AZP_TOKEN      = var.ado_pat
            AZP_URL        = "https://dev.azure.com/mrb-insight"
            AZP_POOL       = "container_pool"
            AZP_AGENT_NAME = "python-ado-agent"
          }
        }
      ]
    }
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "adoacrhb4"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

module "ado_agents" {
  for_each = local.containers
  source   = "../.."

  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  create_registry         = lookup(each.value, "create_registry", false)
  container_registry_name = azurerm_container_registry.acr.name
  container_group_name    = each.value.name
  subnet_id               = each.value.subnet_id

  containers = each.value.containers

  log_analytics_workspace_id  = azurerm_log_analytics_workspace.law.workspace_id
  log_analytics_workspace_key = azurerm_log_analytics_workspace.law.primary_shared_key

  depends_on = [module.vnet]
}

variable "ado_pat" {
  type        = string
  description = "The Azure DevOps personal access token."
  default     = ""
}
