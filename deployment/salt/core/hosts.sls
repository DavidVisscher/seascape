{# Manages the /etc/hosts file of each minion to ease discovery #}

core-manage-hosts:
  file.managed:
    - name: /etc/hosts
    - source: salt://core/files/_etc_hosts
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
