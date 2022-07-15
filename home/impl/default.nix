# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, inputs, lib, machineConfig, pkgs, ... }: {
  _module.args = {
    libX = import ./lib { inherit lib; };
  };

  # https://github.com/nix-community/home-manager/issues/2942
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);
  nixpkgs.overlays = [
    inputs.nur.overlay
    (import ./overlay)
  ];

  imports = [
    ./profiles
    ./programs/direnv
    ./programs/firefox
    ./programs/vim
    ./programs/xmonad
    ./programs/zsh
    ./programs/bat.nix
    ./programs/deezer.nix
    ./programs/dropbox.nix
    ./programs/git.nix
    ./programs/gnupg.nix
    ./programs/jq.nix
    ./programs/keepass.nix
    ./programs/kitty.nix
    ./programs/mate.nix
    ./programs/nix-index.nix
    ./programs/picom.nix
    ./programs/polybar.nix
    ./programs/rofi.nix
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
