#!/usr/bin/env sh
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

. "${BASEDIR}/config.cfg"

docker image rm "${DOCKER_IMAGE_NAME}"
docker volume rm ${ATOM_HOME_VOLUME_NAME}
docker volume rm ${RUST_HOME_VOLUME_NAME}
