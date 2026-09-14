#!/bin/sh
sudo pacman -S --noconfirm --needed git base-devel #Dependencies
sudo pacman -S --noconfirm --needed rustup

rustup default stable
