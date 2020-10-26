resource "openstack_compute_instance_v2" "haproxy" {
  name            = "haproxy-0"
  flavor_id       = "2"
  key_pair        = "David"
  security_groups = ["default", "http_in"]

  user_data = templatefile(
                "${path.module}/cloud-init/minion.yml", 
                {       
                    count = 0,
                    role = "haproxy",
                    master_ip = openstack_compute_instance_v2.salt-master.network.0.fixed_ip_v4
                }
              )

  block_device {
    uuid                  = "a11117ac-7a21-4681-96bf-f88e69f7187a" # CentOS 8
    source_type           = "image"
    volume_size           = 100
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "seascape_network"
    access_network = true
  }

  depends_on = [openstack_networking_network_v2.seascape_network,
                openstack_networking_secgroup_v2.http_in,
                openstack_compute_instance_v2.salt-master]
}

resource "openstack_networking_floatingip_v2" "haproxy" {
  pool = "vlan16"
}

resource "openstack_compute_floatingip_associate_v2" "haproxy" {
  floating_ip = openstack_networking_floatingip_v2.haproxy.address
  instance_id = openstack_compute_instance_v2.haproxy.id
  fixed_ip    = openstack_compute_instance_v2.haproxy.network.0.fixed_ip_v4
}
