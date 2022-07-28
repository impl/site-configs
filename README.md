<!--
SPDX-FileCopyrightText: 2021-2022 Noah Fontes

SPDX-License-Identifier: CC-BY-NC-SA-4.0
-->

# site-configs

## Getting the Installer

This distribution contains an installer image with a bunch of applications already configured. You should copy it to removable media to perform the bootstrapping phase on physical hardware.

For example:

```
[you@somewhere:~/site-configs]$ nix build \
    --override-input nixpkgs github:nixos/nixpkgs/nixos-22.05 \
    --print-build-logs \
    '.#installer'
[...]

[you@somewhere:~/site-configs]$ sudo dd \
    if=result/iso/nixos-22.05.*-x86_64-linux.iso \
    of=/dev/sdb \
    status=progress
[...]
```

## Bootstrapping

### Become the Superuser

```
[nixos@nixos:~]$ sudo -i
```

### Configure Wi-Fi

```
[root@nixos:~]# systemctl start wpa_supplicant.service

[root@nixos:~]# wpa_cli
wpa_cli v2.10
Copyright (c) 2004-2022, Jouni Malinen <j@wi.fi> and contributors

This software may be distributed under the terms of the BSD license.
See README for more details.


Selected interface 'wlp1s0'

Interactive mode

> add_network
0
> set_network 0 ssid "<network-name>"
OK
> set_network 0 psk "<network-key>"
OK
> set_network 0 key_mgmt WPA-PSK
OK
> enable_network 0
OK
> save
OK
> quit
```

### Partition the Disk

```
[root@nixos:~]# gdisk /dev/nvme0n1
Command (? for help): o
This command deletes all partitions and creates a new protective MBR.
Proceed? (Y/N): y

Command (? for help): n
Partition number (1-128, default 1):
First sector (34-2000409230, default = 2048) or {+-}size{KMGTP}:
Last sector (2048-2000409230, default = 2000409230) or {+-}size{KMGTP}: 512M
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300): ef00
Changed type of partition to 'EFI system partition'

Command (? for help): n
Partition number (2-128, default 2):
First sector (34-2000409230, default = 1050624) or {+-}size{KMGTP}:
Last sector (2048-2000409230, default = 2000409230) or {+-}size{KMGTP}:
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300):
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): y
OK; writing new GUID partition table (GPT) to /dev/nvme0n1.
The operation has completed successfully.

[root@nixos:~]# mkfs.vfat /dev/nvme0n1p1
mkfs.fat 4.2 (2021-01-31)

[root@nixos:~]# cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 256 -h sha512 /dev/nvme0n1p2
WARNING: Device /dev/nvme0n1p2 already contains a 'ext4' superblock signature.

WARNING!
========
This will overwrite data on /dev/nvme0n1p2 irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for /dev/nvme0n1p2:
Verify passphrase:

[root@nixos:~]# nix flake clone github:impl/site-configs --dest tmp
Cloning into 'tmp'...
[...]

[root@nixos:~]# sops -d tmp/machines/<machine>/keyfile.root.sops >keyfile.root

[root@nixos:~]# cryptsetup luksAddKey /dev/nvme0n1p2 keyfile.root
Enter any existing passphrase:

[root@nixos:~]# cryptsetup luksOpen /dev/nvme0n1p2 root
Enter passphrase for /dev/nvme0n1p2:

[root@nixos:~]# mkfs.btrfs /dev/mapper/root
btrfs-progs v5.17
See http://btrfs.wiki.kernel.org for more information.

NOTE: several default settings have changed in version 5.15, please make sure
      this does not affect your deployments:
      - DUP for metadata (-m dup)
      - enabled no-holes (-O no-holes)
      - enabled free-space-tree (-R free-space-tree)

Label:              (null)
UUID:               [...]
Node size:          16384
Sector size:        4096
Filesystem size:    953.37GiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         DUP               1.00GiB
  System:           DUP               8.00MiB
SSD detected:       yes
Zoned device:       no
Incompat features:  extref, skinny-metadata, no-holes
Runtime features:   free-space-tree
Checksum:           crc32c
Number of devices:  1
Devices:
  ID         SIZE  PATH
   1    953.37GiB  /dev/mapper/root

```

### Set Up Btrfs

```
[root@nixos:~]# mount /dev/mapper/root /mnt

[root@nixos:~]# btrfs subvolume create /mnt/@
Create subvolume '/mnt/@'

[root@nixos:~]# btrfs subvolume create /mnt/@nix
Create subvolume '/mnt/@nix'

[root@nixos:~]# btrfs subvolume create /mnt/@home
Create subvolume '/mnt/@home'

[root@nixos:~]# btrfs subvolume create /mnt/@snapshots
Create subvolume '/mnt/@snapshots'

[root@nixos:~]# btrfs subvolume create /mnt/@swap
Create subvolume '/mnt/@swap'

[root@nixos:~]# umount /mnt

[root@nixos:~]# mount -o subvol=@,compress=zstd,relatime /dev/mapper/root /mnt

[root@nixos:~]# mkdir -p /mnt/{boot/efi,nix,home,snapshots,swap,root/.gnupg}

[root@nixos:~]# mount /dev/nvme0n1p1 /mnt/boot/efi

[root@nixos:~]# mount -o subvol=@nix,compress=zstd,relatime /dev/mapper/root /mnt/nix

[root@nixos:~]# mount -o subvol=@home,compress=zstd,relatime /dev/mapper/root /mnt/home

[root@nixos:~]# mount -o subvol=@snapshots,compress=zstd,relatime /dev/mapper/root /mnt/snapshots

[root@nixos:~]# mount -o subvol=@swap,relatime /dev/mapper/root /mnt/swap
```

### Set Up Swap

```
[root@nixos:~]# truncate -s 0 /mnt/swap/0

[root@nixos:~]# chattr +C /mnt/swap/0

[root@nixos:~]# fallocate -l 16G /mnt/swap/0

[root@nixos:~]# chmod 0600 /mnt/swap/0

[root@nixos:~]# mkswap /mnt/swap/0
Setting up swapspace version 1, size = 16 GiB (17179865088 bytes)
no label, UUID=[...]

[root@nixos:~]# swapon /mnt/swap/0
```

### Install NixOS

```
[root@nixos:~]# mount --bind /root/.gnupg /mnt/root/.gnupg

[root@nixos:~]# mkdir -p /mnt/etc/nixos

[root@nixos:~]# cd /mnt/etc/nixos

[root@nixos:~]# nix flake init -t github:impl/site-configs
wrote: /mnt/etc/nixos/flake.nix
wrote: /mnt/etc/nixos/configuration.nix

[root@nixos:~]# nixos-generate-config --root /mnt
writing /mnt/etc/nixos/hardware-configuration.nix...
warning: not overwriting existing /mnt/etc/nixos/configuration.nix

[root@nixos:~]# nixos-install --flake '.#<machine>' --no-root-passwd
warning: creating lock file '/mnt/etc/nixos/flake.lock'
copying channel...
building the flake in [...]
installing the boot loader...
setting up /etc...
[...]
Installation finished!

[root@nixos:~]# reboot
```

## Setting Up a Home Directory

When you log in for the first time as a normal user, you should set up [Home Manager](https://github.com/nix-community/home-manager). Once it's installed, you can use `home-manager switch` as usual to manage the process, but to create the required configuration you need to evaluate it once directly from its activation package:

```
[you@somewhere:~]$ nix shell \
    "github:impl/site-configs#homeConfigurations.${USER}@$(uname -n).activationPackage" \
    --command home-manager-generation
```
