#!/usr/bin/env bash

# Before committing, run this script to copy changes
# made to the actual dotfiles into the dotfiles repo
for file in\
    ".bashrc"\
    ".bash_aliases"\
    ".bash_profile"\
    ".inputrc"\
    ".gitconfig"\
    ".vimrc"
do
    echo $file
    rsync -t ~/"$file" ~/code/dotfiles/
done

mkdir -p .config/nvim
cp ~/.config/nvim/init.lua .config/nvim
cp -R ~/.config/nvim/autoload/ .config/nvim

mkdir -p .config/Code/User/
cp ~/.config/Code/User/{settings.json,keybindings.json} .config/Code/User/

dconf dump / > ./gnome_settings # to restore, dconf load / < ./gnome_settings

mkdir -p .config/mpv
cp ~/.config/mpv/* .config/mpv/

mkdir -p .config/ptpython
cp ~/.config/ptpython/* .config/ptpython

