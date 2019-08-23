#!/bin/bash

# Utility script to more easily update and manage nvim vim-plug deps

env SHELL=$(which sh) nvim +PlugInstall +PlugClean +PlugUpdate +UpdateRemotePlugins
