{
  config,
  pkgs,
  lib,
  ...
}:

let
  canAccessSopsSecrets = builtins.tryEval (
    builtins.pathExists config.sops.secrets.copyright-respecter-config.path
  );
in
{
  # Docker configuration for torrent client with VPN
  virtualisation.docker.enable = true;

  # Create necessary directories
  systemd.tmpfiles.rules = [
    "d /var/lib/torrent/config 0755 root root -"
    "d /var/lib/torrent/downloads 0755 root root -"
    "d /var/lib/torrent/watch 0755 root root -"
    "d /var/lib/nextcloud/data/torrent 0755 nextcloud nextcloud -"
  ];

  # Docker compose service for torrent + VPN
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      # VPN container
      gluetun = {
        image = "qmcgaw/gluetun:latest";
        environment = {
          VPN_SERVICE_PROVIDER = "custom";
          VPN_TYPE = "wireguard";
          VPN_ENDPOINT_IP = "YOUR_VPN_SERVER_IP";
          VPN_ENDPOINT_PORT = "51820";
          WIREGUARD_ADDRESSES = "10.0.0.2/32";
          FIREWALL_OUTBOUND_SUBNETS = "192.168.178.0/24"; # Your local network
        };
        volumes = [
          "${config.sops.secrets.copyright-respecter-config.path}:/gluetun/wireguard/wg0.conf:ro"
        ];
        ports = [
          "8080:8080" # qBittorrent web UI
          "6881:6881" # qBittorrent port
          "6881:6881/udp"
        ];
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--device=/dev/net/tun"
          "--restart=unless-stopped"
        ];
      };

      # qBittorrent container using VPN network
      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Berlin";
          WEBUI_PORT = "8080";
        };
        volumes = [
          "/var/lib/torrent/config:/config"
          "/var/lib/torrent/downloads:/downloads"
          "/var/lib/nextcloud/data/torrent:/downloads/nextcloud"
        ];
        dependsOn = [ "gluetun" ];
        extraOptions = [
          "--network=container:gluetun"
          "--restart=unless-stopped"
        ];
      };
    };
  };

  # SOPS secrets for VPN config
  sops.secrets.copyright-respecter-config = {
    sopsFile = "../../../secrets/vpn/copyright-respecter.yaml";
    age.keyFile = "/home/zoe/.config/sops/age/keys.txt";
    key = "copyright-respecter.config";
    owner = "root";
    group = "root";
    mode = "0600";
  };

  # Ensure Docker service is enabled
  systemd.services.docker-gluetun.wantedBy = lib.mkForce [ "multi-user.target" ];
  systemd.services.docker-qbittorrent.wantedBy = lib.mkForce [ "multi-user.target" ];

  # Open firewall for web interface (local network only)
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
