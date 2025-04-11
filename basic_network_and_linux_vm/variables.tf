variable "subscription_id" {
    type = string
    description = "Subscription in which Azure resources should be deployed."
    sensitive = true
}

variable "location" {
    type = string
    default = "West Europe"
}

variable "location_shorthand"{
    type = map(string)
    default = {
        "West Europe" = "weu"
        "North Europe" = "neu"
    }
}

variable "user_identifier" {
    type = string
}
variable "user_email" {
    type = string
}

variable "workload_identifier" {
    type = string
}

variable "cost_center" {
    type = string
}

variable "cost_unit" {
    type = string
}

variable "nsg_allowed_ip_address" {
    type = string
    sensitive = true
}

variable "nsg_allowed_ip_addresses" {
    type = list
    sensitive = true
}