# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib }:
let
  mkLib = self:
    let
      importLib = file: import file { inherit self lib; };
    in
    {
      colors = importLib ./colors.nix;
      edid = importLib ./edid.nix;
      encoding = importLib ./encoding.nix;
      math = importLib ./math.nix;
    };
in lib.makeExtensible mkLib
