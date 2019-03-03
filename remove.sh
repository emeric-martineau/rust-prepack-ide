#!/usr/bin/env sh
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

. "${BASEDIR}/config.cfg"

docker image rm "${DOCKER_IMAGE_NAME}"
docker volume rm ${DOCKER_ATOM_HOME_VOLUME_NAME}

if [ "$1" != "--keep-rust-home-volume" ]; then
  docker volume rm ${DOCKER_RUST_HOME_VOLUME_NAME}
fi
