#!/bin/sh
if command -v mise >/dev/null 2>&1; then
    mise use -g hk
else
    ARCH=$(uname -m)
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$ARCH" in
        x86_64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    case "$OS" in
        linux) TARGET="${ARCH}-unknown-linux-gnu" ;;
        darwin) TARGET="${ARCH}-apple-darwin" ;;
        *) echo "Unsupported OS: $OS"; exit 1 ;;
    esac
    mkdir -p "$HOME/.local/bin"
    curl -sSfL "https://github.com/jdx/hk/releases/latest/download/hk-${TARGET}.tar.gz" | tar -xz -C "$HOME/.local/bin" hk
fi
