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
  description = <<EOF
List of ports configuration including:
  `port`     - The port number to expose
  `protocol` - The protocol for the port (TCP or UDP)
EOF
  default     = []
}

variable "os_type" {
  type        = string
  description = "OS type for the container group"
  default     = "Linux"
}

variable "containers" {
  type = list(object({
    name                   = string
    image                  = string
    tag                    = string
    dockerfile_type        = optional(string, null)
    custom_dockerfile_path = optional(string)
    cpu                    = number
    memory                 = number
    ports = optional(list(object({
      port     = number
      protocol = string
    })), [])
    environment_variables        = optional(map(string), {})
    secure_environment_variables = optional(map(string), {})
  }))
  description = <<EOF
List of container configurations including:
  `name`                   - Name of the container instance
  `image`                  - Container image to use
  `tag`                    - Image tag
  `dockerfile_type`        - (Optional) Type of dockerfile to use
  `custom_dockerfile_path` - (Optional) Path to custom dockerfile
  `cpu`                    - Number of CPU cores
  `memory`                 - Memory in GB
  `ports`                  - (Optional) List of ports configuration containing:
    `port`                 - The port number to expose
    `protocol`            - The protocol for the port (TCP or UDP)
  `environment_variables`  - (Optional) Map of non-sensitive environment variables
  `secure_environment_variables` - (Optional) Map of sensitive environment variables
EOF
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

variable "container_registry" {
  type = object({
    id              = string
    name            = string
    login_server    = string
    admin_username  = string
    admin_password  = string
    principal_id    = string
  })
  description = <<EOF
Container registry configuration object including:
  `id`              - The resource ID of the container registry.
  `name`            - The name of the container registry.
  `login_server`    - The login server URL for the container registry.
  `admin_username`  - The username used for admin access.
  `admin_password`  - The password used for admin access.
  `principal_id`    - The principal ID used for role assignments.
EOF
}
