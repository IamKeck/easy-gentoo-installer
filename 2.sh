#!/bin/sh

echo "###### chrooted ######"
source /etc/profile
mount /dev/sda2 /boot

emerge-webrsync
emerge --sync
emerge -vuDN @world

echo "Asia/Tokyo" >> /etc/timezone
emerge --config sys-libs/timezone-data

echo 'LANG="ja_JP.utf8"' > /etc/env.d/02locale

env-update
source /etc/profile

# build and install kernel
emerge -v sys-kernel/gentoo-sources
cd /usr/src/linux
cp /kernel-config ./.config
make && make modules_install && make install

# set temporary root password
echo "root:asdf1234" | chpasswd

# install bootloader
emerge -v sys-boot/grub:2
grub-install /dev/sda
echo 'GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd"' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg




