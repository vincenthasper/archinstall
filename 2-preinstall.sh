#!/usr/bin/env bash

source setup.conf

timedatectl set-ntp true

sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

pacman -S archlinux-keyring --noconfirm --needed

umount -A --recursive /mnt

sgdisk -Z "$DISK"
sgdisk -a 2048 -o "$DISK"

sgdisk -n 1::+1G -t 1:ef00 -c 1:'EFIBOOT' "$DISK"
sgdisk -n 2::+1G -t 2:8300 -c 2:'BOOT' "$DISK"
sgdisk -n 3::+4G -t 3:8200 -c 3:'SWAP' "$DISK"
sgdisk -n 4::+32G -t 4:8300 -c 4:'ROOT' "$DISK"
sgdisk -n 5::-0 -t 5:8300 -c 5:'HOME' "$DISK"

partprobe "$DISK"

mkfs.vfat -F 32 -n 'EFIBOOT' "${DISK}p1"
mkfs.ext4 -F -L 'BOOT' "${DISK}p2"
mkswap -L 'SWAP' "${DISK}p3"
mkfs.ext4 -F -L 'ROOT' "${DISK}p4"
mkfs.ext4 -F -L 'HOME' "${DISK}p5"

mount "${DISK}p4" /mnt
mount --mkdir "${DISK}p2" /mnt/boot
mount --mkdir "${DISK}p1" /mnt/boot/efi
mount --mkdir "${DISK}p5" /mnt/home
swapon "${DISK}p3"

pacman -S reflector --noconfirm --needed
country="$(curl -s ifconfig.co/country)"
reflector -a 48 -c "$country" -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt base base-devel linux linux-headers linux-firmware --noconfirm --needed

genfstab -L /mnt >> /mnt/etc/fstab
