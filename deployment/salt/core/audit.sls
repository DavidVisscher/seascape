audit:
  pkg.installed

auditd:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: audit
