mine_functions:
  test.ping: []
  network.ip_addrs:
    interface: eth0
  pkg.list_pkgs: []
  grains.items: []

selinux_mode: permissive

core:
  packages:
    install_updates: True

additional_hostnames:
  haproxy-0.seascape.example: ["ingest.seascape.example", "seascape.example"]
