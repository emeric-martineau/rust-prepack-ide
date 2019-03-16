#!/usr/bin/env bash

# From https://raw.githubusercontent.com/ivanceras/rustupefy/master/setup.sh

# Install all plugin.
#
# $1 plugin list
install_plugin() {
  for plugin in ${1}; do
    echo -n "Install plugin '${plugin}'"

    if [ -d "${PLUGINS_BASEDIR}/${plugin}" ]; then
      chmod u+x "${PLUGINS_BASEDIR}/${plugin}/install.sh"

      "${PLUGINS_BASEDIR}/${plugin}/install.sh"

      if [ $? -eq 0 ]; then
        print_ok
      else
        print_ko
      fi
    else
      echo -n " [folder plugin missing]"
      print_ko
    fi
  done
}

REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"
PLUGINS_BASEDIR="${BASEDIR}/plugins"

. "${BASEDIR}/config.cfg"

if [ -n "$1" ]; then
  SCRIPTS_BASEDIR="$1/install-scripts"
else
  SCRIPTS_BASEDIR="${BASEDIR}/../../install-scripts"
fi

. "${SCRIPTS_BASEDIR}/common.sh"

# make vim directories
mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle $HOME/.vim/plugin/

install_plugin "${PLUGINS}"

exit

## update or install rust.vim PLUGIN #2
if [ -d $HOME/.vim/bundle/rust.vim ]; then
    echo "Updating existing rust.vim"
    cd $HOME/.vim/bundle/rust.vim/
    git pull
else
    echo "Installing rust.vim plugin"
    git clone --depth 1 --branch master https://github.com/rust-lang/rust.vim.git $HOME/.vim/bundle/rust.vim
fi

## update or install vim-airline PLUGIN #3
if [ -d $HOME/.vim/bundle/vim-airline ]; then
    echo "Updating existing vim-airline plugin"
    cd $HOME/.vim/bundle/vim-airline/
    git pull
elsep
    echo "Installing vim-airline plugin"
    git clone --depth 1 --branch master https://github.com/bling/vim-airline $HOME/.vim/bundle/vim-airline
fi

## update or install vim-numbertoggle PLUGIN #4
if [ -d $HOME/.vim/bundle/vim-numbertoggle ]; then
    echo "Updating existing $HOME/.vim/bundle/vim-numbertoggle plugin"
    cd $HOME/.vim/bundle/vim-numbertoggle/
    git pull
else
    echo "Installing vim-numbertoggle plugin"
    git clone --depth 1 --branch master git://github.com/jeffkreeftmeijer/vim-numbertoggle.git $HOME/.vim/bundle/numbertoggle
fi


## update vim-racer PLUGIN #5
curl -LSso $HOME/.vim/plugin/racer.vim https://raw.githubusercontent.com/racer-rust/vim-racer/master/ftplugin/rust_racer.vim
