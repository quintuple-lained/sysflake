{ pkgs
, ...
}:
{
  imports = [
    ../generic.nix
    ../desktop
    ../plasma
    ../firefox
    ../gaming
    ../nixvim/dev.nix
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  home.username = "zoe";
  home.homeDirectory = "/home/zoe";

  home.packages =
    let
      development = with pkgs; [
      ];

      fonts = with pkgs; [
      ];

      misc-packages = with pkgs; [
        yt-dlp
        networkmanager
        kicad
      ];

      graphical = with pkgs; [ ];

      security = with pkgs; [
        sbctl
      ];
    in
    development ++ fonts ++ misc-packages ++ graphical ++ security;
}
