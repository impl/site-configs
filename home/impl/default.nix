# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, lib, pkgs, ... }: with lib; {
  _module.args = {
    pkgsHome = pkgs.callPackage ./pkgs { };
  };

  imports = [
    ./locations/home
    ./profiles
    ./programs/cachix
    ./programs/direnv
    ./programs/dropbox
    ./programs/git
    ./programs/vim
    ./programs/zsh
    ./programs/amethyst.nix
    ./programs/alacritty.nix
    ./programs/bat.nix
    ./programs/deezer.nix
    ./programs/gnupg.nix
    ./programs/jq.nix
    ./programs/karp.nix
    ./programs/nix-index.nix
    ./programs/nix.nix
    ./programs/ripgrep.nix
    ./programs/ssh.nix
    ./programs/valgrind.nix
    ./programs/vscode.nix
    ./programs/yubikey-touch-detector.nix
    ./theme
  ] ++ optionals (class == "nixos") [
    ./programs/emacs
    ./programs/firefox
    ./programs/xmonad
    ./programs/autorandr.nix
    ./programs/bambu-studio.nix
    ./programs/flatpak.nix
    ./programs/keepass
    ./programs/mate.nix
    ./programs/picom.nix
    ./programs/polybar.nix
    ./programs/rofi.nix
    ./programs/steam.nix
  ] ++ optionals (class == "darwin") [
    ./programs/keepassxc.nix
  ];

  home.stateVersion = "22.11";
}
