# file for create container instances of lab
resource "azurerm_container_group" "main" {
  name                = "sample-monitor-stack-${lower(random_id.storage_account.hex)}"
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
    name   = "nginx"
    image  = "nginx"
    cpu    = "0.1"
    memory = "0.5"
    environment_variables = {
      TZ = "America/Sao_Paulo"
    }

    ports {
      port     = 80
      protocol = "TCP"
    }

    ports {
      port     = 8080
      protocol = "TCP"
    }

    ports {
      port     = 443
      protocol = "TCP"
    }

    volume {
      name                 = "nginx"
      mount_path           = "/etc/nginx/"
      share_name           = "nginx"
      read_only            = false
      storage_account_name = azurerm_storage_account.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
    }
  }

  container {
    name   = "nginx-prometheus-exporter"
    image  = "nginx/nginx-prometheus-exporter"
    cpu    = "0.1"
    memory = "0.5"
    environment_variables = {
      TZ = "America/Sao_Paulo"
    }

    commands = [
      "-nginx.scrape-uri=http://localhost:8080/stub_status"
    ]
  }

  container {
    name   = "busybox"
    image  = "busybox"
    cpu    = "0.1"
    memory = "0.5"
    environment_variables = {
      TZ = "America/Sao_Paulo"
    }
  }

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
      "--config.file=/etc/prometheus/prometheus.yml"
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

    volume {
      name                 = "dashboards"
      mount_path           = "/etc/grafana/provisioning/dashboards/"
      share_name           = "dashboards"
      read_only            = false
      storage_account_name = azurerm_storage_account.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
    }

    volume {
      name                 = "datasources"
      mount_path           = "/etc/grafana/provisioning/datasources/"
      share_name           = "datasources"
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
