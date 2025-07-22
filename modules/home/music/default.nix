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
      music-packages = with pkgs; [
        ncmpcpp
        mpc
        ashuffle
      ];
    in
    music-packages;
}
