# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ fetchurl, lib, stdenv, unzip }:
stdenv.mkDerivation rec {
  pname = "Amethyst";
  version = "0.21.1";

  src = fetchurl {
    url = "https://github.com/ianyh/Amethyst/releases/download/v${version}/Amethyst.zip";
    hash = "sha256-TGSCrv6eeXaBJ1b2P6mZuFXfTQQ/7CjTiyA1VOYHCCg=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Automatic tiling window manager for macOS à la XMonad";
    homepage = "https://ianyh.com/amethyst/";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
