{ pkgs, options, ...}:

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
      "zfs"
      "xfs"
    ];
    zfs.forceImportRoot = false;
    kernelParams = [
      "fbcon=rotate:1"           # Console rotation (90° left)
      "video=DSI-1:panel_orientation=left_side_up"  # Panel orientation
    ];
  };

  networking = {
    hostName = "chuwu";
    hostId = "7f630874";
    networkmanager.enable = true;  # Add this line
  };
  
  services.openssh.enable = true;

  services.desktopManager.plasma6.enable = true;

  # SDDM rotation configuration (chuwu-specific)
  services.displayManager.sddm.settings = {
    # X11 settings for rotation
    X11 = {
      DisplayCommand = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --rotate left || \
        ${pkgs.xorg.xrandr}/bin/xrandr --output eDP1 --rotate left || \
        ${pkgs.xorg.xrandr}/bin/xrandr --output LVDS-1 --rotate left || \
        ${pkgs.xorg.xrandr}/bin/xrandr --output LVDS1 --rotate left || true
      '';
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    # X11 display rotation
    displayManager.setupCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --rotate left || true
      ${pkgs.xorg.xrandr}/bin/xrandr --output eDP1 --rotate left || true
      ${pkgs.xorg.xrandr}/bin/xrandr --output LVDS-1 --rotate left || true
      ${pkgs.xorg.xrandr}/bin/xrandr --output LVDS1 --rotate left || true
    '';
  };
  
  hardware.steam-hardware.enable = true;
  hardware.bluetooth.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.enable = true;
  services.thermald.enable = true;

  # Additional display rotation setup
  environment.etc."sddm/scripts/Xsetup" = {
    text = ''
      #!/bin/sh
      # Rotate display for SDDM
      ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --rotate left 2>/dev/null || \
      ${pkgs.xorg.xrandr}/bin/xrandr --output eDP1 --rotate left 2>/dev/null || \
      ${pkgs.xorg.xrandr}/bin/xrandr --output LVDS-1 --rotate left 2>/dev/null || \
      ${pkgs.xorg.xrandr}/bin/xrandr --output LVDS1 --rotate left 2>/dev/null || true
    '';
    mode = "0755";
  };
}
