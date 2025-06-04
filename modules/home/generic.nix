{
  pkgs,
  inputs,
  system,
  ...
}:
{
  imports = [
    ./fish
    ./neovim
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  services = {
    lorri.enable = true;
    gpg-agent = {
      enable = true;
      pinentryPackage =pkgs.pinentry-gtk2;
    };
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    gpg.enable = true;
    nix-index.enable = true;
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages = 
    let
      development = with pkgs; [
        nixfmt-rfc-style
        direnv
        fd
        tree
        git
        ripgrep
      ];

      fonts = with pkgs; [
        source-code-pro
        source-sans-pro
      ];

      misc-packages = with pkgs; [
        bottom
        hyfetch
        fastfetch
        nix-index
        nix-search-cli
        openvpn
        wireguard-tools
      ];
}