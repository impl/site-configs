# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ buildFirefoxXpiAddon, lib }: buildFirefoxXpiAddon rec {
  pname = "kee-password-manager";
  version = "3.11.13";
  addonId = "keefox@chris.tomlinson";
  url = "https://addons.mozilla.org/firefox/downloads/file/4183074/keefox-${version}.xpi";
  sha256 = "sha256-VWYr3Lfsu2re2bGtAk6xdR1lI7yzSJOye/TgcelTads=";
  meta = with lib; {
    homepage = "https://www.kee.pm";
    description = "Save time, sign in easily to websites and avoid the hassle of forgotten password resets.\n\nProtect yourself and people you know from the nightmare of your accounts being hacked.";
    license = licenses.agpl3Only;
    platforms = platforms.all;
  };
}
