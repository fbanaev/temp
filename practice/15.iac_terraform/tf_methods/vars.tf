variable "domain_name" {}
variable "project_id" {}
variable "user_name" {}
variable "user_password" {}
variable "region" {}
variable "az_zone" {}
variable "volume_type" {}
variable "public_key" {}
variable "create_server" { default = "true"}
variable "hdd_size" {
  default = "5"
}
