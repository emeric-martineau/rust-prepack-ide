#!/usr/bin/env bash

install_plugin "${HOME}/.vim/bundle/vim-airline" https://github.com/bling/vim-airline.git master

# Enable plugin
cat <<EOF >>${HOME}/.vimrc

"---------------------------------[ airline ]-----------------------------------
"use the power line fonts
let g:airline_powerline_fonts = 0

"This will allow the airline plugin to load up as soon as you start editing a file
set laststatus=2

"to get colors working correctly.
set t_Co=256
"-------------------------------------------------------------------------------

EOF
