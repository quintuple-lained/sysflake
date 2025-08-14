{ pkgs
, ...
}:

{
  home.packages =
    let
      envrc = pkgs.writeShellScriptBin "envrc" ''
        echo "use flake" > .envrc
        echo ".direnv" >> .gitignore
        echo ".pre-commit-config.yaml" >> .gitignore
        direnv allow
      '';

      dev-packages = with pkgs; [
        envrc
      ];
    in
    dev-packages;
}
