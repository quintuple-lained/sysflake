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
    ../develop
    ../emacs
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
        imhex
        google-chrome
        nmap
        # qt web engine
        #nmapsi4
        zenmap
        rustscan
        inetutils
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
        opentrack
      ];

    in
    development ++ fonts ++ misc-packages ++ graphical;
}
