<!--
SPDX-FileCopyrightText: 2024 Noah Fontes

SPDX-License-Identifier: CC-BY-NC-SA-4.0
-->

# Printing from the Installer

The installer includes CUPS and the `lp` suite of commands to print documents from the CLI:

```
[root@nixos:~]# systemctl start cups.service

[root@nixos:~]# lpadmin -p default -E -v 'ipp://printer.example.com/ipp/print' -m everywhere

[root@nixos:~]# lpadmin -d default

[root@nixos:~]# lp something.pdf
[...]
```
