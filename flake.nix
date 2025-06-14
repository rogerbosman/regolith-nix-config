{
  description = "Regolith NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    regolith.url = "github:regolith-lab/regolith-nix";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      host = "regolith";
      username = "roronoa";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem rec {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit username;
            inherit host;
          };
          modules = [
            ./hosts/${host}/config.nix
            # inputs.distro-grub-themes.nixosModules.${system}.default
          ];
        };
      };
      templates.regolith-starter = {
        path = ./.; # Directory containing install.sh and other starter files
        description = "A starter template with install.sh for easy setup";
        welcomeText = ''
          # Welcome to Regolith Nix Starter Template

          To get started, run:

              ./install.sh

          This will set up your configuration.
        '';
      };

      templates.default = self.templates.regolith-starter;
    };
}
