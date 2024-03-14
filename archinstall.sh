#!/usr/bin/env bash
#
# @file archinstall.sh
# @brief ...

pacman -Sy git --noconfirm --needed 
git clone https://github.com/vincenthasper/archinstall.git && cd archinstall/
chmod +x archinstall.sh setup.sh preinstall.sh postinstall.sh; clear

bash setup.sh
bash preinstall.sh

cp postinstall.sh setup.conf /mnt/
arch-chroot /mnt ./postinstall.sh

umount -A --recursive /mnt

echo -e "\n\e[32mInstallation finished!\e[0m"
