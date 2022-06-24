output "server_external_ip" {
  value = openstack_networking_floatingip_v2.floatingip_1.address
}

# output "network_id" {
#   value = openstack_networking_network_v2.network_1.id
# }
