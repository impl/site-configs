# SPDX-FileCopyrightText: 2022 Edmund Wu
# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: MIT
#
# Portions of this file are derived from
# https://github.com/NixOS/nixpkgs/blob/66a6cd1d5191af8d3ad3dfd7c31f49d930696b68/pkgs/applications/editors/vscode/with-extensions.nix

# https://github.com/nix-community/home-manager/issues/3507
# https://github.com/microsoft/vscode/commit/23b25e9d4d3aad79f59a087f25bffb859afea88e
{ drvs, writeTextFile }:
let
  toExtensionJsonEntry = drv: rec {
    identifier = {
      id = "${drv.vscodeExtPublisher}.${drv.vscodeExtName}";
      uuid = "";
    };

    version = drv.version;

    location = {
      "$mid" = 1;
      fsPath = drv.outPath + "/share/vscode/extensions/${drv.vscodeExtUniqueId}";
      path = location.fsPath;
      scheme = "file";
    };

    metadata = {
      id = identifier.uuid;
      publisherId = "";
      publisherDisplayName = drv.vscodeExtPublisher;
      targetPlatform = "undefined";
      isApplicationScoped = false;
      updated = false;
      isPreReleaseVersion = false;
      installedTimestamp = 0;
      preRelease = false;
    };
  };
in
writeTextFile {
  name = "vscode-extensions-json";
  text = builtins.toJSON (map toExtensionJsonEntry drvs);
  destination = "/share/vscode/extensions/extensions.json";
}
