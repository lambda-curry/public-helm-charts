#! /bin/bash

set -e

if [ "${S3_ACCESS_KEY_ID}" == "**None**" ]; then
  echo "Warning: You did not set the S3_ACCESS_KEY_ID environment variable."
fi

if [ "${S3_SECRET_ACCESS_KEY}" == "**None**" ]; then
  echo "Warning: You did not set the S3_SECRET_ACCESS_KEY environment variable."
fi

if [ "${S3_BUCKET}" == "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${MONGO_HOST}" == "**None**" ]; then
  echo "You need to set the MONGO_HOST environment variable."
  exit 1
fi

if [ "${MONGO_PORT}" == "**None**" ]; then
  export MONGO_PORT=27017
fi

if [ "${MONGO_USER}" == "**None**" ]; then
  echo "You need to set the MONGO_USER environment variable."
  exit 1
fi

if [ "${MONGO_PASSWORD}" == "**None**" ]; then
  echo "You need to set the MONGO_PASSWORD environment variable."
  exit 1
fi

if [ "${S3_IAMROLE}" != "true" ]; then
  # env vars needed for aws tools - only if an IAM role is not used
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
  export AWS_DEFAULT_REGION=$S3_REGION
fi

MONGO_URI="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}"
DUMP_START_TIME=$(date +"%Y-%m-%dT%H%M%SZ")

error_notify() {
  MESSAGE=$1
  >&2 echo $MESSAGE
  if [ ! "${SLACK_WEBHOOK_URL}" == "**None**" ]; then
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${MESSAGE}\"}" $SLACK_WEBHOOK_URL
  fi
}

copy_s3 () {
  SRC_FILE=$1
  DEST_FILE=$2

  if [ "${S3_ENDPOINT}" == "**None**" ]; then
    AWS_ARGS=""
  else
    AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi

  echo "Uploading ${DEST_FILE} on S3..."

  cat $SRC_FILE | aws $AWS_ARGS s3 cp - s3://$S3_BUCKET/$S3_PREFIX/$DEST_FILE

  if [ $? != 0 ]; then
    error_notify "Error uploading ${DEST_FILE} on S3"
    exit 1
  fi

  rm $SRC_FILE
}

# Multi file: yes
if [ ! -z "$(echo $MULTI_FILES | grep -i -E "(yes|true|1)")" ]; then
  DATABASES=`echo "db.getMongo().getDBNames()"|mongo "${MONGO_URI}" --quiet |tr -d \[\] | tr , "\n"|cut -c3-| tr -d \"| grep -Ev "(config|local)"`

  for DB in $DATABASES; do
    echo "Creating individual dump of ${DB} from ${MONGO_HOST}..."

    DUMP_FILE="/tmp/${DB}.gz"

    echo "mongodump \"${MONGO_URI}\" --db $DB --archive=$DUMP_FILE --gzip"

    mongodump "${MONGO_URI}" --authenticationDatabase ${MONGO_AUTH_DATABASE} --db $DB --archive=$DUMP_FILE --gzip
    
    if [ $? != 0 ]; then
      error_notify "Failed to execute mongodump"
    fi

    if [ $? == 0 ]; then
      if [ "${S3_FILENAME}" == "**None**" ]; then
        S3_FILE="${DUMP_START_TIME}.${DB}.gz"
      else
        S3_FILE="${S3_FILENAME}.${DB}.gz"
      fi

      copy_s3 $DUMP_FILE $S3_FILE
    else
      error_notify "Error creating dump of ${DB}"
    fi
  done
# Multi file: no
else
  echo "Creating dump for ${MONGODUMP_DATABASE} from ${MONGO_HOST}..."

  DUMP_FILE="/tmp/all.gz"

  echo "mongodump \"${MONGO_URI}\" --archive=$DUMP_FILE --gzip"
  mongodump "${MONGO_URI}" --authenticationDatabase ${MONGO_AUTH_DATABASE} --archive=$DUMP_FILE --gzip

  if [ $? == 0 ]; then
    if [ "${S3_FILENAME}" == "**None**" ]; then
      S3_FILE="${DUMP_START_TIME}.all.gz"
    else
      S3_FILE="${S3_FILENAME}.gz"
    fi
    copy_s3 $DUMP_FILE $S3_FILE
  else
    error_notify "Error creating dump of all databases"
  fi
fi

echo "Mongo backup finished"
