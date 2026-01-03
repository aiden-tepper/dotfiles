Minimal Arch + Btrfs + UEFI Bootstrap Guide

This guide prepares a "Thin Arch" base designed to be managed by Nix/Home Manager.
1. Partitioning (GPT/UEFI)

Assuming the disk is /dev/vda. Use cfdisk /dev/vda to create:

    512MiB EFI System partition (/dev/vda1)

    Remaining Space Linux Filesystem partition (/dev/vda2)

Bash

# Format partitions
mkfs.fat -F 32 /dev/vda1
mkfs.btrfs /dev/vda2

2. Btrfs Subvolume Setup

We use subvolumes to separate the OS (@), User Data (@home), and the Nix Store (@nix).
Bash

# Mount root to create subvolumes
mount /dev/vda2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
umount /mnt

# Mount with optimized flags (Zstd compression)
mount -o compress=zstd,subvol=@ /dev/vda2 /mnt
mkdir -p /mnt/{boot,home,nix,var/log}
mount /dev/vda1 /mnt/boot
mount -o compress=zstd,subvol=@home /dev/vda2 /mnt/home
mount -o compress=zstd,subvol=@nix /dev/vda2 /mnt/nix
mount -o compress=zstd,subvol=@log /dev/vda2 /mnt/var/log

3. Base Installation

Install only the essentials. Everything else will come from Nix later.
Bash

pacstrap -K /mnt base linux linux-firmware btrfs-progs git vim networkmanager sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

4. System Configuration (Inside Chroot)
Bash

# Localization
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "arch-nix-vm" > /etc/hostname

# User Setup (Replace 'yourusername')
useradd -m -G wheel yourusername
passwd yourusername
# Use 'visudo' to uncomment: %wheel ALL=(ALL:ALL) ALL

# Bootloader (systemd-boot)
bootctl install

# Create Boot Entry
# Tip: find PARTUUID with: blkid -s PARTUUID -o value /dev/vda2
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/vda2) rootflags=subvol=@ rw
EOF

# Update initramfs for Btrfs support
# Ensure 'btrfs' is in the HOOKS array in /etc/mkinitcpio.conf
mkinitcpio -P

5. Exit and Reboot
Bash

exit
umount -R /mnt
reboot
