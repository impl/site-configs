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
}:
let
  version = "6.0.60";
  aunetxVersion = "v6.0.60-1";

  electron = electron_13.overrideAttrs (old: {
    meta = old.meta // {
      # Ignore EOL for old Electron versions.
      knownVulnerabilities = [ ];
    };
  });

  aunetxAddl = fetchFromGitHub {
    owner = "aunetx";
    repo = "deezer-linux";
    rev = aunetxVersion;
    sparseCheckout = [
      "extra"
      "icons"
      "patches"
    ];
    sha256 = "sha256-EJ6bzKeHdCEogSS8y/RNxrv75aTElbtnunT/mBmbhn8=";
  };
in
stdenv.mkDerivation rec {
  pname = "deezer-desktop";
  inherit version;

  src = fetchurl {
    url = "https://www.deezer.com/desktop/download/artifact/win32/x86/${version}";
    sha256 = "sha256-RjUIxCWi56A3IaGxo2vsfQ4h8JCht1RhHw/jDdd6JW8=";
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

  prePatch = "prettier --trailing-comma es5 --write 'build/*.js'";

  patches = [
    "${aunetxAddl}/patches/remove-kernel-version-from-user-agent.patch"
    "${aunetxAddl}/patches/avoid-change-default-texthtml-mime-type.patch"
    "${aunetxAddl}/patches/start-hidden-in-tray.patch"
    "${aunetxAddl}/patches/quit.patch"
  ];

  noBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec $out/bin
    cp -r ${electron}/libexec/electron $out/libexec/deezer-desktop
    chmod -R +w $out/libexec/deezer-desktop

    cp -r . $out/libexec/deezer-desktop/resources/app
    cp -r ${aunetxAddl}/extra/. $out/libexec/deezer-desktop/resources

    for icon in ${aunetxAddl}/icons/*.png; do
      mkdir -p "$out/share/icons/hicolor/$(basename "$icon" .png)/apps"
      cp "$icon" "$out/share/icons/hicolor/$(basename "$icon" .png)/apps/deezer-desktop.png"
    done

    runHook postInstall
  '';

  postFixup = ''
    declare -a wrapperCmd="( $(strings -dw "$out/libexec/deezer-desktop/electron" | sed -n -e "s,${electron}/libexec/electron,$out/libexec/deezer-desktop,g" -e '/^makeCWrapper/,/^$/ p' ) )"
    test ''${#wrapperCmd[@]} -gt 1
    makeWrapper "''${wrapperCmd[1]}" \
      $out/bin/deezer-desktop \
      "''${wrapperCmd[@]:2}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ]} \
      --add-flags --disable-systray
  '';
}
