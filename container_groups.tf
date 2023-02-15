# file for create container instances of lab
resource "azurerm_container_group" "main" {
  name                = "sample-monitor-stack"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "Public"
  dns_name_label      = "aci-${lower(random_id.storage_account.hex)}"
  os_type             = "Linux"
  exposed_port = [
    {
      port     = 9090
      protocol = "TCP"
    },
    {
      port     = 3000
      protocol = "TCP"
    }
  ]

  container {
    name   = "prometheus"
    image  = "prom/prometheus:latest"
    cpu    = "1.0"
    memory = "1.5"
    environment_variables = {
      TZ = "America/Sao_Paulo"
    }

    commands = [
      "/bin/prometheus",
      "--config.file=/etc/prometheus/prometheus.yml",
      "--storage.tsdb.path=/etc/prometheus/data",
      "--storage.tsdb.retention.time=200h",
      "-web.enable-lifecycle"
    ]

    ports {
      port     = 9090
      protocol = "TCP"
    }

    volume {
      name                 = "prometheus"
      mount_path           = "/etc/prometheus/"
      share_name           = "prometheus"
      storage_account_name = azurerm_storage_account.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
      read_only            = false
    }
  }

  container {
    name   = "grafana"
    image  = "grafana/grafana:latest"
    cpu    = "1.0"
    memory = "1.5"
    environment_variables = {
      TZ = "America/Sao_Paulo"
    }

    ports {
      port     = 3000
      protocol = "TCP"
    }

    volume {
      name                 = "grafana"
      mount_path           = "/var/lib/grafana"
      share_name           = "grafana"
      read_only            = false
      storage_account_name = azurerm_storage_account.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
    }
  }

  tags = {
    environment = "terraform-monitor-stack"
  }

  depends_on = [
    azurerm_resource_group.main,
    azurerm_storage_account.main
  ]
}
