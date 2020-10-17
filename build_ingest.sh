#! /bin/bash

docker build seascape_umbrella/ -f seascape_umbrella/Dockerfile.ingest -t qqwy/seascape:ingest \
    && docker push qqwy/seascape:ingest
