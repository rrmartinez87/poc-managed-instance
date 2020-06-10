// Azure provider configuration
terraform {
  required_version = ">= 0.12"
  backend "azurerm" {}
}
provider "azurerm" {
    version = "~>2.0"
    features {}
	subscription_id = "a7b78be8-6f3c-4faf-a43d-285ac7e92a05"
	tenant_id       = "c160a942-c869-429f-8a96-f8c8296d57db"
 }
// Resource required to generate random guids
resource "random_uuid" "poc" { }

// Azure resource group definition
resource "azurerm_resource_group" "rg" {

  // Arguments required by Terraform API
  name = join(local.separator, [var.resource_group_name, random_uuid.poc.result])
  location = var.location

  // Optional Terraform resource manager arguments but required by architecture
  tags = var.tags
}

// Create dedicated virtual network to host the managed instance
resource "azurerm_virtual_network" "vnet" {
  
  // Arguments required by Terraform API
  name = join(local.separator, [var.vnet_name, random_uuid.poc.result])
  address_space = [var.vnet_address_space]
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

// Create associated subnet
resource "azurerm_subnet" "subnet" {
  
  // Arguments required by Terraform API
  name = join(local.separator, [var.subnet_name, random_uuid.poc.result])
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = var.subnet_address_prefixes
  
  // Optional Terraform resource manager arguments but required by architecture
  enforce_private_link_endpoint_network_policies = true
  //service_endpoints = ["Microsoft.Sql"]
  
  delegation {
    name = var.service_delegation_name
    service_delegation {
      name = local.service_delegation_name
    }
  }
}

// Create dedicated Network Security Group and associate to subnet
resource "azurerm_network_security_group" "nsg" {
  
  // Arguments required by Terraform API
  name = join(local.separator, [var.nsg_name, random_uuid.poc.result])
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  // Optional Terraform resource manager arguments but required by architecture
  security_rule {
    name = "AllowTcpInbound_Redirect"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_ranges = ["11000-11999", "1433"] // required for redirect connections
    source_address_prefixes = azurerm_subnet.subnet-test.address_prefixes // change prefixes
    destination_address_prefix = "*"
  }

  tags = var.tags
}

// Associate subnet to Network Security Group
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  
  // Arguments required by Terraform API
  subnet_id = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

// Create Route Table and associate to subnet
resource "azurerm_route_table" "rt" {
  
  // Arguments required by Terraform API
  name = join(local.separator, [var.route_table_name, random_uuid.poc.result])
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  //***********************************disable_bgp_route_propagation = false

  // Optional Terraform resource manager arguments but required by architecture
  tags = var.tags
}

// Associate subnet to Network Security Group
resource "azurerm_subnet_route_table_association" "rt_association" {
  
  // Arguments required by Terraform API
  subnet_id = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.rt.id
}



// CREATE TEST VNET
// Create virtual network to set up a private endpoint later
resource "azurerm_virtual_network" "vnet-test" {
  
  // Arguments required by Terraform API
  name = join(local.separator, ["vnet-test", random_uuid.poc.result])
  address_space = ["10.1.0.0/16"]
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  
  // Optional Terraform resource manager arguments but required by architecture
  tags = var.tags
}

// Create associated subnet
resource "azurerm_subnet" "subnet-test" {
  
  // Arguments required by Terraform API
  name = join(local.separator, ["subnet-test", random_uuid.poc.result])
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-test.name
  address_prefixes = ["10.1.0.0/24"] //var.subnet_address_prefixes
  
  // Optional Terraform resource manager arguments but required by architecture
  //enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_policies
  //service_endpoints = ["Microsoft.Sql"]
}

// Create VNet Peerings to connect both VNets: Managed Instance VNet and Test connection VNet
resource "azurerm_virtual_network_peering" "test-peering" {
  name                      = "test_vnet_to_mi_vnet"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet-test.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_virtual_network_peering" "mi-peering" {
  name                      = "mi_vnet_to_test_vnet"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-test.id
}
/*
// Create the Managed Instance
// This resource can't be configured using Terraform Azure provider API
resource "null_resource" "create_managed_instance" { 
  provisioner local-exec {
    command = "az sql mi create --resource-group ${azurerm_resource_group.rg.name} --name ${join(local.separator, [var.managed_instance_name, random_uuid.poc.result])} --location ${azurerm_resource_group.rg.location} --admin-user ${var.admin_user} --admin-password ${var.admin_password} --license-type ${var.license_type} --subnet ${azurerm_subnet.subnet.id} --capacity ${var.capacity} --storage ${var.storage} --edition ${var.edition} --family ${var.family} --proxy-override ${local.connection_type} --minimal-tls-version ${local.tls_version} --public-data-endpoint-enabled ${local.public-data-endpoint-enabled}"
  }
}
*/
