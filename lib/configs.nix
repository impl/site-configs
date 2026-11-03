# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, overlaysDir, shallowRemapsDir, ... }:
{
  shared = {
    imports = [
      ({ config, lib, options, pkgs, ... }: {
        nixpkgs.overlays = [
          (import (overlaysDir + "/general"))
          (import (overlaysDir + "/${lib.trivial.release}"))
        ];
        nix.registry.nixpkgs.to = {
          type = "path";
          path = "${pkgs.path}";
        };
      })
      (self.mods.mkOverrideOld 50 [ "_module" "args" "pkgs" ]
        (pkgs: pkgs.lib.foldl' (p: remap: p // remap p) pkgs [
          (import (shallowRemapsDir + "/general"))
          (import (shallowRemapsDir + "/${pkgs.lib.trivial.release}"))
        ]))
    ];
  };
}
