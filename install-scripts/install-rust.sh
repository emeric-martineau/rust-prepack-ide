#!/usr/bin/env bash

# Check if nightly build contains rls-preview.
#
# $1 nightly build date with format 'YYYY-MM-DD'
# $2 arch name for rust
#
# print true or false
find_lastest_date_with_rls() {
  local check_date="$1"
  local arch="$2"
  local filename=/tmp/channel-rust-nightly.toml

  curl https://static.rust-lang.org/dist/${check_date}/channel-rust-nightly.toml --output ${filename} 2>/dev/null

  local line_number=$(cat "${filename}" | grep -n '\[pkg.rls-preview.target.'${arch}'\]' | cut -d ':' -f 1)
  line_number="$(expr ${line_number} + 1)"

  # Hope last line is 'available'
  local line="$(sed ${line_number}'!d' "${filename}" | grep 'available')"

  rm -f "${filename}"

  if [ -n "${line}" ]; then
    local available=$(echo ${line} |  cut -d '=' -f 2 | xargs)

    [ "${available}" = "true" ]

    return $?
  else
    return 1
  fi
}

# Find lastest nightly channel with rls-preview.
#
# Value set in 'CHANNEL' environment variable
find_rust_channel() {
  local arch="$(rustup show | grep 'Default host:' | cut -d ':' -f 2 | xargs)"

  echo "Search last available date of nightly channel for rls-preview"

  # rls-preview never available on current day
  local count=1

  while [ ${count} -lt 30 ]; do
    local current_date="$(date -d '19:00 today - '${count}' days' +'%Y-%m-%d')"

    echo -n "Check for nightly-${current_date}..."

    find_lastest_date_with_rls ${current_date} ${arch}

    if [ $? -eq 0 ]; then
      print_ok
      CHANNEL="nightly-${current_date}"
      return
    else
      print_ko
    fi

    count=$(expr ${count} + 1)
  done

  CHANNEL=""
}

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

find_rust_channel

if [ -z "${CHANNEL}" ]; then
  echo "Can't find a valid nightly channel for 'rls-preview'!" >&2
  exit 1
fi

install_rustup_components "rls-preview rls rust-analysis rust-src"
install_rustup_components "${RUSTUP_COMPONENTS}"

rustup install nightly
rustup install "${CHANNEL}"

install_rustup_components "rls-preview rls rust-analysis rust-src" "${CHANNEL}"

install_cargo_components "racer" "nightly"
install_cargo_components "${CARGO_COMPONENTS}"

echo "${CHANNEL}" > "${TMP_RUST_CHANNEL}"
