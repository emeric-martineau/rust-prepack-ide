#!/usr/bin/env bash

# Install rustup components.
#
# $1 list of components
# $2 (optional) rust channel
install_rustup_components() {
  local rustup_components="$1"
  local channel=""

  if [ -n "$2" ]; then
    channel="--toolchain $2"
  fi

  local current_rustup_components="$(rustup component list)"
  local is_installed=""

  # Install cargo components
  if [ -n "${rustup_components}" ]; then
    for pck_name in ${rustup_components}; do
      # Check if package is installed
      is_installed=$(echo $current_rustup_components | grep "${pck_name}")

      if [ -n "${is_installed}" ]; then
        echo -n "Rustup package '${pck_name}' already installed"
        print_ok
      else
        rustup component add "${pck_name}" ${channel}
      fi
    done
  fi
}

# Install cargo components.
#
# $1 list of components
# $2 (optional) rust channel
install_cargo_components() {
  local cargo_components="$1"
  local channel=""

  if [ -n "$2" ]; then
    channel="+$2"
  fi

  local current_cargo_components="$(cargo install --list)"
  local is_installed=""

  # Install cargo components
  if [ -n "${cargo_components}" ]; then
    for pck_name in ${cargo_components}; do
      # Check if package is installed
      is_installed=$(echo ${current_cargo_components} | grep "${pck_name}")

      if [ -n "${is_installed}" ]; then
        echo -n "Cargo package '${pck_name}' already installed"
        print_ok
      else
        cargo ${channel} install "${pck_name}"
      fi
    done
  fi
}

REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

. "${BASEDIR}/../config.cfg"

. "${BASEDIR}/common.sh"

if [ "$(whoami)" != "${USERNAME_TO_RUN}" ]; then
  sudo chown -R ${USERNAME_TO_RUN}:${USERNAME_TO_RUN} ${RUST_HOME}
fi

# Check if need install rust
if [ ! -f "${CARGO_BIN}/rustup" ]; then
  curl https://sh.rustup.rs -sSf -o /tmp/install-rust.sh
  chmod u+x /tmp/install-rust.sh

  /tmp/install-rust.sh -v -y
  rm /tmp/install-rust.sh
fi

# Install stable version if set
if [ -n "${RUST_STABLE_CHANEL_VERSION}" ] && [ -z "$(rustup show | grep ${RUST_STABLE_CHANEL_VERSION})" ]; then
  echo ${CARGO_BIN}/rustup install "${RUST_STABLE_CHANEL_VERSION}"
fi

rustup install nightly

install_rustup_components "rls-preview rls rust-analysis rust-src" "nightly"
install_rustup_components "${RUSTUP_COMPONENTS}"

install_cargo_components "racer" "nightly"
install_cargo_components "${CARGO_COMPONENTS}"
