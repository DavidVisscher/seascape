docker:
  compose:
    kibana:
      image: "docker.elastic.co/kibana/kibana:7.5.2"
      container_name: "kibana"
      environment:
        SERVER_NAME: "{{ grains['id'].split('.', 1)[0] }}"
        ELASTICSEARCH_HOSTS: 'http://elasticsearch:9200'
      links:
        - 'elasticsearch:elasticsearch'
      ports:
        - '5601:5601'
