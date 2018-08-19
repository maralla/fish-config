#!/usr/bin/env sh

set -e

FISH=~/.config/fish

date=$(date "+%Y-%m-%dT%H:%M:%S")

# backup
test -d $FISH && mv $FISH $FISH-bak-$date

# clone source
git clone https://github.com/maralla/fish-config.git $FISH

# install fisher
curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://raw.githubusercontent.com/fisherman/fisherman/master/fisher.fish

# install plugins
fisher up

# Rely on py2 virtualenv
# install python virtualenv helpers
$HOME/.dotfiles/virtualenvs/py2/bin/pip install virtualfish
