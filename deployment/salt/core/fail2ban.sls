fail2ban_config:
  file.managed:
    - name: /etc/fail2ban/jail.local
    - source: salt://{{ slspath }}/files/_etc_fail2ban_jail_conf

fail2ban_install:
  pkg.installed:
    - pkgs:
      - fail2ban
 
fail2ban:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: fail2ban_config
