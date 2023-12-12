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

mkswap "${DISK}"-part5
swapon "${DISK}"-part5

# update pacman mirrolist
echo -e "\n${GRN}Updating pacman mirrorlist...${NC}\n"

# reflector --country US --age 6 --sort rate --save /etc/pacman.d/mirrorlist 






