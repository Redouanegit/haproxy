terraform {
  required_version = ">= 1.3.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.54.1"
    }
  }
}

provider "openstack" {
  auth_url    = var.auth_url
  region      = var.region
  user_name   = var.user_name
  password    = var.password
  tenant_name = var.tenant_name
}

# Clé SSH importée dans OpenStack
resource "openstack_compute_keypair_v2" "this" {
  name       = "terraform-key"
  public_key = file(var.public_key_path)
}

# Security group: SSH, HTTP, backend (8080), et ICMP
resource "openstack_networking_secgroup_v2" "web" {
  name        = "sg-web"
  description = "SSH, HTTP, backend, ICMP"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.web.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.web.id
}

resource "openstack_networking_secgroup_rule_v2" "backend" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  security_group_id = openstack_networking_secgroup_v2.web.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.web.id
}

# Instances: lb + app2 (deux VMs)
locals {
  instances = {
    lb   = { name = "lb" }
    app2 = { name = "app2" }
  }
}

resource "openstack_compute_instance_v2" "vm" {
  for_each    = local.instances
  name        = each.value.name
  image_name  = var.image_name
  flavor_name = var.flavor_name
  key_pair    = openstack_compute_keypair_v2.this.name

  security_groups = [openstack_networking_secgroup_v2.web.name]

  network {
    uuid = var.network_id
  }
}

# Associer une IP flottante à chaque VM pour l'accès Ansible/SSH
resource "openstack_networking_floatingip_v2" "fip" {
  for_each = local.instances
  pool     = var.floatingip_pool # ex: "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  for_each    = local.instances
  floating_ip = openstack_networking_floatingip_v2.fip[each.key].address
  instance_id = openstack_compute_instance_v2.vm[each.key].id
}

# Générez l'inventaire Ansible (INI) depuis Terraform
resource "local_file" "inventory" {
  filename = "${path.module}/inventory.ini"
  content  = templatefile("${path.module}/inventory.tpl", {
    ssh_username  = var.ssh_username
    lb_fip        = openstack_networking_floatingip_v2.fip["lb"].address
    lb_priv_ip    = openstack_compute_instance_v2.vm["lb"].access_ip_v4 != null ? openstack_compute_instance_v2.vm["lb"].access_ip_v4 : openstack_compute_instance_v2.vm["lb"].network[0].fixed_ip_v4
    app2_fip      = openstack_networking_floatingip_v2.fip["app2"].address
    app2_priv_ip  = openstack_compute_instance_v2.vm["app2"].access_ip_v4 != null ? openstack_compute_instance_v2.vm["app2"].access_ip_v4 : openstack_compute_instance_v2.vm["app2"].network[0].fixed_ip_v4
  })
}