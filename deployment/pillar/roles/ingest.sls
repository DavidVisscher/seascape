{% set other_ips = salt['saltutil.runner']('mine.get', tgt='*', fun='network.ip_addrs') %}


docker:
  compose:
    seascape-web:
      image: 'qqwy/seascape:ingest'
      container_name: 'seascape-ingest'
      extra_hosts:
      {% for minion, addrs in other_ips.items() %}
        - {{ minion }}:{{ addrs[0] }}
        - {{ minion.split('.',1)[0] }}:{{ addrs[0] }}
      {% endfor %}
      environment:
        ELASTICSEARCH_DB_URL: "http://elastic-0.seascape.example:9200/"
        SECRET_KEY_BASE: "9f6xBOshzFnIhGFwqXnifKU7ksZyBNTo7lhN91V2/eBFePRczYytfgjqO97beDm1" # Change this in prod
      ports:
        - '4001:4001'
        - '45892:45892'
