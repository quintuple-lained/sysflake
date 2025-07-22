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

        # Choose your Rust version - you can switch between these:
        # rust-bin' = pkgs.rust-bin.stable.latest.default.override {
        #   extensions = [ "rust-src" "rustfmt" "clippy" ];
        # };

        rust-bin' = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rustfmt"
            "clippy"
            "rust-analyzer"
          ];
        };

        # rust-bin' = pkgs.rust-bin.selectLatestNightlyWith (
        # toolchain:
        # toolchain.default.override {
        # extensions = [
        # "rust-src"
        # "rustfmt"
        # "clippy"
        # "rust-analyzer"
        # ];
        # }
        # );

        naersk' = pkgs.callPackage naersk {
          cargo = rust-bin';
          rustc = rust-bin';
        };

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Rust-specific hooks
            rustfmt.enable = true;
            clippy = {
              enable = true;
              description = "Lint Rust code.";
              entry = "${rust-bin'}/bin/cargo-clippy clippy";
              language = "system";
              files = "\\.rs$";
              pass_filenames = false;
            };

            # Generic hooks
            check-yaml.enable = true;
            check-json.enable = true;
            check-toml.enable = true;
            check-merge-conflicts.enable = true;
            check-added-large-files = {
              enable = true;
              args = [ "--maxkb=5120" ];
            };
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
        # Build package with naersk
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
              # Rust toolchain
              rust-bin'

              # Development tools
              bacon # background rust code checker
              cargo-watch # watch for changes and run commands
              cargo-edit # cargo add, cargo rm, cargo upgrade
              cargo-outdated # check for outdated dependencies
              cargo-audit # security audit
              cargo-deny # linting for Cargo.toml
              cargo-expand # show macro expansions
              cargo-bloat # find what takes space in executable

              # System dependencies (add as needed)
              pkg-config
              openssl

              # Optional: database tools if you're using them
              # sqlite
              # postgresql

              # Git and pre-commit
              git
              pre-commit
            ]
            ++ pre-commit-check.enabledPackages;

          # Environment variables
          RUST_SRC_PATH = "${rust-bin'}/lib/rustlib/src/rust/library";
          RUST_LOG = "debug";
          RUST_BACKTRACE = "1";

          # Welcome message and setup
          shellHook =
            pre-commit-check.shellHook
            + ''
              echo "🦀 Rust development environment loaded!"
              echo "📋 Available tools:"
              echo "   • cargo ($(cargo --version))"
              echo "   • rustc ($(rustc --version))"
              echo "   • clippy, rustfmt, rust-analyzer"
              echo "   • bacon, cargo-watch, cargo-edit, cargo-audit"
              echo ""
              echo "🪝 Pre-commit hooks are installed and will run on commit"
              echo "   Run 'pre-commit run --all-files' to check all files manually"
              echo ""

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
