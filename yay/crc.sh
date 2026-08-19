sudo pacman -S --needed --noconfirm libvirt qemu-base networkmanager dnsmasq firewalld gpgme-json

sudo systemctl enable --now libvirtd
sudo systemctl enable --now NetworkManager

sudo usermod -aG libvirt $USER
newgrp libvirt

yay -S crc
crc setup
