# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: {
  _module.args = {
    libX = import ./lib { inherit lib; };
    pkgsX = pkgs.callPackage ./pkgs {};
  };

  # https://github.com/nix-community/home-manager/issues/2942
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);
  nixpkgs.overlays = [
    (builtins.getFlake "github:nix-community/NUR/2e20efb3d185d01eb7b6219014f3ae63ae9f4173").overlay
    (import ./overlay)
  ];

  imports = [
    ./locations/home
    ./profiles
    ./programs/direnv
    ./programs/firefox
    ./programs/git
    ./programs/keepass
    ./programs/vim
    ./programs/xmonad
    ./programs/zsh
    ./programs/autorandr.nix
    ./programs/bat.nix
    ./programs/deezer.nix
    ./programs/dropbox.nix
    ./programs/gnupg.nix
    ./programs/jq.nix
    ./programs/kitty.nix
    ./programs/mate.nix
    ./programs/nix-index.nix
    ./programs/picom.nix
    ./programs/polybar.nix
    ./programs/rofi.nix
    ./programs/steam.nix
    ./programs/vscode.nix
    ./programs/yubikey-touch-detector.nix
    ./theme
  ];

  xdg.userDirs = {
    enable = true;
    createDirectories = false;
  };

  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;

  home.stateVersion = "22.11";
}
