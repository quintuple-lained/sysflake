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
      };
      work_name = {
        key = "git.work.name";
      };
      pro_email = {
        key = "git.pro.email";
      };
      pro_name = {
        key = "git.pro.name";
      };
      fun_email = {
        key = "git.fun.email";
      };
      fun_name = {
        key = "git.fun.name";
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

      user.work.name = config.sops.secrets.work_name.path;
      user.work.email = config.sops.secrets.work_email.path;

      user.pro.name = config.sops.secrets.pro_name.path;
      user.pro.email = config.sops.secrets.pro_email.path;

      user.fun.name = config.sops.secrets.fun_name.path;
      user.fun.email = config.sops.secrets.fun_email;

      user.personal.name = config.sops.secrets.fun_name.path;
      user.personal.email = config.sops.secrets.fun_email.path;
    };

    aliases = {
      identity = "! git-identity";
      id = "! git-identity";
    };
  };
}
