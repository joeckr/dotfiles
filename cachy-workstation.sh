echo "This script will install a number of things on you Arch based desktop."
echo "Some software may require prompts, but most should be skipped."
echo "**WARNING** system will reboot once complete **WARNING**"

sudo pacman -Syu

# Pacman installation scripts
cd pacman
sh chromium.sh      # Browser of choice for debugging/testing
sh discord.sh       # Talking to friends
sh docker.sh        # Container things. I use primarily for local development
sh firefox.sh       # Incase it is not already installed. Browser of choice for coding things
sh gimp.sh          # Image editing
sh github-cli.sh    # Add github cli so that I can login :)
sh gitleaks.sh      # Finds secrets in codebase
sh go.sh            # Go programming language
sh gparted.sh       # Storage/Disk management
sh kate.sh          # One of a few text editors
sh kotlin.sh        # Kotlin programming language
sh kubectl.sh       # CLI tool for controlling kubernetes environments
sh lua.sh           # Lua programming language
sh mise.sh          # Tool to streamline installing application dependencies
sh neovim.sh        # Terminal based text editor
sh nodejs.sh        # Node programming language
sh obs-studio.sh    # Screen capture (Both local and through capture card)
sh obsidian.sh      # Notes
sh ollama.sh        # Local AI. Great for parsing through recently output things in the terminal
sh openjdk.sh       # Open Source Java programming language dev kit
sh openssh.sh       # SSH stuff
sh openssl.sh       # Important for web development and such
sh openvpn.sh       # VPN into your own networks! Or others
sh podman.sh        # Container things. I use primarily to test helm charts and run in my homelab
sh rust.sh          # Rust programming language
sh talosctl.sh      # Talos Container Platform
sh uv.sh            # Fast python package installer
sh vim.sh           # Terminal based text editor
sh vlc.sh           # All hail traffic cone media player
sh vscodium.sh      # Open Source version of VS Code IDE
sh warp.sh          # File transfer software
sh waydroid.sh      # Android on Linux
sh wezterm.sh       # Terminal
sh yay.sh           # Package Manager for AUR
sh zed.sh           # One of a few text editors

# AUR packages via yay
cd ../yay
sh brave.sh         # Browser of choice for gaming things
sh chrome.sh        # Browser of choice for work things
sh crc.sh           # CRC OpenShift Container Platform
sh prek.sh          # Pre commit
sh rust-desk.sh     # Remote desktop software

# NPM pacakges
cd ../npm
sh angular-cli.sh   # CLI tools for Angular framework
sh nodemon.sh       # Recompiles Node code as you make changes
sh vue-cli.sh       # CLI tools for Vue framework

reboot
