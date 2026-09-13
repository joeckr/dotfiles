echo "This script will install a number of things on your Windows desktop."
echo "Some software may require prompts, but most should be skipped."
echo "**WARNING** system will reboot once complete **WARNING**"

# Winget installation scripts
cd winget
sh 7zip.sh          # Archive utility
sh amd.sh           # AMD Software / Drivers
sh brave.sh         # Browser of choice for gaming things
sh chrome.sh        # Browser of choice for work things
sh chromium.sh      # Browser of choice for debugging/testing
sh crc.sh           # Red Hat OpenShift Local
sh discord.sh       # Talking to friends
sh docker.sh        # Container things. I use primarily for local development
sh dolphin-emu.sh   # Gamecube emulator
sh firefox.sh       # Incase it is not already installed. Browser of choice for coding things
sh gh.sh            # Add github cli so that I can login :)
sh git.sh           # Git version control
sh gitleaks.sh      # Finds secrets in codebase
sh go.sh            # Go programming language
sh godot.sh         # Game engine
sh helix.sh         # One of a few text editors
sh helm.sh          # Kubernetes package manager
sh kind.sh          # Kubernetes in Docker
sh kubectl.sh       # CLI tool for controlling kubernetes environments
sh lua.sh           # Lua programming language
sh mise.sh          # Tool to streamline installing application dependencies
sh nerdfonts.sh     # Cascadia Code Nerd Font for terminals and editors
sh node.sh          # Node programming language
sh obs.sh           # Screen capture (Both local and through capture card)
sh ollama.sh        # Local AI. Great for parsing through recently output things in the terminal
sh playnite.sh      # Unified game library manager
sh powertoys.sh     # System utilities (FancyZones, PowerToys Run)
sh prek.sh          # Pre commit
sh python.sh        # Python programming language
sh retroarch.sh     # RetroArch emulator
sh rust.sh          # Rust programming language via rustup
sh rustdesk.sh      # Remote desktop software
sh steam.sh         # Steam gaming platform
sh sunshine.sh      # Remote streaming software
sh talosctl.sh      # Talos Container Platform
sh terminal.sh      # Windows Terminal
sh trivy.sh         # Security and vulnerability scanner
sh uv.sh            # Fast python package installer
sh vlc.sh           # All hail traffic cone media player
sh vscode.sh        # Visual Studio Code IDE
sh wsl2.sh          # Windows Subsystem for Linux
sh zed.sh           # One of a few text editors

# NPM packages
cd ../npm
sh angular-cli.sh   # CLI tools for Angular framework
sh jules.sh         # Google Jules CLI
sh nodemon.sh       # Recompiles Node code as you make changes
sh vue-cli.sh       # CLI tools for Vue framework

shutdown /r /t 60
