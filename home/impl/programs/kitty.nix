# SPDX-FileCopyrightText: 2021-2022 Noah Fontes
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

  programs.zsh.initExtra = ''
    if test -n "$KITTY_INSTALLATION_DIR"; then
      export KITTY_SHELL_INTEGRATION="enabled"
      autoload -Uz -- "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty-integration"
      kitty-integration
      unfunction kitty-integration
    fi
  '';
}
