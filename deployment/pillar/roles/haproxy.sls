{% set web_ips = salt['saltutil.runner']('mine.get', tgt='web*', fun='network.ip_addrs') %}
{% set ingest_ips = salt['saltutil.runner']('mine.get', tgt='ingest*', fun='network.ip_addrs') %}

haproxy:
  proxy:
    enabled: True
    mode: http
    logging: syslog
    maxconn: 32768 
    listen:
      admin_page:
        type: admin
        binds:
        - address: 127.0.0.1
          port: 8801
        user: admin
        password: "TIJDELIJKWACHTWOORD!AANPASSEN"
      https_in:
        format: end
        type: http
        force_ssl: true
        rate_limit:
          duration: 900s
          enabled: true
          requests: 250
          track: content
        acls:
        - name: ingest_host
          conditions:
          - type: "hdr(host)"
            condition: "ingest.seascape.example"
          servers:
          {% for minion, addrs in ingest_ips.items() %}
          - name: {{ minion }}
            host: {{ addrs[0] }}
            port: 4000
          {% endfor %}
        - name: web_host
          conditions:
          - type: "hdr(host)"
            condition: "seascape.example"
          servers:
          {% for minion, addrs in web_ips.items() %}
          - name: {{ minion }}
            host: {{ addrs[0] }}
            port: 4000
          {% endfor %}
        binds:
        - address: 0.0.0.0
          port: 80
        - address: 0.0.0.0
          port: 443
          ssl:
            enabled: True
            pem_file: /etc/certs/seascape.example.pem
