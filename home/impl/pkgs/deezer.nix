# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ copyDesktopItems
, electron_13
, fetchFromGitHub
, fetchurl
, lib
, makeBinaryWrapper
, makeDesktopItem
, nodePackages
, p7zip
, stdenv
, udev
}: let
  version = "5.30.220";
  aunetxVersion = "v${version}-2";

  electron = electron_13.overrideAttrs (old: {
    meta = old.meta // {
      # Ignore EOL for old Electron versions.
      knownVulnerabilities = [];
    };
  });

  aunetxAddl = fetchFromGitHub {
    owner = "aunetx";
    repo = "deezer-linux";
    rev = aunetxVersion;
    sparseCheckout = ''
      extra
      icons
      patches
    '';
    sha256 = "sha256-ZPOJzFUNjYRt3NGgpqcneNavSV36IF1JveA4qM4CPKs=";
  };
in stdenv.mkDerivation rec {
  pname = "deezer-desktop";
  inherit version;

  src = fetchurl {
    url = "https://www.deezer.com/desktop/download/artifact/win32/x86/${version}";
    sha256 = "sha256-YOJmpLtEgdRn4yjK9dsCTVaW1Oc6ZgaJ9tU5y9vQP8c=";
  };

  meta = with lib; {
    description = "Online music streaming service";
    license = licenses.unfree;
    homepage = "https://www.deezer.com";
    platforms = platforms.linux;
  };

  desktopItems = lib.singleton (makeDesktopItem {
    name = pname;
    tryExec = "deezer-desktop";
    exec = "deezer-desktop %U";
    desktopName = "Deezer";
    genericName = meta.description;
    icon = pname;
    comment = "Listen and download all your favorite music";
    categories = [ "Utility" "AudioVideo" "Audio" "Player" "Music" ];
    keywords = [ "Music" "Player" "Streaming" "Online" ];
    mimeTypes = [ "x-scheme-handler/deezer" ];
    startupWMClass = "Deezer";
  });

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
    nodePackages.asar
    nodePackages.prettier
    p7zip
  ];

  unpackCmd = ''
    7z e -y -bsp0 -bso0 $curSrc '$PLUGINSDIR/app-32.7z'
    7z e -y -bsp0 -bso0 app-32.7z resources/app.asar
    asar extract app.asar app
  '';

  prePatch = "prettier --write 'build/*.js'";

  patches = lib.filesystem.listFilesRecursive "${aunetxAddl}/patches";

  noBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin
    cp -r ${electron}/lib/electron $out/lib/deezer-desktop
    chmod -R +w $out/lib/deezer-desktop

    cp -r . $out/lib/deezer-desktop/resources/app
    cp -r ${aunetxAddl}/extra/. $out/lib/deezer-desktop/resources

    for icon in ${aunetxAddl}/icons/*.png; do
      mkdir -p "$out/share/icons/hicolor/$(basename "$icon" .png)/apps"
      cp "$icon" "$out/share/icons/hicolor/$(basename "$icon" .png)/apps/deezer-desktop.png"
    done

    runHook postInstall
  '';

  postFixup = ''
    declare -a wrapperCmd="( $(strings -dw "$out/lib/deezer-desktop/electron" | sed -n -e "s,${electron}/lib/electron,$out/lib/deezer-desktop,g" -e '/^makeCWrapper/,/^$/ p' ) )"
    test ''${#wrapperCmd[@]} -gt 1
    makeWrapper "''${wrapperCmd[1]}" \
      $out/bin/deezer-desktop \
      "''${wrapperCmd[@]:2}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ]} \
      --add-flags --disable-systray
  '';
}
