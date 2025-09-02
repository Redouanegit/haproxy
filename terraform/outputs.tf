output "lb_floating_ip" {
  value = openstack_networking_floatingip_v2.fip["lb"].address
}

output "app2_floating_ip" {
  value = openstack_networking_floatingip_v2.fip["app2"].address
}