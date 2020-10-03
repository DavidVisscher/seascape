docker:
  compose:
    elasticsearch:
      image: 'docker.elastic.co/elasticsearch/elasticsearch:7.5.2'
      container_name: 'elasticsearch'
      environment:
        node.name: "{{ grains['id'] }}"
        cluster.name: "seascape-elasticsearch-cluster"
        # This assumes a minimum of three nodes!
        discovery.seed_hosts: elastic-0,elastic-1,elastic-2
        cluster.intial_master_nodes: elastic-0,elastic-1,elastic-2
        bootstrap.memory_lock: "true"
        # ES_JAVA_OPTS: '-Xms512m - Xmx512m'
      ulimits:
        memlock:
          soft: -1
          hard: -1
      volumes:
        - '/docker-volumes/elasticsearch/data:/usr/share/elasticsearch/data'
      ports:
        - '9200:9200'
