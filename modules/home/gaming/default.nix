{ pkgs
, ...
}:
{
  home.packages = with pkgs; [
    libgdiplus
    gamescope
    prismlauncher

    (steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          gtk3
          zlib
          dbus
          vulkan-tools
          freetype
          glib
          atk
          cairo
          gdk-pixbuf
          pango
          python3
          fontconfig
          xorg.libxcb
          libpng
        ];
    })
    steam-run
    steam-run-native
    # Lutris with Wine support
    (lutris.override {
      extraPkgs =
        pkgs: with pkgs; [
          # Wine dependencies
          winetricks

          # Additional libraries for better compatibility
          gtk3
          gtk4
          glib
          cairo
          atk
          pango
          gdk-pixbuf
          harfbuzz
          fontconfig
          freetype
          dbus
          zlib
          openssl
          vulkan-tools
          vulkan-loader
          mesa

          # Audio support
          alsa-lib
          pulseaudio

          # 32-bit libraries for Wine
          pkgsi686Linux.gtk3
          pkgsi686Linux.glib
          pkgsi686Linux.cairo
          pkgsi686Linux.atk
          pkgsi686Linux.pango
          pkgsi686Linux.gdk-pixbuf
          pkgsi686Linux.fontconfig
          pkgsi686Linux.freetype
          pkgsi686Linux.zlib
          pkgsi686Linux.openssl
          pkgsi686Linux.alsa-lib
          pkgsi686Linux.mesa

          # X11 libraries
          xorg.libX11
          xorg.libXcursor
          xorg.libXrandr
          xorg.libXi
          xorg.libXext
          xorg.libXfixes
          xorg.libXrender
          xorg.libXScrnSaver
          xorg.libXxf86vm
          xorg.libxcb

          # 32-bit X11 libraries
          pkgsi686Linux.xorg.libX11
          pkgsi686Linux.xorg.libXcursor
          pkgsi686Linux.xorg.libXrandr
          pkgsi686Linux.xorg.libXi
          pkgsi686Linux.xorg.libXext
          pkgsi686Linux.xorg.libXfixes
          pkgsi686Linux.xorg.libXrender
          pkgsi686Linux.xorg.libXScrnSaver
          pkgsi686Linux.xorg.libXxf86vm
          pkgsi686Linux.xorg.libxcb

          # Gaming-specific libraries
          libpng
          libjpeg
          libtiff
          giflib
          libxml2
          mpg123
          openal
          libpulseaudio
          libGLU
          libGL

          # 32-bit gaming libraries
          pkgsi686Linux.libpng
          pkgsi686Linux.libjpeg
          pkgsi686Linux.libtiff
          pkgsi686Linux.giflib
          pkgsi686Linux.libxml2
          pkgsi686Linux.mpg123
          pkgsi686Linux.openal
          pkgsi686Linux.libpulseaudio
          pkgsi686Linux.libGLU
          pkgsi686Linux.libGL
        ];
      extraLibraries =
        pkgs: with pkgs; [
          pipewire
          xdg-utils
        ];
    })
    jdk8
    jdk17
    temurin-bin-21
    graalvm-ce
    graalvm-oracle
  ];
}
