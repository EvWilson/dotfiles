#!/bin/bash

# Dotfile symlink manager

# Create associative array of dotfiles(key) to symlink(val)
# NOTE: assoc arrays added in bash 4
declare -A arr
arr["${HOME}/.dotfiles/nvim/init.vim"]="${HOME}/.config/nvim/init.vim"
arr["${HOME}/.dotfiles/alacritty/alacritty.yml"]="${HOME}/.config/alacritty/alacritty.yml"

# Add ability to remove symlinks if need be/they get messed up
if [ \( $# -eq 1 \) -a \( "${1}" == "--rm" \) ]; then
    for key in ${!arr[@]}; do
        echo "Removing ${key} <- ${arr[${key}]} ..."
        unlink ${arr[${key}]}
    done
    exit 0
fi

# Link config files to their needed destinations
for key in ${!arr[@]}; do
    echo "Creating link ${key} <- ${arr[${key}]} ..."
    ln -s ${key} ${arr[${key}]}
done
