# SPDX-FileCopyrightText: 2021-2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ self, inputs, lib, overlaysDir, pkgsDir, profilesDir, ... }:
let
  enhanceMachine = { class, check ? true }: machine@{ modules, specialArgs ? { }, ... }:
    machine // {
      modules = modules ++ [
        {
          # nix-darwin doesn't get far enough along in the checked module
          # process to correctly expose extendModules, so we make checks
          # conditional to be able to extract it for later.
          _module.check = check;
        }
      ];

      specialArgs = specialArgs // {
        inherit class;
      };
    };
in
{
  mkSystem = nixpkgs: builder: machine: (builder machine).extendModules {
    modules = [
      {
        nixpkgs.overlays = [
          (import "${overlaysDir}/${nixpkgs.lib.trivial.release}")
        ];
        nix.registry.nixpkgs.flake = nixpkgs;
      }
      profilesDir
      ({ pkgs, ... }: {
        _module = {
          args = {
            libX = self;
            libSops = inputs.nix-sops.lib;
            libDNS = inputs.dns.lib;
            pkgsNUR = import inputs.nur {
              nurpkgs = pkgs;
              inherit pkgs;
            };
            pkgsUnstable = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
            pkgsX = pkgs.callPackage pkgsDir { };
          };
          check = lib.mkForce true;
        };
      })
    ];
  };

  mkNixosSystem = nixpkgs:
    let
      builder = machine@{ specialArgs ? { }, ... }:
        let
          cfg = nixpkgs.lib.nixosSystem (enhanceMachine { class = "nixos"; check = false; } machine);
        in
        cfg.extendModules {
          modules = [
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.nix-sops.nixosModules.default
            inputs.systemd-user-sleep.nixosModules.systemd-user-sleep
          ];
        };
    in
    self.machines.mkSystem nixpkgs builder;

  mkDarwinSystem = nix-darwin:
    let
      builder = machine@{ modules, specialArgs ? { }, ... }:
        let
          cfg = nix-darwin.lib.darwinSystem (enhanceMachine { class = "darwin"; check = false; } machine);

          mkExtensible = cfg: {
            inherit (cfg._module.args) pkgs;
            inherit (cfg) options config _module;
            class = "darwin";
            system = cfg.config.system.build.toplevel;
            extendModules = args: mkExtensible (cfg._module.args.extendModules args);
          };
        in
        mkExtensible cfg;
    in
    self.machines.mkSystem nix-darwin.inputs.nixpkgs builder;

  mkMachineConfiguration = eval: eval {
    nixos_unstable = self.machines.mkNixosSystem inputs.nixpkgs;
    nixos_2511 = self.machines.mkNixosSystem inputs.nixos_2511;
    nix-darwin_2511 = self.machines.mkDarwinSystem inputs.nix-darwin_2511;
  };

  mkMachineConfigurations = machines:
    let
      mkMachineWithHostName = hostName: eval: (self.machines.mkMachineConfiguration eval).extendModules {
        modules = [
          { networking = { inherit hostName; }; }
        ];
      };
    in
    builtins.mapAttrs mkMachineWithHostName machines;

  mkMachineOutputs = cfgs:
    let
      mkMachineOutput = hostName: cfg@{ class ? "nixos", ... }:
        let
          classAttr =
            if class == "darwin" then "darwinConfigurations"
            else if class == "nixos" then "nixosConfigurations"
            else throw "Unsupported machine class: ${class}.";
        in
        {
          ${classAttr}.${hostName} = cfg;
        };
    in
    builtins.zipAttrsWith (name: values: lib.mergeAttrsList values) (lib.mapAttrsToList mkMachineOutput cfgs);
}
