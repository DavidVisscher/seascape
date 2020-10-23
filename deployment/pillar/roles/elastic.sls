{% set elastic_ips = salt['saltutil.runner']('mine.get', tgt='elastic*', fun='network.ip_addrs') %}


docker:
  compose:
    elasticsearch:
      image: 'docker.elastic.co/elasticsearch/elasticsearch:7.5.2'
      container_name: 'elasticsearch'
      environment:
        node.name: "{{ grains['id'].split('.', 1)[0] }}"
        cluster.name: "seascape-elasticsearch-cluster"
        # This assumes a minimum of three nodes!
        discovery.seed_hosts: elastic-0,elastic-1,elastic-2
        cluster.initial_master_nodes: elastic-0,elastic-1,elastic-2
        bootstrap.memory_lock: "false"
        ES_JAVA_OPTS: '-Xms1G -Xmx1G'
        network.publish_host: {{ elastic_ips[grains['id']][0] }}
        transport.publish_host: {{ elastic_ips[grains['id']][0] }}
      extra_hosts:
      {% for minion, addrs in elastic_ips.items() %}
        - {{ minion }}:{{ addrs[0] }}
        - {{ minion.split('.',1)[0] }}:{{ addrs[0] }}
      {% endfor %}
      ulimits:
        memlock:
          soft: -1
          hard: -1
      volumes:
        - '/docker-volumes/elasticsearch/data:/usr/share/elasticsearch/data'
      ports:
        - '9200:9200'
        - '9300:9300'
