{
  pkgs,
  ...
}:
{
  # Desktop-independent GUI applications and configurations
  # This module contains software that you'd want on any desktop environment
  
  home.packages = with pkgs; [
    # Web browsers
    firefox
    
    # messaging
    (discord.override {
   #   withOpenASAR = true;
      withVencord = true;
    })
    
    signal-desktop
    
    # Media
    vlc
    mpv
    
    # Graphics & Design
    gimp
    inkscape
    
    # Office & Productivity
    libreoffice
    
    # File management
    kdePackages.dolphin
    
    # System utilities
    gparted
    # wireshark  # Network analysis
    
    # Development (GUI)
    vscode-fhs

    # Archive management
    p7zip
    unzip
    zip
    kitty
  ];

  # XDG configuration for desktop applications
  xdg = {
    enable = true;
    
    # Default applications
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
      };
    };
  };
}