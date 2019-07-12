#!/bin/bash

env SHELL=$(which sh) vim +PlugInstall +PlugClean +PlugUpdate +UpdateRemotePlugins
