{ config
, lib
, pkgs
, ...
}:

{
  # Add sops secret for VPN configuration
  sops = {
    age.keyFile = "/home/zoe/.config/sops/age/keys.txt";
    secrets = {
      wireguard_config = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "copyright-respecter.config";
        owner = "root";
        group = "root";
        mode = "0600";
        path = "/var/lib/qbittorrent/wireguard/wg0.conf";
      };
      qbittorrent_username = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "qbittorrent.username";
        owner = "root";
        group = "root";
        mode = "0644";
        # Don't specify path - will be at /run/secrets/qbittorrent_username
      };
      qbittorrent_password = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "qbittorrent.password";
        owner = "root";
        group = "root";
        mode = "0644";
        # Don't specify path - will be at /run/secrets/qbittorrent_password
      };
    };
  };

  # Enable docker for container support
  virtualisation.docker.enable = true;
  users.users.zoe.extraGroups = [ "docker" ];

  # Create necessary directories
  systemd.tmpfiles.rules = [
    "d /var/lib/qbittorrent 0755 root root"
    "d /var/lib/qbittorrent/config 0755 root root"
    "d /var/lib/qbittorrent/wireguard 0700 root root"
    "d /main_pool/storage/torrent 0755 zoe users"
    "d /main_pool/storage/torrent/incomplete 0755 zoe users"
    "d /main_pool/storage/torrent/complete 0755 zoe users"
  ];

  # qBittorrent container service
  systemd.services.qbittorrent-vpn = {
    description = "qBittorrent with VPN";
    after = [
      "docker.service"
      "network.target"
      "sops-nix.service" # Ensure secrets are available
    ];
    requires = [ "docker.service" ];
    wants = [ "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Add a delay to ensure container is fully started
      ExecStartPost = "${pkgs.coreutils}/bin/sleep 10";
      ExecStartPre = [
        # Stop and remove existing container if it exists
        "-${pkgs.docker}/bin/docker stop qbittorrent-vpn"
        "-${pkgs.docker}/bin/docker rm qbittorrent-vpn"
        # Create docker volume if it doesn't exist
        "-${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker volume create qbittorrent_data || true'"
        # Verify secrets exist
        "${pkgs.coreutils}/bin/test -f ${config.sops.secrets.wireguard_config.path}"
        "${pkgs.coreutils}/bin/test -f /run/secrets/qbittorrent_username"
        "${pkgs.coreutils}/bin/test -f /run/secrets/qbittorrent_password"
      ];
      ExecStart =
        let
          # Create a script that reads the secrets and starts the container
          startScript = pkgs.writeShellScript "start-qbittorrent-vpn" ''
            USERNAME=$(cat /run/secrets/qbittorrent_username)
            PASSWORD=$(cat /run/secrets/qbittorrent_password)

            ${pkgs.docker}/bin/docker run -d \
              --name qbittorrent-vpn \
              --restart unless-stopped \
              -p 8080:8080 \
              -p 5573:5573 \
              --cap-add NET_ADMIN \
              --cap-add SYS_MODULE \
              --sysctl net.ipv4.conf.all.src_valid_mark=1 \
              --sysctl net.ipv6.conf.all.disable_ipv6=0 \
              --device /dev/net/tun \
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
              -e QBITTORRENT_WEBUI_PORT=8080 \
              -e QBITTORRENT_CONFIG_VALIDATION=true \
              -v qbittorrent_data:/config \
              -v ${config.sops.secrets.wireguard_config.path}:/config/wireguard/wg0.conf:ro \
              -v /main_pool/storage/torrent/incomplete:/data/incomplete \
              -v /main_pool/storage/torrent/complete:/data/complete \
              ghcr.io/hotio/qbittorrent:latest
          '';
        in
        "${startScript}";
      ExecStop = "${pkgs.docker}/bin/docker stop qbittorrent-vpn";
      ExecReload = "${pkgs.docker}/bin/docker restart qbittorrent-vpn";
    };
  };

  # Open firewall for web interface
  networking.firewall.allowedTCPPorts = [ 8080 ];

  systemd.services.qbittorrent-vpn-healthcheck = {
    description = "qBittorrent VPN Health Check";
    after = [ "qbittorrent-vpn.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "qbittorrent-healthcheck" ''
        # Wait for service to start
        sleep 30

        # Check if container is running
        if ! ${pkgs.docker}/bin/docker ps | grep -q qbittorrent-vpn; then
          echo "Container not running"
          exit 1
        fi

        # Check if web interface is accessible
        if ! ${pkgs.curl}/bin/curl -f http://localhost:8080 >/dev/null 2>&1; then
          echo "Web interface not accessible"
          exit 1
        fi

        # Check VPN status via container logs
        if ${pkgs.docker}/bin/docker logs qbittorrent-vpn 2>&1 | grep -q "VPN connection established"; then
          echo "VPN connection verified"
        else
          echo "Warning: VPN status unclear"
        fi

        echo "Health check passed"
      '';
      TimeoutStartSec = "300";
    };
  };

  # Optional: Add a systemd timer to restart the service daily
  systemd.timers.qbittorrent-vpn-restart = {
    description = "Restart qBittorrent VPN daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  systemd.services.qbittorrent-vpn-restart = {
    description = "Restart qBittorrent VPN service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart qbittorrent-vpn.service";
    };
  };
}
