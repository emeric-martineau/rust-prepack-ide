#!/usr/bin/env bash

PLUGIN_FILE="${HOME}/.vim/plugin/racer.vim"

if [ -f "${PLUGIN_FILE}" ]; then
  echo -n " (updating)"
fi

curl -LSso "${PLUGIN_FILE}" https://raw.githubusercontent.com/racer-rust/vim-racer/master/ftplugin/rust_racer.vim
