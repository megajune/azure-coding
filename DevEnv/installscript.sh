#!/bin/bash

cd /tmp

sudo apt update

sudo apt install apt-transport-https ca-certificates curl software-properties-common -f

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

apt-cache policy docker-ce

sudo apt install docker-ce -f

sudo systemctl status docker

#apt-get install resolvconf

