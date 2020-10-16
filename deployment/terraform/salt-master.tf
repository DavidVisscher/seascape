resource "openstack_compute_instance_v2" "salt-master" {
  name            = "salt-master"
  flavor_id       = "2"
  key_pair        = "David"
  security_groups = ["default"]

  user_data = templatefile(
                "${path.module}/cloud-init/salt.yml", 
                {       
                    deploy_key =var.deploy_key, 
                    deploy_pubkey = var.deploy_pubkey
                    deploy_pubkey_decoded = base64decode(var.deploy_pubkey)
                }
              )

  block_device {
    uuid                  = "a11117ac-7a21-4681-96bf-f88e69f7187a" # CentOS 8
    source_type           = "image"
    volume_size           = 25
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
  
  network {
    access_network = true
    name = "seascape_network"
  }

  depends_on = [openstack_networking_network_v2.seascape_network]
}

resource "openstack_networking_floatingip_v2" "salt-master" {
  pool = "vlan16"
}

resource "openstack_compute_floatingip_associate_v2" "salt-master" {
  floating_ip = openstack_networking_floatingip_v2.salt-master.address
  instance_id = openstack_compute_instance_v2.salt-master.id
  fixed_ip    = openstack_compute_instance_v2.salt-master.network.0.fixed_ip_v4
}
