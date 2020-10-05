#!/bin/bash
#
# Note from David:
# This is a script I wrote a while ago, but updated to our situation.
# It may be floating around the internet on other projects I've contributed to.

if [ "$EUID" -ne 0 ]
    then echo "Please run this script as root"
    exit 1
fi

yum makecache
yum update -y
yum install -y curl

yum install -y https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest.el8.noarch.rpm 
yum clean expire-cache
yum install -y salt-minion

systemctl enable salt-minion
systemctl start salt-minion

echo "Please log into the salt-master and accept this minion's key"
echo "Press any key to continue..."
read -n 1 -s

salt-call state.highstate
