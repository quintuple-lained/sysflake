{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Expanded SOPS secrets for all services
  sops = {
    age.keyFile = "/home/zoe/.config/sops/age/keys.txt";
    secrets = {
      # VPN Configuration
      wireguard_config = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "copyright-respecter.config";
        owner = "root";
        group = "root";
        mode = "0600";
        path = "/var/lib/qbittorrent/wireguard/wg0.conf";
      };
      
      # qBittorrent Credentials
      qbittorrent_username = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "qbittorrent.username";
        owner = "root";
        group = "root";
        mode = "0644";
      };
      qbittorrent_password = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "qbittorrent.password";
        owner = "root";
        group = "root";
        mode = "0644";
      };
      
      # Nextcloud Admin Password
      nextcloud_admin_password = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "nextcloud.admin_password";
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0600";
        path = "/var/lib/nextcloud/admin-pass";
      };
      
      # Nextcloud Database Password
      nextcloud_db_password = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "nextcloud.db_password";
        owner = "postgres";
        group = "postgres";
        mode = "0600";
      };
      
      # ACME/Let's Encrypt email for SSL certificates
      acme_email = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "acme.email";
        owner = "acme";
        group = "acme";
        mode = "0600";
      };
    };
  };

  # NVIDIA GPU Support for GTX 660
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false; # GTX 660 requires proprietary driver
      nvidiaSettings = true;
      # Force specific driver version for GTX 660 compatibility
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    };
  };

  # Load NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable docker for qBittorrent container
  virtualisation.docker.enable = true;
  users.users.zoe.extraGroups = [ "docker" ];

  # Create necessary directories with proper structure
  systemd.tmpfiles.rules = [
    # qBittorrent directories
    "d /var/lib/qbittorrent 0755 root root"
    "d /var/lib/qbittorrent/config 0755 root root"
    "d /var/lib/qbittorrent/wireguard 0700 root root"
    
    # Storage structure on ZFS
    "d /main_pool/storage 0755 root root"
    "d /main_pool/storage/torrent 0755 zoe users"
    "d /main_pool/storage/torrent/incomplete 0755 zoe users"
    "d /main_pool/storage/torrent/complete 0755 zoe users"
    "d /main_pool/storage/media 0755 zoe users"
    "d /main_pool/storage/media/movies 0755 zoe users"
    "d /main_pool/storage/media/tv 0755 zoe users"
    "d /main_pool/storage/media/music 0755 zoe users"
    "d /main_pool/storage/nextcloud 0755 nextcloud nextcloud"
    "d /main_pool/storage/jellyfin 0755 jellyfin jellyfin"
    "d /main_pool/storage/backups 0755 root root"
    
    # ACME directory for Let's Encrypt certificates
    "d /var/lib/acme 0755 acme acme"
  ];

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
    # Set up database with password from secrets
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE nextcloud WITH LOGIN PASSWORD '$(cat ${config.sops.secrets.nextcloud_db_password.path})';
      CREATE DATABASE nextcloud;
      GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud;
    '';
  };

  services.redis.servers."" = {
    enable = true;
    port = 6379;
  };

  # Nextcloud Configuration
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
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
      trusted_proxies = [ "127.0.0.1" "192.168.178.0/24" ];
      
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
    extraApps = with config.services.nextcloud.package.packages; {
      inherit memories files_texteditor previewgenerator;
    };
  };

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

  # ACME (Let's Encrypt) Configuration for automatic SSL certificates
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = builtins.readFile config.sops.secrets.acme_email.path;
      # Use DNS challenge for internal domains or HTTP challenge for public domains
      # For internal domains, you might want to use a different method
      dnsProvider = "route53"; # Change this to your DNS provider or remove for HTTP challenge
      # For HTTP challenge (if your domains are publicly accessible):
      # webroot = "/var/lib/acme/acme-challenge";
    };
    # Create certificates for all our domains
    certs = {
      "copyright-respecter.local" = {
        domain = "copyright-respecter.local";
        extraDomainNames = [
          "nextcloud.copyright-respecter.local"
          "jellyfin.copyright-respecter.local"
          "torrent.copyright-respecter.local"
        ];
      };
    };
  };

  # Self-signed certificate fallback for local development
  systemd.services.generate-self-signed-certs = {
    description = "Generate self-signed certificates for local domains";
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "generate-certs" ''
        CERT_DIR="/var/lib/acme/copyright-respecter.local"
        mkdir -p "$CERT_DIR"
        
        # Only generate if certificates don't exist
        if [ ! -f "$CERT_DIR/cert.pem" ] || [ ! -f "$CERT_DIR/key.pem" ]; then
          echo "Generating self-signed certificates..."
          
          # Create certificate authority
          ${pkgs.openssl}/bin/openssl genrsa -out "$CERT_DIR/ca.key" 4096
          ${pkgs.openssl}/bin/openssl req -new -x509 -days 3650 -key "$CERT_DIR/ca.key" -out "$CERT_DIR/ca.crt" -subj "/C=DE/ST=NRW/L=Bad Salzuflen/O=HomeServer/CN=Copyright Respecter CA"
          
          # Create server key
          ${pkgs.openssl}/bin/openssl genrsa -out "$CERT_DIR/key.pem" 4096
          
          # Create certificate signing request
          cat > "$CERT_DIR/server.conf" << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = DE
ST = NRW
L = Bad Salzuflen
O = HomeServer
CN = copyright-respecter.local

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = copyright-respecter.local
DNS.2 = nextcloud.copyright-respecter.local
DNS.3 = jellyfin.copyright-respecter.local
DNS.4 = torrent.copyright-respecter.local
DNS.5 = localhost
IP.1 = 192.168.178.109
IP.2 = 127.0.0.1
EOF

          ${pkgs.openssl}/bin/openssl req -new -key "$CERT_DIR/key.pem" -out "$CERT_DIR/server.csr" -config "$CERT_DIR/server.conf"
          
          # Sign the certificate
          ${pkgs.openssl}/bin/openssl x509 -req -in "$CERT_DIR/server.csr" -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial -out "$CERT_DIR/cert.pem" -days 3650 -extensions v3_req -extfile "$CERT_DIR/server.conf"
          
          # Set proper permissions
          chown -R acme:nginx "$CERT_DIR"
          chmod 640 "$CERT_DIR"/*.pem
          chmod 644 "$CERT_DIR"/*.crt
          
          echo "Self-signed certificates generated successfully!"
          echo "To trust these certificates, add $CERT_DIR/ca.crt to your browser's trusted certificate authorities."
        else
          echo "Certificates already exist, skipping generation."
        fi
      '';
    };
  };

  # Nginx Reverse Proxy with human-friendly URLs
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    
    # Global proxy settings
    appendHttpConfig = ''
      # Rate limiting
      limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
      
      # Real IP configuration
      set_real_ip_from 192.168.178.0/24;
      real_ip_header X-Forwarded-For;
      real_ip_recursive on;
    '';
    
    virtualHosts = {
      # Main landing page
      "copyright-respecter.local" = {
        forceSSL = true;
        useACMEHost = "copyright-respecter.local";
        
        locations."/" = {
          return = "200 '<html><head><title>Media Server</title><style>body{font-family:Arial;margin:40px;background:#f5f5f5}h1{color:#333}.service{background:white;padding:20px;margin:10px 0;border-radius:8px;box-shadow:0 2px 4px rgba(0,0,0,0.1)}.service a{text-decoration:none;color:#0066cc;font-weight:bold;display:inline-block;margin-top:10px;padding:8px 16px;background:#f0f8ff;border-radius:4px;border:1px solid #0066cc}.service a:hover{background:#0066cc;color:white}.status{font-size:12px;color:#666;margin-top:5px}</style></head><body><h1>🏠 Copyright Respecter Media Server</h1><div class=\"service\"><h3>🌩️ Nextcloud</h3><p>File management, sync, and media organization</p><a href=\"https://nextcloud.copyright-respecter.local\">Open Nextcloud</a><div class=\"status\">Secure file storage with automatic syncing</div></div><div class=\"service\"><h3>🎬 Jellyfin</h3><p>Media streaming server with GPU acceleration</p><a href=\"https://jellyfin.copyright-respecter.local\">Open Jellyfin</a><div class=\"status\">Hardware-accelerated video streaming</div></div><div class=\"service\"><h3>📁 qBittorrent</h3><p>Secure torrent client with VPN protection</p><a href=\"https://torrent.copyright-respecter.local\">Open qBittorrent</a><div class=\"status\">VPN-protected torrenting</div></div><div style=\"margin-top:40px;padding:20px;background:#e8f4fd;border-radius:8px;border-left:4px solid #0066cc;\"><h4>📋 Server Status</h4><p><strong>ZFS Pool:</strong> main_pool<br><strong>GPU:</strong> NVIDIA GTX 660 (Hardware acceleration enabled)<br><strong>VPN:</strong> WireGuard active<br><strong>SSL:</strong> Automatic certificate management</p></div></body></html>'";
          extraConfig = ''
            add_header Content-Type text/html;
          '';
        };
      };
      
      # Nextcloud
      "nextcloud.copyright-respecter.local" = {
        forceSSL = true;
        useACMEHost = "copyright-respecter.local";
        
        locations = {
          "/" = {
            extraConfig = ''
              # Security headers
              add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
              add_header Referrer-Policy "no-referrer" always;
              add_header X-Content-Type-Options "nosniff" always;
              add_header X-Download-Options "noopen" always;
              add_header X-Frame-Options "SAMEORIGIN" always;
              add_header X-Permitted-Cross-Domain-Policies "none" always;
              add_header X-Robots-Tag "none" always;
              add_header X-XSS-Protection "1; mode=block" always;
              
              # Rate limiting for login
              location ~ ^/login {
                limit_req zone=login burst=5 nodelay;
                try_files $uri $uri/ /index.php$request_uri;
              }
            '';
          };
        };
      };
      
      # Jellyfin
      "jellyfin.copyright-respecter.local" = {
        forceSSL = true;
        useACMEHost = "copyright-respecter.local";
        
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          extraConfig = ''
            # Jellyfin specific headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            
            # Disable buffering for streaming
            proxy_buffering off;
            proxy_request_buffering off;
            
            # Increase timeouts for large file streaming
            proxy_connect_timeout 600s;
            proxy_send_timeout 600s;
            proxy_read_timeout 600s;
            
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
          '';
        };
      };
      
      # qBittorrent
      "torrent.copyright-respecter.local" = {
        forceSSL = true;
        useACMEHost = "copyright-respecter.local";
        
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # qBittorrent WebUI specific
            proxy_hide_header Referer;
            proxy_hide_header Origin;
            proxy_set_header Referer '';
            proxy_set_header Origin '';
          '';
        };
      };
    };
  };

  # qBittorrent container service (updated with secrets integration)
  systemd.services.qbittorrent-vpn = {
    description = "qBittorrent with VPN";
    after = [
      "docker.service"
      "network.target"
      "sops-nix.service"
    ];
    requires = [ "docker.service" ];
    wants = [ "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPost = "${pkgs.coreutils}/bin/sleep 10";
      ExecStartPre = [
        "-${pkgs.docker}/bin/docker stop qbittorrent-vpn"
        "-${pkgs.docker}/bin/docker rm qbittorrent-vpn"
        "-${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker volume create qbittorrent_data || true'"
        "${pkgs.coreutils}/bin/test -f ${config.sops.secrets.wireguard_config.path}"
        "${pkgs.coreutils}/bin/test -f /run/secrets/qbittorrent_username"
        "${pkgs.coreutils}/bin/test -f /run/secrets/qbittorrent_password"
      ];
      ExecStart =
        let
          startScript = pkgs.writeShellScript "start-qbittorrent-vpn" ''
            USERNAME=$(cat /run/secrets/qbittorrent_username)
            PASSWORD=$(cat /run/secrets/qbittorrent_password)

            ${pkgs.docker}/bin/docker run -d \
              --name qbittorrent-vpn \
              --restart unless-stopped \
              -p 127.0.0.1:8080:8080 \
              -p 5573:5573 \
              --cap-add NET_ADMIN \
              --sysctl net.ipv4.conf.all.src_valid_mark=1 \
              --sysctl net.ipv6.conf.all.disable_ipv6=0 \
              -e PUID=1000 \
              -e PGID=1000 \
              -e UMASK=002 \
              -e TZ=Europe/Berlin \
              -e WEBUI_PORTS=8080/tcp,8080/udp \
              -e VPN_ENABLED=true \
              -e VPN_CONF=wg0 \
              -e VPN_PROVIDER=generic \
              -e VPN_LAN_NETWORK=192.168.178.0/24 \
              -e VPN_LAN_LEAK_ENABLED=false \
              -e VPN_AUTO_PORT_FORWARD=true \
              -e VPN_AUTO_PORT_FORWARD_TO_PORTS=5573 \
              -e VPN_KEEP_LOCAL_DNS=false \
              -e VPN_FIREWALL_TYPE=auto \
              -e VPN_HEALTHCHECK_ENABLED=true \
              -e PRIVOXY_ENABLED=false \
              -e UNBOUND_ENABLED=false \
              -e QBITTORRENT_USERNAME="$USERNAME" \
              -e QBITTORRENT_PASSWORD="$PASSWORD" \
              -v qbittorrent_data:/config \
              -v ${config.sops.secrets.wireguard_config.path}:/config/wireguard/wg0.conf:ro \
              -v /main_pool/storage/torrent/incomplete:/data/incomplete \
              -v /main_pool/storage/torrent/complete:/data/complete \
              ghcr.io/hotio/qbittorrent:latest
          '';
        in
        "${startScript}";
      ExecStop = "${pkgs.docker}/bin/docker stop qbittorrent-vpn";
    };
  };

  # Create media symlinks for easy file management
  systemd.services.create-media-symlinks = {
    description = "Create symlinks for media management";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" "nextcloud-setup.service" ];
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
        
        # Trigger Nextcloud files scan
        sudo -u nextcloud ${config.services.nextcloud.occ}/bin/nextcloud-occ files:scan admin
      '';
    };
  };

  # Backup service
  systemd.services.backup-configs = {
    description = "Backup service configurations and data";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "backup-configs" ''
        BACKUP_DIR="/main_pool/storage/backups/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        
        # Backup Nextcloud config
        tar -czf "$BACKUP_DIR/nextcloud-config.tar.gz" -C /main_pool/storage/nextcloud config || true
        
        # Backup Jellyfin config
        tar -czf "$BACKUP_DIR/jellyfin-config.tar.gz" -C /main_pool/storage/jellyfin config || true
        
        # Backup PostgreSQL database
        sudo -u postgres pg_dump nextcloud > "$BACKUP_DIR/nextcloud-db.sql" || true
        
        # Keep only last 7 days of backups
        find /main_pool/storage/backups -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \; 2>/dev/null || true
      '';
    };
  };

  systemd.timers.backup-configs = {
    description = "Daily backup of service configs";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Health check services
  systemd.services.services-healthcheck = {
    description = "Check all services are running";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "healthcheck" ''
        echo "Checking service health..."
        
        # Check qBittorrent
        ${pkgs.curl}/bin/curl -f http://localhost:8080 >/dev/null 2>&1 || echo "qBittorrent not responding"
        
        # Check Jellyfin
        ${pkgs.curl}/bin/curl -f http://localhost:8096 >/dev/null 2>&1 || echo "Jellyfin not responding"
        
        # Check Nextcloud
        ${pkgs.curl}/bin/curl -f http://nextcloud.copyright-respecter.local >/dev/null 2>&1 || echo "Nextcloud not responding"
        
        echo "Health check completed"
      '';
    };
  };

  systemd.timers.services-healthcheck = {
    description = "Hourly service health check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  # Daily qBittorrent restart timer
  systemd.timers.qbittorrent-vpn-restart = {
    description = "Restart qBittorrent VPN daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  systemd.services.qbittorrent-vpn-restart = {
    description = "Restart qBittorrent VPN service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart qbittorrent-vpn.service";
    };
  };

  # Open firewall ports (only HTTP/HTTPS, services proxied internally)
  networking.firewall = {
    allowedTCPPorts = [ 
      80    # HTTP
      443   # HTTPS
    ];
    allowedUDPPorts = [ 
      1900  # Jellyfin DLNA
      7359  # Jellyfin auto-discovery
    ];
  };

  # Additional packages for media management
  environment.systemPackages = with pkgs; [
    ffmpeg
    mediainfo
    curl
    rsync
    htop
    ncdu
  ];
}
