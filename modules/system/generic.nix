{
  pkgs,
  ...
}:
{
  boot = {
    loader.timeout = 5;
    initrd.compressor = "zstd";

    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "systemd.show_status=auto"
    ];
  };
  i18n.defaultLocale = "en_GB.UTF-8";

  time.timeZone = "Europe/Berlin";

  services.resolved.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  system.stateVersion = "25.05";
  system.autoUpgrade.enable = false;

  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;

      auto-optimise-store = true;
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users.users.zoe = {
    shell = pkgs.bash;
    isNormalUser = true;
    autoSubUidGidRange = true;
    home = "/home/zoe";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];

    initialPassword = "ZoeZoe";
  };

  programs.nix-index-database.comma.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/zoe/sysflake";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      #userServices = true;
    };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  programs.fish.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # just the basics
  environment.systemPackages = with pkgs; [
    binutils
    coreutils
    git
    curl
    wget
    neovim
  ];

  # i wish i could use it but it causes too many issues with nixos ;-;
  # doas my beloved
  #security = {
  #  sudo.enable = false;
  #  doas.enable = true;
  #  doas.extraRules = [
  #     {
  #       users = [ "zoe" ];
  #       keepEnv = true;
  #       persist = true;
  #       cmd = "nixos-rebuild"; # Only allow passwordless nixos-rebuild
  #       noPass = true;
  #     }
  #     {
  #       users = [ "zoe" ];
  #       keepEnv = true;
  #       persist = true;
  #       # This rule will require password for other commands
  #     }
  #   ];
  # };
}
