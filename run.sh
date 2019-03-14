#!/usr/bin/env sh
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"


UID=$(id -u ${USER})
GID=$(id -g ${USER})

. "${BASEDIR}/config.cfg"

EDITOR="$1"
EXEC_CMD=""
DCK_EXTRA_ARGS=""

case "${EDITOR}" in
  "atom") EXEC_CMD="${ATOM_EXEC}";;
  "intellij") EXEC_CMD="${INTELLIJ_EXEC}";;
  "vim") EXEC_CMD="${VIM_EXEC}"; DCK_EXTRA_ARGS="-it";;
  *)
    echo "Run script with option 'atom' or 'intellij'!" >&2
    exit 1;;
esac

if [ "$2" = "--shell" ]; then
  EXEC_CMD="/bin/bash"
  DCK_EXTRA_ARGS="-it"
fi

docker run -v /dev/shm:/dev/shm \
           -v ${DOCKER_HOME_VOLUME_NAME}:/home/${USER} \
           -v ${SOURCE_FOLDER}:/home/${USER}/Documents \
           -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
           -e DISPLAY \
           -e USERNAME_TO_RUN=${USER} \
           -e USERNAME_TO_RUN_GID=${GID} \
           -e USERNAME_TO_RUN_UID=${UID} \
           --init \
           --rm ${DCK_EXTRA_ARGS} \
           "${DOCKER_IMAGE_NAME}" ${EXEC_CMD}
