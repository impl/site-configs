# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ lib, ... }:
{
  importDir = dir:
    if builtins.pathExists (dir + "/default.nix") then
      import dir
    else
      let
        contents = builtins.readDir dir;

        isImportable = name: type:
          type == "regular" && lib.hasSuffix ".nix" name ||
          type == "directory" && builtins.pathExists (dir + "/${name}/default.nix") && !lib.matchAttrs { ${name} = "regular"; } contents;

        doImport = name: type:
          lib.nameValuePair
            (if type == "regular" then lib.removeSuffix ".nix" name else name)
            (import (dir + "/${name}"));
      in
        lib.mapAttrs' doImport (lib.filterAttrs isImportable contents);

  mkOverrideOld = priority: path: f:
    { options, ... }:
    let
      root = lib.getAttrFromPath (lib.init path) options;
      opt = lib.last path;
      defs = builtins.foldl'
        (acc: def:
          acc ++ lib.optionals
            (
              (builtins.hasAttr opt def.value) &&
              (
                if (def.value.${opt}._type or null) == "override"
                then def.value.${opt}.priority
                else lib.modules.defaultOverridePriority
              ) > priority
            )
            [ { value = def.value.${opt}; } ])
        [ ] root.definitionsWithLocations;
      value = lib.mergeOneOption path (lib.modules.filterOverrides defs);
    in lib.setAttrByPath path (lib.mkOverride priority (f value));
}
