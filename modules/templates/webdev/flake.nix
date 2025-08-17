{
  description = "web dev flake with pre-commit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit-hooks
    ,
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

            conventional-commits = {
              enable = true;
              name = "conventional-commits";
              entry = "${pkgs.writeShellScript "conventional-commits-check" ''
                commit_regex='^\[(feat|fix|init|docs|style|refactor|perf|test|build|ci|chore|revert)\] .+'

                if ! grep -qE "$commit_regex" "$1"; then
                  echo "Invalid commit message format!"
                  echo "Format: [type] description" 
                  echo "Types: feat, fix, init, docs, style, refactor, perf, test, build, ci, chore, revert"
                  echo "Example: [feat] add user authentication"
                  exit 1
                fi
              ''}";
              language = "system";
              stages = [ "commit-msg" ];
            };

            # generic hooks
            check-yaml.enable = true;
            check-json.enable = true;
            check-toml.enable = true;
            check-merge-conflicts.enable = true;
            end-of-file-fixer.enable = true;

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
        apps = {
          serve = {
            type = "app";
            program = "${pkgs.writeShellScript "serve-static" ''
              PORT=''${1:-8080}
              echo "site on http://localhost:$PORT"
              ${pkgs.static-web-server}/bin/static-web-server \
                --port $PORT \
                --root . \
                --compression gzip \
                --cors-allow-origins "*" \
                --log-level info
            ''}";
          };
          dev = {
            type = "app";
            program = "${pkgs.writeShellScript "dev-server" ''
              port=''${1:-3000}
              echo "site live on http://localhost:$PORT"
              ${pkgs.nodePackages.browser-sync}/bin/browser-sync start \
                --server \
                --port $PORT \
                --files "*.html,*.css,*.js,assets/**/*" \
                --no-open \
                --no-notify
            ''}";
          };
        };
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              pandoc
              nodejs
              nodePackages.npm
              nodePackages.yarn
              nodePackages.prettier
              nodePackages.eslint
              nodePackages.htmlhint
              nodePackages.markdownlint-cli
              nodePackages.stylelint
              nodePackages.browser-sync
              static-web-server
              imagemagick
              optipng
              jpegoptim
              dart-sass
              python3
              git
              pre-commit
            ]
            ++ pre-commit-check.enabledPackages;

          shellHook = pre-commit-check.shellHook + ''
            echo ""
            echo ""
            echo "Dev serving:"
            echo "  nix run .#dev [port]    - Live reload server"
            echo "  nix run .#serve [port]  - prod like static server"
            echo ""
            echo ""
          '';
        };

        checks = {
          pre-commit-check = pre-commit-check;
        };

        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
