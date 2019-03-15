#!/usr/bin/env bash

# Set nightly channel in atom config file for 'ide-rust' plugin.
#
# $1
set_channel_in_atom_editor() {
  filename="${HOME}/.atom/config.cson"
  local line_number=$(cat "${filename}" | grep -n 'rlsToolchain' | cut -d ':' -f 1)
  sed -i ${line_number}'s/.*/    rlsToolchain: "'$1'"/' "${filename}"
}

REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

. "${BASEDIR}/config.cfg"
. "${BASEDIR}/../install-scripts/common.sh"

# Check if apm is installed
if [ -z "$(command -v apm)" ]; then
  echo -n "Atom not found! Check 'apm' is in path "
  print_ko
  exit 1
fi

CHANNEL=$(cat "${TMP_RUST_CHANNEL}")

for pck_name in ${PLUGINS}; do
  # Check if package is installed
  IS_INSTALLED=$(apm list --installed --bare | grep "${pck_name}")

  if [ -n "${IS_INSTALLED}" ]; then
    echo "Atom package '${pck_name}' already installed"
  else
    apm install "${pck_name}"
  fi
done

if [ ! -f "~/.atom/config.cson" ]; then
  cp ${BASEDIR}/template/config.cson ~/.atom/config.cson
fi

if [ ! -f "~/.atom/terminal-commands.json" ]; then
  cp ${BASEDIR}/template/terminal-commands.json ~/.atom/terminal-commands.json
fi

set_channel_in_atom_editor "${CHANNEL}"

rm -rf "${TMP_RUST_CHANNEL}"
