{ pkgs
, ...
}:
{

  home.packages = with pkgs; [
    # Web browsers

    # messaging
    (discord.override {
      #   withOpenASAR = true;
      withVencord = true;
    })

    signal-desktop
    firefox

    # Media
    vlc
    mpv

    # Graphics & Design
    gimp
    inkscape

    # Office & Productivity
    libreoffice
    # for sql because autism
    litecli
    dbeaver-bin

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
    nicotine-plus
    tldr
    exfatprogs
    cinny-desktop

    # who?
    whois
  ];

  home.file."projects/pro/.keep" = {
    text = "";
  };
  home.file."projects/fun/.keep" = {
    text = "";
  };

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
