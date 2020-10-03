ss_wave_dependencies:
  pkg.installed:
    - pkgs:
      - python38
      - python38-pip
      - python3-virtualenv

ss_wave_clone:
  file.directory:
    - name: "/opt/seascape"
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 700
    - recurse:
      - user
      - group
      - mode
  git.latest:
    - name: "git@github.com:rug-wacc/2020_group_13_s3278891_s2776278.git"
    - target: /opt/seascape
    - user: root
    - identity:
      - /tmp/github_key
    - branch: {{ salt['pillar.get']('ss_wave:branch', 'master') }}
    - force_reset: True
    - force_checkout: True

ss_wave_venv:
  virtualenv.managed:
    - name: /var/run/ss_wave.env
    - python: /bin/python3.8
    - requirements: /opt/seascape/seascape_wave/requirements.txt

ss_wave_unit:
  file.managed:
    - name: /etc/systemd/system/ss_wave.service
    - source:
      - salt://{{ slspath }}/files/ss_wave.service

ss_wave_reload_daemon:
  cmd.run:
    - name: "systemctl daemon-reload"
    - onchanges:
      - file: ss_wave_unit

ss_wave_service:
  service.running:
    - name: ss_wave.service
    - enable: True
    - watch:
      - git: ss_wave_clone
      - file: ss_wave_unit
