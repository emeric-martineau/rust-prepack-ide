#!/usr/bin/env bash
install_plugin "${HOME}/.vim/bundle/vim-racer" https://github.com/racer-rust/vim-racer.git master

if [ $? -eq 0 ]; then
  FILE_PLUGIN="${HOME}/.vim/plugin/rust_racer.vim"

  if [ -f "${FILE_PLUGIN}" ]; then
    rm -rf "${FILE_PLUGIN}"
  fi

  ln -s "${HOME}/.vim/bundle/vim-racer/ftplugin/rust_racer.vim" "${FILE_PLUGIN}"

  CHANNEL=$(cat "${TMP_RUST_CHANNEL}")

  RUST_SYS_ROOT=$(rustup run "${CHANNEL}" rustc --print sysroot)

# Enable plugin
cat <<EOF >>${HOME}/.vimrc

"---------------------------------[ racer ]-------------------------------------
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)

let \$RUST_SRC_PATH="${RUST_SYS_ROOT}/lib/rustlib/src/rust/src"
"-------------------------------------------------------------------------------

EOF
else
  exit 1
fi
