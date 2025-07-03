{
  description = "hugo dev flake with pre-commit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            prettier = {
              enable = true;
              description = "Format web files";
              types_or = [
                "javascript"
                "jsx"
                "ts"
                "tsx"
                "css"
                "scss"
                "html"
                "json"
                "yaml"
                "markdown"
              ];
            };

            # generic hooks
            check-yaml.enable = true;
            check-json.enable = true;
            check-toml.enable = true;
            check-merge-conflicts.enable = true;
            check-added-large-files.enable = true;
            end-of-file-fixer.enable = true;

            # hugo build
            hugo-build = {
              enable = true;
              name = "hugo build check";
              entry = "${pkgs.hugo}/bin/hugo --minify --buildDrafts";
              language = "system";
              pass_filenames = false;
              files = "\\.(md|html|toml|yaml|yml|js|css|scss)$";
            };

            # html validation
            htmlhint = {
              enable = true;
              name = "htmlhint";
              entry = "${pkgs.nodePackages.htmlhint}/bin/htmlhint";
              language = "system";
              files = "\\.html$";
            };

            # markdown linting
            markdownlint = {
              enable = true;
              name = "markdownlint";
              entry = "${pkgs.nodePackages.markdownlint-cli}/bin/markdownlint";
              language = "system";
              files = "\\.md$";
            };
          };
        };
      in
      rec {
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              hugo
              nodejs
              nodePackages.npm
              nodePackages.yarn
              nodePackages.prettier
              nodePackages.eslint
              nodePackages.htmlhint
              nodePackages.markdownlint-cli
              nodePackages.stylelint
              imagemagick
              optipng
              jpegoptim
              dart-sass
              python3
              git
              pre-commit
            ]
            ++ pre-commit-check.enabledPackages;

          HUGO_ENVIRONMENT = "development";
          HUGO_ENABLEGITINFO = "true";

          shellHook = pre-commit-check.shellHook;
        };

        checks = {
          pre-commit-check = pre-commit-check;
        };

        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
