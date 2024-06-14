# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ pkgs, ... }: {
  _module.args = {
    pkgsHome = pkgs.callPackage ./pkgs { };
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-13.6.9"
    ];
  };
  nixpkgs.overlays = [
    (import ./overlay)
  ];

  imports = [
    ./locations/home
    ./profiles
    ./programs/cachix
    ./programs/direnv
    ./programs/dropbox
    ./programs/firefox
    ./programs/git
    ./programs/keepass
    ./programs/vim
    ./programs/xmonad
    ./programs/zsh
    ./programs/autorandr.nix
    ./programs/bat.nix
    ./programs/deezer.nix
    ./programs/flatpak.nix
    ./programs/gnupg.nix
    ./programs/jq.nix
    ./programs/kitty.nix
    ./programs/mate.nix
    ./programs/nix-index.nix
    ./programs/nix.nix
    ./programs/picom.nix
    ./programs/polybar.nix
    ./programs/ripgrep.nix
    ./programs/rofi.nix
    ./programs/ssh.nix
    ./programs/steam.nix
    ./programs/valgrind.nix
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
