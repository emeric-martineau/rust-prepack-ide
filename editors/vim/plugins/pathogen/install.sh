#!/usr/bin/env bash

PLUGIN_FILE="${HOME}/.vim/autoload/pathogen.vim"

if [ -f "${PLUGIN_FILE}" ]; then
  echo -n " (updating)"
fi

curl -LSso "${PLUGIN_FILE}" https://tpo.pe/pathogen.vim
