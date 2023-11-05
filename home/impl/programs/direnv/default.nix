# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  home.file."x/direnv-support" = let
    fallbackRegistryConf = (pkgs.formats.json {}).generate "registry.json" {
      version = 2;
      flakes = [];
    };
    pkg = pkgs.runCommand "direnv-support" {
      registryConf = "${config.xdg.configFile."nix/registry.json".source or fallbackRegistryConf}";
      nativeBuildInputs = [ (if config.nix.package != null then config.nix.package else pkgs.nix) ];
    } ''
      export NIX_CONF_DIR="$TMPDIR/etc/nix"
      export NIX_STORE_DIR="$TMPDIR/nix/store"
      export NIX_STATE_DIR="$TMPDIR/nix/var"

      mkdir -p "$NIX_CONF_DIR"
      cat >>"$NIX_CONF_DIR/nix.conf" <<EOT
      experimental-features = nix-command flakes
      flake-registry = $registryConf
      EOT

      for flake in ${./support}/*.nix; do
        mkdir -p "$out/$(basename "$flake" .nix)"
        cp "$flake" "$out/$(basename "$flake" .nix)/flake.nix"
        nix --offline --extra-experimental-features "nix-command flakes" flake lock "$out/$(basename "$flake" .nix)" --show-trace
      done
    '';
  in {
    source = pkg;
  };
}
