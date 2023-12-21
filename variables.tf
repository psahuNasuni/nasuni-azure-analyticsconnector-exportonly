########################################################
##  Developed By  :   Pradeepta Kumar Sahu
##  Project       :   Nasuni Azure Cognitive Search Integration
##  Organization  :   Nasuni Labs   
#########################################################

variable "acs_resource_group" {
  description = "Resouce group name for Azure Cognitive Search"
  type        = string
  default     = "nasuni-labs-acs-rg"
}
variable "exp_resource_group" {
  description = "Resouce group name for ExportOnly"
  type        = string
  default     = ""
}
variable "acs_admin_app_config_name" {
  description = "Azure acs_admin_app_config_name"
  type        = string
  default     = "nasuni-labs-acs-admin"
}

variable "acs_nmc_volume_name" {
  description = "NMC Volume Name"
  type        = string
  default     = ""
}

variable "nac_resource_group_name" {
  description = "nac resource group name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "tags to apply to all resources"
  type        = map(string)
  default = {
    Application     = "Nasuni Analytics Connector with Azure Cognitive Search"
    Developer       = "Nasuni"
    PublicationType = "Nasuni Community Tool"
    Version         = "V 0.2"

  }
}

variable "output_path" {
  type        = string
  description = "function_path of file where zip file is stored"
  default     = "./ACSFunction.zip"
}

variable "networking_resource_group" {
  description = "Resouce group name for Azure Function"
  type        = string
  default     = ""
}

variable "user_vnet_name" {
  description = "Virtual Network Name for Azure Function"
  type        = string
  default     = ""
}

variable "user_subnet_name" {
  description = "Available subnet name in Virtual Network"
  type        = string
  default     = ""
}

variable "use_private_acs" {
  description = "Use Private ACS"
  type        = string
  default     = "N"
}

variable "discovery_outbound_subnet" {
  description = "Available subnet name in Virtual Network"
  type        = list(string)
  default     = [""]
}

variable "nac_subnet" {
  description = "Subnet range from Virtual Network for NAC Deployment"
  type        = list(string)
  default     = [""]
}

variable "datasource_connection_string" {
  description = "Destination Storage Account Connection Stringe"
  type        = string
  default     = ""
}

variable "destination_container_name" {
  description = "Destination Storage Account Container Name"
  type        = string
  default     = ""
}
variable "service_name" {
  default = ""
}
