output "ip_address" {
  value = azurerm_container_group.main.ip_address
}

#the dns fqdn of the container group if dns_name_label is set
output "fqdn" {
  value = azurerm_container_group.main.fqdn
}

output "http-grafana" {
  value = "http://${azurerm_container_group.main.fqdn}:3000/"
}

output "http-prometheus" {
  value = "http://${azurerm_container_group.main.fqdn}:9090/"
}
