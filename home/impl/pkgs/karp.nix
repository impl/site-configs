# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ makeWrapper, stdenv, pinentry, pinentryFlavor ? null }: let
  base = (builtins.getFlake "github:impl/karp/816e55effc066b96c4aabd110a3ee404e3c227e2").outputs.packages.${stdenv.hostPlatform.system}.karp;
in
  if pinentryFlavor != null
  then
    base.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/karp \
          --add-flags "--pinentry-program ${pinentry.${pinentryFlavor}}/bin/pinentry"
      '';
    })
  else base
