{ pkgs
, ...
}:
{
  imports = [
    ../generic.nix
    ../desktop
    ../plasma
    ../gaming
    ../firefox
    ../nixvim/dev.nix
    ../music
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  home.username = "zoe";
  home.homeDirectory = "/home/zoe";

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  home.packages =
    let
      development = with pkgs; [
        kicad
        dub-to-nix
        dub
        gcc
        dmd
        harfbuzz
        libadwaita
        libimobiledevice
        virt-manager
        okteta
        qbittorrent
      ];

      fonts = with pkgs; [
      ];

      misc-packages = with pkgs; [
        yt-dlp
        networkmanager
      ];

      graphical = with pkgs; [
        blender
        presenterm
        obs-studio
        obsidian
        ryubing
      ];

    in
    development ++ fonts ++ misc-packages ++ graphical;
}
