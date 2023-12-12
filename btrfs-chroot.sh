GRN='\033[0;32m'
NC='\033[0m'
BBLU='\033[1;34m'
BRED='\033[1;31m'

# Configure pacman
# echo -e "\n${GRN}Configure pacman...${NC}\n"\

# sed -i 's|#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|' /etc/pacman.conf
# pacman -Sy

# Set hostname
echo -e "\n${GRN}Set hostname...${NC}\n"

echo arch > /etc/hostname
echo -e '127.0.0.1 localhost\n::1 localhost\n127.0.1.1 arch' >> /etc/hosts

# Generate locales
echo -e "\n${GRN}Generate locales...${NC}\n"

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

# Enable services
echo -e "\n${GRN}Enable services...${NC}\n"

echo -e "[Match]\nName=eno*\n\n[Network]\nDHCP=yes" > /etc/systemd/network/20-wired.network
echo -e "\nnameserver 1.1.1.1\nnameserver 9.9.9.9" >> /etc/resolv.conf
sed -i 's|#PasswordAuthentication|PasswordAuthentication|' /etc/ssh/sshd_config

systemctl enable systemd-timesyncd
systemctl enable systemd-networkd
systemctl enable sshd

# # Install and configure syslinux
echo -e "\n${GRN}Configure syslinux...${NC}\n"

syslinux-install_update -i -a -m

sed -i 's|TIMEOUT 50|TIMEOUT 30|' /boot/syslinux/syslinux.cfg
sed -i 's|initramfs-linux.img|intel-ucode.img,../initramfs-linux.img|' /boot/syslinux/syslinux.cfg

# # Install GRUB
# echo -e "\n${GRN}Install GRUB...${NC}\n"

# mkinitcpio -p linux
# pacman -S grub
# grub-install /dev/sda
# grub-mkconfig -o /boot/grub/grub.cfg

# Adding user 
echo -e "\n${GRN}Adding user mk...${NC}\n"

# groupadd sudo
useradd -m -G root,wheel mk

echo -e "\n${ORG}Changing password for mk:${NC}\n"
passwd mk
echo -e "\n${ORG}Changing password for root:${NC}\n"
passwd root