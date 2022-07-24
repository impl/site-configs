# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

self: super: {
  mate = super.mate.overrideScope' (self': super': {
    mate-power-manager = super'.mate-power-manager.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (self.fetchpatch {
          url = "https://github.com/impl/mate-power-manager/compare/v1.26.0...backlight-logind-fallback-v1.26.diff";
          sha256 = "sha256-KxAI6tc1ngS7bucviaEyPz97dum9wwVZ0vU22cKmolA=";
        })
      ];

      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
        self.autoreconfHook
        self'.mate-common
        self.which
        self.yelp-tools
      ];

      buildInputs = (old.buildInputs or []) ++ [
        self.autoconf-archive
        self.libgudev
      ];

      autoreconfPhase = ''
        export ACLOCAL_FLAGS=''${ACLOCAL_PATH+-I }''${ACLOCAL_PATH//:/ -I /}
        ./autogen.sh
      '';

      configureFlags = (old.configureFlags or []) ++ [ "--with-udev" ];
    });
  });
  makeDesktopItem = args@{ extraConfig ? {}, ... }: super.makeDesktopItem (args // { extraConfig = { "Version" = "1.0"; } // extraConfig; });
}
