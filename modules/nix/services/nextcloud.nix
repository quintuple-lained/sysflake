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

  # Create necessary directories and CAN_INSTALL file
  systemd.tmpfiles.rules = [
    "d /main_pool/appdata/nextcloud 0750 nextcloud nextcloud"
    "f /main_pool/appdata/nextcloud/CAN_INSTALL 0644 nextcloud nextcloud"
  ];

  services = {
    # PostgreSQL database
    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

    # Nextcloud
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud29;
      hostName = "192.168.178.109";

      # Use ZFS pool for data
      home = "/main_pool/appdata/nextcloud";

      # Database config
      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        adminuser = "admin";
        adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
      };

      # Basic settings
      settings = {
        default_phone_region = "DE";
        trusted_domains = [
          "192.168.178.109"
          "localhost"
        ];
      };
    };
  };

  # Open firewall for Nextcloud
  networking.firewall.allowedTCPPorts = [ 80 ];
}
