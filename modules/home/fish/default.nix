{ config
, pkgs
, lib
, ...
}:

{
  programs.fish = {
    enable = true;

    functions = {
      # Emacs vterm integration

      vterm_printf = ''
        if begin; [  -n "$TMUX" ]  ; and  string match -q -r "screen|tmux" "$TERM"; end
            # tell tmux to pass the escape sequences through
            printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
        else if string match -q -- "screen*" "$TERM"
            # GNU screen (screen, screen-256color, screen-256color-bce)
            printf "\eP\e]%s\007\e\\" "$argv"
        else
            printf "\e]%s\e\\" "$argv"
        end
      '';

      find_file = ''
        set -q argv[1]; or set argv[1] "."
        vterm_cmd find-file (realpath "$argv")
      '';

      say = ''
        vterm_cmd message "%s" "$argv"
      '';

      vterm_cmd = ''
        set -l vterm_elisp ()
        for arg in $argv
            set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
        end
        vterm_printf "51;E"(string join \'\' $vterm_elisp)
      '';

      vterm_prompt_end = ''
        vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
      '';

      # Override clear for vterm
      clear = ''
        if [ "$INSIDE_EMACS" = 'vterm' ]
          vterm_printf "51;Evterm-clear-scrollback"
          tput clear
        else
          command clear
        end
      '';

      # Your custom git functions
      gaa = {
        description = "alias gaa=git add --all";
        wraps = "git add --all";
        body = "git add --all $argv";
      };

      gcm = {
        description = "alias gcm=git commit -m";
        wraps = "git commit -m";
        body = "git commit -m $argv";
      };

      gf = {
        description = "alias gf=git fetch";
        wraps = "git fetch";
        body = "git fetch $argv";
      };

      gpl = {
        description = "alias gpl=git pull";
        wraps = "git pull";
        body = "git pull $argv";
      };

      gps = {
        description = "alias gps=git push";
        wraps = "git push";
        body = "git push $argv";
      };

      gis = {
        description = "alias gis = git status";
        wraps = "git status";
        body = "git status $argv";
      };

      gip = {
        description = "alias gip = git pull";
        wraps = "git pull";
        body = "git pull $argv";
      };

      gif = {
        description = "alias gif = git fetch";
        wraps = "git fetch";
        body = "git fetch $argv";
      };

      ranger = {
        description = "alias ranger = yazi";
        wraps = "yazi";
        body = "yazi $argv";
      };

      doas = {
        description = "alias doas = sudo";
        wraps = "sudo";
        body = "sudo $argv";
      };

      mt = ''
        for item in $argv
            if string match -q '*/' $item
                # It's a directory (ends with /)
                mkdir -p $item
            else
                # It's a file - ensure parent directory exists then touch the file
                set -l dir (dirname $item)
                if test "$dir" != "."
                    mkdir -p $dir
                end
                touch $item
            end
        end
      '';

      vim = {
        description = "alias vim=nvim";
        wraps = "nvim";
        body = "nvim $argv";
      };
    };
    shellAliases = {
      ls = "eza --time-style=long-iso --group-directories-first --icons --color=always";
      ll = "eza --time-style=long-iso --group-directories-first --icons -l --color=always $argv";
    };

    shellInit = ''
      # Go development setup
      set -gx GOPATH $HOME/go
      set -gx PATH $PATH $GOPATH/bin

      set -gx PATH $PATH $HOME/.cargo/bin

      # force override ls and ll functions
    '';

    plugins = [
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "pure-fish";
          repo = "pure";
          rev = "efaf3e70d553c87e58f7e0239669cddc7eeec357";
          hash = "sha256-Oxacuyx4MTE08B8H89F0vJXpgdN9JsQFdGBeCGGm97M=";
        };
      }

      # FZF integration
      #    {
      #      name = "fzf.fish";
      #      src = pkgs.fetchFromGitHub {
      #        owner = "PatrickF1";
      #        repo = "fzf.fish";
      #        rev = "v10.3";
      #        sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
      #      };
      #    }
    ];
  };

  # programs.fzf = {
  #  enable = true;
  #  enableFishIntegration = true;
  # };

  home.sessionVariables = {
    pure_begin_prompt_with_current_directory = "true";
    pure_check_for_new_release = "false";
    pure_enable_single_line_prompt = "true";
    pure_show_system_time = "true";
    pure_show_subsecond_command_duration = "true";
    pure_enable_nixdevshell = "true";
    pure_reverse_prompt_symbol_in_vimode = "true";
    pure_separate_prompt_on_error = "false";

    # Color configuration
    pure_color_primary = "blue";
    pure_color_success = "magenta";
    pure_color_warning = "yellow";
    pure_color_danger = "red";
    pure_color_info = "cyan";
    pure_color_mute = "brblack";
    pure_color_normal = "normal";

    # Symbol configuration
    pure_symbol_prompt = "❯";
    pure_symbol_git_dirty = "*";
    pure_symbol_prefix_root_prompt = "#";
  };

  home.packages = with pkgs; [
    eza
    yazi
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
}
