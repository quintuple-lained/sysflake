{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mpd;
in
{
  options.services.mpd = {
    enable = mkEnableOption "MPD (Music Player Daemon) user service";
    
    musicDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Music";
      description = "Directory where music files are stored";
    };
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional MPD configuration";
    };
    
    network = {
      listenAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Address MPD should listen on";
      };
      
      port = mkOption {
        type = types.port;
        default = 6600;
        description = "Port MPD should listen on";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install MPD and ncmpcpp
    home.packages = with pkgs; [
      mpd
      ncmpcpp
      mpc-cli  # Command line client for MPD
    ];

    # Create necessary directories
    home.file.".config/mpd/.keep".text = "";
    
    # MPD configuration
    home.file.".config/mpd/mpd.conf".text = ''
      # Basic MPD configuration
      music_directory     "${cfg.musicDirectory}"
      playlist_directory  "${config.home.homeDirectory}/.config/mpd/playlists"
      db_file             "${config.home.homeDirectory}/.config/mpd/database"
      log_file            "${config.home.homeDirectory}/.config/mpd/log"
      pid_file            "${config.home.homeDirectory}/.config/mpd/pid"
      state_file          "${config.home.homeDirectory}/.config/mpd/state"
      sticker_file        "${config.home.homeDirectory}/.config/mpd/sticker.sql"
      
      # Network settings
      bind_to_address     "${cfg.network.listenAddress}"
      port                "${toString cfg.network.port}"
      
      # Ensure MPD starts but doesn't auto-play
      restore_paused      "yes"
      auto_update         "yes"
      
      # Audio output configuration
      audio_output {
          type    "pulse"
          name    "PulseAudio Output"
      }
      
      # Allow volume control
      mixer_type          "software"
      
      # File permissions
      user                "${config.home.username}"
      
      # Additional configuration
      ${cfg.extraConfig}
    '';

    # Basic ncmpcpp configuration
    home.file.".config/ncmpcpp/config".text = ''
      # Connection settings
      mpd_host = "${cfg.network.listenAddress}"
      mpd_port = "${toString cfg.network.port}"
      mpd_music_dir = "${cfg.musicDirectory}"
      
      # Interface settings
      user_interface = "alternative"
      alternative_header_first_line_format = "$b$1$aqqu$/a$9 {%t}|{%f} $1$atqq$/a$9$/b"
      alternative_header_second_line_format = "{{$4$b%a$/b$9}{ - $7%b$9}{ ($4%y$9)}}|{%D}"
      
      # Playlist settings
      playlist_display_mode = "columns"
      browser_display_mode = "columns"
      search_engine_display_mode = "columns"
      
      # Progress bar
      progressbar_look = "━━━"
      progressbar_boldness = "yes"
      
      # Colors
      colors_enabled = "yes"
      main_window_color = "default"
      header_window_color = "default"
      volume_color = "default"
      state_line_color = "default"
      state_flags_color = "default"
      progressbar_color = "black"
      progressbar_elapsed_color = "green"
      statusbar_color = "default"
      alternative_ui_separator_color = "black"
      active_column_color = "red"
      window_border_color = "green"
      active_window_border = "red"
      
      # Misc
      display_bitrate = "yes"
      autocenter_mode = "yes"
      centered_cursor = "yes"
      cyclic_scrolling = "yes"
      mouse_support = "yes"
      mouse_list_scroll_whole_page = "yes"
      lines_scrolled = "2"
      
      # Visualizer (requires ncmpcpp to be built with visualizer support)
      visualizer_fifo_path = "/tmp/mpd.fifo"
      visualizer_output_name = "Visualizer"
      visualizer_in_stereo = "yes"
      visualizer_sync_interval = "30"
      visualizer_type = "spectrum"
      visualizer_look = "●▮"
      visualizer_color = "blue, cyan, green, yellow, magenta, red"
    '';

    # Create playlists directory
    home.file.".config/mpd/playlists/.keep".text = "";

    # User service definition
    systemd.user.services.mpd = {
      Unit = {
        Description = "Music Player Daemon";
        After = [ "network.target" "sound.target" ];
      };
      
      Service = {
        Type = "notify";
        ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon ${config.home.homeDirectory}/.config/mpd/mpd.conf";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        KillMode = "mixed";
        Restart = "on-failure";
        RestartSec = 1;
        
        # Security settings
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = false;
        PrivateTmp = true;
        PrivateDevices = false;  # Needed for audio devices
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        
        # Allow access to audio and music directories
        ReadWritePaths = [ 
          "${config.home.homeDirectory}/.config/mpd"
          "${cfg.musicDirectory}"
        ];
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # Enable and start the service on login
    systemd.user.services.mpd.enable = true;
    
    # Start MPD automatically when user logs in
    systemd.user.targets.default.wants = [ "mpd.service" ];
  };
}