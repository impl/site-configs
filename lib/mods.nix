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
}
