{ config
, lib
, pkgs
, ...
}:

{
  systemd.tmpfiles.rules = [
    "d /main_pool/storage/media 0755 zoe users"
    "d /main_pool/storage/media/movies 0755 zoe users"
    "d /main_pool/storage/media/series 0755 zoe users"
    "d /main_pool/storage/media/music 0755 zoe users"
    "d /main_pool/storage/media/anime 0755 zoe users"

    "d /main_pool/appdata 0755 root root"
    "d /main_pool/appdata/sonarr 0750 sonarr users"
    "d /main_pool/appdata/radarr 0750 radarr users"
    "d /main_pool/appdata/prowlarr 0750 prowlarr users"
  ];

  services = {
    jellyfin = {
      enable = true;
      user = "zoe";
      group = "users";
    };
    sonarr = {
      enable = true;
      user = "sonarr";
      group = "users";
      dataDir = "/main_pool/appdata/sonarr";
    };
    radarr = {
      enable = true;
      user = "radarr";
      group = "users";
      dataDir = "/main_pool/appdata/radarr";
    };
    prowlarr = {
      enable = true;
      dataDir = "/main_pool/appdata/prowlarr";
    };
  };

  networking.firewall.allowedTCPPorts = [
    8989
    7878
    9696
  ];
}
