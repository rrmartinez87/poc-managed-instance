/*
  Input variable definitions for an Azure SQL Single database resource and its dependences
*/

// Variables to indicate whether some resources should be created or not
variable "create_resource_group" {
    description = "Flag indicating whether the resource group must be created or use existing"
    type = bool
    default = true
}

variable "create_database_server" {
    description = "Flag indicating whether the database server must be created or use existing"
    type = bool
    default = true
}

// Common variables definition
variable "resource_group_name" { 
    description = "The name of the resource group in which to create the elastic pool. This must be the same as the resource group of the underlying SQL server."
    type = string
    default = "rg-sql-managedinstance-poc"
}

variable "location" { 
    description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
    type = string
    default = "westus2"
}

variable "tags" { 
    description = "A mapping of tags to assign to the resource."
    type = map
    default = {
        environment = "development"
        product_type = "poc"
    }
}

// Managed instance variables
variable "managed_instance_name" { 
    description = ""
    type = string
    default = "yuma-mi"
}

variable "admin_user"  { 
    description = ""
    type = string
    default = "yuma-user"
}

variable "admin_password" { 
    description = ""
    type = string
    default = "_Adm123!_Adm123!_Adm123!"
}

variable "license_type" { 
    description = ""
    type = string
    default = "LicenseIncluded" //BasePrice (AHB)
}

variable "capacity" { 
    description = ""
    type = number
    default = 4
}

variable "storage" { 
    description = ""
    type = number
    default = 32
}

variable "edition" { 
    description = ""
    type = string
    default = "GeneralPurpose"
}

variable "family" { 
    description = ""
    type = string
    default = "Gen5"
}

variable "managed_database_name" { 
    description = ""
    type = string
    default = "yuma-midb1"
}

// Virtual network variables
variable "vnet_name" {
    description = "The name of the virtual network. Changing this forces a new resource to be created."
    type = string
    default = "vnet"
}

variable "vnet_address_space" {
    description = "The address space that is used the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
    type = string
    default = "10.0.0.0/16"
}

// Subnet variables
variable "subnet_name" {
    description = "The name of the subnet. Changing this forces a new resource to be created."
    type = string
    default = "subnet"
}

variable "subnet_address_prefixes" {
    description = "The address prefixes to use for the subnet."
    type = list(string)
    default     = ["10.0.1.0/24"]
}

variable "service_delegation_name" {
    description = "A name for this delegation."
    type = string
    default = "service_delegation_name"
}

// Route table variables
variable "route_table_name" {
    description = "The name of the route table. Changing this forces a new resource to be created."
    type = string
    default = "route_table_name"
}

// Network security group variables
variable "nsg_name" {
    description = "Specifies the name of the network security group. Changing this forces a new resource to be created."
    type = string
    default = "nsg_name"
}


// Private endopoint variables
variable "private_endpoint_name" {
    description = "Specifies the Name of the Private Endpoint. Changing this forces a new resource to be created."
    type = string
    default = "private-endpoint"
}

variable "service_connection_name" {
    description = "Specifies the Name of the Private Service Connection. Changing this forces a new resource to be created."
    type = string
    default = "service_connection_name" 
}

// VNet rule name variable
variable "vnet_rule_name" {
    description = "he name of the SQL virtual network rule. Changing this forces a new resource to be created. Cannot be empty and must only contain alphanumeric characters and hyphens. Cannot start with a number, and cannot start or end with a hyphen."
    type = string
    default = "vnet-rule"  
}
