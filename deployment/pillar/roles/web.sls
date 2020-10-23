{% set other_ips = salt['saltutil.runner']('mine.get', tgt='*', fun='network.ip_addrs') %}


docker:
  compose:
    seascape-web:
      image: 'qqwy/seascape:web'
      container_name: 'seascape-web'
      extra_hosts:
      {% for minion, addrs in other_ips.items() %}
        - {{ minion }}:{{ addrs[0] }}
        - {{ minion.split('.',1)[0] }}:{{ addrs[0] }}
      {% endfor %}
      environment:
        ELASTICSEARCH_DB_URL: "http://elastic-0.seascape.example:9200/"
        SECRET_KEY_BASE: "9f6xBOshzFnIhGFwqXnifKU7ksZyBNTo7lhN91V2/eBFePRczYytfgjqO97beDm1" # Change this in prod
        CONTAINER_HOST: "{{ grains['id'] }}"
        RELEASE_DISTRIBUTION: "name"
        RELEASE_NODE: "web@{{ grains['id'] }}"
        BEAM_PORT: 4370
      ports:
        - '4000:4000'
        - '4369:4369'
        - '4370:4370'
        - '45892:45892/udp'
