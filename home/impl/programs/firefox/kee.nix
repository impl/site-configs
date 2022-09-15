# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, nur }: nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon rec {
  pname = "kee-password-manager";
  version = "3.9.5";
  addonId = "keefox@chris.tomlinson";
  url = "https://addons.mozilla.org/firefox/downloads/file/3771439/kee_password_manager-${version}-fx.xpi";
  sha256 = "c36b9c888f40cf2611223a4d2264cc38a3dfe70687935218fa123fcad4341023";
  meta = with lib; {
    homepage = "https://www.kee.pm";
    description = "Save time, sign in easily to websites and avoid the hassle of forgotten password resets.\n\nProtect yourself and people you know from the nightmare of your accounts being hacked.";
    license = licenses.agpl3;
    platforms = platforms.all;
  };
}
