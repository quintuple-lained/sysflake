{
  pkgs,
  ...
}:
{
  imports = [
    ../generic.nix
    ../desktop
    ../kitty
    ../plasma
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
      ];

      graphical = with pkgs; [];
    in
  development ++ fonts ++ misc-packages ++ graphical
}