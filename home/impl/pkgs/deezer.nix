# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ callPackage
, copyDesktopItems
, electron_33
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
  version = "7.0.20";

  patchSrc = fetchFromGitHub {
    owner = "SibrenVasse";
    repo = "deezer";
    rev = "v${version}";
    hash = "sha256-XMsTUXupQh/57xqFdAfEDae2icwEM6rE/qLTEiywG0U=";
  };

  iconSrc = fetchFromGitHub {
    owner = "aunetx";
    repo = "deezer-linux";
    rev = "c65da965f23c659984c7a295ffc4ed33d3a3bf13";
    hash = "sha256-oxio4oiobNtMEso/WtjzWeH6t6GRzHlELjTHVLQDBvI=";
  };
in
stdenv.mkDerivation rec {
  pname = "deezer-desktop";
  inherit version;

  src = fetchurl {
    url = "https://www.deezer.com/desktop/download/artifact-win32-x86-${version}";
    hash = "sha256-bJ3IvN9cwBn1W37eaHA2sz4Aq/WLNxzSroxQb7KhS7o=";
  };

  meta = with lib; {
    description = "Online music streaming service";
    mainProgram = "deezer-desktop";
    license = licenses.unfree;
    homepage = "https://www.deezer.com";
    platforms = platforms.linux;
  };

  desktopItems = lib.singleton (makeDesktopItem {
    name = pname;
    tryExec = meta.mainProgram;
    exec = "${meta.mainProgram} %U";
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
    7z x -y -bsp0 -bso0 app-32.7z
    asar extract resources/app.asar resources/app
  '';

  sourceRoot = "resources/app";

  prePatch = "prettier --write 'build/*.js'";

  patches = [
    "${patchSrc}/remove-kernel-version-from-user-agent.patch"
    "${patchSrc}/avoid-change-default-texthtml-mime-type.patch"
    "${patchSrc}/start-hidden-in-tray.patch"
    "${patchSrc}/systray.patch"
    "${patchSrc}/systray-buttons-fix.patch"
    "${patchSrc}/quit.patch"
  ];

  noBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/deezer-desktop/resources
    asar pack . $out/share/deezer-desktop/resources/app.asar

    mkdir $out/share/deezer-desktop/resources/linux
    cp $NIX_BUILD_TOP/resources/win/systray.png $out/share/deezer-desktop/resources/linux

    for icon in ${iconSrc}/icons/*.png; do
      mkdir -p "$out/share/icons/hicolor/$(basename "$icon" .png)/apps"
      cp "$icon" "$out/share/icons/hicolor/$(basename "$icon" .png)/apps/${meta.mainProgram}.png"
    done

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${lib.getExe electron_33} $out/bin/${meta.mainProgram} \
      --add-flags --disable-systray \
      --add-flags $out/share/deezer-desktop/resources/app.asar \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ]}
  '';
}
