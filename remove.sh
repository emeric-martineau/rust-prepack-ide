#!/usr/bin/env sh
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

. "${BASEDIR}/config.cfg"

docker image rm "${DOCKER_IMAGE_NAME}"

if [ "$1" != "--keep-rust-home-volume" ]; then
  docker volume rm ${DOCKER_HOME_VOLUME_NAME}
fi
