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

parted --script --align=optimal  "${DISK}" -- \
    mklabel gpt \
    mkpart BIOS 1MiB 500MiB \
    mkpart archlinux 500MiB -$((SWAPSIZE + RESERVE))GiB \
    mkpart swap  -$((SWAPSIZE + RESERVE))GiB -"${RESERVE}"GiB \
    set 1 bios_grub on \
    set 1 legacy_boot on \
    set 3 swap on

partprobe "${DISK}"

# Swap setup
echo -e "\n${GRN}Swap setup...${NC}\n"

mkswap "${DISK}"3
swapon "${DISK}"3

# Format partitions
echo -e "\n${GRN}Format partitions...${NC}\n"

mkfs.vfat "${DISK}"1
mkfs.ext4 "${DISK}"2

# Mount partitions
echo -e "\n${GRN}Mount partitions...${NC}\n"

mount "${DISK}"2 "${MNT}"
mkdir "${MNT}"/home
mkdir "${MNT}"/boot
mount "${DISK}"1 "${MNT}/boot"


# Update pacman mirrolist
echo -e "\n${GRN}Updating pacman mirrorlist...${NC}\n"

# reflector --country US --age 6 --sort rate --save /etc/pacman.d/mirrorlist 

# Pacstrap packages to MNT
echo -e "\n${GRN}Pacstrap packages to "${MNT}"...${NC}\n"

pacstrap "${MNT}" base base-devel linux linux-headers linux-firmware grub efibootmgr openssh nano micro ansible git intel-ucode amd-ucode
cp /etc/resolv.conf "${MNT}"/etc/resolv.conf

# Generate fstab:
echo -e "\n${GRN}Generate fstab...${NC}\n"

genfstab -U -p "${MNT}" >> "${MNT}"/etc/fstab
cat "${MNT}"/etc/fstab

# Copy chroot-btrfs
echo -e "\n${GRN}Copy chroot-btrfs to "${MNT}"...${NC}\n"

cp ./chroot-btrfs.sh "${MNT}"/root

# Run chroot-btrfs
echo -e "\n${BBLU}Run chroot-btrfs...${NC}\n"

arch-chroot "${MNT}" /usr/bin/env DISK="${DISK}" sh /root/chroot-btrfs.sh








