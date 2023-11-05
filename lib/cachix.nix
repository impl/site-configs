# SPDX-FileCopyrightText: 2022-2023 Noah Fontes
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
    (self.cachix.cacheMetadata { name = "impl"; sha256 = "sha256-6eE0SoJiL9ufD875hxwJPXr0bBT8mT9M18ZNYJ1B838="; })
  ];
}
