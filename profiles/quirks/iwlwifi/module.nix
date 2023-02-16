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
  inherit (kernel) version;

  hardeningDisable = [ "pic" "format" ];

  src = builtins.path {
    name = "kernel";
    path = "${kernel.dev}/lib/modules/${kernel.modDirVersion}";
  };

  postUnpack = ''
    chmod -R u+w kernel
    tar -C kernel/source \
      -xf ${kernel.src} \
      --strip-components=1 \
      --wildcards \
      '*/drivers/net/wireless/intel/'
  '';

  sourceRoot = "kernel/source";

  patches = [
    ./iwlwifi-missed-beacons-timeout.patch
  ];

  postPatch = ''
    substituteInPlace drivers/net/wireless/intel/iwlwifi/Makefile \
      --replace '$(src)' '$(srctree)/$(src)'
  '';

  makeFlags = [
    "O=../build"
    "M=drivers/net/wireless/intel/iwlwifi"
    "CC=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
    "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
    "HOSTLD=${buildPackages.stdenv.cc.bintools}/bin/${buildPackages.stdenv.cc.targetPrefix}ld"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "INSTALL_MOD_PATH=${builtins.placeholder "out"}"
  ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  buildFlags = [ "modules" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "Intel Wireless WiFi Next Gen AGN - Wireless-N/Advanced-N/Ultimate-N (iwlwifi)";
    inherit (kernel.meta) homepage license platforms;
  };
}
