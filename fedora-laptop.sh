echo "This script will install a number of things on you Fedora based laptop."
echo "Some software may require prompts, but most should be skipped."
echo "**WARNING** system will reboot once complete **WARNING**"

sudo dnf update -y
sudo dnf upgrade -y

cd dnf

sh alacritty.sh
sh aws-cli.sh
sh brave.sh
sh chrome.sh
sh chromium.sh
sh docker.sh
sh firefox.sh
sh gh-cli.sh
sh gimp.sh
sh gitleaks.sh
sh go.sh
sh gparted.sh
sh inkspace.sh
sh kate.sh
sh kubectl.sh
sh lua.sh
sh lutris.sh
sh mise.sh
sh navi.sh
sh nodejs.sh
sh ollama.sh
sh openjdk.sh
sh openssl.sh
sh openvpn.sh
sh podman.sh
sh retroarch.sh
sh rust.sh
sh steam.sh
sh uv.sh
sh vim.sh
sh vlc.sh
sh vscode.sh
sh waydroid.sh

cd ../flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sh discord.sh
sh godot.sh
sh heroic.sh
sh kdenlive.sh
sh obsidian.sh
sh podman-desktop.sh
sh protonup-qt.sh
sh rust-desk.sh

cd ../curl

sh prek.sh
sh zed.sh

cd ../npm

sh angular-cli.sh
sh nodemon.sh
sh vue-cli.sh
