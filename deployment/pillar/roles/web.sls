{% set other_ips = salt['saltutil.runner']('mine.get', tgt='*', fun='network.ip_addrs') %}


docker:
  compose:
    seascape-web:
      image: 'qqwy/seascape:web'
      container_name: 'seascape-web'
      extra_hosts:
      {% for minion, addrs in other_ips.items() %}
        - {{ minion.split('.',1)[0] }}:{{ addrs[0] }}
      {% endfor %}
      ports:
        - '4000:4000'
