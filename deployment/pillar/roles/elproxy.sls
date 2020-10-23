{% set elastic_ips = salt['saltutil.runner']('mine.get', tgt='elastic*', fun='network.ip_addrs') %}

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
      normal_in:
        balance: source
        type: http
        servers:
        {% for minion, addrs in elastic_ips.items() %}
        - name: {{ minion }}
          host: {{ addrs[0] }}
          port: 9200
          params: "check inter 15s fastinter 2s downinter 1s rise 5 fall 3" 
        {% endfor %}
        binds:
        - address: 0.0.0.0
          port: 9200
      clustering_in:
        balance: source
        type: http
        servers:
        {% for minion, addrs in elastic_ips.items() %}
        - name: {{ minion }}
          host: {{ addrs[0] }}
          port: 9300
          params: "check inter 15s fastinter 2s downinter 1s rise 5 fall 3" 
        {% endfor %}
        binds:
        - address: 0.0.0.0
          port: 9300
