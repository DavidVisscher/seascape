resource "openstack_networking_secgroup_v2" "ssh_in" {
  name        = "ssh_in"
  description = "Allows incoming SSH connections"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_in_22" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.ssh_in.id}"
}



resource "openstack_networking_secgroup_v2" "http_in" {
  name        = "http_in"
  description = "Allows incoming HTTP(S) connections"
}

resource "openstack_networking_secgroup_rule_v2" "http_in_80" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.http_in.id}"
}

resource "openstack_networking_secgroup_rule_v2" "http_in_443" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.http_in.id}"
}
