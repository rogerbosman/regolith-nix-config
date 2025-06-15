{
  description = "Regolith NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    regolith.url = "github:regolith-lab/regolith-nix";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      # Ensure Home Manager uses the same nixpkgs as your system
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, home-manager, ... }:  
    let
      system = "x86_64-linux";
      host = "regolith";
      username = "roger";

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
            
            # Add Home Manager as a NixOS module
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.roger = import ./hosts/regolith/home.nix;
            }
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
