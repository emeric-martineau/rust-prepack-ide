#!/usr/bin/env sh
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

UID=$(id -u ${USER})
GID=$(id -g ${USER})

. "${BASEDIR}/config.cfg"

docker run -v /dev/shm:/dev/shm \
           -v ${DOCKER_ATOM_HOME_VOLUME_NAME}:/home/${USER} \
           -v ${DOCKER_RUST_HOME_VOLUME_NAME}:/opt/rust \
           -v ${SOURCE_FOLDER}:/home/${USER}/Documents \
           -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
           -e DISPLAY \
           -e USERNAME_TO_RUN=${USER} \
           -e USERNAME_TO_RUN_GID=${GID} \
           -e USERNAME_TO_RUN_UID=${UID} \
           --init \
           -it \
           --rm \
           "${DOCKER_IMAGE_NAME}" /usr/bin/atom -f
