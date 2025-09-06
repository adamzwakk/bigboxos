{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";

    home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: let
      system = "x86_64-linux";
      pkgs = import nixpkgs { 
        inherit system;  
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        testvm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./system
            ./system/hosts/vm/hardware-config.nix
          ];

          specialArgs.flake-inputs = inputs;
        };
      };

      # packages.${system} = pkgs.lib.packagesFromDirectoryRecursive {
      #   callPackage = pkgs.lib.callPackageWith (pkgs // { inherit (pkgs) lib; });
      #   directory = ./packages;
      # };
    };
}
