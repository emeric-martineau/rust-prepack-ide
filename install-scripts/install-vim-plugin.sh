#!/usr/bin/env bash

# From https://raw.githubusercontent.com/ivanceras/rustupefy/master/setup.sh

## make vim directories
mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle $HOME/.vim/plugin/

## install pathogen
curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

## go to working directory
cd $HOME/.vim/bundle

## Update or install

## copy the vimrc file
curl -LSso $HOME/.vimrc https://raw.githubusercontent.com/ivanceras/rustupefy/master/vimrc

## update or install nerdtree PLUGIN #1
if [ -d $HOME/.vim/bundle/nerdtree ]; then
  # Add let g:NERDTreeDirArrows=0
    echo "Updating existing nerdtree plugin"
    cd $HOME/.vim/bundle/nerdtree/
    git pull
else
    echo "Installing nerdtree plugin"
    git clone --depth 1 --branch master https://github.com/scrooloose/nerdtree.git $HOME/.vim/bundle/nerdtree/
fi

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
