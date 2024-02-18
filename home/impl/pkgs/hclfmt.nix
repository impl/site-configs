# SPDX-FileCopyrightText: 2022-2024 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ buildGoModule, lib, fetchFromGitHub }:

let
  version = "2.14.0";
in
buildGoModule {
  pname = "hclfmt";
  inherit version;

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "hcl";
    rev = "v${version}";
    sha256 = "sha256-Rx073Ob7CqaPEGIskJHW/xmt4S+WE/AWKewXpjY3kQ4=";
  };

  subPackages = [ "cmd/hclfmt" ];

  vendorHash = "sha256-9IGHILgByNFviQcHJCFoEX9cZif1uuHCu4xvmGZYoXk=";

  meta = with lib; {
    description = "Format HCL files";
    homepage = "https://github.com/hashicorp/hcl";
    license = licenses.mpl20;
  };
}
