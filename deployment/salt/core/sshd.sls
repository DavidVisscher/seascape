sshd_config:  
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://{{ slspath }}/files/_etc_ssh_sshd_config
    - template: jinja
    - user: root
    - group: root
    - mode: 600

sshd:
  service.running:
    - enable: True
    - reload: True
    - onchanges:
      - file: sshd_config
