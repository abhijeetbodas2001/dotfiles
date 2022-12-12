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

rsync -a --delete ~/.config/ ~/code/dotfiles/.config/

