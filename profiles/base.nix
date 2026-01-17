# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, libX, pkgs, ... }: with lib;
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

  config = mkMerge [
    {
      # Nix (for Flakes support, required).
      nix = {
        enable = true;
        package = pkgs.nixVersions.latest;
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          substituters = map (cache: cache.uri) libX.cachix.repoCacheMetadata;
          trusted-public-keys = concatMap (cache: cache.publicSigningKeys) libX.cachix.repoCacheMetadata;
        };
      };

      # Merge unfree packages into a single predicate.
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) (map lib.getName cfg.allowUnfreePackages);
    }
    (optionalAttrs (class == "nixos") {
      nix.settings = {
        allowed-users = [ "@wheel" ];
        trusted-users = [ "root" "@wheel" ];
      };

      networking.useNetworkd = true;
      networking.useDHCP = mkOverride 500 false;
      services.resolved.enable = true;

      # Internationalization.
      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
      };

      # Do not allow mutable users, not now, not ever.
      users.mutableUsers = false;

      # For packages that expose debugging information, include it in the path.
      environment.enableDebugInfo = true;

      # Must configure firewall for each machine.
      networking.firewall.enable = true;
      networking.nftables.enable = true;
    })
  ];
}
