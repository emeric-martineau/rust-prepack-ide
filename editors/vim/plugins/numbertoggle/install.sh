#!/usr/bin/env bash

install_plugin "${HOME}/.vim/bundle/vim-numbertoggle" https://github.com/jeffkreeftmeijer/vim-numbertoggle.git master

# Enable plugin
cat <<EOF >>${HOME}/.vimrc

"------------------------------[ numbertoggle ]---------------------------------
"number toggle
"if you want relative number by default
"set relativenumber
"set to abosulte numerbing
set number
"CTRL-n to toggle numbers
nnoremap <silent> <C-n> :set relativenumber!<cr>
"set norelativenumber
"-------------------------------------------------------------------------------

EOF
