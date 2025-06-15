{
  description = "My system";

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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";

    catppuccin.url = "github:catppuccin/nix";

    flatpaks.url = "github:gmodena/nix-flatpak";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-index-database,
      catppuccin,
      flatpaks,
      plasma-manager,
      firefox-addons,
      sops-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      machines = [
        "chuwu"
        "copyright-respecter"
        "nixtop"
      ];

      overlays = [ ];

      pkgs = import nixpkgs {
        inherit system overlays;

        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
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

            sops-nix.nixosModules.sops

            # system configs
            ./modules/system/generic.nix
            ./modules/system/${machine}/config.nix
            ./modules/system/${machine}/hardware-config.nix

            home-manager.nixosModules.default
            {
              home-manager = {
                extraSpecialArgs = {
                  inherit system inputs;
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.zoe.imports = [
                  catppuccin.homeModules.catppuccin
                  plasma-manager.homeManagerModules.plasma-manager
                  ./modules/home/${machine}/home.nix
                ];
              };
            }
          ];
        }
      );

      templates = {
        full = {
          path = ./.;
          description = "My system";
        };
      } // import ./modules/templates;

      devShells."${system}".default = import ./shell.nix { inherit pkgs; };
    };
}
