{
  config,
  lib,
  pkgs,
  ...
}:

let
  gitIdentity = pkgs.writeShellScriptBin "git-identity" (builtins.readFile ./git-identity);

  canAccessSopsSecrets = builtins.tryEval (builtins.pathExists config.sops.secrets.work_email.path);
in
{
  sops = {
    defaultSopsFile = ../../../secrets/git.yaml;
    age.keyFile = "/home/zoe/.config/sops/age/keys.txt";
    secrets = {
      work_email = {
        key = "git.work.email";
        owner = "zoe";
        group = "users";
        mode = "0600";
      };
      work_name = {
        key = "git.work.name";
        owner = "zoe";
        group = "users";
        mode = "0600";
      };
      pro_email = {
        key = "git.pro.email";
        owner = "zoe";
        group = "users";
        mode = "0600";
      };
      pro_name = {
        key = "git.pro.name";
        owner = "zoe";
        group = "users";
        mode = "0600";
      };
      fun_email = {
        key = "git.fun.email";
        owner = "zoe";
        group = "users";
        mode = "0600";
      };
      fun_name = {
        key = "git.fun.name";
        owner = "zoe";
        group = "users";
        mode = "0600";
      };
    };
  };

  home.packages = with pkgs; [
    gitIdentity
    fzf
  ];
  programs.git = {
    enable = true;
    extraConfig = {
      user.useConfigOnly = true;

      user.work.name = config.sops.secrets.work_name;
      user.work.email = config.sops.secrets.work_email;

      user.pro.name = config.sops.secrets.pro_name;
      user.pro.email = config.sops.secrets.pro_email;

      user.fun.name = config.sops.secrets.fun_name;
      user.fun.email = config.sops.secrets.fun_email;

      user.personal.name = config.sops.secrets.fun_name;
      user.personal.email = config.sops.secrets.fun_email;
    };
    aliases = {
      identity = "! git-identity";
      id = "! git-identity";
    };
  };
}
