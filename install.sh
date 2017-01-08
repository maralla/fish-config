#!/usr/bin/env sh

# install fisher
curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher

# install plugins
fisher up

# install python virtualenv helpers
pip install virtualfish
