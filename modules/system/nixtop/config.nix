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
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.displayManager.sddm.settings = {
    # X11 settings for rotation
    X11 = {
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    videoDrivers = [ "nvidia" ];
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

  hardware.steam-hardware.enable = true;
  hardware.bluetooth.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.enable = true;
  services.thermald.enable = true;
}
