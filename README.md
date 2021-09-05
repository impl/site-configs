# site-configs

## Bootstrapping

Set up your filesystems and other bootstrap configuration as usual. Then, in `/mnt/etc/nixos`, run:

```
[root@nixos:/mnt/etc/nixos]# nix-shell -p nixUnstable
[nix-shell:/mnt/etc/nixos]# nix flake init -t github:impl/site-configs
[nix-shell:/mnt/etc/nixos]# nixos-generate-config --root /mnt
[nix-shell:/mnt/etc/nixos]# nixos-install --flake '.#<machine-name>'
```

(Where `<machine-name>` should be substituted with the hostname of the machine you want to install.)

## Setting up a home directory

When you log in for the first time as a normal user, you should set up [Home Manager](https://github.com/nix-community/home-manager). Once it's installed, you can use `home-manager switch` as usual to manage the process, but to create the required configuration you need to evaluate it once directly from its activation package:

```
$ nix shell \
    "github:impl/site-configs#homeConfigurations.${USER}@$(uname -n).activationPackage" \
    --command home-manager-generation
```
