data "azurerm_client_config" "current" {}

locals {
  available_dockerfiles = {
    terraform = "${path.module}/Dockerfile.linux_terraform"
    python    = "${path.module}/Dockerfile.linux_python"
    java      = "${path.module}/Dockerfile.linux_java"
    dotnet    = "${path.module}/Dockerfile.linux_dotnet"
  }

  containers = [
    for container in var.containers : {
      dockerfile_path = container.custom_dockerfile_path != null ? container.custom_dockerfile_path : (
        container.dockerfile_type != null ? (
          contains(keys(local.available_dockerfiles), container.dockerfile_type)
          ? lookup(local.available_dockerfiles, container.dockerfile_type)
          : fail("Invalid dockerfile_type for container ${container.name}. Valid options are: ${join(", ", keys(local.available_dockerfiles))}")
        ) : fail("Either a custom_dockerfile_path or a valid dockerfile_type must be provided for container ${container.name}")
      )
      image = container.image
      tag   = container.tag
      content_hash = sha256(join("", [
        file(
          container.custom_dockerfile_path != null ? container.custom_dockerfile_path :
          lookup(local.available_dockerfiles, container.dockerfile_type, "")
        ),
        var.agent_version,
        var.target_arch
      ]))
    }
  ]
}

resource "azurerm_role_assignment" "acr_pull" {
  count                = var.create_registry ? 1 : 0
  scope                = var.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_client_config.current.object_id

}

resource "time_sleep" "timer" {
  depends_on      = [azurerm_role_assignment.acr_pull]
  create_duration = "10s"
}

resource "null_resource" "build_and_push_image" {
  for_each = { for c in local.containers : c.image => c }

  triggers = {
    content_hash = each.value.content_hash
  }
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOT
      az acr build \
        --registry ${var.container_registry.name} \
        --image ${format("%s:%s", each.value.image, each.value.content_hash)} \
        --file '${each.value.dockerfile_path}' \
        --build-arg AGENT_VERSION=${var.agent_version} \
        --build-arg TARGETARCH=${var.target_arch} \
        "$(dirname '${each.value.dockerfile_path}')"
      EOT
  }

  depends_on = [time_sleep.timer]
}

resource "azurerm_container_group" "cg" {
  name                = var.container_group_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  ip_address_type     = "Private"
  subnet_ids          = [var.subnet_id]

  dynamic "exposed_port" {
    for_each = var.exposed_ports
    content {
      port     = exposed_port.value.port
      protocol = exposed_port.value.protocol
    }
  }

  image_registry_credential {
    server   = var.container_registry.login_server
    username = var.container_registry.admin_username
    password = var.container_registry.admin_password
  }

  dynamic "container" {
    for_each = var.containers
    content {
      name = container.value.name
      image = format("%s/%s:%s", var.container_registry.login_server, container.value.image,
      [for c in local.containers : c.content_hash if c.image == container.value.image][0])
      cpu    = container.value.cpu
      memory = container.value.memory

      dynamic "ports" {
        for_each = container.value.ports
        content {
          port     = ports.value.port
          protocol = ports.value.protocol
        }
      }

      environment_variables = container.value.environment_variables
      secure_environment_variables = container.value.secure_environment_variables
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = var.log_analytics_workspace_id
      workspace_key = var.log_analytics_workspace_key
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    replace_triggered_by = [null_resource.build_and_push_image]
  }

  tags = var.tags

  depends_on = [null_resource.build_and_push_image]
}

resource "azurerm_role_assignment" "acr_pull_ca" {
  scope                = var.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_group.cg.identity[0].principal_id
}
