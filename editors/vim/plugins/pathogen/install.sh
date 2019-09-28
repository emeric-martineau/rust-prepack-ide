#!/usr/bin/env bash

PLUGIN_FILE="${HOME}/.vim/autoload/pathogen.vim"

if [ -f "${PLUGIN_FILE}" ]; then
  echo -n " (updating)"
fi

curl -Lo "${PLUGIN_FILE}" https://tpo.pe/pathogen.vim >"${INSTALL_PLUGIN_VIM_LOGFILE}" 2>&1

if [ $? -eq 0 ]; then
# Enable plugin
cat <<EOF >>${HOME}/.vimrc

"--------------------------------[ pathogen ]-----------------------------------
execute pathogen#infect()
syntax on
"filetype plugin indent on
"-------------------------------------------------------------------------------

EOF
else
  exit 1
fi
