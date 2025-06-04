{
  description = "My system"

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    catppuccin.url = "github:catppuccin/nix";

    flatpaks.url = "github:gmodena/nix-flatpak";

  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-index-database,
    catppuccin,
    flatpaks,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    machines = [
      "chuwu"
    ];

  overlays = [];

    pkgs = import nixpkgs {
      inherit system overlays;

      config = {
        allowUnfree = true;
      };
    };

    in
    with nixpkgs.lib;
    {
      nixosConfigurations = genAttrs machines (
        machine:
        nixosSystem {
          inherit pkgs system;

          specialArgs = {
            inherit inputs;
          };

          modules = [
            # things from inputs
            catppuccin.nixosModules.catppuccin
            nix-index-database.nixosModules.nix-index

            # system configs
            ./modules/system/generic.nix
            ./modules/system/${machine}/config.nix
            ./modules/system/${machine}/hardware-config.nix

            home-manager.nixosModules.default
            {
              home-manager={
                extraSpecialArgs = {
                  inherit system inputs;
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.zoe.imports = [
                  catppuccin.homeModules.catppuccin
                  ./modules/system/${machine}/home.nix
                ];
              };
            }
          ];
        }
      );

      templates = {
        full = {
          path = ./.;
          description = "My system"
        };
      } // import ./modules/templates;

      devShells."${system}".default = import ./shell.nix { inherit pkgs; };
    };
}