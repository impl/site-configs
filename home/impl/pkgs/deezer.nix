# SPDX-FileCopyrightText: 2022-2025 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ callPackage
, copyDesktopItems
, electron_37
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
  version = "7.0.160";

  patchSrc = fetchFromGitHub {
    owner = "SibrenVasse";
    repo = "deezer";
    rev = version;
    hash = "sha256-rXuECZUtkiCXfihFxFpIFEIeh1e2hLUnoa8sOJlivhM=";
  };

  iconSrc = fetchFromGitHub {
    owner = "aunetx";
    repo = "deezer-linux";
    rev = "v7.0.150";
    hash = "sha256-KtPR8tgtT3WX5KgE94LQIburh1ok9lxxKLVZ8P6oa+0=";
  };
in
stdenv.mkDerivation rec {
  pname = "deezer-desktop";
  inherit version;

  src = fetchurl {
    url = "https://www.deezer.com/desktop/download/artifact-win32-x86-${version}";
    hash = "sha256-sN1Ux07eouYkLDclK4Bx8WSVuaciJJWq1w7dDEslWkw=";
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

  prePatch = "prettier --write 'build/*.{js,html}'";

  patches = [
    "${patchSrc}/01-start-hidden-in-tray.patch"
    "${patchSrc}/02-avoid-change-default-texthtml-mime-type.patch"
    "${patchSrc}/03-quit.patch"
    "${patchSrc}/04-disable-auto-updater.patch"
    "${patchSrc}/05-remove-os-information.patch"
    "${patchSrc}/06-better-management-of-MPRIS.patch"
    "${patchSrc}/07-log-level-environment-variable.patch"
    "${patchSrc}/08-additional-metadata.patch"
    "${patchSrc}/10-improve-responsiveness.patch"
    "${patchSrc}/11-hide-appoffline-banner.patch"
    "${patchSrc}/12-disable-animations.patch"
    "${patchSrc}/13-disable-notifications.patch"
    "${patchSrc}/14-thumbar-actions.patch"
    "${patchSrc}/15-systray-icon.patch"
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
    makeWrapper ${lib.getExe electron_37} $out/bin/${meta.mainProgram} \
      --add-flags --disable-systray \
      --add-flags $out/share/deezer-desktop/resources/app.asar \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ]}
  '';
}
