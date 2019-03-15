#!/usr/bin/env sh
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"
EDITOR_BASEDIR="${BASEDIR}/editors"

UID=$(id -u ${USER})
GID=$(id -g ${USER})

. "${BASEDIR}/config.cfg"

if [ ! $# -eq 1 ] || [ ! -d "${EDITOR_BASEDIR}/$1" ] ; then
  echo -n "Run script with option " >&2
  for editor in $(ls "${EDITOR_BASEDIR}"); do
    echo -n "'${editor}' " >&2
  done
  echo "!" >&2

  exit 1
fi

# Include editor config
EDITOR="$1"
. "${EDITOR_BASEDIR}/${EDITOR}/config.cfg"
DCK_EXTRA_ARGS=""

if [ "$2" = "--shell" ]; then
  EXEC="/bin/bash"
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
           "${DOCKER_IMAGE_NAME}" ${EXEC}
