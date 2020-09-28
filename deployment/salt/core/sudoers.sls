nopasswd_sudoers:
  file.line:
    - name: /etc/sudoers
    - match: "^%wheel"
    - mode: replace
    - content: "%wheel ALL=(ALL) NOPASSWD:ALL"

remove_sudoers_import:
  file.line:
    - name: /etc/sudoers
    - match: "#includedir /etc/sudoers.d"
    - mode: delete
