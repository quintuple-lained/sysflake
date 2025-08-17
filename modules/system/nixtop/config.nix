{ pkgs, options, ... }:

{
  imports = [
    ../../nix/ssh/ssh-client/default.nix
  ];
  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 7;
      memtest86.enable = true;
    };
    supportedFilesystems = [
      "xfs"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  sops.secrets.wg_config = {
    sopsFile = ../../../secrets/devices/nixtop.yaml;
    key = "nixtop.config";
    path = "/etc/wireguard/wg0.conf";
    mode = "0600";
  };

  networking = rec {
    hostName = "nixtop";
    hostId = builtins.substring 0 8 (builtins.hashString "sha256" hostName);
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  services.desktopManager.plasma6.enable = true;

  i18n.extraLocaleSettings = {
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

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    pulseaudio.enable = false;

    displayManager.sddm.settings = {
      X11 = { };
    };

    xserver = {
      enable = true;
      xkb.layout = "us";
      videoDrivers = [ "nvidia" ];
    };
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "NixOS Samba Server";
          "netbios name" = "nixos-server";
          security = "user";
          "map to guest" = "bad user";
          "guest account" = "nobody";

          # Enable better performance
          "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
          "read raw" = "yes";
          "write raw" = "yes";
          "max xmit" = "65535";
          "dead time" = "15";
          "getwd cache" = "yes";
        };

        # Define the music share
        music = {
          path = "/home/zoe/Music";
          "valid users" = "zoe";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          comment = "Zoe's Music Collection";
          browseable = "yes";
        };
      };

    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    #package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  users.groups.libvirtd.members = [ "zoe" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    virtiofsd
  ];

  hardware.steam-hardware.enable = true;
  hardware.bluetooth.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.enable = true;
  services.thermald.enable = true;
}
