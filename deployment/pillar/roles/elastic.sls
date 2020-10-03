
docker:
  compose:
    elasticsearch:
      image: 'docker.elastic.co/elasticsearch/elasticsearch:7.5.2'
      container_name: 'elasticsearch'
      environment:
        node.name: "{{ grains['id'].split('.', 1)[0] }}"
        cluster.name: "seascape-elasticsearch-cluster"
        # This assumes a minimum of three nodes!
        discovery.seed_hosts: "{% for minion, addrs in salt['mine.get']('*', 'network.ip_addrs', tgt_type='glob') | dictsort() %} {{minion}} ,{% endfor %}"
        cluster.initial_master_nodes: elastic-0,elastic-1,elastic-2
        bootstrap.memory_lock: "false"
        ES_JAVA_OPTS: '-Xms1G -Xmx1G'
      ulimits:
        memlock:
          soft: -1
          hard: -1
      volumes:
        - '/docker-volumes/elasticsearch/data:/usr/share/elasticsearch/data'
      ports:
        - '9200:9200'
