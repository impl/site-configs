# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ callPackage
, copyDesktopItems
, fetchFromGitHub
, fetchurl
, lib
, makeBinaryWrapper
, makeDesktopItem
, nodePackages
, path
, p7zip
, stdenv
, udev
}:
let
  version = "6.0.60";
  aunetxVersion = "v6.0.60-1";

  mkElectron = callPackage (import "${path}/pkgs/development/tools/electron/binary/generic.nix") { };
  electron = mkElectron "13.6.9" {
    armv7l-linux = "e70cf80ac17850f3291c19a89235c59a7a6e0c791e7965805872ce584479c419";
    aarch64-linux = "cb570f77e46403a75b99740c41b297154f057dc3b9aa75fd235dccc5619972cf";
    x86_64-linux = "5e29701394041ba2acd8a9bb042d77967c399b8fe007d7ffbd1d3e6bfdb9eb8a";
    i686-linux = "7c31b60ee0e1d9966b8cf977528ace91e10ce25bb289a46eabbcf6087bee50e6";
    x86_64-darwin = "3393f0e87f30be325b76fb2275fe2d5614d995457de77fe00fa6eef2d60f331e";
    aarch64-darwin = "8471777eafc6fb641148a9c6acff2ea41c02a989d4d0a3a460322672d85169df";
    headers = "0vvizddmhprprbdf6bklasz6amwc254bpc9j0zlx23d1pgyxpnhc";
  };

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
