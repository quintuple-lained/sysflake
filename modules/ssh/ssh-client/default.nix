{
  config,
  lib,
  pkgs,
  ...
}:

let
  canAccessSopsSecrets = builtins.tryEval (
    builtins.pathExists config.sops.secrets.ssh_private_key.path
    && builtins.pathExists config.sops.secrets.ssh_public_key.path
  );
in
{
  sops = {
    defaultSopsFile = ../../../secrets/ssh-keys.yaml;
    age.keyFile = "/home/zoe/.config/sops/age/keys.txt";
    secrets = {
      ssh_private_key = {
        owner = "zoe";
        group = "users";
        mode = "0600";
        path = "/home/zoe/.ssh/id_ed25519";
      };
      ssh_public_key = {
        owner = "zoe";
        group = "users";
        mode = "0644";
        path = "/home/zoe/.ssh/id_ed25519.pub";
      };
    };
  };

  system.activationScripts.setupSshDir = {
    text = ''
      mkdir -p /home/zoe/.ssh 
      chown zoe:users /home/zoe/.ssh/ 
      chmod 700 /home/zoe/.ssh
    '';
    deps = [ "users" ];
  };

  system.activationScripts.setupSshKeys =
    lib.mkIf (canAccessSopsSecrets.success && canAccessSopsSecrets.value)
      {
        text = ''
          # Ensure SSH keys have correct permissions after sops places them
          if [ -f "/home/zoe/.ssh/id_ed25519" ]; then
            chmod 600 /home/zoe/.ssh/id_ed25519
            chown zoe:users /home/zoe/.ssh/id_ed25519
          fi
          if [ -f "/home/zoe/.ssh/id_ed25519.pub" ]; then
            chmod 644 /home/zoe/.ssh/id_ed25519.pub
            chown zoe:users /home/zoe/.ssh/id_ed25519.pub
          fi
        '';
        deps = [
          "setupSshDir"
          "sops-nix"
        ];
      };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      Host *
        IdentityFile ~/.ssh/id_ed25519
        AddKeysToAgent yes
        IdentitiesOnly yes
    '';
  };
}
