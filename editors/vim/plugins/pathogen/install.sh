#!/usr/bin/env bash

PLUGIN_FILE="${HOME}/.vim/autoload/pathogen.vim"

if [ -f "${PLUGIN_FILE}" ]; then
  echo -n " (updating)"
fi

curl -LSso "${PLUGIN_FILE}" https://tpo.pe/pathogen.vim

# Enable plugin
cat <<EOF >>${HOME}/.vimrc

"--------------------------------[ pathogen ]-----------------------------------
execute pathogen#infect()
syntax on
"filetype plugin indent on
"-------------------------------------------------------------------------------

EOF
