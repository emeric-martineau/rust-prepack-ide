#!/usr/bin/env sh
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

create_volume() {
  local VOLUME_NAME="$1"
  local IS_VOLUME_EXISTS="$(docker volume list --filter "Name=${VOLUME_NAME}")"

  if [ -z "${IS_VOLUME_EXISTS}" ]; then
    echo "Create missing volume '${VOLUME_NAME}'"
    docker volume create --name "${VOLUME_NAME}"
  fi
}

. "${BASEDIR}/config.cfg"

if [ ! $# -eq 1 ]; then
  echo "Run script with option 'atom', 'intellij' or 'vim'!" >&2
  exit 1
fi

EDITOR="$1"

case "${EDITOR}" in
  "atom")
    if [ ! -f atom.deb ]; then
      curl -o atom.deb -L https://atom-installer.github.com/v${ATOM_VERSION}/atom-amd64.deb
    fi;;
  "intellij")
    if [ ! -f intellij.tar.gz ]; then
      curl -o intellij.tar.gz -L https://download.jetbrains.com/idea/ideaIC-${INTELLIJ_VERSION}-no-jdk.tar.gz
    fi;;
  "vim");;
  *)
    echo "Run script with option 'atom', 'intellij', 'vim'!" >&2
    exit 1;;
esac

create_volume "${DOCKER_HOME_VOLUME_NAME}"

docker build . \
  -t "${DOCKER_IMAGE_NAME}" \
  -f docker-files/Dockerfile.${EDITOR}

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
    -e USERNAME_TO_RUN=${USER} \
    -e USERNAME_TO_RUN_GID=${GID} \
    -e USERNAME_TO_RUN_UID=${UID} \
    -t \
    --rm \
    --init \
    "${DOCKER_IMAGE_NAME}" /bin/bash /install/install-scripts/install-${EDITOR}-plugin.sh
fi
