{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.caddy = {
    enable = true;

    # Fix: Use configFile instead of globalConfig + virtualHosts
    configFile = pkgs.writeText "Caddyfile" ''
      {
        # Global options for local development
        local_certs
      }

      # Main landing page
      copyright-respecter.local {
        respond `<html><head><title>Media Server</title><style>body{font-family:Arial;margin:40px;background:#f5f5f5}h1{color:#333}.service{background:white;padding:20px;margin:10px 0;border-radius:8px;box-shadow:0 2px 4px rgba(0,0,0,0.1)}.service a{text-decoration:none;color:#0066cc;font-weight:bold;display:inline-block;margin-top:10px;padding:8px 16px;background:#f0f8ff;border-radius:4px;border:1px solid #0066cc}.service a:hover{background:#0066cc;color:white}.status{font-size:12px;color:#666;margin-top:5px}</style></head><body><h1>🏠 Copyright Respecter Media Server</h1><div class="service"><h3>🌩️ Nextcloud</h3><p>File management, sync, and media organization</p><a href="https://nextcloud.copyright-respecter.local">Open Nextcloud</a><div class="status">Secure file storage with automatic syncing</div></div><div class="service"><h3>🎬 Jellyfin</h3><p>Media streaming server with GPU acceleration</p><a href="https://jellyfin.copyright-respecter.local">Open Jellyfin</a><div class="status">Hardware-accelerated video streaming</div></div><div class="service"><h3>📁 qBittorrent</h3><p>Secure torrent client with VPN protection</p><a href="https://torrent.copyright-respecter.local">Open qBittorrent</a><div class="status">VPN-protected torrenting</div></div><div style="margin-top:40px;padding:20px;background:#e8f4fd;border-radius:8px;border-left:4px solid #0066cc;"><h4>📋 Server Status</h4><p><strong>ZFS Pool:</strong> main_pool<br><strong>GPU:</strong> NVIDIA GTX 660 (Hardware acceleration enabled)<br><strong>VPN:</strong> WireGuard active<br><strong>SSL:</strong> Automatic certificate management</p></div></body></html>`
      }

      # Nextcloud
      nextcloud.copyright-respecter.local {
        reverse_proxy localhost:80

        # Security headers
        header {
          Strict-Transport-Security "max-age=31536000; includeSubDomains"
          Referrer-Policy "no-referrer"
          X-Content-Type-Options "nosniff"
          X-Download-Options "noopen"
          X-Frame-Options "SAMEORIGIN"
          X-Permitted-Cross-Domain-Policies "none"
          X-Robots-Tag "none"
          X-XSS-Protection "1; mode=block"
        }
      }

      # Jellyfin
      jellyfin.copyright-respecter.local {
        reverse_proxy localhost:8096 {
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
        }
      }

      # qBittorrent
      torrent.copyright-respecter.local {
        reverse_proxy localhost:8080 {
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
          header_up -Referer
          header_up -Origin
        }
      }
    '';
  };
}
