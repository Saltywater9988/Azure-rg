variable "resource_group_name" {
  type = string
  description = "resource group name"
}
variable "resource_group_location" {
  type = string
  description = "resource group location"
}
variable "resource_group_tags" {
  type = map(string)
   description = "resource group tags"
}