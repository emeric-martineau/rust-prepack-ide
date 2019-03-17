#!/usr/bin/env bash

install_plugin "${HOME}/.vim/bundle/rust.vim" https://github.com/rust-lang/rust.vim.git master

# Enable plugin
cat <<EOF >>${HOME}/.vimrc

"----------------------------------[ rust ]-------------------------------------
"the following lines are appended from the setup to set RUST_SRC_PATH
"-------------------------------------------------------------------------------

EOF
