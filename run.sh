#!/usr/bin/env sh
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"


UID=$(id -u ${USER})
GID=$(id -g ${USER})

. "${BASEDIR}/config.cfg"

EDITOR="$1"
EXEC_CMD=""

case "${EDITOR}" in
  "atom") EXEC_CMD="${ATOM_EXEC}";;
  "intellij") EXEC_CMD="${INTELLIJ_EXEC}";;
  *)
    echo "Run script with option 'atom' or 'intellij'!" >&2
    exit 1;;
esac

docker run -v /dev/shm:/dev/shm \
           -v ${DOCKER_HOME_VOLUME_NAME}:/home/${USER} \
           -v ${SOURCE_FOLDER}:/home/${USER}/Documents \
           -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
           -e DISPLAY \
           -e USERNAME_TO_RUN=${USER} \
           -e USERNAME_TO_RUN_GID=${GID} \
           -e USERNAME_TO_RUN_UID=${UID} \
           --init \
           -it \
           --rm \
           "${DOCKER_IMAGE_NAME}" ${EXEC_CMD}
