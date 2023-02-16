# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ buildPackages, kernel, lib, stdenv }:
stdenv.mkDerivation rec {
  pname = "iwlwifi";
  inherit (kernel) version;

  hardeningDisable = [ "pic" "format" ];

  src = builtins.path {
    name = "kernel";
    path = "${kernel.dev}/lib/modules/${kernel.modDirVersion}";
  };

  postUnpack = ''
    tar -C kernel/source -xf ${kernel.src} --strip-components=1 --wildcards '*/drivers/net/wireless/intel/'
  '';

  patchFlags = [ "-p1" "-d" "source" ];
  patches = [
    ./iwlwifi-missed-beacons-timeout.patch
  ];

  postPatch = ''
    substituteInPlace source/drivers/net/wireless/intel/iwlwifi/Makefile \
      --replace '$(src)' '$(srctree)/$(src)'
  '';

  makefile = "source/Makefile";
  makeFlags = [
    "O=build"
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
