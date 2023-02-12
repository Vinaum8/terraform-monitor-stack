resource "azurerm_resource_group" "main" {
    name = "rg-terraform-monitor-stack"
    location = var.location
}

resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_storage_account" "main" {
    name = "stg${lower(random_id.storage_account.hex)}"
    account_tier = "Standard"
    account_replication_type = "LRS"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    depends_on = [
      azurerm_resource_group.main,
      random_id.storage_account
    ]
}

resource "azurerm_storage_share" "stg_files_prometheus" {
  name                 = "prometheus"
  storage_account_name = azurerm_storage_account.main.name
  quota = 10
  depends_on           = [azurerm_storage_account.main]
}

resource "azurerm_storage_share_file" "prometheus_config_file" {
  name = "prometheus.yml"
  storage_share_id = azurerm_storage_share.stg_files_prometheus.id
  source = "./prometheus/prometheus.yml"  
}

resource "azurerm_storage_share" "stg_files_grafana" {
  name                 = "grafana"
  storage_account_name = azurerm_storage_account.main.name
  quota = 10
  depends_on           = [azurerm_storage_account.main]
}