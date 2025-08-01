{ config
, lib
, pkgs
, ...
}:

{
  # SOPS secrets for Nextcloud
  sops.secrets = {
    # Nextcloud Admin Password
    nextcloud_admin_password = {
      sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
      key = "nextcloud.admin_password";
      owner = "nextcloud";
      group = "nextcloud";
      mode = "0600";
    };

    # Nextcloud Database Password
    nextcloud_db_password = {
      sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
      key = "nextcloud.db_password";
      owner = "nextcloud";
      group = "nextcloud";
      mode = "0600";
    };
  };

  # Database Services
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
  };

  # Fix: Separate database setup service
  systemd.services.nextcloud-db-setup = {
    description = "Setup Nextcloud database";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    before = [ "nextcloud-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
      ExecStart = pkgs.writeShellScript "setup-nextcloud-db" ''
        # Wait for PostgreSQL to be ready
        until ${pkgs.postgresql}/bin/pg_isready; do
          sleep 1
        done

        # Check if database user exists, create if not
        if ! ${pkgs.postgresql}/bin/psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='nextcloud'" | grep -q 1; then
          ${pkgs.postgresql}/bin/psql -c "CREATE ROLE nextcloud WITH LOGIN;"
        fi

        # Set password from secret file
        ${pkgs.postgresql}/bin/psql -c "ALTER ROLE nextcloud WITH PASSWORD '$(cat ${config.sops.secrets.nextcloud_db_password.path})';"

        # Ensure database exists and grant privileges
        ${pkgs.postgresql}/bin/psql -c "CREATE DATABASE nextcloud OWNER nextcloud;" || true
        ${pkgs.postgresql}/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud;"
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.redis.servers."" = {
    enable = true;
    port = 6379;
  };

  # Nextcloud Configuration
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = "nextcloud.copyright-respecter.local";

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = config.sops.secrets.nextcloud_db_password.path;
      adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
      adminuser = "admin";
    };

    home = "/main_pool/storage/nextcloud";
    configureRedis = true;
    caching.redis = true;

    settings = {
      trusted_domains = [
        "nextcloud.copyright-respecter.local"
        "192.168.178.109"
        "localhost"
      ];
      trusted_proxies = [
        "127.0.0.1"
        "192.168.178.0/24"
      ];

      "memcache.local" = "\\OC\\Memcache\\APCu";
      "memcache.distributed" = "\\OC\\Memcache\\Redis";
      "memcache.locking" = "\\OC\\Memcache\\Redis";

      default_phone_region = "DE";

      enable_previews = true;
      enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
        "OC\\Preview\\Movie"
      ];
    };

    autoUpdateApps.enable = true;
    extraAppsEnable = true;
  };

  # Fix: Update the dependency and remove sudo usage
  systemd.services.create-media-symlinks = {
    description = "Create symlinks for media management";
    wantedBy = [ "multi-user.target" ];
    after = [
      "local-fs.target"
      "nextcloud-setup.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "create-symlinks" ''
        # Wait for Nextcloud to be ready
        sleep 30

        # Create symlinks in Nextcloud data for easy access
        mkdir -p /main_pool/storage/nextcloud/data/admin/files/Media
        mkdir -p /main_pool/storage/nextcloud/data/admin/files

        ln -sfn /main_pool/storage/media/movies /main_pool/storage/nextcloud/data/admin/files/Media/Movies
        ln -sfn /main_pool/storage/media/tv /main_pool/storage/nextcloud/data/admin/files/Media/TV
        ln -sfn /main_pool/storage/media/music /main_pool/storage/nextcloud/data/admin/files/Media/Music
        ln -sfn /main_pool/storage/torrent/complete /main_pool/storage/nextcloud/data/admin/files/Downloads

        # Set proper permissions
        chown -h nextcloud:nextcloud /main_pool/storage/nextcloud/data/admin/files/Media/* 2>/dev/null || true
        chown -h nextcloud:nextcloud /main_pool/storage/nextcloud/data/admin/files/Downloads 2>/dev/null || true

        # Trigger Nextcloud files scan using the occ wrapper
        ${config.services.nextcloud.occ}/bin/nextcloud-occ files:scan admin
      '';
    };
  };

  # Backup service for Nextcloud
  systemd.services.backup-nextcloud = {
    description = "Backup Nextcloud configurations and data";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "backup-nextcloud" ''
        BACKUP_DIR="/main_pool/storage/backups/nextcloud/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"

        # Backup Nextcloud config
        tar -czf "$BACKUP_DIR/nextcloud-config.tar.gz" -C /main_pool/storage/nextcloud config || true

        # Backup PostgreSQL database
        ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/pg_dump nextcloud > "$BACKUP_DIR/nextcloud-db.sql" || true

        # Keep only last 7 days of backups
        find /main_pool/storage/backups/nextcloud -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \; 2>/dev/null || true
      '';
    };
  };

  systemd.timers.backup-nextcloud = {
    description = "Daily backup of Nextcloud";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Create necessary directories for Nextcloud
  systemd.tmpfiles.rules = [
    "d /main_pool/storage/nextcloud 0755 nextcloud nextcloud"
    "d /main_pool/storage/backups 0755 root root"
    "d /main_pool/storage/backups/nextcloud 0755 root root"
    "d /var/lib/acme 0755 acme acme"
  ];

  # Health check for Nextcloud
  systemd.services.nextcloud-healthcheck = {
    description = "Check Nextcloud is running";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "nextcloud-healthcheck" ''
        echo "Checking Nextcloud health..."
        ${pkgs.curl}/bin/curl -f http://nextcloud.copyright-respecter.local >/dev/null 2>&1 || echo "Nextcloud not responding"
        echo "Nextcloud health check completed"
      '';
    };
  };

  systemd.timers.nextcloud-healthcheck = {
    description = "Hourly Nextcloud health check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
