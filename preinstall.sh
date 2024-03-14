#!/usr/bin/env bash
#
# @file preinstall.sh
# @brief ...

source setup.conf

timedatectl set-ntp true

sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

pacman -S archlinux-keyring --noconfirm --needed

umount -A --recursive /mnt
sgdisk -Z $DISK
sgdisk -a 2048 -o $DISK

sgdisk -n 1::+1G -t 1:ef00 -c 1:'EFIBOOT' $DISK
sgdisk -n 2::+1G -t 2:8300 -c 2:'BOOT' $DISK
sgdisk -n 3::+4G -t 3:8200 -c 3:'SWAP' $DISK
sgdisk -n 4::+32G -t 4:8300 -c 4:'ROOT' $DISK
sgdisk -n 5::-0 -t 5:8300 -c 5:'HOME' $DISK

partprobe $DISK

mkfs.vfat -F 32 -n 'EFIBOOT' ${DISK}1
mkfs.ext4 -L 'BOOT' ${DISK}2
mkswap -L 'SWAP' ${DISK}3
mkfs.ext4 -L 'ROOT' ${DISK}4
mkfs.ext4 -L 'HOME' ${DISK}5

mount ${DISK}4 /mnt
mount --mkdir ${DISK}2 /mnt/boot
mount --mkdir ${DISK}1 /mnt/boot/efi
mount --mkdir ${DISK}5 /mnt/home
swapon ${DISK}3

pacman -S reflector --noconfirm --needed
country="$(curl ifconfig.co/country)"
reflector -a 48 -c $country -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt base base-devel linux linux-headers linux-firmware --noconfirm --needed

genfstab -L /mnt >> /mnt/etc/fstab
