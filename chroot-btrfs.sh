# Configure pacman
echo -e "\n${GRN}Configure pacman...${NC}\n"\

sed -i 's|#Include = /etc/pacman.d/mirrorlist|PasswordAutInclude = /etc/pacman.d/mirrorlistentication|' /etc/pacman.d/mirrorlist
pacman -Sy

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