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
        nixpkgs.follows = "unstable";
      };
    };

    catppuccin.url = "github:catppuccin/nix";

  };

  outputs = {
    unstable,
    home-manager,
    nix-index-database,
    catppuccin,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    machines = [
      "chuwu"
    ];

    pkgs = import unstable {
      inherit system overlays;

      config = {
        allowUnfree = true;
      };
    };

    in
    with unstable.lib;
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
            ./modules/system/${machine}/hardware-config/nix

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