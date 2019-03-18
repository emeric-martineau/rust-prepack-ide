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
    git pull >"${INSTALL_PLUGIN_VIM_LOGFILE}" 2>&1

    return $?
  else
    git clone --depth 1 --branch "$3" "$2" "$1" >"${INSTALL_PLUGIN_VIM_LOGFILE}" 2>&1

    return $?
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
        cat "${INSTALL_PLUGIN_VIM_LOGFILE}"
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
export INSTALL_PLUGIN_VIM_LOGFILE="/tmp/install_plugin_vim.log"


. "${BASEDIR}/config.cfg"

if [ -n "$1" ]; then
  SCRIPTS_BASEDIR="$1/install-scripts"
else
  SCRIPTS_BASEDIR="${BASEDIR}/../../install-scripts"
fi

. "${SCRIPTS_BASEDIR}/common.sh"

export TMP_RUST_CHANNEL

# make vim directories
mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle $HOME/.vim/plugin/

export -f install_plugin

cp "${BASEDIR}/.vimrc" "${HOME}"

install_plugins "${PLUGINS}"

rm -rf "${TMP_RUST_CHANNEL}" "${INSTALL_PLUGIN_VIM_LOGFILE}"
