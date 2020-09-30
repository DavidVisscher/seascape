#!/bin/bash
#
# Note from David:
# This is a script I wrote a while ago, but updated to our situation.
# It may be floating around the internet on other projects I've contributed to.

if [ "$EUID" -ne 0 ]
    then echo "Please run this script as root"
    exit 1
fi

printf "LANG=en_US.UTF-8" > /etc/locale.conf
localectl set-locale LANG=en_US.UTF-8

yum update -y
yum install -y curl

printf "\n127.0.0.1\tsalt\n" >> /etc/hosts

yum install -y https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest.el8.noarch.rpm
yum clean expire-cache
yum install -y salt-master salt-minion salt-ssh salt-syndic salt-cloud salt-api

systemctl start salt-master
sleep 10
systemctl start salt-minion

salt-key -yA

yum install -y git

mkdir -p /root/.ssh
ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -P ""
clear
echo "Please add this key as a deploy key in the github repo:"
cat /root/.ssh/id_ed25519.pub
echo "Press any key to continue"
read -n 1 -s

mkdir -p /srv/
git clone git@github.com:rug-wacc/2020_group_13_s3278891_s2776278.git --recurse-submodules /srv/seascape
ln -s /srv/seascape/deployment/salt /srv/salt
ln -s /srv/seascape/deployment/pillar /srv/pillar
ln -s /srv/seascape/deployment/reactor /srv/reactor

systemctl enable salt-master
systemctl start salt-master

systemctl enable salt-minion
systemctl start salt-minion

sleep 10

salt-key -ya $(hostname)

salt $(hostname) state.highstate
