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
    secrets = {
      crafty_wireguard_config = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "crafty-server.config";
        owner = "root";
        group = "root";
        mode = "0600";
        path = "/var/lib/crafty/wireguard/wg0.conf";
      };
    };
  };

  # Enable docker for container support
  virtualisation.docker.enable = true;
  users.users.zoe.extraGroups = [ "docker" ];

  # Create necessary directories
  systemd.tmpfiles.rules = [
    "d /var/lib/crafty 0755 root root"
    "d /var/lib/crafty/wireguard 0700 root root"
    "d /var/lib/crafty/docker 0755 root root"
    "d /var/lib/crafty/docker/backups 0755 root root"
    "d /var/lib/crafty/docker/logs 0755 root root"
    "d /var/lib/crafty/docker/servers 0755 root root"
    "d /var/lib/crafty/docker/config 0755 root root"
    "d /var/lib/crafty/docker/import 0755 root root"
  ];

  # Crafty Controller container service with VPN
  systemd.services.crafty-vpn = {
    description = "Crafty Controller with VPN";
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
      ExecStartPost = "${pkgs.coreutils}/bin/sleep 15";
      ExecStartPre = [
        # Stop and remove existing container if it exists
        "-${pkgs.docker}/bin/docker stop crafty-vpn"
        "-${pkgs.docker}/bin/docker rm crafty-vpn"
        # Verify secrets exist
        "${pkgs.coreutils}/bin/test -f ${config.sops.secrets.crafty_wireguard_config.path}"
      ];
      ExecStart =
        let
          startScript = pkgs.writeShellScript "start-crafty-vpn" ''
            ${pkgs.docker}/bin/docker run -d \
              --name crafty-vpn \
              --restart unless-stopped \
              -p 8443:8443 \
              -p 8123:8123 \
              -p 19132:19132/udp \
              -p 25500-25600:25500-25600 \
              --cap-add NET_ADMIN \
              --cap-add SYS_MODULE \
              --sysctl net.ipv4.conf.all.src_valid_mark=1 \
              --sysctl net.ipv6.conf.all.disable_ipv6=0 \
              --device /dev/net/tun \
              -e PUID=1000 \
              -e PGID=1000 \
              -e TZ=Etc/UTC \
              -e VPN_ENABLED=true \
              -e VPN_CONF=wg0 \
              -e VPN_PROVIDER=generic \
              -e VPN_LAN_NETWORK=192.168.178.0/24 \
              -e VPN_LAN_LEAK_ENABLED=false \
              -e VPN_FIREWALL_TYPE=auto \
              -e VPN_HEALTHCHECK_ENABLED=true \
              -e CRAFTY_WEB_HOST=0.0.0.0
              -v ${config.sops.secrets.crafty_wireguard_config.path}:/config/wireguard/wg0.conf:ro \
              -v /var/lib/crafty/docker/backups:/crafty/backups \
              -v /var/lib/crafty/docker/logs:/crafty/logs \
              -v /var/lib/crafty/docker/servers:/crafty/servers \
              -v /var/lib/crafty/docker/config:/crafty/app/config \
              -v /var/lib/crafty/docker/import:/crafty/import \
              registry.gitlab.com/crafty-controller/crafty-4:latest
          '';
        in
        "${startScript}";
      ExecStop = "${pkgs.docker}/bin/docker stop crafty-vpn";
      ExecReload = "${pkgs.docker}/bin/docker restart crafty-vpn";
    };
  };

  # Open firewall ports
  networking.firewall = {
    allowedTCPPorts = [
      8443
      8123
    ] ++ (lib.range 25500 25600);
    allowedUDPPorts = [ 19132 ];
  };

  # Health check service
  systemd.services.crafty-vpn-healthcheck = {
    description = "Crafty VPN Health Check";
    after = [ "crafty-vpn.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "crafty-healthcheck" ''
        # Wait for service to start
        sleep 30

        # Check if container is running
        if ! ${pkgs.docker}/bin/docker ps | grep -q crafty-vpn; then
          echo "Container not running"
          exit 1
        fi

        # Check if web interface is accessible
        if ! ${pkgs.curl}/bin/curl -k -f https://localhost:8443 >/dev/null 2>&1; then
          echo "Web interface not accessible"
          exit 1
        fi

        # Check VPN status via container logs
        if ${pkgs.docker}/bin/docker logs crafty-vpn 2>&1 | grep -q "VPN connection established"; then
          echo "VPN connection verified"
        else
          echo "Warning: VPN status unclear"
        fi

        echo "Health check passed"
      '';
      TimeoutStartSec = "300";
    };
  };

  # Optional: Daily restart timer
  systemd.timers.crafty-vpn-restart = {
    description = "Restart Crafty VPN daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  systemd.services.crafty-vpn-restart = {
    description = "Restart Crafty VPN service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart crafty-vpn.service";
    };
  };
}
