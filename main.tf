data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "resource_group" {
  ### Purpose: Function APP - NAC_Discovery function - Storage Accont for Function SSA
  # name = var.service_name == "exp" ? var.exp_resource_group : var.acs_resource_group
  name = var.acs_resource_group
}
# SSA

########## START ::: Provision NAC_Discovery Function  #################

resource "random_id" "nac_unique_stack_id" {
  byte_length = 4
}

data "archive_file" "test" {
  type        = "zip"
  source_dir  = "./ACSFunction"
  output_path = var.output_path
}

data "azurerm_virtual_network" "VnetToBeUsed" {
  count               = var.use_private_acs == "Y" ? 1 : 0
  name                = var.user_vnet_name
  resource_group_name = var.networking_resource_group
}

data "azurerm_subnet" "azure_subnet_name" {
  count                = var.use_private_acs == "Y" ? 1 : 0
  name                 = var.user_subnet_name
  virtual_network_name = data.azurerm_virtual_network.VnetToBeUsed[0].name
  resource_group_name  = data.azurerm_virtual_network.VnetToBeUsed[0].resource_group_name
}

resource "azurerm_subnet" "discovery_outbound_subnet_name" {
  count                = var.use_private_acs == "Y" ? 1 : 0
  name                 = "outbound-vnetSubnet-${random_id.nac_unique_stack_id.hex}"
  virtual_network_name = data.azurerm_virtual_network.VnetToBeUsed[0].name
  resource_group_name  = data.azurerm_virtual_network.VnetToBeUsed[0].resource_group_name
  address_prefixes     = [var.discovery_outbound_subnet[0]]
  delegation {
    name = "serverFarms_delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "nac_subnet_name" {
  count                = var.use_private_acs == "Y" ? length(var.nac_subnet) : 0
  name                 = "vnetSubnets-${count.index}"
  resource_group_name  = data.azurerm_virtual_network.VnetToBeUsed[0].resource_group_name
  virtual_network_name = data.azurerm_virtual_network.VnetToBeUsed[0].name
  address_prefixes     = [var.nac_subnet[count.index]]

  delegation {
    name = "serverFarms_delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }

  depends_on = [
    azurerm_subnet.discovery_outbound_subnet_name
  ]
}

resource "null_resource" "update_subnet_name" {
  count = var.use_private_acs == "Y" ? length(var.nac_subnet) : 0
  provisioner "local-exec" {
    command = "echo \"vnetSubnetName-${count.index}: \"${azurerm_subnet.nac_subnet_name[count.index].name} >> config.dat"
  }
  depends_on = [
    azurerm_subnet.nac_subnet_name
  ]
  triggers = {
    input_json = var.nac_subnet[count.index]
  }
}

###### Storage Account for: Azure function NAC_Discovery in ACS Resource Group ###############

data "azurerm_private_dns_zone" "storage_account_dns_zone" {
  count               = var.use_private_acs == "Y" && var.service_name != "EXP" ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_virtual_network.VnetToBeUsed[0].resource_group_name
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "nasunist${random_id.nac_unique_stack_id.hex}"
  resource_group_name      = data.azurerm_resource_group.resource_group.name
  location                 = data.azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags

  depends_on = [
    null_resource.update_subnet_name,
    data.azurerm_private_dns_zone.storage_account_dns_zone
  ]
}

resource "null_resource" "disable_storage_public_access" {
  provisioner "local-exec" {
    command = var.use_private_acs == "Y" ? "az storage account update --allow-blob-public-access false --name ${azurerm_storage_account.storage_account.name} --resource-group ${azurerm_storage_account.storage_account.resource_group_name}" : "echo 'INFO ::: Destination Storage Account is Public...'"
  }
  depends_on = [azurerm_storage_account.storage_account]
}

########## START : Provision NAC ###########################

resource "null_resource" "dos2unix" {
  provisioner "local-exec" {
    command     = "dos2unix ./nac-auth.sh"
    interpreter = ["/bin/bash", "-c"]
  }

}

resource "null_resource" "provision_nac" {
  provisioner "local-exec" {
    command     =  "./nac-auth.sh acs ${var.acs_nmc_volume_name} ${var.nac_resource_group_name} EXP"  
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    null_resource.dos2unix,

  ]
}
########### END : Provision NAC ###########################


