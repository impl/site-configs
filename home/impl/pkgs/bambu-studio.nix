# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{
  appimageTools
, cacert
, fetchurl
, glib-networking
, lib
, makeDesktopItem
}:
let
  version = "02.02.02.56";
  pr = "8184";
in
appimageTools.wrapType2 rec {
  name = "BambuStudio";
  pname = "bambu-studio";
  inherit version;

  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/Bambu_Studio_ubuntu-24.04_PR-${pr}.AppImage";
    hash = "sha256-ziipEMz58lG/+uxubCd53c6BjJ9W3doJ9/Z8VJp+Za4=";
  };

  profile = ''
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    export GIO_MODULE_DIR="${glib-networking}/lib/gio/modules/"
  '';

  extraPkgs = pkgs: with pkgs; [
    cacert
    curl
    glib
    glib-networking
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    webkitgtk_4_1
    libglvnd
    fontconfig
    dejavu_fonts
    liberation_ttf
    libxkbcommon
    hack-font
  ];

  meta = with lib; {
    description = "PC Software for BambuLab and other 3D printers";
    mainProgram = "bambu-studio";
    license = licenses.agpl3Plus;
    homepage = "https://github.com/bambulab/BambuStudio";
    platforms = platforms.linux;
  };

  desktopItems = lib.singleton (makeDesktopItem {
    name = pname;
    tryExec = meta.mainProgram;
    exec = "${meta.mainProgram} %U";
    desktopName = "Bambu Studio";
    genericName = meta.description;
    icon = "BambuStudio";
    categories = [ "Graphics" "3DGraphics" "Engineering" ];
    mimeTypes = [
      "model/stl"
      "model/3mf"
      "application/vnd.ms-3mfdocument"
      "application/prs.wavefront-obj"
      "application/x-amf"
      "x-scheme-handler/bambustudio"
    ];
  });
}
