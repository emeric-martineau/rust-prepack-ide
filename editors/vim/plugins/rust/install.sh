#!/usr/bin/env bash

RUST_FOLDER="${HOME}/.vim/bundle/rust.vim "

if [ -d "${RUST_FOLDER}" ]; then
    echo -n " (updating)"
    cd "${RUST_FOLDER}"
    git pull
else
    git clone --depth 1 --branch master https://github.com/rust-lang/rust.vim.git "${RUST_FOLDER}"
fi
