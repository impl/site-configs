# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  configuration = { config, inputs, machineConfig, pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      inputs.nur.overlay
    ];

    imports = [
      ./modules/gui.nix
      ./modules/user-interactive.nix
      ./programs/firefox
      ./programs/polybar
      ./programs/vim
      ./programs/xmonad
      ./programs/zsh
      ./programs/direnv.nix
      ./programs/dropbox.nix
      ./programs/git.nix
      ./programs/gnupg.nix
      ./programs/jq.nix
      ./programs/keepass.nix
      ./programs/kitty.nix
      ./programs/picom.nix
      ./programs/rofi.nix
      ./programs/vscode.nix
      ./programs/yubikey-touch-detector.nix
    ];

    xdg.userDirs = {
      enable = true;
      createDirectories = false;
    };

    systemd.user.startServices = "sd-switch";

    programs.home-manager.enable = true;
  };
}
