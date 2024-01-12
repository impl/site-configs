<!--
SPDX-FileCopyrightText: 2021-2024 Noah Fontes

SPDX-License-Identifier: CC-BY-NC-SA-4.0
-->

# Setting Up a Home Directory

When you log in for the first time as a normal user, you should set up [Home Manager](https://github.com/nix-community/home-manager). Once it's installed, you can use `home-manager switch` as usual to manage the process, but to create the required configuration you need to evaluate it once directly from its activation package:

```
[you@somewhere:~]$ nix shell \
    "github:impl/site-configs#homeConfigurations.${USER}@$(uname -n).activationPackage" \
    --command home-manager-generation
```
