# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib
, makeWrapper
, stdenv
, pinentry
, pinentryPackage ? null
}:
let
  base = (builtins.getFlake "github:impl/karp/55d5163aba456502a2a2ac2430e6bf13de2f2a9a").outputs.packages.${stdenv.hostPlatform.system}.karp;
in
if pinentryPackage != null
then
  base.overrideAttrs
    (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/karp \
          --add-flags "--pinentry-program ${lib.getExe pinentryPackage}"
      '';
    })
else base
