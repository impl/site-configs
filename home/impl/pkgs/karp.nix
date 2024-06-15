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
  base = (builtins.getFlake "github:impl/karp/d5051334ea0771350d5e3492e1cbc96bae1e53ed").outputs.packages.${stdenv.hostPlatform.system}.karp;
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
