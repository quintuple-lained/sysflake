{
  pkgs,
  ...
}:
{
  imports = [
    ../generic.nix
    ../desktop
    ../plasma
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  home.username = "zoe";
  home.homeDirectory = "/home/zoe";
  networkmanager.enable = true;

  home.packages = 
    let
      development = with pkgs; [
      ];

      fonts = with pkgs; [
      ];

      misc-packages = with pkgs; [
        yt-dlp
        networkmanager
      ];

      graphical = with pkgs; [];
    in
  development ++ fonts ++ misc-packages ++ graphical;
}