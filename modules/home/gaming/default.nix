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
    jdk8
    jdk17
    temurin-bin-21
    graalvm-ce
    graalvm-oracle
  ];
}
