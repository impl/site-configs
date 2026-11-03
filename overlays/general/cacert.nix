# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

self: super:
let
  certdata-filter = self.callPackage ../../pkgs/certdata-filter { };
  allowlist = [
    { subject = { O = "Amazon"; C = "US"; }; }
    { subject = { O = "DigiCert Inc"; C = "US"; }; }
    { subject = { O = "DigiCert, Inc."; C = "US"; }; }
    { subject = { O = "GlobalSign"; }; }
    { subject = { O = "GlobalSign nv-sa"; C = "BE"; }; }
    { subject = { O = "Google Trust Services LLC"; C = "US"; }; }
    { subject = { O = "Internet Security Research Group"; C = "US"; }; }
    { subject = { O = "Microsoft Corporation"; C = "US"; }; }
    { subject = { O = "Sectigo Limited"; C = "GB"; }; }
  ];
  allowlistFile = self.writers.writeJSON "certdata-allowlist.json" allowlist;
  certdata-filtered = self.runCommand "certdata-filtered" { }
    ''
      mkdir -p $out
      ${super.lib.getExe certdata-filter} ${allowlistFile} ${super.cacert.src} >$out/certdata.txt
    '';
in
{
  cacert-unfiltered = self.cacert;
  cacert-filtered = self.cacert.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-filtered";
    src = "${certdata-filtered}/certdata.txt";
  });
}
