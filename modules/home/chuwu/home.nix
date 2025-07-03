{
  pkgs,
  ...
}:
{
  imports = [
    ../generic.nix
    ../desktop
    ../plasma
    ../firefox
<<<<<<< HEAD
    ../gaming
=======
    ../nixvim/dev.nix
>>>>>>> 784774fa5223139db13e1d0fb15cc26377641156
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
      ];

      graphical = with pkgs; [ ];
    in
    development ++ fonts ++ misc-packages ++ graphical;
}
