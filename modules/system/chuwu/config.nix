{ pkgs, options, ...}:

{
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
    zfs.forceImportRoot = false;
    kernelParams = ["fbcon=rotate:1"];
  };

  networking = {
    hostName = "chuwu";
  };
  services.openssh.enable = true;

  services.desktopManager.plasma6.enable = true;

  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };
  hardware.steam-hardware.enable = true;
  hardware.bluetooth.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.enable = true;
  services.thermald.enable = true;
}