#!/bin/bash
set -e

GRN='\033[0;32m'
NC='\033[0m'
BBLU='\033[1;34m'
BRED='\033[1;31m'

# Setting variables
echo -e "\n${GRN}Set variables...${NC}\n"

DISK='/dev/sda' #'/dev/disk/by-id/ata-Hitachi_HDS5C3020BLE630_MCE7215P035WTN'
MNT=/mnt
SWAPSIZE=8
RESERVE=1

# create partitions
echo -e "\n${GRN}Create partitions...${NC}\n"

(echo n; echo p; echo 1; echo ""; echo +1G; echo n; echo p; echo 2; echo ""; echo +8G; echo t; echo 2; echo 82; echo n; echo p; echo 3; echo ""; echo ""; echo a; echo 1; echo w; echo q) | fdisk /dev/sda

# parted --script --align=optimal  "${DISK}" -- \
#     mklabel gpt \
#     mkpart BIOS 1MiB 500MiB \
#     mkpart archlinux 500MiB -$((SWAPSIZE + RESERVE))GiB \
#     mkpart swap  -$((SWAPSIZE + RESERVE))GiB -"${RESERVE}"GiB \
#     set 1 bios_grub on \
#     set 1 legacy_boot on \
#     set 3 swap on

partprobe "${DISK}"

# Swap setup
echo -e "\n${GRN}Swap setup...${NC}\n"

mkswap "${DISK}"2
swapon "${DISK}"2

# Format partitions
echo -e "\n${GRN}Format partitions...${NC}\n"

mkfs.ext4 -L "boot" "${DISK}"1
mkfs.ext4 -L "arch_os" "${DISK}"3

# Mount partitions
echo -e "\n${GRN}Mount partitions...${NC}\n"

mount "${DISK}"3 "${MNT}"
mkdir "${MNT}"/home
mkdir "${MNT}"/boot
mount "${DISK}"1 "${MNT}/boot"


# Update pacman mirrolist
echo -e "\n${GRN}Updating pacman mirrorlist...${NC}\n"

# reflector --country US --age 6 --sort rate --save /etc/pacman.d/mirrorlist 
# pacman -Syy

# Pacstrap packages to MNT
echo -e "\n${GRN}Pacstrap packages to "${MNT}"...${NC}\n"

pacstrap "${MNT}" base base-devel linux linux-headers linux-firmware syslinux nano micro intel-ucode amd-ucode sudo man-db man-pages grub openssh ansible git 
cp /etc/resolv.conf "${MNT}"/etc/resolv.conf

# Generate fstab:
echo -e "\n${GRN}Generate fstab...${NC}\n"

genfstab -U -p "${MNT}" >> "${MNT}"/etc/fstab
cat "${MNT}"/etc/fstab

# Copy btrfs-chroot
echo -e "\n${GRN}Copy btrfs-chroot to "${MNT}"...${NC}\n"

cp ./btrfs-chroot.sh "${MNT}"/root

# Run btrfs-chroot
echo -e "\n${BBLU}Run btrfs-chroot...${NC}\n"

arch-chroot "${MNT}" /usr/bin/env DISK="${DISK}" sh /root/btrfs-chroot.sh

# Cleanup
echo -e "\n${GRN}Cleanup...${NC}\n"

rm "${MNT}"/root/btrfs-chroot.sh 

echo -e "\n${BRED}Run swapoff -a${NC}"
echo -e "\n${BRED}Run umount -Rl /mnt${NC}"
# swapoff -a
# umount -Rl "${MNT}"
# zpool export -a

echo -e "\n${GRN}Done...${NC}\n"








