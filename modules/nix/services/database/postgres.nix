{ config
, lib
, pkgs
, ...
}:

{
  # Add sops secrets for database credentials
  sops = {
    age.keyFile = "/home/zoe/.config/sops/age/keys.txt";
    secrets = {
      postgres_superuser_password = {
        sopsFile = ../../../../secrets/devices/copyright-respecter.yaml;
        key = "postgres.superuser_password";
        owner = "postgres";
        group = "postgres";
        mode = "0600";
      };
      postgres_nextcloud_password = {
        sopsFile = ../../../../secrets/devices/copyright-respecter.yaml;
        key = "postgres.nextcloud_password";
        owner = "postgres";
        group = "postgres";
        mode = "0600";
      };
    };
  };

  # Create database directories on ZFS pool
  systemd.tmpfiles.rules = [
    "d /main_pool/storage/databases 0755 postgres postgres"
    "d /main_pool/storage/databases/postgresql 0700 postgres postgres"
    "d /main_pool/storage/databases/backups 0755 postgres postgres"
    "d /main_pool/storage/databases/logs 0755 postgres postgres"
  ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;

    # Use ZFS pool for database storage
    dataDir = "/main_pool/storage/databases/postgresql";

    # Listen on all interfaces
    settings = {
      listen_addresses = "*";
      port = 5432;
      max_connections = 150;

      # Memory settings: 16GB total PostgreSQL allocation
      shared_buffers = "4GB"; # Main database cache
      effective_cache_size = "32GB"; # Tell PG about ZFS ARC + OS cache
      work_mem = "16MB"; # 150 connections * 16MB = ~2.4GB max
      maintenance_work_mem = "1GB"; # Large maintenance operations

      # WAL settings for better write performance
      wal_buffers = "64MB"; # Still buffer writes well
      min_wal_size = "2GB";
      max_wal_size = "8GB";
      checkpoint_completion_target = 0.9;

      # HDD-optimized settings
      random_page_cost = 4.0;
      seq_page_cost = 1.0;
      effective_io_concurrency = 2;

      # Additional performance settings
      temp_buffers = "32MB";
      max_files_per_process = 4000;

      # Query planner settings
      default_statistics_target = 500;
      constraint_exclusion = "partition";

      # Checkpointing for HDD optimization
      checkpoint_timeout = "15min";
      checkpoint_warning = "30s";

      # Background writer settings for HDD
      bgwriter_delay = "200ms";
      bgwriter_lru_maxpages = 100;
      bgwriter_lru_multiplier = 2.0;

      # Autovacuum tuning
      autovacuum_max_workers = 4;
      autovacuum_naptime = "30s";
      autovacuum_vacuum_scale_factor = 0.1;
      autovacuum_analyze_scale_factor = 0.05;

      # Logging
      log_destination = "stderr";
      logging_collector = true;
      log_directory = "/main_pool/storage/databases/logs";
      log_filename = "postgresql-%Y-%m-%d_%H%M%S.log";
      log_statement = "all";
      log_min_duration_statement = 1000; # Log slow queries (>1s)
      log_rotation_age = "1d";
      log_rotation_size = "100MB";
      log_truncate_on_rotation = false;

      log_line_prefix = "%t [%p-%l] %q%u@%d";
      log_checkpoints = true;
      log_connections = true;
      log_disconnections = true;
      log_lock_waits = true;
      log_temp_files = 10240;

      # Connection and authentication
      ssl = false; # Enable if you need SSL
      password_encryption = "scram-sha-256";
    };

    # Authentication configuration
    authentication = ''
      # Local connections
      local   all             postgres                                peer
      local   all             all                                     md5

      # Network connections
      host    all             all             192.168.178.0/24        scram-sha-256
      host    all             all             127.0.0.1/32            scram-sha-256
      host    all             all             ::1/128                 scram-sha-256
    '';

    # Database initialization - minimal setup for current needs
    initialScript = pkgs.writeText "postgres-init.sql" ''
      -- Create user for Nextcloud (current need)
      CREATE USER nextcloud_user WITH PASSWORD 'PLACEHOLDER_NEXTCLOUD_PASSWORD';

      -- Create Nextcloud database
      CREATE DATABASE nextcloud OWNER nextcloud_user;

      -- Grant all privileges to nextcloud user
      GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud_user;

      -- Set up proper permissions for nextcloud database
      \c nextcloud;
      GRANT ALL ON SCHEMA public TO nextcloud_user;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO nextcloud_user;
      GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO nextcloud_user;

      -- Create extensions for nextcloud
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For better text search
    '';

    # Enable automatic backups
    enableTCPIP = true;
  };

  # Service to set up passwords after initialization
  systemd.services.postgres-setup-passwords = {
    description = "Set up PostgreSQL passwords from secrets";
    after = [
      "postgresql.service"
      "sops-nix.service"
    ];
    wants = [ "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
      Group = "postgres";
    };

    script = ''
      # Wait for PostgreSQL to be ready
      while ! ${pkgs.postgresql_17}/bin/pg_isready -h localhost -p 5432; do
        echo "Waiting for PostgreSQL to be ready..."
        sleep 2
      done

      # Set superuser password
      if [ -f "${config.sops.secrets.postgres_superuser_password.path}" ]; then
        SUPERUSER_PASSWORD=$(cat "${config.sops.secrets.postgres_superuser_password.path}")
        ${pkgs.postgresql_17}/bin/psql -c "ALTER USER postgres PASSWORD '$SUPERUSER_PASSWORD';"
      fi

      # Set nextcloud user password
      if [ -f "${config.sops.secrets.postgres_nextcloud_password.path}" ]; then
        NEXTCLOUD_PASSWORD=$(cat "${config.sops.secrets.postgres_nextcloud_password.path}")
        ${pkgs.postgresql_17}/bin/psql -c "ALTER USER nextcloud_user PASSWORD '$NEXTCLOUD_PASSWORD';"
      fi

      echo "PostgreSQL password setup complete"
    '';
  };

  # Automated backup service
  systemd.services.postgres-backup = {
    description = "PostgreSQL backup";
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
    };

    script =
      let
        backupScript = pkgs.writeShellScript "postgres-backup" ''
          set -euo pipefail

          BACKUP_DIR="/main_pool/storage/databases/backups"
          DATE=$(${pkgs.coreutils}/bin/date +%Y%m%d_%H%M%S)

          # Create backup directory if it doesn't exist
          mkdir -p "$BACKUP_DIR"

          # Backup all databases
          echo "Starting PostgreSQL backup..."
          ${pkgs.postgresql_17}/bin/pg_dumpall > "$BACKUP_DIR/postgres_full_$DATE.sql"

          # Compress the backup
          ${pkgs.gzip}/bin/gzip "$BACKUP_DIR/postgres_full_$DATE.sql"

          # Keep only last 7 days of backups
          ${pkgs.findutils}/bin/find "$BACKUP_DIR" -name "postgres_full_*.sql.gz" -mtime +7 -delete

          echo "Backup completed: postgres_full_$DATE.sql.gz"
        '';
      in
      "${backupScript}";
  };

  # Daily backup timer
  systemd.timers.postgres-backup = {
    description = "Daily PostgreSQL backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "02:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  # Health monitoring service
  systemd.services.postgres-health = {
    description = "PostgreSQL health check";
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = pkgs.writeShellScript "postgres-health" ''
        # Check if PostgreSQL is running
        if ! ${pkgs.postgresql_17}/bin/pg_isready -h localhost -p 5432; then
          echo "PostgreSQL is not ready"
          exit 1
        fi

        # Check if we can connect to nextcloud database
        if ${pkgs.postgresql_17}/bin/psql -d nextcloud -U nextcloud_user -c "SELECT 1;" >/dev/null 2>&1; then
          echo "✓ Nextcloud database accessible"
        else
          echo "✗ Nextcloud database not accessible"
        fi

        # Show database sizes
        echo ""
        echo "Database sizes:"
        ${pkgs.postgresql_17}/bin/psql -c "
          SELECT 
            datname as database_name,
            pg_size_pretty(pg_database_size(datname)) as size
          FROM pg_database 
          WHERE datistemplate = false
          ORDER BY pg_database_size(datname) DESC;
        "
      '';
    };
  };

  # Open firewall for PostgreSQL
  networking.firewall.allowedTCPPorts = [ 5432 ];

  # Convenience scripts
  environment.systemPackages = [
    # PostgreSQL client tools
    pkgs.postgresql_17

    # Backup restore script
    (pkgs.writeShellScriptBin "postgres-restore" ''
      if [ $# -ne 1 ]; then
        echo "Usage: postgres-restore <backup-file.sql.gz>"
        echo ""
        echo "Available backups:"
        ls -la /main_pool/storage/databases/backups/postgres_full_*.sql.gz 2>/dev/null || echo "No backups found"
        exit 1
      fi

      BACKUP_FILE="$1"

      if [ ! -f "$BACKUP_FILE" ]; then
        echo "Error: Backup file '$BACKUP_FILE' not found"
        exit 1
      fi

      echo "WARNING: This will overwrite all databases!"
      echo "Press Ctrl+C to cancel, or Enter to continue..."
      read

      echo "Stopping services that use the database..."
      sudo systemctl stop nextcloud-setup.service

      echo "Restoring from $BACKUP_FILE..."
      ${pkgs.gzip}/bin/zcat "$BACKUP_FILE" | sudo -u postgres ${pkgs.postgresql_17}/bin/psql

      echo "Starting services..."
      sudo systemctl start nextcloud-setup.service

      echo "Restore complete!"
    '')

    # Database connection script
    (pkgs.writeShellScriptBin "postgres-connect" ''
      if [ $# -eq 0 ]; then
        echo "Usage: postgres-connect <database-name>"
        echo ""
        echo "Available databases:"
        sudo -u postgres ${pkgs.postgresql_17}/bin/psql -l
        exit 1
      fi

      DATABASE="$1"
      echo "Connecting to database: $DATABASE"
      sudo -u postgres ${pkgs.postgresql_17}/bin/psql -d "$DATABASE"
    '')

    # Quick status script
    (pkgs.writeShellScriptBin "postgres-status" ''
      echo "=== PostgreSQL Status ==="
      echo ""

      # Service status
      systemctl status postgresql.service --no-pager -l

      echo ""
      echo "=== Database List ==="
      sudo -u postgres ${pkgs.postgresql_17}/bin/psql -l

      echo ""
      echo "=== Database Users ==="
      sudo -u postgres ${pkgs.postgresql_17}/bin/psql -c "
        SELECT 
          usename as username,
          usesuper as is_superuser,
          usecreatedb as can_create_db,
          usebypassrls as can_bypass_rls
        FROM pg_user 
        ORDER BY usename;
      "

      echo ""
      echo "=== Recent Backups ==="
      ls -la /main_pool/storage/databases/backups/ | tail -5
    '')

    # Connection string generator
    (pkgs.writeShellScriptBin "postgres-connection-info" ''
      echo "=== PostgreSQL Connection Information ==="
      echo ""
      echo "Server: 192.168.178.109:5432"
      echo ""
      echo "Connection information for current services:"
      echo ""
      echo "Nextcloud:"
      echo "  Database: nextcloud"
      echo "  User: nextcloud_user"
      echo "  Connection: postgresql://nextcloud_user:PASSWORD@192.168.178.109:5432/nextcloud"
      echo ""
      echo "Other services (Jellyfin, Sonarr, Radarr, Prowlarr, Slskd) currently use SQLite."
      echo "Use 'postgres-add-user' to migrate them to PostgreSQL if needed in the future."
      echo ""
      echo "To get passwords, use: sops -d secrets/devices/copyright-respecter.yaml | grep postgres"
    '')

    # Add new database user script
    (pkgs.writeShellScriptBin "postgres-add-user" ''
      if [ $# -ne 2 ]; then
        echo "Usage: postgres-add-user <username> <database_name>"
        echo ""
        echo "This will create a new user and database for a service"
        exit 1
      fi

      USERNAME="$1"
      DATABASE="$2"

      echo "Creating user '$USERNAME' and database '$DATABASE'..."
      echo "You'll be prompted for a password for the new user."
      echo ""

      sudo -u postgres ${pkgs.postgresql_17}/bin/createuser --pwprompt "$USERNAME"
      sudo -u postgres ${pkgs.postgresql_17}/bin/createdb --owner="$USERNAME" "$DATABASE"

      # Grant permissions
      sudo -u postgres ${pkgs.postgresql_17}/bin/psql -d "$DATABASE" -c "
        GRANT ALL ON SCHEMA public TO $USERNAME;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $USERNAME;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $USERNAME;
      "

      echo ""
      echo "User and database created successfully!"
      echo "Connection string: postgresql://$USERNAME:PASSWORD@192.168.178.109:5432/$DATABASE"
      echo ""
      echo "Don't forget to add the password to your sops secrets!"
    '')
  ];
}
