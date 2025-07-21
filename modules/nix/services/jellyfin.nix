{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Jellyfin Configuration
  services.jellyfin = {
    enable = true;
    user = "jellyfin";
    group = "jellyfin";
    dataDir = "/main_pool/storage/jellyfin";
    configDir = "/main_pool/storage/jellyfin/config";
    cacheDir = "/main_pool/storage/jellyfin/cache";
    logDir = "/main_pool/storage/jellyfin/log";
  };

  # Backup service for Jellyfin
  systemd.services.backup-jellyfin = {
    description = "Backup Jellyfin configuration";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "backup-jellyfin" ''
        BACKUP_DIR="/main_pool/storage/backups/jellyfin/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"

        # Backup Jellyfin config
        tar -czf "$BACKUP_DIR/jellyfin-config.tar.gz" -C /main_pool/storage/jellyfin config || true

        # Keep only last 7 days of backups
        find /main_pool/storage/backups/jellyfin -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \; 2>/dev/null || true
      '';
    };
  };

  systemd.timers.backup-jellyfin = {
    description = "Daily backup of Jellyfin";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Create necessary directories for Jellyfin
  systemd.tmpfiles.rules = [
    "d /main_pool/storage/jellyfin 0755 jellyfin jellyfin"
    "d /main_pool/storage/backups/jellyfin 0755 root root"
    "d /main_pool/storage/media 0755 zoe users"
    "d /main_pool/storage/media/movies 0755 zoe users"
    "d /main_pool/storage/media/tv 0755 zoe users"
    "d /main_pool/storage/media/music 0755 zoe users"
  ];

  # Health check for Jellyfin
  systemd.services.jellyfin-healthcheck = {
    description = "Check Jellyfin is running";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "jellyfin-healthcheck" ''
        echo "Checking Jellyfin health..."
        ${pkgs.curl}/bin/curl -f http://localhost:8096 >/dev/null 2>&1 || echo "Jellyfin not responding"
        echo "Jellyfin health check completed"
      '';
    };
  };

  systemd.timers.jellyfin-healthcheck = {
    description = "Hourly Jellyfin health check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  # Firewall ports for Jellyfin
  networking.firewall = {
    allowedUDPPorts = [
      1900 # Jellyfin DLNA
      7359 # Jellyfin auto-discovery
    ];
  };

  # Media packages
  environment.systemPackages = with pkgs; [
    ffmpeg
    mediainfo
  ];
}
