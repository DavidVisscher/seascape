resource "openstack_compute_instance_v2" "ingest" {
  name            = "ingest-${count.index}"
  count           = 2
  flavor_id       = "2"
  key_pair        = "David"
  security_groups = ["default"]
  image_id        = "a11117ac-7a21-4681-96bf-f88e69f7187a" # CentOS 8

  user_data = templatefile(
                "${path.module}/cloud-init/minion.yml", 
                {       
                    count = count.index,
                    role = "ingest",
                    master_ip = openstack_compute_instance_v2.salt-master.network.0.fixed_ip_v4
                }
              )

  block_device {
    uuid                  = "a11117ac-7a21-4681-96bf-f88e69f7187a" # CentOS 8
    source_type           = "image"
    volume_size           = 20
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
  
  network {
    name = "seascape_network"
    access_network = true
  }

  depends_on = [openstack_networking_network_v2.seascape_network,
                openstack_compute_instance_v2.salt-master]
}

