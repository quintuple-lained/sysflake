{
  description = "Rust development environment with pre-commit hooks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    naersk.url = "github:nix-community/naersk";
    rust-overlay.url = "github:oxalica/rust-overlay";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , naersk
    , rust-overlay
    , pre-commit-hooks
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system;
          inherit overlays;
        };

        rust-bin' = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rustfmt"
            "clippy"
            "rust-analyzer"
          ];
        };

        naersk' = pkgs.callPackage naersk {
          cargo = rust-bin';
          rustc = rust-bin';
        };

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
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
            rustfmt.enable = true;
            clippy = {
              enable = true;
              description = "Lint Rust code.";
              entry = "${rust-bin'}/bin/cargo-clippy clippy";
              language = "system";
              files = "\\.rs$";
              pass_filenames = false;
            };

            check-yaml.enable = true;
            check-json.enable = true;
            check-toml.enable = true;
            check-merge-conflicts.enable = true;
            end-of-file-fixer.enable = true;

            # Custom hook for cargo check
            cargo-check = {
              enable = true;
              name = "cargo check";
              description = "Check the package for errors.";
              entry = "${rust-bin'}/bin/cargo check --all";
              language = "system";
              pass_filenames = false;
              files = "\\.rs$";
            };
          };
        };

      in
      rec {
        packages = pkgs.lib.optionalAttrs (builtins.pathExists ./Cargo.toml) {
          default = naersk'.buildPackage {
            src = ./.;
            buildInputs = with pkgs; [
              pkg-config
              openssl
            ];
          };
        };
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              rust-bin'

              bacon
              cargo-watch
              cargo-edit
              cargo-outdated
              cargo-audit
              cargo-deny
              cargo-expand
              cargo-bloat

              pkg-config
              openssl

              git
              pre-commit
            ]
            ++ pre-commit-check.enabledPackages;

          RUST_SRC_PATH = "${rust-bin'}/lib/rustlib/src/rust/library";
          RUST_LOG = "debug";
          RUST_BACKTRACE = "1";

          shellHook = pre-commit-check.shellHook + ''
            # Setup pre-commit hooks if not already done
            if [ ! -f .git/hooks/pre-commit ]; then
              echo "Setting up pre-commit hooks..."
              pre-commit install
            fi
          '';
        };

        # Expose the pre-commit check for CI
        checks = {
          pre-commit-check = pre-commit-check;
        };

        # Formatter for `nix fmt`
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
