#! /usr/bin/env bash

set -e

sudo apt update
sudo apt -y full-upgrade

# Install the dependencies for building python
sudo apt install -y build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl git \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
libffi-dev liblzma-dev

curl https://pyenv.run | bash

# Add the "loader" line to .bashrc ONLY if it's not already there
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PYENV_CONFIG_FILE="$SCRIPT_DIR/.pyenvrc"
LOADER_LINE="[[ -f $PYENV_CONFIG_FILE ]] && source $PYENV_CONFIG_FILE"

if ! grep -Fq "$LOADER_LINE" ~/.bashrc; then
    echo -e "\n# Load pyenv configuration\n$LOADER_LINE\n" >> ~/.bashrc
    echo "Added loader to ~/.bashrc"
else
    echo "Loader already exists in ~/.bashrc"
fi

source ~/.bashrc

