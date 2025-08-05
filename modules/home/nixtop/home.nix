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
        <<<<<<< HEAD
        blender
        presenterm
        obs-studio
        obsidian
        orca-slicer
        =======
        ryubing
        >>>>>>> 85808
        c59f0bd5cfc3363206c5489312e12a8d8d6
      ];

    in
    development ++ fonts ++ misc-packages ++ graphical;
}
