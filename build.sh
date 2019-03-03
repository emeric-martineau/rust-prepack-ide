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

if [ ! -f atom.deb ]; then
  curl -o atom.deb -L https://atom-installer.github.com/v${ATOM_VERSION}/atom-amd64.deb
fi

create_volume "${DOCKER_DOCKER_DOCKER_RUST_HOME_VOLUME_NAME}"
create_volume "${DOCKER_DOCKER_DOCKER_ATOM_HOME_VOLUME_NAME}"

docker build . \
  -t "${DOCKER_IMAGE_NAME}" \
  -f docker-files/Dockerfile \
  --build-arg "rust_home=${RUST_HOME}" \
  --build-arg "rustup_home=${RUSTUP_HOME}" \
  --build-arg "cargo_home=${CARGO_HOME}" \
  --build-arg "cargo_bin=${CARGO_BIN}"

if [ $? -eq 0 ]; then
  UID=$(id -u ${USER})
  GID=$(id -g ${USER})

  echo "Install atom plugin..."

  docker run \
    -v ${DOCKER_DOCKER_DOCKER_ATOM_HOME_VOLUME_NAME}:/home/${USER} \
    -v ${DOCKER_DOCKER_DOCKER_RUST_HOME_VOLUME_NAME}:/opt/rust \
    -v ${BASEDIR}:/install \
    -e USERNAME_TO_RUN=${USER} \
    -e USERNAME_TO_RUN_GID=${GID} \
    -e USERNAME_TO_RUN_UID=${UID} \
    -t \
    --rm \
    --init \
    "${DOCKER_IMAGE_NAME}" /bin/sh /install/install-scripts/install-atom-plugin.sh

  echo "Install rust..."

  docker run \
    -v ${DOCKER_DOCKER_DOCKER_ATOM_HOME_VOLUME_NAME}:/home/${USER} \
    -v ${DOCKER_DOCKER_DOCKER_RUST_HOME_VOLUME_NAME}:/opt/rust \
    -v ${BASEDIR}:/install \
    -e USERNAME_TO_RUN=${USER} \
    -e USERNAME_TO_RUN_GID=${GID} \
    -e USERNAME_TO_RUN_UID=${UID} \
    -t \
    --rm \
    --init \
    "${DOCKER_IMAGE_NAME}" /bin/sh /install/install-scripts/install-rust.sh
fi
