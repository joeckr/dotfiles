#!/bin/sh
brew tap siderolabs/tap
brew trust siderolabs/tap
CI=1 brew install siderolabs/tap/talosctl
