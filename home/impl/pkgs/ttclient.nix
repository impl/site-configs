# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ autoPatchelfHook
, buildPackages
, cairo
, cups
, emptyFile
, fetchurl
, fontconfig
, freetype
, gccForLibs
, gdk-pixbuf
, glib
, gtk2
, inetutils
, lib
, libGL
, libX11
, libXcomposite
, libXrender
, libXtst
, libxcrypt-legacy
, makeWrapper
, openjdk17
, oracle-instantclient
, pango
, perl
, stdenvNoCC
, sqlite
, unzip
, writeTextFile
, zlib
}:
stdenvNoCC.mkDerivation rec {
  pname = "ttclient";
  version = "2022.2.0";

  src = fetchurl {
    url = "https://ftp.perforce.com/alm/helixalm/r${version}/ttlinuxclientinstall.tar.gz";
    sha256 = "d06ce1d9c5e1ca39e8edda71f6bcf847ff09618651ce254055819a8b3ed6be62";
  };

  meta = with lib; {
    description = "Perforce Helix ALM Desktop Client";
    license = licenses.unfree;
    homepage = "https://www.perforce.com/products/helix-alm";
    platforms = [ "x86_64-linux" ];
  };

  nativeBuildInputs = [
    autoPatchelfHook
    inetutils
    makeWrapper
    openjdk17
    perl
    unzip
  ];

  buildInputs = [
    cairo
    cups
    gccForLibs
    gdk-pixbuf
    glib
    gtk2
    fontconfig
    freetype
    libGL
    libX11
    libXcomposite
    libXrender
    libXtst
    libxcrypt-legacy
    oracle-instantclient
    pango
    sqlite
    zlib
  ];

  sourceRoot = ".";

  postConfigure = ''
    cat >installer.properties <<EOF
    CHOSEN_INSTALL_SET=Client
    APPLICATION_DIR_1=$out/share/ttclient
    INSTALL_64BIT=1
    INSTALL_32BIT=0
    START_TTCLIENT=0
    VIEW_README=0
    EOF
  '';

  # Note that the installer needs to be run twice to install the binaries (no, I
  # don't know why).
  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR/home
    export IATEMPDIR=$TMPDIR
    mkdir -p $out/bin $out/lib
    export LD_PRELOAD=${buildPackages.libredirect}/lib/libredirect.so
    export NIX_REDIRECTS=/usr/bin/tr=${buildPackages.coreutils}/bin/tr:/etc/fstab=${emptyFile}:/usr/bin=$out/bin:/usr/lib/seapine=$out/lib/seapine:/etc/ttclient.conf=$TMPDIR/ttclient.conf:/Library=$TMPDIR/darwin
    bash ./ttlinuxclientinstall.bin -i Silent -f installer.properties
    bash ./ttlinuxclientinstall.bin -i Silent -f installer.properties
    unset LD_PRELOAD
    unset NIX_REDIRECTS
    tar -C $out/lib/seapine/tt64 -xf $out/lib/seapine/tt64/qtlibs64.tar.gz
    rm -rf $out/share/ttclient/jre64 $out/share/ttclient/UninstallData $out/share/ttclient/UninstallData_old
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    chmod +x $out/bin/*
    for i in $out/bin/*; do
      wrapProgram $i \
        --prefix QT_PLUGIN_PATH : $out/share/ttclient/qtplugins/64tt \
        --prefix QT_PLUGIN_PATH : $out/share/ttclient/qtplugins/64 \
        --chdir $out/share/ttclient
    done
    runHook postInstall
  '';
}
