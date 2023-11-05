# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, pkgs, pkgsX, ... }: with lib;
let
  cfg = config.profiles.userInteractive;
in
{
  options = {
    profiles.userInteractive = {
      enable = mkEnableOption "the user-interactive profile";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
      vim
    ];

    programs.bash.enableCompletion = true;
    programs.zsh = {
      enable = true;
      enableCompletion = true;
    };

    users.defaultUserShell = pkgsX.choysh;
    environment.etc."choysh".source = "${pkgs.bashInteractive}${pkgs.bashInteractive.shellPath}";

    # Allow users to use firejail.
    programs.firejail.enable = true;
  };
}
