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

## Vagrant development environment

Setting up a local development using vagrant is possible. 
It requires a machine with a working libvirt installation and that the current user can make use of it.
Then, follow these steps:
 1. Navigate to deployment/vagrant and run `vagrant up --provider libvirt`.
 2. After this is done, you can ssh to the salt master with `vagrant ssh`.
 3. Once on the salt master, run `salt -b 1 \* state.highstate` as root. Depending on your network connection, this may take quite a while. I've also had it fail when connections drop, in that case you may need to run it again. Normally this shouldn't happen if the connection is stable.
