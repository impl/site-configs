# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, lib, ... }: with lib; {
  cacheMetadata = { name, sha256 }: let
    data = builtins.fromJSON (builtins.readFile (builtins.fetchurl {
      url = "https://cachix.org/api/v1/cache/${name}";
      inherit sha256;
    }));
  in getAttrs [ "uri" "publicSigningKeys" ] data;

  repoCacheMetadata = [
    (self.cachix.cacheMetadata { name = "impl"; sha256 = "1qd58arr286zv56dvk4pajbbjz92cjw19wpizfc78674iydv91zb"; })
  ];
}
