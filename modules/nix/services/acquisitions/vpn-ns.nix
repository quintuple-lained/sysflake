{ pkgs
, config
, lib
, ...
}:

{
  sops = {
    age.keyFile = "/home/zoe/.config/sops/age/keys.txt";
    secrets = {
      vpn_wireguard_config = {
        sopsFile = ../../../../secrets/devices/copyright-respecter.yaml;
        key = "copyright-respecter.config";
        owner = "root";
        group = "root";
        mode = "0600";
        path = "/var/lib/vpn-namespace/wg0.conf";
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/vpn-namespace 0700 root root"
  ];

  systemd.services.vpn-namespace = {
    description = "VPN network namespace wireguard";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "sops-nix.service"
    ];
    wants = [ "sops-nix.service" ];
    requires = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStartPre = [
        "${pkgs.coreutils}/bin/test -f ${config.sops.secrets.vpn_wireguard_config.path}"
        "${pkgs.kmod}/bin/modprobe wireguard"
        # Clean up any existing namespace before starting
        "${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip netns delete vpn 2>/dev/null || true'"
        "${pkgs.bash}/bin/bash -c 'rm -f /var/run/netns/vpn || true'"
      ];

      ExecStart = pkgs.writeShellScript "vpn-namespace-up" ''
        set -euo pipefail
          
        # Define our namespace name - keeping it simple and predictable
        NAMESPACE="vpn"
          
        echo "Setting up VPN namespace '$NAMESPACE'..."
          
        # Clean up any existing namespace first (redundant but safe)
        ${pkgs.iproute2}/bin/ip netns delete "$NAMESPACE" 2>/dev/null || true
        rm -f "/var/run/netns/$NAMESPACE" 2>/dev/null || true

        # Create the namespace 
        echo "Creating network namespace: $NAMESPACE"
        ${pkgs.iproute2}/bin/ip netns add "$NAMESPACE"
          
        # Set up DNS resolution within the namespace
        # We use Cloudflare's DNS by default, but you could make this configurable
        mkdir -p "/etc/netns/$NAMESPACE"
        echo "nameserver 1.1.1.1" > "/etc/netns/$NAMESPACE/resolv.conf"
        echo "nameserver 1.0.0.1" >> "/etc/netns/$NAMESPACE/resolv.conf"
          
        # Clean up any existing WireGuard interface (in case of restart)
        ${pkgs.iproute2}/bin/ip link delete wg0 2>/dev/null || true
          
        # Create the WireGuard interface
        echo "Creating WireGuard interface..."
        ${pkgs.iproute2}/bin/ip link add wg0 type wireguard
          
        # Move the interface into our namespace
        echo "Moving interface to namespace..."
        ${pkgs.iproute2}/bin/ip link set wg0 netns "$NAMESPACE"
          
        # Extract the private IP from the WireGuard config
        # This is a bit of shell magic to parse the config file
        PRIVATE_IP=$(${pkgs.gnugrep}/bin/grep -E "^Address\s*=" "${config.sops.secrets.vpn_wireguard_config.path}" | ${pkgs.coreutils}/bin/cut -d'=' -f2 | ${pkgs.coreutils}/bin/tr -d ' ')
          
        if [ -z "$PRIVATE_IP" ]; then
          echo "Error: Could not find Address in WireGuard config"
          exit 1
        fi
          
        echo "Using private IP: $PRIVATE_IP"
          
        # Configure the interface inside the namespace
        echo "Configuring WireGuard interface..."
        ${pkgs.iproute2}/bin/ip -n "$NAMESPACE" addr add "$PRIVATE_IP" dev wg0
          
        # Apply the WireGuard configuration
        ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" \
          ${pkgs.wireguard-tools}/bin/wg setconf wg0 "${config.sops.secrets.vpn_wireguard_config.path}"
          
        # Bring up the loopback interface (needed for basic networking)
        ${pkgs.iproute2}/bin/ip -n "$NAMESPACE" link set lo up
          
        # Bring up the WireGuard interface
        ${pkgs.iproute2}/bin/ip -n "$NAMESPACE" link set wg0 up
          
        # Set the default route to go through WireGuard
        # This ensures all traffic in the namespace uses the VPN
        ${pkgs.iproute2}/bin/ip -n "$NAMESPACE" route add default dev wg0
          
        echo "VPN namespace setup complete!"
          
        # Optional: Test the connection
        echo "Testing VPN connection..."
        if ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iputils}/bin/ping -c 1 -W 5 1.1.1.1 >/dev/null 2>&1; then
          echo "VPN connection test: SUCCESS"
        else
          echo "VPN connection test: FAILED (this might be normal if the VPN server doesn't respond to pings)"
        fi
      '';

      # Cleanup script - removes the namespace and all associated interfaces
      ExecStop = pkgs.writeShellScript "vpn-namespace-down" ''
        set -euo pipefail
          
        NAMESPACE="vpn"
          
        echo "Cleaning up VPN namespace '$NAMESPACE'..."
          
        # Delete the namespace (this automatically cleans up interfaces inside it)
        if ${pkgs.iproute2}/bin/ip netns list | ${pkgs.gnugrep}/bin/grep -q "^$NAMESPACE\$"; then
          ${pkgs.iproute2}/bin/ip netns delete "$NAMESPACE"
          echo "Namespace $NAMESPACE removed"
        else
          echo "Namespace $NAMESPACE was not present"
        fi

        # Clean up any leftover files
        rm -f "/var/run/netns/$NAMESPACE" 2>/dev/null || true
        rm -rf "/etc/netns/$NAMESPACE" 2>/dev/null || true
          
        echo "VPN namespace cleanup complete"
      '';

      # More aggressive cleanup on stop
      ExecStopPost = pkgs.writeShellScript "vpn-namespace-cleanup" ''
        # Final cleanup - make sure everything is gone
        ${pkgs.iproute2}/bin/ip netns delete vpn 2>/dev/null || true
        rm -f /var/run/netns/vpn 2>/dev/null || true
        rm -rf /etc/netns/vpn 2>/dev/null || true
      '';

      # Restart the service if it fails
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  # Create the convenience wrapper script that other services can use
  # This is the key to making the namespace easily usable by other parts of your system
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "vpn-exec" ''
      # This script runs commands inside the VPN namespace
      # Usage: vpn-exec <command> [arguments...]

      NAMESPACE="vpn"

      if [ $# -eq 0 ]; then
        echo "Usage: vpn-exec <command> [arguments...]"
        echo ""
        echo "This runs the specified command inside the VPN namespace."
        echo "All network traffic from the command will go through the VPN."
        echo ""
        echo "Examples:"
        echo "  vpn-exec curl ifconfig.me     # Check your VPN IP address"
        echo "  vpn-exec wget https://..."    # Download using VPN"
        echo "  vpn-exec transmission-daemon  # Run BitTorrent client through VPN"
        exit 1
      fi

      # Check if the namespace exists
      if ! ${pkgs.iproute2}/bin/ip netns list | ${pkgs.gnugrep}/bin/grep -q "^$NAMESPACE\$"; then
        echo "Error: VPN namespace '$NAMESPACE' not found."
        echo "Make sure the vpn-namespace service is running:"
        echo "  sudo systemctl status vpn-namespace"
        exit 1
      fi

      # Execute the command in the VPN namespace
      exec ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" "$@"
    '')

    # Add a status checking script
    (pkgs.writeShellScriptBin "vpn-status" ''
      # This script shows the status of the VPN namespace

      NAMESPACE="vpn"

      echo "=== VPN Namespace Status ==="
      echo ""

      # Check if namespace exists
      if ${pkgs.iproute2}/bin/ip netns list | ${pkgs.gnugrep}/bin/grep -q "^$NAMESPACE\$"; then
        echo "✓ Namespace '$NAMESPACE' exists"
      else
        echo "✗ Namespace '$NAMESPACE' not found"
        exit 1
      fi

      # Show network interfaces in the namespace
      echo ""
      echo "Network interfaces in namespace:"
      ${pkgs.iproute2}/bin/ip -n "$NAMESPACE" link show

      # Show routing table
      echo ""
      echo "Routing table in namespace:"
      ${pkgs.iproute2}/bin/ip -n "$NAMESPACE" route show

      # Test external connectivity
      echo ""
      echo "Testing external connectivity..."
      if ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iputils}/bin/ping -c 1 -W 5 1.1.1.1 >/dev/null 2>&1; then
        echo "✓ External connectivity working"
      else
        echo "✗ External connectivity failed"
      fi

      # Show current external IP (if curl is available and working)
      echo ""
      echo "Current external IP address:"
      ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.curl}/bin/curl -s --connect-timeout 10 ifconfig.me 2>/dev/null || echo "Unable to determine external IP"
    '')

    # Add a cleanup script for manual use
    (pkgs.writeShellScriptBin "vpn-cleanup" ''
      # Manual cleanup script for stuck VPN namespace

      echo "Cleaning up VPN namespace..."

      # Stop the service first
      sudo systemctl stop vpn-namespace.service 2>/dev/null || true

      # Clean up namespace
      sudo ${pkgs.iproute2}/bin/ip netns delete vpn 2>/dev/null || true

      # Clean up files
      sudo rm -f /var/run/netns/vpn 2>/dev/null || true
      sudo rm -rf /etc/netns/vpn 2>/dev/null || true

      # Clean up any wg0 interfaces
      sudo ${pkgs.iproute2}/bin/ip link delete wg0 2>/dev/null || true

      echo "Cleanup complete. You can now restart the service:"
      echo "  sudo systemctl start vpn-namespace.service"
    '')
  ];
}
