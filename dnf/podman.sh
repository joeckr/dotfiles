#!/bin/sh
sudo dnf install -y podman

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOTFILES_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

mkdir -p "$HOME/.config/containers"
cp "$DOTFILES_DIR/containers/containers.conf" "$HOME/.config/containers/containers.conf"
