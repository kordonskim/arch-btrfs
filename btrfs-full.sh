#!/bin/bash
set -e

DISK='/dev/sda' #'/dev/disk/by-id/ata-Hitachi_HDS5C3020BLE630_MCE7215P035WTN'
MNT=/mnt
SWAPSIZE=16
RESERVE=1


parted --script --align=optimal  /dev/sda -- \
    mklabel gpt \
    mkpart BIOS 1MiB 500MiB \
    mkpart archlinux 500MiB -$((SWAPSIZE + RESERVE))GiB \
    mkpart swap  -$((SWAPSIZE + RESERVE))GiB -"${RESERVE}"GiB \
    set 1 bios_grub on \
    set 1 legacy_boot on \
    set 3 swap on


reflector --country US --age 6 --sort rate --save /etc/pacman.d/mirrorlist 

