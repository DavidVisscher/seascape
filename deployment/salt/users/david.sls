david:
  user.present:
    - fullname: David Visscher
    - shell: /bin/bash
    - home: /home/david
    - createhome: True
    - groups:
      - wheel

david_key:
  ssh_auth.present:
    - name: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5rBLGgYdxyvTyXsfri48evA/unE8I7HZlb9DjFZIFR david@Fruity-Rectangle.local"
    - user: david
    - enc: ssh-ed25519
    - require:
      - user: david

david_home_key:
  ssh_auth.present:
    - name: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJQjEM4UkGAuLuFeylO0fnLn5o9syBwWiatrUMxW8LS8aydmk4XPdQ+Z5bpWAnJLIzaIvAQDItcVHVm+SRq9+eINN/Rwgm7gnIJFH6sRzPM7lGfRKkHW0dNVNLqMS6mwS5uFApk4dN+xFHLaI9YCfoUvu8v5s/5BU2rA+7qciJxjf1Qn3GGKtNddQvGcTECd3Dah3FPB92MHhpYSF8gKACvo3QiAxddX7TsXe4irTTvEhYaWr9S4LfZ9ll1u6NP6rdw1hIVGDO0tvGvIT3it4WmlSwYLaiu5e6LPatpeZpOlTyKOpwgOUhncWgWnwoVuReX/cJdVj1C4YglR68lNBh david@DESKTOP-6M3K9R4"
    - user: david
    - enc: ssh-rsa
    - require:
      - user: david

david_workstation_key:
  ssh_auth.present:
    - name: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL4e86juakHyKFjP7HG0ptTd5MAso7H9hg8XPrEuc9wY david@aardappel"
    - user: david
    - enc: ssh-ed25519
    - require:
      - user: david
