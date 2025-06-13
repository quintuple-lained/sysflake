{
  config,
  lib,
  pkgs,
  ...
}:

let
  canAccessSopsSecrets = builtins.tryEval (
    builtins.pathExists config.sops.secrets.ssh_public_key.path
  );
in
{
  sops = {
    defaultSopsFile = ../../../secrets/ssh-keys.yaml;
    secrets = {
      ssh_public_key = {
        owner = "root";
        group = "root";
        mode = "0644";
      };
    };
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
      AllowUsers = [ "zoe" ];
    };

  };

  users.users.zoe.openssh.authorizedKeys.keyFiles =
    lib.optional (canAccessSopsSecrets.success && canAccessSopsSecrets.value)
      [
        config.sops.secrets.ssh_public_key.path
      ];

  # Fail2ban for additional security
  services.fail2ban = {
    enable = true;
    bantime = "24h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
    };
  };

  # Open firewall for SSH
  networking.firewall.allowedTCPPorts = [ 22 ];
}
