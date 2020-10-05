selinux_dependencies:
  pkg.installed:
    - pkgs:
      - audit
      - policycoreutils
      - python3-policycoreutils
      - policycoreutils-python-utils

selinux_mode:
  selinux.mode: 
    - name: {{ salt['pillar.get']('selinux_mode', 'enforcing') }}
