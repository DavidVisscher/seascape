{% set all_ips = salt['saltutil.runner']('mine.get', tgt='*', fun='network.ip_addrs') %}
{% set elixir_cluster_nodes = [] %}
{% for minion, addrs in all_ips.items() %}
  {% if not grains['id'] == minion %}
    {% if grains['id'].startswith('web') %}
      {% do elixir_cluster_nodes.append("web@" + addrs[0]) %}
    {% endif %}
    {% if grains['id'].startswith('ingest') %}
      {% do elixir_cluster_nodes.append("ingest@" + addrs[0]) %}
    {% endif %}
  {% endif %}
{% endfor %}

docker:
  compose:
    seascape-web:
      image: 'qqwy/seascape:ingest'
      container_name: 'seascape-ingest'
      extra_hosts:
      {% for minion, addrs in all_ips.items() %}
      {% if not grains['id'] == minion %}
        - {{ minion }}:{{ addrs[0] }}
        - {{ minion.split('.',1)[0] }}:{{ addrs[0] }}
      {% endif %}
      {% endfor %}
      environment:
        ELASTICSEARCH_DB_URL: "http://elproxy-0.seascape.example:9200/"
        SECRET_KEY_BASE: "9f6xBOshzFnIhGFwqXnifKU7ksZyBNTo7lhN91V2/eBFePRczYytfgjqO97beDm1" # Change this in prod
        # CONTAINER_HOST: "{{ grains['id'] }}"
        RELEASE_DISTRIBUTION: "name"
        RELEASE_NODE: "ingest@{{ all_ips[grains['id']][0] }}"
        BEAM_PORT: 4370
        OTHER_ELIXIR_CLUSTER_NODES: "{{ elixir_cluster_nodes.join(',') }}"
      ports:
        - '4001:4001' # web
        - '4369:4369' # EPMD
        - '4370:4370' # the Elixir node itself
