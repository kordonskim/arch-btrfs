umount -R /mnt
mount | grep mnt
swapoff -a  
wipefs -a -f /dev/sda
lsblk