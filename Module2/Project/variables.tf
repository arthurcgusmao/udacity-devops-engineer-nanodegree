variable "name" {
  description = "The prefix which should be used for all resources in this module."
  default = "project1"
}

variable "location" {
  description = "The Azure Region in which the resources will be created."
  default = "westeurope"
}

variable "username" {
  description = "Username of the VM's OS."
  default     = "ubuntu"
}
variable "password" {
  description = "Password of the VM's OS."
}

variable "environment" {
  description = "Environment the resource belongs to: dev, staging, or prod."
  type        = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Value not allowed."
  }
}

variable "replicas" {
  description = "Number of VMs to be created."
  type = number
  default = 2
}
