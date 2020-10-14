# External Network

resource "openstack_networking_network_v2" "seascape_ext_network" {
  name           = "seascape_ext_network"
  admin_state_up = "true"
}


resource "openstack_networking_subnet_v2" "seascape_ext_subnet" {
  name       = "seascape_ext_subnet"
  network_id = "${openstack_networking_network_v2.seascape_ext_network.id}"
  cidr       = "10.0.0.0/16"
  ip_version = 4
  dns_nameservers = ["1.1.1.1", "1.0.0.1"]
}

resource "openstack_networking_subnet_route_v2" "seascape_ext_subnet_route" {
  subnet_id        = "${openstack_networking_subnet_v2.seascape_ext_subnet.id}"
  destination_cidr = "0.0.0.0/0"
  next_hop         = "10.0.0.1"
}

resource "openstack_networking_router_v2" "seascape_router" {
  name                = "seascape_router"
  admin_state_up      = "true" 
  external_network_id = "afd0a5a6-a4ce-415a-9a28-9325a6857dfd"
}

resource "openstack_networking_router_interface_v2" "seascape_router_interface_1" {
  router_id = "${openstack_networking_router_v2.seascape_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.seascape_ext_subnet.id}"
}


# Internal Network

resource "openstack_networking_network_v2" "seascape_int_network" {
  name           = "seascape_int_network"
  admin_state_up = "true"
}


resource "openstack_networking_subnet_v2" "seascape_int_subnet" {
  name       = "seascape_int_subnet"
  network_id = "${openstack_networking_network_v2.seascape_int_network.id}"
  cidr       = "10.1.0.0/16"
  ip_version = 4
  dns_nameservers = ["1.1.1.1", "1.0.0.1"]
}
