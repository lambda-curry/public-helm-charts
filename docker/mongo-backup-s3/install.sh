#! /bin/sh

# exit if a command fails
set -e


apk update

# install mysqldump
apk add mongodb-tools

# install s3 tools
apk add python3 py3-pip
pip3 install awscli six

# install go-cron
apk add curl
# cleanup
rm -rf /var/cache/apk/*
