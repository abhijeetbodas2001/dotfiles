#!/usr/bin/env bash

# "Installing" dotfiles is just copying them at the right place

# cd to the location where the dotfiles are
cd "$(dirname "$0")"
for file in\
    ".bashrc"\
    ".bash_aliases"\
    ".bash_profile"\
    ".inputrc"\
    ".gitconfig"\
    ".vimrc"
do
    echo $file
    cp "$file" ~/"$file"
done

mkdir -p ~/.config
cp -R .config/* ~/.config/

