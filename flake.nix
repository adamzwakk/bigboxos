{
  description = "BBOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
        url = "github:nix-community/home-manager/release-25.05";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Base ISO
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./installer
        ];
      };
      bbos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./system
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