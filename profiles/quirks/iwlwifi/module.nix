# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ bc
, bison
, buildPackages
, elfutils
, flex
, kernel
, lib
, openssl
, python3Minimal
, stdenv
, zlib
}:
stdenv.mkDerivation rec {
  pname = "iwlwifi";
  inherit (kernel) version src;

  hardeningDisable = [ "pic" "format" ];

  nativeBuildInputs = [ bc bison elfutils flex openssl python3Minimal zlib ];

  patches = [
    ./iwlwifi-missed-beacons-timeout.patch
  ];

  postPatch = ''
    patchShebangs scripts
  '';

  postConfigure = ''
    cp ${kernel.configfile} .config
  '';

  makeFlags = [
    "CC=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
    "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
    "HOSTLD=${buildPackages.stdenv.cc.bintools}/bin/${buildPackages.stdenv.cc.targetPrefix}ld"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "INSTALL_MOD_PATH=$(out)"
  ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  buildPhase = ''
    runHook preBuild
    make $makeFlags modules_prepare
    make $makeFlags M=drivers/net/wireless/intel/iwlwifi modules
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make $makeFlags M=drivers/net/wireless/intel/iwlwifi modules_install
    runHook postInstall
  '';

  meta = {
    description = "Intel Wireless WiFi Next Gen AGN - Wireless-N/Advanced-N/Ultimate-N (iwlwifi)";
    inherit (kernel.meta) homepage license platforms;
  };
}
