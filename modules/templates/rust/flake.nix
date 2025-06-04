{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    naersk.url = "github:nix-community/naersk";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, naersk, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
        overlays = [ (import rust-overlay) ];

        rust-bin' = pkgs.rust-bin.selectLatestNightlyWith (toolchain:
          toolchain.default.override { extensions = [ "rustfmt" "clippy" ]; });

        naersk' = pkgs.callPackage naersk {
          cargo = rust-bin';
          rustc = rust-bin';
        };
      in rec {
        packages.default = naersk'.buildPackage { src = ./.; };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ rust-bin' rust-analyzer ];

          RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
        };
      });
}
