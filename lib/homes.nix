{ self, homeDir, inputs, lib, ... }:
let
  homes = self.mods.importDir homeDir;
in
{
  mkHomeConfigurations = nixosConfigurations:
    let
      mkHomeConfigurationsForNixosConfiguration = hostName: nixosConfiguration:
        let
          machineConfig = nixosConfiguration.config;
          machineHasUser = userName: cfg: builtins.hasAttr userName machineConfig.users.users;

          mkHomeConfiguration = userName: cfg:
            let
              homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration (cfg // {
                extraModules = [ inputs.nix-sops.homeModule ];
                extraSpecialArgs = {
                  inherit inputs machineConfig;
                };

                system = machineConfig.nixpkgs.system;
                username = userName;
                homeDirectory = machineConfig.users.users.${userName}.home;
              });
            in
              lib.nameValuePair "${userName}@${hostName}" homeConfiguration;
        in
          lib.mapAttrs' mkHomeConfiguration (lib.filterAttrs machineHasUser homes);

      homeConfigurations = builtins.mapAttrs mkHomeConfigurationsForNixosConfiguration nixosConfigurations;
    in
      lib.foldAttrs (n: a: n // a) {} (builtins.attrValues homeConfigurations);
}
