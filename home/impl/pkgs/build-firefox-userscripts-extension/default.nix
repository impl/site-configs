# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ stdenv
, formats
, jq
, lib
, linkFarm
, lndir
, moreutils
, symlinkJoin
, zip
}:

userScripts:
let
  mapped = lib.imap0
    (i: { matches, jsFile }:
      let
        fileName = "data/script-${toString i}.js";
      in
      {
        config = {
          inherit matches;
          js = [{ file = fileName; }];
        };
        data = {
          name = fileName;
          path = "${jsFile}";
        };
      })
    userScripts;

  config = (formats.json { }).generate "user-scripts-config.json"
    (builtins.catAttrs "config" mapped);
  data = linkFarm "user-scripts-data"
    ((builtins.catAttrs "data" mapped) ++ [{ name = "config.json"; path = config; }]);

  addonId = "user-scripts@impl";
in
stdenv.mkDerivation {
  name = "user-scripts-extension";
  src = ./src;

  nativeBuildInputs = [ jq lndir moreutils zip ];

  buildPhase = ''
    runHook preBuild
    jq '.browser_specific_settings.gecko.id = "${addonId}"' manifest.json \
      | sponge manifest.json
    lndir -silent ${data} .
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    zip -r -q -FS "$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${addonId}.xpi" *
    runHook postInstall
  '';

  passthru = {
    inherit addonId;
  };
}
