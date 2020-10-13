#!/bin/bash

# Utility script to more easily update and manage nvim vim-plug deps

nvim +PlugInstall +PlugClean +PlugUpdate +UpdateRemotePlugins
