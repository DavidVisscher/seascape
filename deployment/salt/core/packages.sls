{% if salt['pillar.get']('core:packages:install_updates', False) %}
up_to_date:
  pkg.uptodate:
    - refresh: True
{% endif %}

base_packages:
  pkg.installed:
    - pkgs:
      - git
      - vim-enhanced
      - zsh
      - tcpdump
      - bind-utils
      - fail2ban
      - mdadm
      - python3-dnf-plugin-versionlock
