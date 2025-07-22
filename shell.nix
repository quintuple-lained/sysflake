{ pkgs
, pre-commit-hooks
, system
,
}:
let
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      # Nix-specific hooks
      nixpkgs-fmt.enable = true;
      # Optional: Custom nil hook (remove if conflicts with built-in)
      # nil = {
      #   enable = true;
      #   description = "Nix language server linter";
      #   entry = "${pkgs.nil}/bin/nil diagnostics";
      #   language = "system";
      #   files = "\\.nix$";
      #   pass_filenames = false;
      # };

      # Generic hooks
      check-yaml.enable = true;
      check-json.enable = true;
      check-toml.enable = true;
      check-merge-conflicts.enable = true;
      check-added-large-files.enable = true;
      end-of-file-fixer.enable = true;

      # deadnix = {
      #   enable = true;
      #   name = "deadnix";
      #   description = "Remove dead Nix code";
      #   entry = "${pkgs.deadnix}/bin/deadnix --edit";
      #   language = "system";
      #   files = "\\.nix$";
      # };

      # statix = {
      #   enable = true;
      #   name = "statix";
      #   description = "Lints and suggestions for Nix";
      #   entry = "${pkgs.statix}/bin/statix check";
      #   language = "system";
      #   files = "\\.nix$";
      #   pass_filenames = false;
      # };
    };
  };

in
pkgs.mkShell {
  buildInputs =
    with pkgs;
    [
      # Nix development tools
      nixpkgs-fmt
      nil # nix language server
      deadnix # remove dead nix code
      statix # nix linter
      nix-tree # explore nix store dependencies
      nix-du # disk usage analyzer for nix store

      # System administration tools
      git
      just # command runner (if you use justfiles)

      # Optional: if you manage secrets
      sops
      age

      # Development utilities
      direnv

    ]
    ++ pre-commit-check.enabledPackages;

  # Environment setup
  shellHook =
    pre-commit-check.shellHook
    + ''
      alias fmt="nixpkgs-fmt ."
      alias check="nix flake check"
      alias fix="nixpkgs-fmt . && nix flake check"

      # Automatically install pre-commit hooks if git repo exists
      if [ -d .git ] && [ ! -f .git/hooks/pre-commit ]; then
        ${pkgs.pre-commit}/bin/pre-commit install
      fi

      echo "setup done"
    '';
}
