{
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [
    ./hardware-config.nix
    #../../srv/ssh/ssh-server.nix
    #../../srv/services/vpn-server.nix
    #../../srv/services/jellyfin.nix
    #../../srv/services/nextcloud.nix
    #../../srv/services/torrent.nix
    #../../srv/services/pihole.nix
  ];

  networking = rec {
    hostName = "copyright-respecter";
    hostId = builtins.substring 0 8 (builtins.hashString "sha256" hostName);
    networkmanager.enable = true;
  };

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 7;
      memtest86.enable = true;
    };
    supportedFilesystems = [
      "zfs"
      "xfs"
    ];
    zfs.forceImportRoot = false;
  };

}
