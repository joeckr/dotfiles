#!/bin/sh
/bin/bash -c "$(curl -fsSL https://raw.githubcontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /Users/"$USER"/.zprofile
# shellcheck disable=SC2016
echo 'eval "$(/usr/local/bin/brew shellenv zsh)"' >> /Users/"$USER"/.zprofile
eval "$(/usr/local/bin/brew shellenv zsh)"

brew update
