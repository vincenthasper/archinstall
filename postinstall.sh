#!/usr/bin/env bash
#
# @file postinstall.sh
# @brief ...

source setup.conf

sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

pacman -Sy networkmanager grub efibootmgr sudo dosfstools --noconfirm --needed

timezone="$(curl https://ipapi.co/timezone)"
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "$HOSTNAME" > /etc/hostname

systemctl enable NetworkManager.service

echo -e "\n127.0.0.1\t${HOSTNAME}.localdomain\n::1\t\t${HOSTNAME}.localdomain" >> /etc/hosts

echo "root:$ROOT_PASSWORD" | chpasswd

useradd -m -G users,wheel $USERNAME
echo "$USERNAME:$USER_PASSWORD" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB $DISK
grub-mkconfig -o /boot/grub/grub.cfg

rm -rf postinstall.sh setup.conf
