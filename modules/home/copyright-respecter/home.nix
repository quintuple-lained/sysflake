{ pkgs
, ...
}:
{
  imports = [
    ../generic.nix
    ../nixvim
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
        networkmanager
      ];

      graphical = with pkgs; [ ];
    in
    development ++ fonts ++ misc-packages ++ graphical;
}
