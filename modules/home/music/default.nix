{ pkgs
, ...
}:
{
  services.mpd = {
    enable = true;
    musicDirectory = "~/Music";
    extraConfig = ''
      audio_output {
        type "pulse"
        name "pulse audio"
        }
    '';
  };

  home.packages =
    let
      music-help = pkgs.writeShellScriptBin "music-help" ''
        echo "🎵 Music Commands Quick Reference"
        echo "================================"
        echo ""
        echo "MPC (Music Player Control):"
        echo "  mpc play           - Start playing"
        echo "  mpc pause          - Pause playback"
        echo "  mpc stop           - Stop playback"
        echo "  mpc next           - Next track"
        echo "  mpc prev           - Previous track"
        echo "  mpc random on/off  - Toggle shuffle"
        echo "  mpc repeat on/off  - Toggle repeat"
        echo "  mpc volume 80      - Set volume (0-100)"
        echo "  mpc status         - Show current track"
        echo "  mpc add <path>     - Add song/folder to playlist"
        echo "  mpc clear          - Clear playlist"
        echo "  mpc ls             - List music library"
        echo ""
        echo "ASHUFFLE (Auto-shuffle):"
        echo "  ashuffle           - Continuously add random songs"
        echo "  ashuffle -n 10     - Add 10 random songs then stop"
        echo "  ashuffle --only genre Rock  - Only shuffle rock music"
        echo ""
        echo "Quick start: mpc add / && mpc play && ashuffle"
      '';

      music-packages = with pkgs; [
        mpc
        ashuffle
        music-help
        mmtc
      ];
    in
    music-packages;
}
