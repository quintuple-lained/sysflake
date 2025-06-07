{
  pkgs,
  ...
}:
{
  game-stuff = with pkgs; [
    libgdiplus
    (steam.override {
      extraPkgs =
      pkgs: with pkgs; [
      gtk3
      zlib
      dbus
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