#!/usr/bin/env sh
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"
EDITOR_BASEDIR="${BASEDIR}/editors"
DL_BASEDIR="${BASEDIR}/download"

create_volume() {
  local VOLUME_NAME="$1"
  local IS_VOLUME_EXISTS="$(docker volume list --filter "Name=${VOLUME_NAME}")"

  if [ -z "${IS_VOLUME_EXISTS}" ]; then
    echo "Create missing volume '${VOLUME_NAME}'"
    docker volume create --name "${VOLUME_NAME}"
  fi
}

. "${BASEDIR}/config.cfg"

if [ ! $# -eq 1 ] || [ ! -d "${EDITOR_BASEDIR}/$1" ] ; then
  echo -n "Run script with option " >&2
  for editor in $(ls "${EDITOR_BASEDIR}"); do
    echo -n "'${editor}' " >&2
  done
  echo "!" >&2

  exit 1
fi

. "${BASEDIR}/config.cfg"

# Include editor config
EDITOR="$1"
. "${EDITOR_BASEDIR}/${EDITOR}/config.cfg"

# Download file if need
if [ -n "${DOWNLOAD_FILE}" ] && [ -n "${DOWNLOAD_URL}" ]; then
  mkdir -p "${DL_BASEDIR}"

  if [ ! -f "${DL_BASEDIR}/${DOWNLOAD_FILE}" ]; then
    curl -o "${DL_BASEDIR}/${DOWNLOAD_FILE}" -L "${DOWNLOAD_URL}"
  fi
fi

create_volume "${DOCKER_HOME_VOLUME_NAME}"

docker build . \
  -t "${DOCKER_IMAGE_NAME}" \
  -f "${EDITOR_BASEDIR}/${EDITOR}/Dockerfile"

if [ $? -eq 0 ]; then
  UID=$(id -u ${USER})
  GID=$(id -g ${USER})

  echo "Install rust..."

  docker run \
    -v ${DOCKER_HOME_VOLUME_NAME}:/home/${USER} \
    -v ${BASEDIR}:/install \
    -e USERNAME_TO_RUN=${USER} \
    -e USERNAME_TO_RUN_GID=${GID} \
    -e USERNAME_TO_RUN_UID=${UID} \
    -it \
    --rm \
    --init \
    "${DOCKER_IMAGE_NAME}" /bin/bash /install/install-scripts/install-rust.sh

  echo "Install ${EDITOR} plugins..."

  docker run \
    -v ${DOCKER_HOME_VOLUME_NAME}:/home/${USER} \
    -v ${BASEDIR}:/install \
    -v "${EDITOR_BASEDIR}/${EDITOR}":/install/editor \
    -e USERNAME_TO_RUN=${USER} \
    -e USERNAME_TO_RUN_GID=${GID} \
    -e USERNAME_TO_RUN_UID=${UID} \
    -t \
    --rm \
    --init \
    "${DOCKER_IMAGE_NAME}" /bin/bash /install/editor/install-plugin.sh
fi
