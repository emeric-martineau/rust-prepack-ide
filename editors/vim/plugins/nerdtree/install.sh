#!/usr/bin/env bash

install_plugin "${HOME}/.vim/bundle/nerdtree" https://github.com/scrooloose/nerdtree.git master

if [ $? -eq 0 ]; then
# Enable plugin
cat <<EOF >>${HOME}/.vimrc

"--------------------------------[ nerdtree ]-----------------------------------
" Open nerdtree when no file arg specified
autocmd VimEnter * if !argc() | NERDTree | endif

"CTRL-t to toggle tree view with CTRL-t
nmap <silent> <C-t> :NERDTreeToggle<CR>
nmap <silent> <F2> :NERDTreeFind<CR>

let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '~'
"-------------------------------------------------------------------------------

EOF
else
  exit 1
fi
