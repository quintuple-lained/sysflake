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
    ../nixvim/dev.nix
  ];

  services.mpd = {
    enable = true;
    musicDirectory = "~/Music";
    extraContig = ''
      audio_output {
        type "pulse"
        name "pulse audio"
        }
    '';
  };

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
        ncmpcpp
      ];

      graphical = with pkgs; [ ];

    in
    development ++ fonts ++ misc-packages ++ graphical;
}
