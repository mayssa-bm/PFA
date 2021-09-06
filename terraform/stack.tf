terraform {
  required_providers {
      openstack = { 
            source = "terraform-provider-openstack/openstack"
      }
  }
}


# Configurformie the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = var.passwd
  auth_url    = var.auth_url
  region      = "RegionOne"
  use_octavia   = true
}


resource "openstack_networking_network_v2" "external" {
  name           = "external"
  admin_state_up = "true"
  external       = "true"
}


resource "openstack_networking_subnet_v2" "subnet_ext" {
  name       = "subnet_ext"
  network_id = "${openstack_networking_network_v2.external.id}"
  cidr       = var.ext_addr
  ip_version = 4
}


resource "openstack_networking_network_v2" "network_web" {
  name           = "network_web"
  admin_state_up = "true"
}


resource "openstack_networking_subnet_v2" "subnet_web" {
  name       = "subnet_web"
  network_id = "${openstack_networking_network_v2.network_web.id}"
  cidr       = "10.0.5.0/24"
  ip_version = 4
}


resource "openstack_compute_secgroup_v2" "secgroup_web" {
  name        = "secgroup_web"
  description = "a security group"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}


resource "openstack_networking_port_v2" "port_web" {
  name               = "port_web"
  network_id         = "${openstack_networking_network_v2.network_web.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.secgroup_web.id}"]
  fixed_ip           {
       subnet_id     = "${openstack_networking_subnet_v2.subnet_web.id}" 
       ip_address    = "10.0.5.127"
       }
}


resource "openstack_networking_network_v2" "network_data" {
  name           = "network_data"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_data" {
  name       = "subnet_data"
  network_id = "${openstack_networking_network_v2.network_data.id}"
  cidr       = "10.0.3.0/24"
  ip_version = 4
}

resource "openstack_compute_secgroup_v2" "secgroup_data" {
  name        = "secgroup_data"
  description = "a security group"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}


resource "openstack_networking_port_v2" "port_data" {
  name               = "port_data"
  network_id         = "${openstack_networking_network_v2.network_data.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.secgroup_data.id}"]
}

resource "openstack_networking_router_v2" "router_1" {
  name           = "router_1"
  admin_state_up = "true"
  external_network_id = "${openstack_networking_network_v2.external.id}"
}

resource "openstack_networking_router_interface_v2" "int_web" {
  router_id  = "${openstack_networking_router_v2.router_1.id}"
  subnet_id  = "${openstack_networking_subnet_v2.subnet_web.id}"
}

resource "openstack_networking_router_v2" "router_2" {
  name           = "router_2"
  admin_state_up = "true"
}

resource "openstack_networking_router_interface_v2" "int_web2" {
  router_id = "${openstack_networking_router_v2.router_2.id}"
  port_id    = "${openstack_networking_port_v2.port_web.id}"
}

resource "openstack_networking_router_interface_v2" "int_data" {
  router_id = "${openstack_networking_router_v2.router_2.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_data.id}"
}

resource "openstack_compute_instance_v2" "web_server1" {
  count           = var.count_web
  name            = "web_server1"
  image_id        = var.image_id
  flavor_id       = "2"
  network {
    name = "network_web"
  }
}


resource "openstack_compute_instance_v2" "data" {
  count           = var.count_data
  name            = "data"
  image_id        = var.image_id
  flavor_id       = "1"
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_data.id}"]
  network {
    name = "network_data"
  }
}
