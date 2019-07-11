#!/bin/bash

env SHELL=$(which sh) nvim +PlugInstall +PlugClean +PlugUpdate +UpdateRemotePlugins
