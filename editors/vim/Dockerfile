FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y \
  curl bash build-essential sudo git vim

COPY docker-files/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
