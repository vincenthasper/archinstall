#!/usr/bin/env bash

pacman -Sy git --noconfirm --needed
git clone https://github.com/vincenthasper/archinstall.git && cd archinstall/
chmod +x archinstall.sh 1-setup.sh 2-preinstall.sh 3-postinstall.sh && clear

bash 1-setup.sh
bash 2-preinstall.sh

cp 3-postinstall.sh setup.conf /mnt/
arch-chroot /mnt ./3-postinstall.sh

umount -A --recursive /mnt

echo -e "\n\e[32mInstallation Finished!\e[0m"