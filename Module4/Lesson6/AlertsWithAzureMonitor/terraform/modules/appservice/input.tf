# Resource Group/Location
variable "name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}

# Tags
variable "tags" {
  type = map(string)
}
