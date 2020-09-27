ss_wave_dependencies:
  pkg.installed:
    - pkgs: 
      - python3-pip
      - python-virtualenv

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
    - branch: master

ss_wave_venv:
  virtualenv.managed:
    - name: /var/run/ss_wave.env
    - python: /bin/python3.6
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
      - file: ss_wave_config
      - file: ss_wave_unit
