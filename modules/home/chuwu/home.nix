{
  pkgs,
  ...
}:
{
  imports = [
    ../neovim
    ../fish
    ../kitty
    ../plasma
  ];

  programs.home-manager.enable = true;
  system.stateVersion = "25.05";

  home.username = "zoe";
  home.homeDirectory = "/home/zoe";

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  services = {
    lorri.enable = true;
    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gtk2;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gpg.enable = true;

  programs.nix-index.enable = true;

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
        usbutils
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
        tree
        wireguard-tools
        yt-dlp
      ];

      graphical = with pkgs; []
      
}