#! /bin/bash

docker build seascape_umbrella/ -f seascape_umbrella/Dockerfile.web-t qqwy/seascape:web \
    && docker push qqwy/seascape:web
