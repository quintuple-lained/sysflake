{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
      AllowUsers = [ "zoe" ];
    };
    ports = [ 22 ];
  };

  users.users.zoe.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQsqaVkp8K59d7ioHIgPGzldJLKKARiuWva4QfEGnSt quintuple_lained@proton.me"
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