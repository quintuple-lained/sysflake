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

  
}