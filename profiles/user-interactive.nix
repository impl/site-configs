# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, pkgs, pkgsX, ... }: with lib;
let
  cfg = config.profiles.userInteractive;
in
{
  options = {
    profiles.userInteractive = {
      enable = mkEnableOption "the user-interactive profile";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = with pkgs; [
        git
        vim
        pkgsX.choysh
      ];

      programs.bash = {
        completion.enable = true;
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
      };
    }
    (optionalAttrs (class == "nixos") {
      users.defaultUserShell = pkgsX.choysh;
      environment.etc."choysh".source = "${pkgs.bashInteractive}${pkgs.bashInteractive.shellPath}";

      # Allow users to use firejail.
      programs.firejail.enable = true;
    })
  ]);
}
