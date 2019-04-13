FROM ubuntu:18.04

ARG LINUX_EXTRA_PACKAGES

RUN apt-get update
RUN apt-get install -y \
  curl bash build-essential sudo git jq openjdk-8-jdk unzip $LINUX_EXTRA_PACKAGES

################################## INTELLIJ ####################################
COPY download/intellij.tar.gz /tmp/intellij.tar.gz

RUN mkdir /opt/intellij

RUN tar -xzf /tmp/intellij.tar.gz -C /opt/intellij --strip 1 && \
      rm -f /tmp/intellij.tar.gz

COPY docker-files/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
