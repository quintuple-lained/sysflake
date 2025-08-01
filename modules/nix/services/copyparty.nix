{ config
, lib
, pkgs
, ...
}:

{

  sops = {
    age.keyfile = "/home/zoe/.config/sops/age/keys.txt";
    secrets = {
      copyparty_config = {
        sopsFile = ../../../secrets/devices/copyright-respecter.yaml;
        key = "copyparty_server.config";
        owner = "root";
        group = "root";
        mode = "0600";
        path = "/run/keys/copyparty/password";
      };
    };
  };

  services.copyparty = {
    enable = true;
    settings = {
      i = "0.0.0.0";
      p = [
        3210
        3211
      ];
      no-reload = true;
    };
    accounts = {
      zoe = {
        passwordFile = "/run/keys/copyparty/password";
      };
    };
  };
}
