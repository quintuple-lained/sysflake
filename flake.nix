{
  description = "My system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable-small.url = "github:nixos/nixpkgs/nixos-24.11-small";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
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

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    inputs@{ nixpkgs
    , nixpkgs-stable
    , nixpkgs-small
    , nixpkgs-stable-small
    , home-manager
    , nix-index-database
    , catppuccin
    , flatpaks
    , plasma-manager
    , firefox-addons
    , sops-nix
    , ...
    }:
    let
      system = "x86_64-linux";
      overlays = [ ];

      # Machine configurations with their preferred channels
      machineConfigs = {
        # Full-featured machines
        chuwu = {
          channel = nixpkgs;
        };
        copyright-respecter = {
          channel = nixpkgs;
        };
        nixtop = {
          channel = nixpkgs;
        };
        thickpad = {
          channel = nixpkgs;
        };

        #        minimal-vps = {
        #          channel = nixpkgs-small;
        #        };
      };

      channelPkgs =
        builtins.mapAttrs
          (
            name: channel:
              import channel {
                inherit system overlays;
                config = {
                  allowUnfree = true;
                  nvidia.acceptLicense = true;
                };
              }
          )
          {
            inherit
              nixpkgs
              nixpkgs-stable
              nixpkgs-small
              nixpkgs-stable-small
              ;
          };

      # Helper function to create nixosSystem configurations
      makeNixosSystem =
        machine: config:
        let
          pkgs = channelPkgs.${config.channel.outPath or "nixpkgs"};
          # Fallback to finding the right pkgs
          actualPkgs =
            if config.channel == nixpkgs then
              channelPkgs.nixpkgs
            else if config.channel == nixpkgs-stable then
              channelPkgs.nixpkgs-stable
            else if config.channel == nixpkgs-small then
              channelPkgs.nixpkgs-small
            else if config.channel == nixpkgs-stable-small then
              channelPkgs.nixpkgs-stable-small
            else
              channelPkgs.nixpkgs;
        in
        nixpkgs.lib.nixosSystem {
          pkgs = actualPkgs;
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            # Common modules
            ./modules/system/generic.nix
            ./modules/system/${machine}/config.nix
            ./modules/system/${machine}/hardware-config.nix

            # Always include sops-nix
            sops-nix.nixosModules.sops

            # Conditional modules based on channel choice
            (
              if config.channel == nixpkgs || config.channel == nixpkgs-stable then
                {
                  imports = [
                    catppuccin.nixosModules.catppuccin
                    nix-index-database.nixosModules.nix-index
                  ];
                }
              else
                {
                  # Minimal configuration - just the essentials
                  imports = [ ];
                }
            )

            # Home Manager for all configurations
            home-manager.nixosModules.default
            {
              home-manager = {
                extraSpecialArgs = { inherit system inputs; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.zoe.imports =
                  [
                    sops-nix.homeManagerModules.sops
                    ./modules/home/${machine}/home.nix
                  ]
                  ++ (
                    if config.channel == nixpkgs || config.channel == nixpkgs-stable then
                      [
                        catppuccin.homeModules.catppuccin
                        plasma-manager.homeManagerModules.plasma-manager
                      ]
                    else
                      [ ]
                  );
              };
            }
          ];
        };

    in
    with nixpkgs.lib;
    {
      nixosConfigurations = mapAttrs makeNixosSystem machineConfigs;

      checks."${system}" = {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            check-yaml.enable = true;
            check-json.enable = true;
            check-toml.enable = true;
            check-merge-conflicts.enable = true;
            check-added-large-files.enable = true;
            end-of-file-fixer.enable = true;
          };
        };
      };

      templates = {
        full = {
          path = ./.;
          description = "My system";
        };
      } // import ./modules/templates;

      devShells."${system}".default = import ./shell.nix {
        pkgs = channelPkgs.nixpkgs;
        pre-commit-hooks = inputs.pre-commit-hooks;
        inherit system;
      };
    };
}
