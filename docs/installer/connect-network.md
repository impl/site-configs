<!--
SPDX-FileCopyrightText: 2021-2024 Noah Fontes

SPDX-License-Identifier: CC-BY-NC-SA-4.0
-->

# Connecting to a Network

## Wi-Fi

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
