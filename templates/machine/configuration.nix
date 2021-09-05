{ lib, ... }:
{
  imports =
    lib.optionals (builtins.pathExists ./hardware-configuration.nix) [ ./hardware-configuration.nix ];
}
