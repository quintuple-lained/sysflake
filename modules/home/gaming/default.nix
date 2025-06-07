{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    libgdiplus
    (prismlauncher.override { 
      jdks = [
        jdk8 
        jdk17 
        temurin-bin-21];})

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
    ];
}