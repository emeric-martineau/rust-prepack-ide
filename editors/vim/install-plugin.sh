#!/usr/bin/env bash

# From https://raw.githubusercontent.com/ivanceras/rustupefy/master/setup.sh

# Install on plugin
#
# $1 plugin folder
# $2 git url
# $3 git branch
install_plugin() {
  if [ -d "$1" ]; then
    echo -n " (updating)"
    cd "$1"
    git pull >/dev/null 2>&1
  else
    git clone --depth 1 --branch "$3" "$2" "$1" >/dev/null 2>&1
  fi
}

# Install all plugin.
#
# $1 plugin list
install_plugins() {
  for plugin in ${1}; do
    echo -n "Install plugin '${plugin}'"

    if [ -d "${PLUGINS_BASEDIR}/${plugin}" ]; then
      chmod u+x "${PLUGINS_BASEDIR}/${plugin}/install.sh"

      "${PLUGINS_BASEDIR}/${plugin}/install.sh"

      if [ $? -eq 0 ]; then
        print_ok
      else
        print_ko
      fi
    else
      echo -n " [folder plugin missing]"
      print_ko
    fi
  done
}

REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"
PLUGINS_BASEDIR="${BASEDIR}/plugins"

. "${BASEDIR}/config.cfg"

if [ -n "$1" ]; then
  SCRIPTS_BASEDIR="$1/install-scripts"
else
  SCRIPTS_BASEDIR="${BASEDIR}/../../install-scripts"
fi

. "${SCRIPTS_BASEDIR}/common.sh"

# make vim directories
mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle $HOME/.vim/plugin/

export -f install_plugin

install_plugins "${PLUGINS}"
