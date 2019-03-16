#!/usr/bin/env bash

NERDTREE_FOLDER="${HOME}/.vim/bundle/nerdtree"

if [ -d "${NERDTREE_FOLDER}" ]; then
  echo -n " (updating)"
  cd "${NERDTREE_FOLDER}"
  git pull
else
  git clone --depth 1 --branch master https://github.com/scrooloose/nerdtree.git "${NERDTREE_FOLDER}"
fi

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
