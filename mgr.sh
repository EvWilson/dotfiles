#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

function usage() {
    echo "Usage:"
    echo "link -    symlinks configs for nvim and tmux"
    echo "refresh - refresh nvim plugins and packages"
    echo "vimplug-install - install vimplug"
}

# Dotfile symlink management
function link_configs() {
    # Ensure that the minimum bash version (4) is installed
    if [ ${BASH_VERSION::1} -lt 4 ]; then
        echo "Script requires bash v4 and above"
        exit
    fi

    # Create associative array of dotfiles(key) to symlink(val)
    # NOTE: assoc arrays added in bash 4
    declare -A arr
    arr["${SOURCE_DIR}/nvim/init.vim"]="${HOME}/.config/nvim/init.vim"
    arr["${SOURCE_DIR}/tmux/tmux.conf"]="${HOME}/.tmux.conf"

    # Check if each value path exists, create it if it doesn't
    for key in ${!arr[@]}; do
        if [ ! -d $( dirname ${arr[${key}]} ) ]; then
            echo "Directory $( dirname ${arr[${key}]} ) does not exist, creating..."
            mkdir -p $( dirname ${arr[${key}]} )
        fi
    done

    # Link config files to their needed destinations
    for key in ${!arr[@]}; do
        echo "Creating link ${key} <- ${arr[${key}]} ..."
        ln -s ${key} ${arr[${key}]}
    done
}

# Refresh and update neovim packages
function refresh_plugins() {
    nvim +PlugInstall +PlugClean +PlugUpdate +UpdateRemotePlugins
}

# Install vimplug
function vimplug_install() {
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

if [ $# == 0 ]; then
    usage
    exit 0
fi
case $1 in
    "link")
        link_configs
        exit 0
        ;;
    "refresh")
        refresh_plugins
        exit 0
        ;;
    "vimplug-install")
        vimplug_install
        exit 0
        ;;
    *)
        echo "Undefined input, run w/o args for usage"
        exit 1
        ;;
esac
