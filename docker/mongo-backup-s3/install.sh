#! /bin/sh

# exit if a command fails
set -e

# install mongodump
apt-get update
apt-get install -y gnupg wget
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update

apt-get install -y mongodb-org-shell mongodb-org-tools curl

# install s3 tools
apt-get install -y python3 python3-pip
pip3 install awscli six

apt-get clean
