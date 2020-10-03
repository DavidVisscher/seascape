mine_interval:
  file.line:
    - name: /etc/salt/minion
    - content: "mine_interval: 1"
    - match: "mine_interval"
    - mode: replace
