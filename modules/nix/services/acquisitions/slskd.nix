{ config
, lib
, pkgs
, ...
}:

{
  # Add sops secret for soulseek credentials
  sops = {
    age.keyFile = "/home/zoe/.config/sops/age/keys.txt";
    secrets = {
      slskd_username = {
        sopsFile = ../../../../secrets/devices/copyright-respecter.yaml;
        key = "slskd.username";
        owner = "root";
        group = "root";
        mode = "0644";
      };
      slskd_password = {
        sopsFile = ../../../../secrets/devices/copyright-respecter.yaml;
        key = "slskd.password";
        owner = "root";
        group = "root";
        mode = "0644";
      };
    };
  };

  # Create necessary directories
  systemd.tmpfiles.rules = [
    "d /main_pool/storage/music 0755 zoe users"
    "d /main_pool/storage/music/downloads 0755 zoe users"
    "d /main_pool/storage/music/incomplete 0755 zoe users"
    "d /main_pool/storage/music/shares 0755 zoe users"
    "d /var/lib/slskd 0755 slskd slskd"
  ];

  # Create slskd user
  users.users.slskd = {
    isSystemUser = true;
    group = "slskd";
    home = "/var/lib/slskd";
    createHome = true;
  };
  users.groups.slskd = { };

  # Add zoe to slskd group for file access
  users.users.zoe.extraGroups = [ "slskd" ];

  # Slskd service running in VPN namespace
  systemd.services.slskd-vpn = {
    description = "Soulseek daemon with VPN";
    after = [
      "network.target"
      "sops-nix.service"
      "vpn-namespace.service"
    ];
    requires = [ "vpn-namespace.service" ];
    wants = [ "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "slskd";
      Group = "slskd";
      Restart = "on-failure";
      RestartSec = "10s";

      # Run in VPN namespace
      NetworkNamespacePath = "/var/run/netns/vpn";

      # Security settings
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [
        "/var/lib/slskd"
        "/main_pool/storage/music"
      ];

      ExecStartPre = [
        # Verify VPN namespace exists
        "${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip netns list | ${pkgs.gnugrep}/bin/grep -q \"^vpn$\"'"
        # Verify secrets exist
        "${pkgs.coreutils}/bin/test -f /run/secrets/slskd_username"
        "${pkgs.coreutils}/bin/test -f /run/secrets/slskd_password"
      ];

      ExecStart =
        let
          slskdConfig = pkgs.writeText "slskd.yml" ''
            soulseek:
              username: $(cat /run/secrets/slskd_username)
              password: $(cat /run/secrets/slskd_password)

            web:
              port: 5030
              https:
                port: 5031

            directories:
              downloads: /main_pool/storage/music/downloads
              incomplete: /main_pool/storage/music/incomplete

            shares:
              directories:
                - /main_pool/storage/music/shares
              filters:
                - "\.ini$"
                - "Thumbs\.db$"
                - "\.DS_Store$"
                - "desktop\.ini$"

            transfers:
              download:
                slots: 10
                speed_limit: 0
              upload:
                slots: 10
                speed_limit: 0

            feature:
              web: true
              no_share_scan: false
          '';

          startScript = pkgs.writeShellScript "start-slskd-vpn" ''
            set -euo pipefail

            # Read credentials and substitute in config
            USERNAME=$(cat /run/secrets/slskd_username)
            PASSWORD=$(cat /run/secrets/slskd_password)

            # Create runtime config with substituted values
            RUNTIME_CONFIG="/var/lib/slskd/slskd.yml"
            ${pkgs.gnused}/bin/sed \
              -e "s/\$(cat \/run\/secrets\/slskd_username)/$USERNAME/g" \
              -e "s/\$(cat \/run\/secrets\/slskd_password)/$PASSWORD/g" \
              ${slskdConfig} > "$RUNTIME_CONFIG"

            # Start slskd
            exec ${pkgs.slskd}/bin/slskd --config "$RUNTIME_CONFIG" --app-dir /var/lib/slskd
          '';
        in
        "${startScript}";
    };
  };

  # Proxy service to make web interface accessible from host network
  systemd.services.slskd-proxy = {
    description = "Proxy for slskd web interface";
    after = [ "slskd-vpn.service" ];
    wants = [ "slskd-vpn.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "nobody";
      Group = "nogroup";
      Restart = "on-failure";
      RestartSec = "5s";

      ExecStart =
        let
          proxyScript = pkgs.writeShellScript "slskd-proxy" ''
            # Wait for slskd to be ready in VPN namespace
            while ! ${pkgs.iproute2}/bin/ip netns exec vpn ${pkgs.netcat}/bin/nc -z localhost 5030; do
              echo "Waiting for slskd to start..."
              sleep 2
            done

            echo "Starting proxy to slskd web interface..."
            exec ${pkgs.socat}/bin/socat \
              TCP-LISTEN:5030,fork,reuseaddr \
              EXEC:"${pkgs.iproute2}/bin/ip netns exec vpn ${pkgs.socat}/bin/socat STDIO TCP-CONNECT:localhost:5030"
          '';
        in
        "${proxyScript}";
    };
  };

  # Status checking service
  systemd.services.slskd-healthcheck = {
    description = "Slskd VPN Health Check";
    after = [ "slskd-vpn.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "slskd-healthcheck" ''
        # Wait for service to start
        sleep 10

        # Check if slskd is running in VPN namespace
        if ! ${pkgs.iproute2}/bin/ip netns exec vpn ${pkgs.procps}/bin/pgrep -f slskd >/dev/null; then
          echo "slskd not running in VPN namespace"
          exit 1
        fi

        # Check if web interface is accessible in namespace
        if ! ${pkgs.iproute2}/bin/ip netns exec vpn ${pkgs.curl}/bin/curl -f http://localhost:5030 >/dev/null 2>&1; then
          echo "Web interface not accessible in VPN"
          exit 1
        fi

        # Check if proxy is working
        if ! ${pkgs.curl}/bin/curl -f http://localhost:5030 >/dev/null 2>&1; then
          echo "Proxy not accessible from host"
          exit 1
        fi

        echo "Slskd health check passed"
      '';
      TimeoutStartSec = "60";
    };
  };

  # Optional: Restart service daily to keep connection fresh
  systemd.timers.slskd-restart = {
    description = "Restart slskd daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  systemd.services.slskd-restart = {
    description = "Restart slskd service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart slskd-vpn.service slskd-proxy.service";
    };
  };

  # Open firewall for web interface
  networking.firewall.allowedTCPPorts = [ 5030 ];

  # Convenience script to check slskd status
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "slskd-status" ''
      echo "=== Slskd Status ==="
      echo ""

      # Check VPN namespace
      if ${pkgs.iproute2}/bin/ip netns list | ${pkgs.gnugrep}/bin/grep -q "^vpn\$"; then
        echo "✓ VPN namespace exists"
      else
        echo "✗ VPN namespace not found"
        exit 1
      fi

      # Check if slskd is running
      if ${pkgs.iproute2}/bin/ip netns exec vpn ${pkgs.procps}/bin/pgrep -f slskd >/dev/null; then
        echo "✓ Slskd running in VPN namespace"
      else
        echo "✗ Slskd not running"
      fi

      # Check web interface
      if ${pkgs.curl}/bin/curl -s -f http://localhost:5030 >/dev/null 2>&1; then
        echo "✓ Web interface accessible at http://localhost:5030"
      else
        echo "✗ Web interface not accessible"
      fi

      # Show network info in VPN namespace
      echo ""
      echo "VPN namespace network info:"
      ${pkgs.iproute2}/bin/ip netns exec vpn ${pkgs.curl}/bin/curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "Unable to determine VPN IP"
    '')
  ];
}
