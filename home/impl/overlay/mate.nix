# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

self: super: {
  mate = super.mate.overrideScope (self': super': {
    mate-power-manager = super'.mate-power-manager.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (self.fetchpatch {
          url = "https://github.com/impl/mate-power-manager/compare/v1.28.1...backlight-logind-fallback-v1.28.1.diff";
          hash = "sha256-YvK944JsojylwlS17FOvquDNCRs7owbsVKTCNMyGdyM=";
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

    mate-screensaver = super'.mate-screensaver.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [
        self.libGL
      ];

      configureFlags = (old.configureFlags or []) ++ [
        "--with-libgl"
        "--with-xscreensaverhackdir=${self.xscreensaver}/libexec/xscreensaver"
      ];
    });
  });
}
