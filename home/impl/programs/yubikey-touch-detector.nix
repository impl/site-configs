# SPDX-FileCopyrightText: 2019-2021 Jörg Thalheim
# SPDX-FileCopyrightText: 2021-2024 Noah Fontes
#
# SPDX-License-Identifier: MIT
#
# Portions of this file are derived from
# https://github.com/Mic92/nur-packages/blob/2d058f84775f1eb115e5005af7f8d6847d5149e2/pkgs/yubikey-touch-detector/default.nix

{ lib, machineConfig, pkgs, ... }: with lib; mkIf (machineConfig.profiles.physical.enable && machineConfig.profiles.userInteractive.enable) (let
  pkg = with pkgs; buildGoModule rec {
    pname = "yubikey-touch-detector";
    version = "unstable-2021-09-01";
    rev = "0464447c317e78391d7de964579ef72543e11350";

    src = fetchFromGitHub {
      owner = "impl";
      repo = "yubikey-touch-detector";
      inherit rev;
      sha256 = "sha256-G0W5rBfNT4paBCVufO+50A7grhrasdnJLfBXYmN28hw=";
    };

    vendorHash = "sha256-HQriDSaOQ9+E7zU8OGUjobpMECE3cnonSxOvjVVfP0g=";

    meta = with lib; {
      description = " A tool to detect when your YubiKey is waiting for a touch (to send notification or display a visual indicator on the screen)";
      license = licenses.mit;
      homepage = "https://github.com/maximbaz/yubikey-touch-detector";
    };
  };
in
{
  systemd.user.services."yubikey-touch-detector" = {
    Unit = {
      Description = "Detects when your YubiKey is waiting for a touch";
      Requires = "yubikey-touch-detector.socket";
    };

    Service = {
      ExecStart = "${pkg}/bin/yubikey-touch-detector";
      Environment = optionals machineConfig.profiles.gui.enable [
        "PATH=${makeBinPath [ pkgs.gnupg ]}"
        "YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY=true"
      ];
    };

    Install = {
      Also = "yubikey-touch-detector.socket";
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.sockets."yubikey-touch-detector" = {
    Unit = {
      Description = "Description=Unix socket activation for YubiKey touch detector service";
    };

    Socket = {
      ListenStream = "%t/yubikey-touch-detector.socket";
      RemoveOnStop = true;
    };

    Install = {
      WantedBy = [ "sockets.target" ];
    };
  };
})
