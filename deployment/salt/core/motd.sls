issue:
  file.managed:
    - name: /etc/issue
    - source: salt://core/files/_etc_issue
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

issue_net:
  file.managed:
    - name: /etc/issue.net
    - source: salt://core/files/_etc_issue
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

issue_minimal:
  file.managed:
    - name: /etc/issue.minimal
    - source: salt://core/files/_etc_issue
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

motd:
  file.managed:
    - name: /etc/motd
    - source: salt://core/files/_etc_motd
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
