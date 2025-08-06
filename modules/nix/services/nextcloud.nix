{ config
, lib
, pkgs
, ...
}:

{
  # Add secrets for Nextcloud
  sops.secrets = {
    nextcloud_admin_password = {
      sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
      key = "nextcloud.admin_password";
      owner = "nextcloud";
      group = "nextcloud";
      mode = "0600";
    };
  };

  services = {

    # Nextcloud
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = "192.168.178.109";

      # Use ZFS pool for data
      home = "/main_pool/storage/nextcloud";

      database = {
        createLocally = true;
      };
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
      };
      configureRedis = true;
      maxUploadSize = "16G";
    };
  };

  # Open firewall for Nextcloud
  networking.firewall.allowedTCPPorts = [ 80 ];
}
