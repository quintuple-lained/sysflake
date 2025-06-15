{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Add sops secret for VPN configuration
  sops = {
    age.keyFile = "/home/zoe/.config/sops/age/keys.txt";
    secrets.wireguard_config = {
      sopsFile = ../../../secrets/vpn/copyright-respecter.yaml;
      key = "copyright-respecter.config";
      owner = "root";
      group = "root";
      mode = "0600";
      path = "/var/lib/qbittorrent/wireguard/wg0.conf";
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
    ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = [
        # Stop and remove existing container if it exists
        "-${pkgs.docker}/bin/docker stop qbittorrent-vpn"
        "-${pkgs.docker}/bin/docker rm qbittorrent-vpn"
        # Create docker volume if it doesn't exist (fixed syntax)
        "-${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker volume create qbittorrent_data || true'"
      ];
      ExecStart = ''
        ${pkgs.docker}/bin/docker run -d \
          --name qbittorrent-vpn \
          --restart unless-stopped \
          -p 8080:8080 \
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
          -v qbittorrent_data:/config \
          -v ${config.sops.secrets.wireguard_config.path}:/config/wireguard/wg0.conf:ro \
          -v /main_pool/storage/torrent/incomplete:/data/incomplete \
          -v /main_pool/storage/torrent/complete:/data/complete \
          ghcr.io/hotio/qbittorrent:latest
      '';
      ExecStop = "${pkgs.docker}/bin/docker stop qbittorrent-vpn";
    };
  };

  # Open firewall for web interface (VPN traffic will be routed through the container's VPN)
  networking.firewall.allowedTCPPorts = [ 8080 ];

  # Optional: Add a systemd timer to restart the service daily to refresh VPN connection
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
}
