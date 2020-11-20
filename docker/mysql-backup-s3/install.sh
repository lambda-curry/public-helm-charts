#! /bin/sh

# exit if a command fails
set -e


apk update

# install mysqldump
apk add mysql-client

# install s3 tools
apk add python3 py3-pip
pip3 install awscli six

# install go-cron
apk add curl
curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron
chmod u+x /usr/local/bin/go-cron

# cleanup
rm -rf /var/cache/apk/*
