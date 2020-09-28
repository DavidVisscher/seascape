max_open_file_sysctl:
  file.managed:
    - name: /etc/sysctl.conf
    - source: salt://{{ slspath }}/files/_etc_sysctl.conf

max_open_file_security_limits:
  file.line:
    - name: /etc/security/limits.conf
    - mode: ensure
    - after: end
    - content: "* - nofiles 16384"

reload_sysctl:
  cmd.run:
    - name: "/sbin/sysctl -p"
    - onchanges:
      - file: max_open_file_sysctl
      - file: max_open_file_security_limits
