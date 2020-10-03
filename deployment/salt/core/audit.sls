audit:
  pkg.installed

auditd:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: audit

selinux_mode:
  selinux.mode: {{ salt['pillar.get']('selinux_mode', 'enforcing') }}
