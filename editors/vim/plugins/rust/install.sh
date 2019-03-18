#!/usr/bin/env bash

install_plugin "${HOME}/.vim/bundle/rust.vim" https://github.com/rust-lang/rust.vim.git master

if [ $? -eq 0 ]; then
  # Enable plugin
cat <<EOF >>${HOME}/.vimrc

"----------------------------------[ rust ]-------------------------------------
"the following lines are appended from the setup to set RUST_SRC_PATH
"-------------------------------------------------------------------------------

EOF
else
  exit 1
fi
