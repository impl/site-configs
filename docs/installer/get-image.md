<!--
SPDX-FileCopyrightText: 2021-2024 Noah Fontes

SPDX-License-Identifier: CC-BY-NC-SA-4.0
-->

# Getting the Installer Image

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
