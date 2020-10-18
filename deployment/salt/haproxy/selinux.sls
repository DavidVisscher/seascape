haproxy_selinux_port_policy:
  cmd.run:
    - name: 'if semanage port -l | grep 8801; then echo "Port already assigned"; else semanage port -a -p tcp -t http_port_t 8801; fi'
    - onchanges:
      - service: haproxy_service
