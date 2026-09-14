#!/bin/sh
CI=1 brew install openssh

# shellcheck disable=SC2016
echo 'export PATH="/opt/homebrew/opt/openssh/bin:$PATH"' >> ~/.zshrc
# shellcheck source=/dev/null
. "$HOME/.zshrc"
