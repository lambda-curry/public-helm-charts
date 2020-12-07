FROM alpine:3.12
LABEL maintainer="Derek Wene <derek@lambdacurry.dev>"

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

ENV MONGODUMP_DATABASE all
ENV MONGO_HOST **None**
ENV MONGO_PORT 3306
ENV MONGO_USER **None**
ENV MONGO_PASSWORD **None**
ENV S3_ACCESS_KEY_ID **None**
ENV S3_SECRET_ACCESS_KEY **None**
ENV S3_BUCKET **None**
ENV S3_REGION us-east-1
ENV S3_ENDPOINT **None**
ENV S3_S3V4 no
ENV S3_PREFIX 'backup'
ENV S3_FILENAME **None**
ENV MULTI_FILES no

ADD backup.sh backup.sh

CMD ["sh", "backup.sh"]