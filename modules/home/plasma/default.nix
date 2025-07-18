{
  pkgs,
  ...
}:
{
  services.kdeconnect.enable = true;

  # Enable Plasma Manager
  programs.plasma = {
    enable = true;

    # Workspace behavior
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      cursor.theme = "breeze_cursors";
      iconTheme = "breeze-dark";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Next/contents/images/1920x1080.png";

      # Window management
      clickItemTo = "select";
      tooltipDelay = 700;

      # Virtual desktops
      theme = "breeze-dark";
    };

    # Fonts configuration
    fonts = {
      general = {
        family = "Source Sans Pro";
        pointSize = 10;
      };
      fixedWidth = {
        family = "Source Code Pro";
        pointSize = 10;
      };
      small = {
        family = "Source Sans Pro";
        pointSize = 8;
      };
      toolbar = {
        family = "Source Sans Pro";
        pointSize = 10;
      };
      menu = {
        family = "Source Sans Pro";
        pointSize = 10;
      };
      windowTitle = {
        family = "Source Sans Pro";
        pointSize = 10;
      };
    };

    # Panel configuration
    panels = [
      {
        location = "top";
        height = 44;
        alignment = "center";
        hiding = "none";
        floating = false;

        widgets = [
          # Application launcher
          {
            kicker = {
              icon = "nix-snowflake";
            };
          }

          # Task manager
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:firefox.desktop"
                "applications:kitty.desktop"
                "applications:code.desktop"
                "applications:discord.desktop"
              ];
              appearance = {
                showTooltips = true;
                highlightWindows = true;
                indicateAudioStreams = true;
              };
            };
          }

          # Spacer
          "org.kde.plasma.panelspacer"

          # System tray
          {
            systemTray = {
              icons = {
                spacing = "small";
                scaleToFit = false;
              };
              items = {
                shown = [
                  "org.kde.plasma.battery"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.volume"
                  "org.kde.plasma.notifications"
                ];
                hidden = [
                  "org.kde.plasma.clipboard"
                ];
              };
            };
          }

          # Digital clock
          {
            digitalClock = {
              calendar = {
                firstDayOfWeek = "monday";
                showWeekNumbers = true;
              };
              time = {
                format = "24h";
                showSeconds = "always";
              };
              date = {
                enable = true;
                format = "isoDate";
                position = "belowTime";
              };
            };
          }
        ];
      }
    ];

    # Shortcuts configuration
    shortcuts = {
      # Custom shortcuts
      "org.kde.dolphin.desktop"."_launch" = "Meta+E";
      "org.kde.konsole.desktop"."_launch" = "Meta+Return";
      "firefox.desktop"."_launch" = "Meta+B";

      # KWin shortcuts
      "kwin"."Window Quick Tile Bottom" = "Meta+Down";
      "kwin"."Window Quick Tile Top" = "Meta+Up";
      "kwin"."Window Quick Tile Left" = "Meta+Left";
      "kwin"."Window Quick Tile Right" = "Meta+Right";
      "kwin"."Window Maximize" = "Meta+M";
      "kwin"."Window Minimize" = "Meta+N";
      "kwin"."Window Close" = "Meta+Q";

      # Virtual desktop switching
      "kwin"."Switch to Desktop 1" = "Meta+1";
      "kwin"."Switch to Desktop 2" = "Meta+2";
      "kwin"."Switch to Desktop 3" = "Meta+3";
      "kwin"."Switch to Desktop 4" = "Meta+4";

      # Overview
      "kwin"."Overview" = "Meta+Tab";
      "kwin"."Window Operations Menu" = "Meta+Space";

      # Screenshot
      "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Print";
      "org.kde.spectacle.desktop"."FullScreenScreenShot" = "Meta+Shift+S";

      # Audio
      "kmix"."increase_volume" = "Volume Up";
      "kmix"."decrease_volume" = "Volume Down";
      "kmix"."mute" = "Volume Mute";
    };

    # Window management
    window-rules = [
      {
        description = "Dolphin file manager";
        match = {
          window-class = {
            value = "dolphin";
            type = "substring";
          };
        };
        apply = {
          noborder = {
            value = false;
            apply = "initially";
          };
        };
      }
    ];

    # Desktop and window effects
    kwin = {
      titlebarButtons = {
        left = [
          "on-all-desktops"
          "keep-above-windows"
        ]; # Fixed: changed "keep-above-others" to "keep-above-windows"
        right = [
          "minimize"
          "maximize"
          "close"
        ];
      };

      effects = {
        translucency = {
          enable = true;
        };
        wobblyWindows = {
          enable = false;
        };
        cube = {
          enable = false;
        };
        desktopSwitching = {
          animation = "slide";
        };
        blur = {
          enable = true;
        };
      };

      virtualDesktops = {
        rows = 1;
        number = 4;
        names = [
          "Main"
          "Dev"
          "Web"
          "Media"
        ];
      };

      cornerBarrier = false;
      borderlessMaximizedWindows = false;
    };

    # Application settings
    configFile = {
      # Dolphin file manager
      "dolphinrc"."General"."BrowseThroughArchives" = true;
      "dolphinrc"."General"."ShowFullPath" = true;
      "dolphinrc"."IconsMode"."PreviewSize" = 64;

      # Kate text editor
      "katerc"."General"."Close After Last" = false;
      "katerc"."General"."Show Full Path in Title" = true;

      # Konsole terminal
      "konsolerc"."Desktop Entry"."DefaultProfile" = "kitty.profile";
      "konsolerc"."MainWindow"."MenuBar" = "Disabled";

      # KDE settings
      "kdeglobals"."General"."BrowserApplication" = "firefox.desktop";
      "kdeglobals"."General"."TerminalApplication" = "kitty";
      "kdeglobals"."General"."TerminalService" = "kitty.desktop";

      # Power management
      "powermanagementprofilesrc"."AC"."SuspendSession" = false;
      "powermanagementprofilesrc"."Battery"."SuspendSession" = false;
      "powermanagementprofilesrc"."LowBattery"."SuspendSession" = false;

      # Disable Baloo file indexing (optional - can be performance heavy)
      "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
    };
  };

  # Additional KDE packages that work well with Plasma Manager
  home.packages = with pkgs; [
    # KDE applications
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.spectacle # Screenshots
    kdePackages.ark # Archive manager
    kdePackages.okular # PDF viewer
    kdePackages.gwenview # Image viewer
    kdePackages.kcharselect # Character selector
    kdePackages.ksystemlog
    kdePackages.isoimagewriter
    kdiff3
    wayland-utils
    wl-clipboard
    hardinfo2
    kdePackages.partitionmanager
    kdePackages.kclock

    # Plasma widgets and extras
    kdePackages.plasma-browser-integration
    kdePackages.kdeconnect-kde # Phone integration
    kdePackages.filelight

    # Icon themes (optional)
    # papirus-icon-theme
    # tela-icon-theme
  ];
}
