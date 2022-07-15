# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, inputs, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.userInteractive.enable {
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  home.file."x/direnv-support" = let
    pkg = pkgs.runCommand "direnv-support" {
      nativeBuildInputs = [ pkgs.nix ];

      NIXPKGS_OUT_PATH = inputs.nixpkgs.sourceInfo.outPath;
      NIXPKGS_NAR_HASH = inputs.nixpkgs.sourceInfo.narHash;
    } ''
      export NIX_STORE_DIR="$TMPDIR/nix/store"
      export NIX_STATE_DIR="$TMPDIR/nix/var"

      for flake in ${./support}/*.nix; do
        mkdir -p "$out/$(basename "$flake" .nix)"
        substitute "$flake" "$out/$(basename "$flake" .nix)/flake.nix" \
          --subst-var-by nixpkgsOutPath "$NIXPKGS_OUT_PATH" \
          --subst-var-by nixpkgsNarHash "$NIXPKGS_NAR_HASH"
        nix --extra-experimental-features "nix-command flakes" flake lock "$out/$(basename "$flake" .nix)/flake.nix"
      done
    '';
  in {
    source = pkg;
  };
}
