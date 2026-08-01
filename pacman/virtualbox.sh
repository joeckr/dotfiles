sudo pacman --S --noconfirm --needed linux-cachyos-headers virtualbox-host-dkms
sudo pacman -S --noconfirm --needed virtualbox

sudo usermod -aG vboxusers $USER
