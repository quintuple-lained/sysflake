{ pkgs
, config
, lib
, ...
}:

{
  imports = [
    ./hardware-config.nix
    ../../nix/ssh/ssh-server/default.nix

    #    ../../nix/services/caddy.nix
    #    ../../nix/services/vpn-torrent.nix
    #    ../../nix/services/nextcloud.nix
    #    ../../nix/services/jellyfin.nix
    #    ../../nix/services/minecraft.nix

  ];

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 7;
      memtest86.enable = true;
    };
    supportedFilesystems = [
      "zfs"
      "xfs"
    ];
    zfs = {
      forceImportRoot = true;
      forceImportAll = true;
      extraPools = [ "main_pool" ];
    };
    # Use latest kernel for best ZFS compatibility
    kernelPackages = pkgs.linuxPackages;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # ZFS Services Configuration
  services.zfs = {
    autoScrub = {
      enable = true;
      pools = [ "main_pool" ];
      interval = "monthly";
    };
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
    trim.enable = true;
  };

  # Network Configuration
  networking = rec {
    hostName = "copyright-respecter";
    hostId = builtins.substring 0 8 (builtins.hashString "sha256" hostName);
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.enp34s0 = {
      ipv4.addresses = [
        {
          address = "192.168.178.109";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.178.1";
      interface = "enp34s0";
    };
    nameservers = [
      "9.9.9.9"
      "8.8.8.8"
    ];
  };

  # System Configuration
  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  # X11 Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # User Configuration
  users.users.zoe = {
    isNormalUser = true;
    description = "zoe";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  # Package Configuration

  environment.systemPackages = with pkgs; [
    vim
    tree
    git
    wget
    stress
    fastfetch
    curl
    rsync
    htop
    ncdu
  ];

  system.stateVersion = "25.05";
}
