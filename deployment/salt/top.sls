base:
  "salt*":
    - core
    - users
    - ss_wave
  "elastic-*":
    - core
    - users
    - docker
    - docker.compose-ng
  "web-*":
    - core
    - users
    - docker
    - docker.compose-ng
  "ingest-*":
    - core
    - users
    - docker
    - docker.compose-ng
  "haproxy-*":
    - core
    - users
    - haproxy
