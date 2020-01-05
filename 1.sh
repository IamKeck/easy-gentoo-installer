#!/bin/bash
set -Cue


# create partitions
parted -a optimal -s /dev/sda -- mklabel gpt

parted -a optimal -s /dev/sda -- mkpart primary 1 3
parted -a optimal -s /dev/sda -- name 1 grub
parted -a optimal -s /dev/sda -- set 1 bios_grub on

parted -a optimal -s /dev/sda -- mkpart primary 3 131
parted -a optimal -s /dev/sda -- name 2 boot

parted -a optimal -s /dev/sda -- mkpart primary 131 643
parted -a optimal -s /dev/sda -- name 3 swap

parted -a optimal -s /dev/sda -- mkpart primary 643 -1
parted -a optimal -s /dev/sda -- name 4 rootfs

# create filesystems
mkfs.ext2 /dev/sda2
mkfs.ext4 /dev/sda4
mkswap /dev/sda3
swapon /dev/sda3

# mount root fs
mount /dev/sda4 /mnt/gentoo

# download and extract stage3-tarball
cd /mnt/gentoo
curl http://ftp.iij.ad.jp/pub/linux/gentoo/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt | grep stage3-amd64 | sed -e 's/^/http:\/\/ftp.iij.ad.jp\/pub\/linux\/gentoo\/releases\/amd64\/autobuilds\//g' | sed -e 's/ [0-9]*$//g' | xargs curl -O
tar xpvf stage3-*.tar.bz2 --xattrs-include='*.*' --numeric-owner


mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

cd -
# replace make.conf
mv /mnt/gentoo/etc/portage/make.conf /mnt/gentoo/etc/portage/make.conf.old
cp make.conf /mnt/gentoo/etc/portage/

# copy kernel settings and fstab
cp .config /mnt/gentoo/kernel-config
cp fstab /mnt/gentoo/etc/fstab

# copy 2.sh, chroot, and execute it
cp 2.sh /mnt/gentoo/
chroot /mnt/gentoo /2.sh

cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot






