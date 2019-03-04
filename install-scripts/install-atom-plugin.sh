#!/usr/bin/env bash
REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

. "${BASEDIR}/../config.cfg"

# Check if apm is installed
if [ -z "$(command -v apm)" ]; then
  . "${BASEDIR}/common.sh"

  echo -n "Atom not found! Check 'apm' is in path "
  print_ko
  exit 1
fi

for pck_name in ${ATOM_PACKAGE}; do
  # Check if package is installed
  IS_INSTALLED=$(apm list --installed --bare | grep "${pck_name}")

  if [ -n "${IS_INSTALLED}" ]; then
    echo "Atom package '${pck_name}' already installed"
  else
    apm install "${pck_name}"
  fi
done

cp ${BASEDIR}/template/config.cson ~/.atom/config.cson
cp ${BASEDIR}/template/terminal-commands.json ~/.atom/terminal-commands.json
