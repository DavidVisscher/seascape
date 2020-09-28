# Web and Cloud Computing 2020-2021: Group 13
**David Visscher (s3278891) and Wiebe-Marten Wijnja (s2776278)**


Project: **Docker resource use measurement**


## Architecture Slides

We are hosting the architecture slides outside of GitHub for an easy viewing/presenting experience.
You can (re)view them at [https://slides.com/qqwy/web-and-cloud-computing-group-13](https://slides.com/qqwy/web-and-cloud-computing-group-13).

## DB-Maintenance

When running on a new environment where there is no ElasticSearch database yet,
run the `mix seascape.create_elasticsearch_indexes` command to make sure all indexes that are used are actually available.

The reason this command is not automated inside the software of a node (e.g. on startup) is because one of the fallacies of distributed programming is that all software is homogeneous: we do not want a node running e.g. outdated software messing with the indices.

## Salt formulas

We are using some official salt formulas instead of writing all salt states ourselves.
Official formulas are sources from [the SaltStack Formulas Gitlab Organisation](https://github.com/saltstack-formulas)

Currently we're using:
 - [docker-formula v0.44.0](https://github.com/saltstack-formulas/docker-formula/tree/v0.44.0/docker)
 - [haproxy-formula v0.17.0](https://github.com/saltstack-formulas/haproxy-formula/tree/v0.17.0)

