# SPDX-FileCopyrightText: 2021-2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, libX, pkgs, ... }: with lib;
let
  cfg = config.profiles.base;
in
{
  options = {
    profiles.base = {
      allowUnfreePackages = mkOption {
        type = types.listOf types.package;
        description = ''
          The list of unfree packages that are allowed to be installed.
        '';
        default = [ ];
      };
    };
  };

  config = {
    networking.useNetworkd = true;
    networking.useDHCP = mkOverride 500 false;
    services.resolved.enable = true;

    # Internationalization.
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    # Nix (for Flakes support, required).
    nix = {
      package = pkgs.nixUnstable;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        allowed-users = [ "@wheel" ];
        trusted-users = [ "root" "@wheel" ];
        substituters = map (cache: cache.uri) libX.cachix.repoCacheMetadata;
        trusted-public-keys = concatMap (cache: cache.publicSigningKeys) libX.cachix.repoCacheMetadata;
      };
    };

    # Merge unfree packages into a single predicate.
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) (map lib.getName cfg.allowUnfreePackages);

    # Do not allow mutable users, not now, not ever.
    users.mutableUsers = false;

    # For packages that expose debugging information, include it in the path.
    environment.enableDebugInfo = true;

    # Must configure firewall for each machine.
    networking.firewall.enable = true;
  };
}
