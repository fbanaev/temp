output "public_key" {
  value = openstack_compute_keypair_v2.terraform_key.public_key
  sensitive = true
}
