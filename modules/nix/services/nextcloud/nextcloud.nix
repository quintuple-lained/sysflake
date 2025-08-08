{ config
, lib
, pkgs
, ...
}:

{
  systemd.tmpfiles.rules = [
    "f /main_pool/storage/nextcloud/config/CAN_INSTALL 0644 nextcloud nextcloud"
  ];

  sops.secrets = {
    nextcloud_admin_password = {
      sopsFile = ../../../../secrets/devices/copyright-respecter.yaml;
      key = "nextcloud.admin_password";
      owner = "nextcloud";
      group = "nextcloud";
      mode = "0600";
    };
    nextcloud_db_password = {
      sopsFile = ../../../../secrets/devices/copyright-respecter.yaml;
      key = "postgres.nextcloud_password";
      owner = "nextcloud";
      group = "nextcloud";
      mode = "0600";
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = "192.168.178.109";
    home = "/main_pool/storage/nextcloud";

    database.createLocally = false;

    config = {
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbhost = "localhost:5432";
      dbuser = "nextcloud_user";
      dbpassFile = config.sops.secrets.nextcloud_db_password.path;

      adminuser = "admin";
      adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
    };

    configureRedis = true;
    maxUploadSize = "16G";

    settings = {
      # Performance optimizations for PostgreSQL
      "memcache.local" = "\\OC\\Memcache\\APCu";
      "memcache.distributed" = "\\OC\\Memcache\\Redis";
      "memcache.locking" = "\\OC\\Memcache\\Redis";

      # Database optimizations
      "dbdriveroptions" = {
        "1002" = "SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))";
      };

      # File handling
      "filesystem_check_changes" = 1;
      "filelocking.enabled" = true;

      # Security
      "htaccess.RewriteBase" = "/";
      "overwrite.cli.url" = "http://192.168.178.109";

      # Performance
      "maintenance_window_start" = 3;
      "jpeg_quality" = 80;
      "preview_max_x" = 2048;
      "preview_max_y" = 2048;
      "enabledPreviewProviders" = [
        "OC\\Preview\\PNG"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\GIF"
        "OC\\Preview\\BMP"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\MP3"
        "OC\\Preview\\TXT"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\PDF"
      ];
    };

    phpOptions = {
      "opcache.enable" = "1";
      "opcache.enable_cli" = "1";
      "opcache.memory_consumption" = "512";
      "opcache.interned_strings_buffer" = "64";
      "opcache.max_accelerated_files" = "32531";
      "opcache.validate_timestamps" = "0";
      "opcache.save_comments" = "1";
      "opcache.fast_shutdown" = "1";

      # Memory and execution limits
      "upload_max_filesize" = "16G";
      "post_max_size" = "16G";
      "max_execution_time" = "3600";
      "max_input_time" = "3600";
    };
  };

  # Ensure PostgreSQL is running before Nextcloud starts
  systemd.services.nextcloud-setup = {
    after = [
      "postgresql.service"
      "postgres-setup-passwords.service"
    ];
    requires = [
      "postgresql.service"
      "postgres-setup-passwords.service"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
