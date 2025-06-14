{
  pkgs,
  ...
}:
{
  imports = [
    ../generic.nix
    ../desktop
    ../plasma
    ../gaming
    ../firefox
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  home.username = "zoe";
  home.homeDirectory = "/home/zoe";

  home.packages =
    let
      development = with pkgs; [
        rustc
        cargo
        gcc
        pkg-config

      ];

      fonts = with pkgs; [
      ];

      misc-packages = with pkgs; [
        yt-dlp
        networkmanager
      ];

      graphical = with pkgs; [ ];

    in
    development ++ fonts ++ misc-packages ++ graphical;
}
