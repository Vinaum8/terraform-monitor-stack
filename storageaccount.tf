resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_resource_group" "main" {
  name     = "rg-terraform-monitor-stack-${lower(random_id.storage_account.hex)}"
  location = var.location
}

resource "azurerm_storage_account" "main" {
  name                     = "stg${lower(random_id.storage_account.hex)}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name

  depends_on = [
    azurerm_resource_group.main,
    random_id.storage_account
  ]
}

resource "azurerm_storage_share" "stg_files_prometheus" {
  name                 = "prometheus"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 10
  depends_on           = [azurerm_storage_account.main]
}

resource "azurerm_storage_share_file" "prometheus_config_file" {
  name             = "prometheus.yml"
  storage_share_id = azurerm_storage_share.stg_files_prometheus.id
  source           = "./prometheus/prometheus.yml"
}

resource "azurerm_storage_share_file" "prometheus_alert_rules" {
  name             = "alert.rules"
  storage_share_id = azurerm_storage_share.stg_files_prometheus.id
  source           = "./prometheus/alert.rules"
}

resource "azurerm_storage_share" "stg_files_grafana" {
  name                 = "grafana"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 10
  depends_on           = [azurerm_storage_account.main]
}

resource "azurerm_storage_share" "stg_files_grafana_dashboards" {
  name                 = "dashboards"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 10
  depends_on           = [azurerm_storage_account.main]
}

resource "azurerm_storage_share_file" "dashboards" {
  name             = "dashboard.yaml"
  source           = "./grafana/provisioning/dashboards/dashboard.yaml"
  storage_share_id = azurerm_storage_share.stg_files_grafana_dashboards.id
}

resource "azurerm_storage_share" "stg_files_grafana_datasources" {
  name                 = "datasources"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 10
  depends_on           = [azurerm_storage_account.main]
}

resource "azurerm_storage_share_file" "datasources" {
  name             = "datasources.yaml"
  source           = "./grafana/provisioning/datasources/datasources.yaml"
  storage_share_id = azurerm_storage_share.stg_files_grafana_datasources.id
}


resource "azurerm_storage_share" "stg_nginx_fileshare" {
  name                 = "nginx"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 10
  depends_on           = [azurerm_storage_account.main]
}

resource "azurerm_storage_share_file" "nginx_config" {
  name             = "nginx.conf"
  source           = "./nginx/nginx.config"
  storage_share_id = azurerm_storage_share.stg_nginx_fileshare.id
}
