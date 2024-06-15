# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ fetchurl, lib, stdenv, undmg }:
stdenv.mkDerivation rec {
  pname = "BetterDisplay";
  version = "2.3.9";

  src = fetchurl {
    url = "https://github.com/waydabber/BetterDisplay/releases/download/v${version}/BetterDisplay-v${version}.dmg";
    hash = "sha256-PuBD/ViTqzVO+8TJqSKVohs2XlWvNMxkYSJVh4t0ZyI=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Unlock your displays on your Mac";
    homepage = "https://betterdisplay.pro";
    license = licenses.unfree;
    platforms = platforms.darwin;
  };
}
