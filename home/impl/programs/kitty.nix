# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ config, lib, machineConfig, pkgs, ... }: with lib; mkIf machineConfig.profiles.gui.enable {
  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = "no";
      font_family = config.profiles.theme.font.codeFont;
      font_size = 11;
      window_padding_width = "5";
    };
  };

  xdg.configFile."kitty/ssh.conf" = {
    text = ''
      remote_kitty no
    '';
  } // optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    onChange = ''
      ${pkgs.procps}/bin/pkill -USR1 -u $USER kitty || true
    '';
  };
}
