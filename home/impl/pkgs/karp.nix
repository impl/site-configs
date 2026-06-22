# SPDX-FileCopyrightText: 2022-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib
, makeWrapper
, stdenv
, pinentry
, pinentryPackage ? null
}:
let
  base = (builtins.getFlake "github:impl/karp/e84485a2e51b2db3ea129793307d60ad24e1840a").outputs.packages.${stdenv.hostPlatform.system}.karp;
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
