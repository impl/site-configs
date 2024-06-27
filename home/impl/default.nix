# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, lib, pkgs, ... }: with lib; {
  _module.args = {
    pkgsHome = pkgs.callPackage ./pkgs { };
  };

  disabledModules = [
    "services/gpg-agent.nix"
  ];

  imports = [
    ./locations/home
    ./profiles
    ./programs/cachix
    ./programs/direnv
    ./programs/dropbox
    ./programs/git
    ./programs/keepass
    ./programs/vim
    ./programs/zsh
    ./programs/bat.nix
    ./programs/deezer.nix
    ./programs/gnupg.nix
    ./programs/jq.nix
    ./programs/nix-index.nix
    ./programs/nix.nix
    ./programs/ripgrep.nix
    ./programs/ssh.nix
    ./programs/steam.nix
    ./programs/valgrind.nix
    ./programs/vscode.nix
    ./programs/yubikey-touch-detector.nix
    ./services/gpg-agent.nix
    ./theme
  ] ++ optionals (class == "nixos") [
    ./programs/firefox
    ./programs/xmonad
    ./programs/autorandr.nix
    ./programs/flatpak.nix
    ./programs/kitty.nix
    ./programs/mate.nix
    ./programs/picom.nix
    ./programs/polybar.nix
    ./programs/rofi.nix
  ];

  home.stateVersion = "22.11";
}
