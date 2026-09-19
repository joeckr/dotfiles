#!/bin/sh
CI=1 brew install podman
CI=1 brew install --cask podman-desktop

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOTFILES_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

mkdir -p "$HOME/.config/containers"
cp "$DOTFILES_DIR/containers/containers.conf" "$HOME/.config/containers/containers.conf"

if ! podman machine inspect >/dev/null 2>&1; then
	podman machine init
	podman machine start
fi
