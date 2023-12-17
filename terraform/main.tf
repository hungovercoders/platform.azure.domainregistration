resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.region
  tags     = local.tags
}

resource "azurerm_eventhub_namespace" "ehns" {
  name                = local.eventhub_namespace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1
  tags                = local.tags
}

resource "azurerm_storage_account" "data_lake" {
  for_each = local.unique_domains

  name                     = each.value # Naming the storage account based on the domain name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = "North Europe" # Replace with your desired location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  is_hns_enabled = true # Enable Hierarchical Namespace for Data Lake Storage Gen2

  # Add other necessary configurations as needed
}

resource "azurerm_eventhub" "example" {
  for_each = { for eh in local.flattened_eventhubs : eh.name => eh }

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.ehns.name # Adjust accordingly
  resource_group_name = azurerm_resource_group.rg.name       # Adjust accordingly
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
}

resource "azurerm_eventhub_consumer_group" "example" {
  for_each = { for cg in local.flattened_consumer_groups : "${cg.eventhub_name}-${cg.consumer_group}" => cg }

  name                = each.value.consumer_group
  eventhub_name       = each.value.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.ehns.name # Adjust accordingly
  resource_group_name = azurerm_resource_group.rg.name       # Adjust accordingly
}
