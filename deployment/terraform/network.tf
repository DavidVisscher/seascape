# External Network

resource "openstack_networking_network_v2" "seascape_network" {
  name           = "seascape_network"
  admin_state_up = "true"
}


resource "openstack_networking_subnet_v2" "seascape_subnet" {
  name       = "seascape_subnet"
  network_id = "${openstack_networking_network_v2.seascape_network.id}"
  cidr       = "10.0.0.0/16"
  ip_version = 4
  dns_nameservers = ["1.1.1.1", "1.0.0.1"]
}

resource "openstack_networking_router_v2" "seascape_router" {
  name                = "seascape_router"
  admin_state_up      = "true" 
  external_network_id = "afd0a5a6-a4ce-415a-9a28-9325a6857dfd"
}

resource "openstack_networking_router_interface_v2" "seascape_router_interface_1" {
  router_id = "${openstack_networking_router_v2.seascape_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.seascape_subnet.id}"
}
