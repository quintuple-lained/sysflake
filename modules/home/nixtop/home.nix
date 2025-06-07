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

      graphical = with pkgs; [];

      game-stuff = with pkgs; [
        libgdiplus
        (steam.override {
          extraPkgs =
            pkgs: with pkgs; [
              gtk3
              zlib
              dbus
              freetype
              glib
              atk
              cairo
              gdk-pixbuf
              pango
              python3
              fontconfig
              xorg.libxcb
              libpng
            ];
        })
        steam-run
        steam-run-native
      ];
    in
  development ++ fonts ++ misc-packages ++ graphical ++ game-stuff;
}