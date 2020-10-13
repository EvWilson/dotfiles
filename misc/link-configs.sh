#!/bin/bash

# Dotfile symlink manager

# Ensure that the minimum bash version (4) is installed
if [ ${BASH_VERSION::1} -lt 4 ]; then
    echo "Script requires bash v4 and above"
    exit 1
fi

# Create associative array of dotfiles(key) to symlink(val)
# NOTE: assoc arrays added in bash 4
declare -A arr
arr["${HOME}/.dotfiles/nvim/init.vim"]="${HOME}/.config/nvim/init.vim"
arr["${HOME}/.dotfiles/tmux/tmux.conf"]="${HOME}/.tmux.conf"

# Check if each value path exists, create it if it doesn't
for key in ${!arr[@]}; do
    if [ ! -d $( dirname ${arr[${key}]} ) ]; then
        echo "Directory $( dirname ${arr[${key}]} ) does not exist, creating..."
        mkdir -p $( dirname ${arr[${key}]} )
    fi
done

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
