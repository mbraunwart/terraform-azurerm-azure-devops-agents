variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the container registry."
}

variable "location" {
  type        = string
  description = "The Azure region where the container registry will be deployed."
}

variable "create_registry" {
  type        = bool
  description = "Boolean flag to create the container registry."
  default     = true
}

variable "container_registry_name" {
  type        = string
  description = "The name of the container registry."
}

variable "agent_version" {
  description = "Version of the Azure DevOps agent to install"
  type        = string
  default     = "4.251.0"
}

variable "target_arch" {
  description = "Architecture of the agent to install"
  type        = string
  default     = "linux-x64"
}

variable "container_group_name" {
  type        = string
  description = "Name of the container group"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the container group will be placed"
}

variable "exposed_ports" {
  type = list(object({
    port     = number
    protocol = string
  }))
  description = "List of ports to expose on the container group"
  default     = []
}

variable "os_type" {
  type        = string
  description = "OS type for the container group"
  default     = "Linux"
}

variable "containers" {
  type = list(object({
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
  description = "List of containers to deploy in the container group"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics workspace to send diagnostics data"
}

variable "log_analytics_workspace_key" {
  type        = string
  description = "The shared key of the Log Analytics workspace"
  sensitive   = true
}

variable "powershell" {
  description = "Boolean flag to use PowerShell for commands, defaults to Bash"
  type        = bool
  default     = false
}
