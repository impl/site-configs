# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ class, config, lib, ... }: with lib;
let
  cfg = config.profiles.sound;
in
{
  options = {
    profiles.sound = {
      enable = mkEnableOption "the sound profile";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (class == "nixos") {
      sound.enable = true;
      hardware.pulseaudio.enable = true;
    })
  ]);
}
