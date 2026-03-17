# Modern Arch linux installation guide

# Table of contents

- [Introduction](#introduction)
- [Preliminary Steps](#preliminary-steps)
- [Main installation](#main-installation)
  - [Disk partitioning](#disk-partitioning)
  - [Disk formatting](#disk-formatting)
  - [Disk mounting](#disk-mounting)
  - [Packages installation](#packages-installation)
  - [Fstab](#fstab)
  - [Context switch to our new system](#context-switch-to-our-new-system)
  - [Set up the time zone](#set-up-the-time-zone)
  - [Set up the language and tty keyboard map](#set-up-the-language-and-tty-keyboard-map)
  - [Hostname and Host configuration](#hostname-and-host-configuration)
  - [Root and users](#root-and-users)
  - [mkinitcpio configuration](#mkinitcpio-configuration)
  - [UKI setup](#uki-setup)
  - [Unmount everything and reboot](#unmount-everything-and-reboot)
  - [Intel Optane swap](#intel-optane-swap-hp-spectre-14--skip-if-you-dont-have-optane)
  - [zRAM swap](#zram-swap)
  - [Paru AUR helper installation](#paru-aur-helper-installation)
  - [System hygiene and performance](#system-hygiene-and-performance)
    - [XDG Base Directory](#xdg-base-directory)
    - [NetworkManager iwd backend](#networkmanager-iwd-backend)
    - [Reflector configuration](#reflector-configuration)
    - [Firewall](#firewall)
    - [pacman.conf tweaks](#pacmanconf-tweaks)
    - [Maintenance timers](#maintenance-timers)
  - [Finalization](#finalization)
    - [Post-reboot verification checklist](#post-reboot-verification-checklist)
- [Video drivers](#video-drivers)
  - [Intel \(HP Spectre 14\)](#intel-hp-spectre-14)

# Introduction

The goal of this guide is to help new users set up a modern and minimal installation of **Arch Linux** with **BTRFS** on an **UEFI system**. I'll start from the basic terminal installation and then set up **video drivers, a desktop environment and provide basic gaming configuration**. This guide is thought to be read alongside the wiki, so that it if something ever changes you can fix it but it's not necessary unless my guide becomes outdated. Also I will mention external references to justify some choices that I've made so that curious users can delve into the details.  

> **Personal reference note:** This guide was written for my specific hardware (HP Spectre 14 with Intel CPU and Intel Optane). Throughout the guide, you will see references to my username (`aiden`), timezone (`America/New_York`), `intel-ucode`, and Optane-specific sections. Adapt these to your own hardware and preferences — AMD users should replace `intel-ucode` with `amd-ucode`, skip the Optane section, and adjust video driver packages accordingly.

### Note that:

- I **won't** prepare the system for **secure boot** because the procedure of custom key enrollment in the BIOS is dangerous and [can lead to a bricked system](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Creating_and_enrolling_keys). If you are wondering why not using the default OEM keys in the BIOS, it's because they will make secure boot useless by being most likely [not enough secure](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Implementing_Secure_Boot).

- I **won't** encrypt the system because I don't need it and because encryption always adds a little bit of overhead in the boot phase leading to a **slower to varying degrees** start\-up, depending on your configuration. However it may be important for you so if you really wanna go this way I recommend reading [the wiki page in this regards](https://wiki.archlinux.org/title/Dm-crypt) and **must** perform the documented steps **IMMEDIATELY AFTER** [disk partitioning](#disk-partitioning). Also note that you must set the type of partition to a LUKS partition instead of a standard Linux partition when partitioning with `fdisk`.

- I'll **skip** the Arch ISO installation media preparation.

- I'll use a **wifi** connection. Steps to connect are shown in [Preliminary steps](#preliminary-steps) using [`iwctl`](https://wiki.archlinux.org/title/Iwd#iwctl).

<br>

# Preliminary steps  

First set up your keyboard layout  

```bash
# Load the US keyboard layout
loadkeys us
```

<br>

Check that we are in UEFI mode  

```bash
# If this command prints 64 or 32 then you are in UEFI
cat /sys/firmware/efi/fw_platform_size
```

<br>

Connect to WiFi  

```bash
# Launch the iwd interactive prompt
iwctl

# Inside the iwctl prompt:
# List available devices (usually wlan0)
device list

# Scan for networks
station wlan0 scan

# List available networks
station wlan0 get-networks

# Connect to your network (replace YOUR_SSID with your network name)
station wlan0 connect YOUR_SSID

# Exit iwctl
exit
```

<br>

Check the internet connection  

```bash
ping -c 5 archlinux.org 
```

<br>

Check the system clock

```bash
# Check if ntp is active and if the time is right
timedatectl

# In case it's not active you can do (this only affects the live ISO session;
# we enable time sync on the installed system after the first reboot)
timedatectl set-ntp true
```

<br>

# Main installation

## Disk partitioning

I will make 2 partitions:  

| Number | Type | Size |
| --- | --- | --- |
| 1 | EFI | 512 Mb |
| 2 | Linux Filesystem | 99.5Gb \(all of the remaining space \) |  

<br>

```bash
# Check the drive name. Mine is /dev/nvme0n1
# If you have an hdd is something like sdax
fdisk -l

# Now you can either go and partition your disk with fdisk and follow the steps below,
# or if you want to do things yourself and make it easier, use cfdisk ( an fdisk TUI wrapper ) which is
# much more user friendly. A reddit user suggested me this and it's indeed very intuitive to use.
# If you choose cfdisk you will have to invoke it the same way as I did with fdisk below, but
# you don't need to follow my commands blindly as with fdisk below, just navigate the UI with the arrows
# and press enter to get inside menus, remember to write changes before quitting.

# Invoke fdisk to partition
fdisk /dev/nvme0n1

# Now press the following commands, when i write ENTER press enter
g
ENTER
n
ENTER
ENTER
ENTER
+512M
ENTER
t
ENTER
ENTER
1
ENTER
n
ENTER
ENTER
ENTER # If you don't want to use all the space then select the size by writing +XG ( eg: to make a 10GB partition +10G )
p
ENTER # Now check if you got the partitions right

# If so write the changes
w
ENTER

# If not you can quit without saving and redo from the beginning
q
ENTER
```

<br>

## Disk formatting  

For the file system I've chosen [**BTRFS**](https://wiki.archlinux.org/title/Btrfs) which has evolved quite a lot in the recent years. It is most known for its **Copy on Write** feature which enables it to make system snapshots in a blink of a an eye and to save a lot of disk space, which can be even saved to a greater extent by enabling built\-in **compression**. Also it lets the user create **subvolumes** which can be individually snapshotted.

```bash
# Find the efi partition with fdisk -l or lsblk. For me it's /dev/nvme0n1p1 and format it.
mkfs.fat -F 32 /dev/nvme0n1p1

# Find the root partition. For me it's /dev/nvme0n1p2 and format it. I will use BTRFS.
mkfs.btrfs /dev/nvme0n1p2

# HP Spectre 14 ONLY — skip these two commands if you don't have an Optane drive.
# Verify the Optane drive is at /dev/nvme1n1 before formatting.
# Run: lsblk -o NAME,MODEL and confirm nvme1n1 is the Intel Optane device.
# Then format it as swap and activate it so genfstab picks it up.
mkswap /dev/nvme1n1
swapon /dev/nvme1n1

# Mount the root fs to make it accessible
mount /dev/nvme0n1p2 /mnt
```

<br>

## Disk mounting

I will lay down the subvolumes on a **flat** layout, which is overall superior in my opinion and less constrained than a **nested** one. What's the difference ? If you're interested [this section of the old sysadmin guide](https://archive.kernel.org/oldwiki/btrfs.wiki.kernel.org/index.php/SysadminGuide.html#Layout) explains it.

```bash
# Create the subvolumes. Subvolumes are identified by prepending @.
# @        -> /           (root filesystem)
# @home    -> /home       (user data)
# @log     -> /var/log    (logs, excluded from root snapshots)
# @pkg     -> /var/cache/pacman/pkg  (package cache, excluded from root snapshots)
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg

# Unmount the root fs
umount /mnt
```

<br>

For this guide I'll compress the btrfs subvolumes with **Zstd** level 3, which has proven to be [a good algorithm among the choices](https://www.phoronix.com/review/btrfs-zstd-compress). `noatime` is added to all subvolumes to avoid unnecessary write amplification on SSDs.

```bash
# Mount all subvolumes with compress=zstd:3 and noatime for best SSD performance.
mount -o compress=zstd:3,noatime,subvol=@ /dev/nvme0n1p2 /mnt
mkdir -p /mnt/home
mount -o compress=zstd:3,noatime,subvol=@home /dev/nvme0n1p2 /mnt/home
mkdir -p /mnt/var/log
mount -o compress=zstd:3,noatime,subvol=@log /dev/nvme0n1p2 /mnt/var/log
mkdir -p /mnt/var/cache/pacman/pkg
mount -o compress=zstd:3,noatime,subvol=@pkg /dev/nvme0n1p2 /mnt/var/cache/pacman/pkg
```

<br>

Now we have to mount the efi partition. In general there are 2 main mountpoints to use: `/efi` or `/boot` but in this configuration i am **forced** to use `/efi`, because by choosing `/boot` we could experience a **system crash** when trying to restore `@` _\( the root subvolume \)_ to a previous state after kernel updates. This happens because `/boot` files such as the kernel won't reside on `@` but on the efi partition and hence they can't be saved when snapshotting `@`. Also this choice grants separation of concerns and also is good if one wants to encrypt `/boot`, since you can't encrypt efi files. Learn more [here](https://wiki.archlinux.org/title/EFI_system_partition#Typical_mount_points)

```bash
mkdir -p /mnt/efi
mount /dev/nvme0n1p1 /mnt/efi
```

<br>

## Packages installation  

```bash
# This will install some packages to "bootstrap" methaphorically our system. Feel free to add the ones you want
# "base, linux, linux-firmware" are needed. If you want a more stable kernel, then swap linux with linux-lts
# "base-devel" base development packages
# "git" to install the git vcs
# "btrfs-progs" are user-space utilities for file system management ( needed to harness the potential of btrfs )
# "systemd-ukify" builds Unified Kernel Images (UKI) for the systemd-stub bootloader
# "efibootmgr" needed by bootctl to register boot entries
# "timeshift" a GUI app to easily create,plan and restore snapshots using BTRFS capabilities
# "intel-ucode" microcode updates for the cpu (HP Spectre 14 has an Intel CPU)
# "vim" my goto editor, if unfamiliar use nano
# "networkmanager" to manage Internet connections ( it also has an applet package network-manager-applet )
# "iwd" iNet wireless daemon — used as the WiFi backend for NetworkManager for better roaming
# "pipewire pipewire-alsa pipewire-pulse pipewire-jack" for the new audio framework replacing pulse and jack. 
# "wireplumber" the pipewire session manager.
# "reflector" to manage mirrors for pacman
# "pacman-contrib" provides paccache for automated package cache cleaning
# "fish" my favourite shell
# "openssh" to use the ssh client and manage keys (we do NOT enable sshd — this is client-only)
# "man" for manual pages
# "sudo" to run commands as other users
# "nftables" minimal stateful firewall
pacstrap -K /mnt base base-devel linux linux-firmware git btrfs-progs systemd-ukify efibootmgr timeshift vim networkmanager iwd pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber reflector pacman-contrib fish openssh man sudo intel-ucode nftables
```

<br>

## Fstab  

```bash
# Fetch the disk mounting points as they are now ( we mounted everything before ) and generate instructions to let the system know how to mount the various disks automatically
genfstab -U /mnt >> /mnt/etc/fstab

# Check if fstab is fine. Verify that ALL subvolumes (@, @home, @log, @pkg) are listed
# and that each Btrfs line includes "compress=zstd:3" and "noatime" in its options.
cat /mnt/etc/fstab
```

<br>

## Context switch to our new system  

```bash
# To access our new system we chroot into it
arch-chroot /mnt
```

<br>

Disable BTRFS Copy-on-Write on the systemd journal directory. CoW combined with append-heavy workloads like `journald` causes severe file fragmentation over time. `chattr +C` only affects newly written files, so set it on the empty directory now before the journal starts writing:

```bash
mkdir -p /var/log/journal
chattr +C /var/log/journal
```

<br>

## Set up the time zone

```bash
# Set up the local time zone for New York
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# Now sync the system time to the hardware clock
hwclock --systohc
```

<br>

## Set up the language and tty keyboard map

Edit `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8`.  

```bash
# To edit I will use vim, feel free to use nano instead.
vim /etc/locale.gen

# Now issue the generation of the locales
locale-gen
```

<br>

Create `/etc/locale.conf` and set `LANG=en_US.UTF-8`.

```bash
vim /etc/locale.conf
```

<br>

Now to make the current keyboard layout permanent for tty sessions, create `/etc/vconsole.conf` and write `KEYMAP=us`

```bash
vim /etc/vconsole.conf
```

<br>

## Hostname and Host configuration

```bash
# Create /etc/hostname then choose and write the name of your pc in the first line. In my case I'll use Arch
vim /etc/hostname

# Create the /etc/hosts file. This is very important because it will resolve the listed hostnames locally and not over Internet DNS.
```

Write the following ip, hostname pairs inside /etc/hosts, replacing `Arch` with **YOUR** hostname:

```
127.0.0.1 localhost
::1 localhost
127.0.1.1 Arch
```

```bash
# Edit the file with the information above
vim /etc/hosts
```

<br>

## Root and users  

```bash
# Set up the root password
passwd

# Add a new user (aiden).
# -m creates the home dir automatically
# -G adds the user to an initial list of groups, in this case wheel, the administration group.
useradd -mG wheel aiden
passwd aiden

# Instead of editing /etc/sudoers directly with visudo, create a drop-in file in /etc/sudoers.d/.
# This is safer: a broken drop-in file won't lock you out of sudo, and it keeps the base file
# pristine and easy to audit. The file must not be world-writable (chmod 440).
echo '%wheel ALL=(ALL:ALL) ALL' | EDITOR='tee' visudo -f /etc/sudoers.d/10-admins
chmod 440 /etc/sudoers.d/10-admins
```

<br>

## mkinitcpio configuration

Before building the kernel images, verify that mkinitcpio is configured correctly for a BTRFS root filesystem. The default configuration *usually* works because the `btrfs` module is auto-detected, but it's worth being explicit — especially since a missing module means an unbootable system.

```bash
# Verify that the btrfs module will be included in the initramfs.
# Open /etc/mkinitcpio.conf and update HOOKS to include "microcode" and "btrfs"
#   'microcode' MUST be first.
#   'btrfs' should come after 'block'.
# HOOKS=(microcode base systemd autodetect modconf kms keyboard sd-vconsole block btrfs filesystems fsck)
vim /etc/mkinitcpio.conf

# Regenerate initramfs images after any changes
mkinitcpio -P
```

<br>

## UKI setup

A **Unified Kernel Image (UKI)** bundles the kernel, initramfs, kernel command line, and CPU microcode into a single signed `.efi` binary. Instead of managing complex bootloader entries, your BIOS simply points to this one file. We will use `systemd-boot` as our boot manager and `mkinitcpio` to build the UKIs natively.

1. Initialize the Boot Manager

First, install the systemd-boot binaries to your EFI partition.

```bash
bootctl install
```

2. Configure the Kernel Command Line

Unlike a traditional setup where the command line lives in a bootloader config file, for a UKI, it must be embedded *into* the binary.

```bash
mkdir -p /etc/kernel

# We fetch the UUID of your root partition and tell it which subvolume to boot
echo "root=UUID=$(blkid -s UUID -o value /dev/nvme0n1p2) rootflags=subvol=@ rw" \
  > /etc/kernel/cmdline
```

3. Update mkinitcpio presets

This is the "magic" step. We tell `mkinitcpio` to output `.efi` files directly into your EFI partition. Edit the linux preset file:

```bash
vim /etc/mkinitcpio.d/linux.preset
```

Modify the file to look like this (comment out the `.img` lines and add the `.efi` lines):

```bash
# /etc/mkinitcpio.d/linux.preset
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"

PRESETS=('default' 'fallback')

# Default UKI
default_uki="/efi/EFI/Linux/arch-linux.efi"

# Fallback UKI
fallback_options="-S autodetect"
fallback_uki="/efi/EFI/Linux/arch-linux-fallback.efi"
```

4. Build the UKIs

Now, simply run the standard generator. It will see the `_uki` targets and build the combined binaries for you.

```bash
mkdir -p /efi/EFI/Linux
mkinitcpio -P
```

5. Register the Boot Entries

Since we aren't using traditional `loader.conf` entries, we tell the UEFI firmware exactly where these files are.

```bash
# Main Entry
efibootmgr --create --disk /dev/nvme0n1 --part 1 \
  --label "Arch Linux" \
  --loader 'EFI\Linux\arch-linux.efi' --unicode

# Fallback Entry
efibootmgr --create --disk /dev/nvme0n1 --part 1 \
  --label "Arch Linux (Fallback)" \
  --loader 'EFI\Linux\arch-linux-fallback.efi' --unicode
```

## Unmount everything and reboot 

```bash
# Enable newtork manager before rebooting otherwise, you won't be able to connect
systemctl enable NetworkManager

# Exit from chroot
exit

# Unmount everything to check if the drive is busy
umount -R /mnt

# Reboot the system and unplug the installation media
reboot

# Now you'll be presented at the terminal. Log in with your user account: "aiden".

# Enable and start the time synchronization service
timedatectl set-ntp true
```

<br>

## Intel Optane swap (HP Spectre 14 — skip if you don't have Optane)

> **Hardware-specific:** This section applies only to systems with an Intel Optane drive. If your machine doesn't have one, skip ahead to [Paru AUR helper installation](#paru-aur-helper-installation).

The HP Spectre 14 has an Intel Optane drive at `/dev/nvme1n1`. Because Optane offers dramatically lower latency than a regular NVMe SSD, it makes an ideal dedicated swap device — providing better responsiveness under memory pressure and shifting swap-induced wear away from the primary SSD onto the Optane drive.

The drive was already formatted with `mkswap` and activated with `swapon` during the [Disk formatting](#disk-formatting) step, so `genfstab` will have included it in `/etc/fstab` automatically. No further configuration is required.

```bash
# Verify the swap entry is present in fstab
grep swap /etc/fstab

# Verify swap is active
swapon --show
```

Since Optane has much lower latency than a regular SSD, you may want to tune `vm.swappiness` to take better advantage of it. The default value is `60`. A higher value makes the kernel more willing to use swap, which is reasonable when swap is on a fast Optane device:

```bash
# Optional: increase swappiness for low-latency Optane swap (default is 60)
# Values range from 0 (avoid swap) to 200 (aggressively swap).
# 100 is a reasonable choice for Optane; experiment to taste.
echo 'vm.swappiness=100' | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl --system
```

<br>

## zRAM swap

[**zRAM**](https://wiki.archlinux.org/title/Zram) creates a compressed swap device in RAM. Because it never touches disk, it is significantly faster than any physical swap -- even Optane. On laptops it also saves battery by avoiding disk I/O under memory pressure.

zRAM **complements** physical swap: the kernel will prefer the faster zRAM device first and only overflow to disk-backed swap when zRAM fills up. If you have Optane swap configured above, this gives you two tiers (RAM -> Optane). If you skipped the Optane section, zRAM alone is an excellent lightweight swap solution.

We use `zram-generator`, a systemd-native tool that creates and configures the zRAM device automatically at boot:

```bash
sudo pacman -S zram-generator

sudo tee /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
# Allocate half of total RAM for compressed swap.
# With typical ~2:1 compression, this effectively doubles your usable memory.
zram-size = ram / 2
compression-algorithm = zstd
EOF

# Reload systemd so it picks up the new generator config, then start the device
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0

# Verify zRAM is active (should show /dev/zram0 alongside any physical swap)
swapon --show
```

> **Note:** zRAM gets a higher priority than disk swap by default, so the kernel will use it first. No manual priority tuning is needed.

<br>

## Paru AUR helper installation

To gain access to the Arch User Repository we need an AUR helper. I will use [**paru**](https://github.com/Morganamilo/paru), a feature-rich AUR helper written in Rust that also works as a pacman wrapper (you can use `paru` anywhere you would use `pacman`).

> Note: you can't execute makepkg as root, so you need to be logged in as aiden

```bash
# Install paru
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si

# Clean up the build directory
cd ~ && rm -rf paru
```

<br>

## System hygiene and performance

### XDG Base Directory

Setting `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, and `XDG_DATA_HOME` explicitly ensures that well-behaved applications store their files under predictable paths rather than scattering hidden dot-folders across `$HOME`. This keeps the user's home directory clean and easy to back up or inspect.

> **Warning:** `/etc/environment` is parsed by PAM and **does not perform shell variable expansion** — writing `$HOME` there would set the literal string `$HOME`, not your home directory path. Use a shell profile drop-in instead.

```bash
sudo tee /etc/profile.d/xdg-base-dirs.sh << 'EOF'
# XDG Base Directory — keep $HOME pristine
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
EOF
```

<br>

### NetworkManager iwd backend

By default NetworkManager uses its own internal `wpa_supplicant` WiFi backend. Switching to `iwd` (already installed) gives better WiFi roaming, faster scanning, and lower memory usage.

> **Important:** NetworkManager's iwd backend requires the `iwd` daemon to be running. Enable it alongside the configuration.

```bash
sudo mkdir -p /etc/NetworkManager/conf.d

sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf << 'EOF'
[device]
wifi.backend=iwd
EOF

# iwd must be running for the NetworkManager iwd backend to work
sudo systemctl enable --now iwd
```

Restart NetworkManager to apply the change:

```bash
sudo systemctl restart NetworkManager
```

<br>

### Reflector configuration

Before enabling `reflector.timer`, configure it so it selects fast, nearby mirrors instead of using defaults that may be slow:

```bash
sudo mkdir -p /etc/xdg/reflector

sudo tee /etc/xdg/reflector/reflector.conf << 'EOF'
# Reflector configuration — adjust country/count to your location
--save /etc/pacman.d/mirrorlist
--protocol https
--country "United States"
--latest 10
--sort rate
EOF
```

<br>

### Firewall

Even a minimal desktop should have a basic firewall. `nftables` (already installed) is the modern replacement for `iptables`. We'll set up a simple stateful firewall that allows outbound traffic and blocks unsolicited inbound connections:

```bash
sudo tee /etc/nftables.conf << 'EOF'
#!/usr/bin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority filter; policy drop;

        # Allow established/related connections
        ct state established,related accept

        # Allow loopback
        iif "lo" accept

        # Allow ICMP (ping)
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept

        # Drop everything else (policy drop)
    }

    chain forward {
        type filter hook forward priority filter; policy drop;
    }

    chain output {
        type filter hook output priority filter; policy accept;
    }
}
EOF

sudo systemctl enable --now nftables
```

> If you later need to allow inbound connections (e.g., SSH), add a rule like `tcp dport 22 accept` to the `input` chain.

<br>

### pacman.conf tweaks

Enable some quality-of-life options in `/etc/pacman.conf`:

```bash
# Enable colored output, verbose package lists, and parallel downloads.
# Uncomment or add the following lines in the [options] section of /etc/pacman.conf:
#   Color
#   VerbosePkgLists
#   ParallelDownloads = 5
#
# If you need 32-bit library support (e.g., for gaming with Steam), also uncomment:
#   [multilib]
#   Include = /etc/pacman.d/mirrorlist
sudo vim /etc/pacman.conf
```

<br>

### Maintenance timers

Enable these systemd timers so the system keeps itself clean and performant automatically:

- **`fstrim.timer`** — runs periodic TRIM on SSDs (weekly by default). This is the recommended approach over continuous discard (`discard` mount option), as it batches TRIM operations and reduces I/O overhead.
- **`reflector.timer`** — periodically refreshes the pacman mirror list, ensuring you always download from fast mirrors.
- **`paccache.timer`** — runs `paccache` weekly to trim the pacman package cache (from `pacman-contrib`). By default it keeps the three most recent versions of each *installed* package and removes all cached versions of *uninstalled* packages, reclaiming disk space automatically.

```bash
sudo systemctl enable --now fstrim.timer
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now paccache.timer
```

<br>

## Finalization

```bash
# To complete the main/basic installation reboot the system
reboot
```

> After these steps you **should** be able to boot on your newly installed Arch Linux, if so congrats !  

> The basic installation is complete and you could stop here, but if you want to to have a graphical session, you can continue reading the guide.

<br>

### Post-reboot verification checklist

After rebooting, run through these quick sanity checks to confirm everything is working:

```bash
# 1. Verify BTRFS mounts have the correct options (compress, noatime, subvol)
mount | grep btrfs

# 2. Verify swap is active (if applicable)
swapon --show

# 3. Verify network connectivity
ping -c 3 archlinux.org

# 4. Verify time synchronization is active
timedatectl

# 5. Verify all systemd timers are active
systemctl list-timers --all

# 6. Verify the firewall is running
sudo nft list ruleset

# 7. Verify UKI boot entries exist
efibootmgr -v

# 8. Verify the iwd backend is active
systemctl status iwd
```

<br>

# Video drivers

The HP Spectre 14 uses **Intel Iris Xe integrated graphics**. Install the open-source [Intel graphics driver](https://wiki.archlinux.org/title/Intel_graphics#Installation).

<br>

## Intel (HP Spectre 14)

```bash
# What are we installing?
# mesa: DRI driver for 3D acceleration.
# vulkan-intel: Vulkan support.
# intel-media-driver: VA-API hardware video decoding (Broadwell and newer).

sudo pacman -S mesa vulkan-intel intel-media-driver
```
