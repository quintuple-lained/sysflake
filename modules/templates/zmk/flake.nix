{
  description = "a flake for the zmk toolchain";

  inputs = {
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, unstable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import unstable { inherit system; };
        zmk-python = pkgs.python3.withPackages (p:
          with p; [
            setuptools
            pip
            west

            pyelftools
            pyyaml
            pykwalify
            canopen
            packaging
            progress
            psutil
            anytree
            intelhex
          ]);
        gnuarmemb = pkgs.pkgsCross.arm-embedded.buildPackages.gcc;
      in
      rec {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            autoconf
            automake
            bzip2
            cmake
            dfu-util
            dtc
            gcc
            git
            libtool
            ninja
            wget
            xz
            zmk-python

            bashInteractive
          ];

          ZEPHYR_TOOLCHAIN_VARIANT = "gnuarmemb";
          GNUARMEMB_TOOLCHAIN_PATH = pkgs.gcc-arm-embedded;
        };
      });
}
