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
  password    = "f04addf8642d4fa1"
  auth_url    = "http://192.168.100.10:5000/v3"
  region      = "RegionOne"
  use_octavia   = true
}



resource "openstack_networking_network_v2" "network_web" {
  name           = "network_web"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_web" {
  name       = "subnet_web"
  network_id = "${openstack_networking_network_v2.network_web.id}"
  cidr       = "10.0.4.0/25"
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "subnet_web1" {
  name       = "subnet_web1"
  network_id = "${openstack_networking_network_v2.network_web.id}"
  cidr       = "10.0.4.128/25"
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

}


resource "openstack_networking_network_v2" "network_app" {
  name           = "network_app"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_app" {
  name       = "subnet_app"
  network_id = "${openstack_networking_network_v2.network_app.id}"
  cidr       = "10.0.2.0/25"
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "subnet_app1" {
  name       = "subnet_app1"
  network_id = "${openstack_networking_network_v2.network_app.id}"
  cidr       = "10.0.2.128/25"
  ip_version = 4
}

resource "openstack_compute_secgroup_v2" "secgroup_app" {
  name        = "secgroup_app"
  description = "a security group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}
resource "openstack_networking_port_v2" "port_app" {
  name               = "port_app"
  network_id         = "${openstack_networking_network_v2.network_app.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.secgroup_app.id}"]

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
  external_network_id = "af49c089-4c14-4bfa-8ffa-8ca0755a93cd"
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
  subnet_id = "${openstack_networking_subnet_v2.subnet_web1.id}"
}

resource "openstack_networking_router_interface_v2" "int_app1" {
  router_id = "${openstack_networking_router_v2.router_2.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_app.id}"
}


resource "openstack_networking_router_v2" "router_3" {
  name              = "router_3"
  admin_state_up    = "true"
}

resource "openstack_networking_router_interface_v2" "int_data" {
  router_id = "${openstack_networking_router_v2.router_3.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_data.id}"
}

resource "openstack_networking_router_interface_v2" "int_app2" {
  router_id = "${openstack_networking_router_v2.router_3.id}"
  subnet_id   = "${openstack_networking_subnet_v2.subnet_app1.id}"
}

resource "openstack_compute_instance_v2" "web_server1" {
  name            = "web_server1"
  image_id        = "db2becd1-386c-42e7-914c-3ad0b8d65a6b"
  flavor_id       = "2"
 
  network {
    name = "network_web"
  }
}

resource "openstack_compute_instance_v2" "web_server2" {
  name            = "web_server2"
  image_id        = "60d04e6d-69e8-45b1-9c55-ff83989ade27"
  flavor_id       = "1"

  network {
    name = "network_web"
  }
}

resource "openstack_compute_instance_v2" "web_server3" {
  name            = "web_server3"
  image_id        = "db2becd1-386c-42e7-914c-3ad0b8d65a6b"
  flavor_id       = "2"
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_web.id}"]


  network {
    name = "network_web"
  }
}

resource "openstack_compute_instance_v2" "app1" {
  name            = "app1"
  image_id        = "60d04e6d-69e8-45b1-9c55-ff83989ade27"
  flavor_id       = "1"
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_app.id}"]


  network {
    name = "network_app"
  }
}

resource "openstack_compute_instance_v2" "app2" {
  name            = "app2"
  image_id        = "60d04e6d-69e8-45b1-9c55-ff83989ade27"
  flavor_id       = "1"
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_app.id}"]


  network {
    name = "network_app"
  }
}

resource "openstack_lb_loadbalancer_v2" "lb_1" {
     name           = "lb_1"
     admin_state_up = "true"
     vip_subnet_id  = "${openstack_networking_subnet_v2.subnet_web.id}"
}
