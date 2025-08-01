{ config
, pkgs
, lib
, ...
}:

{
  programs.fish = {
    enable = true;

    # i am unable to make this work, i dont use emacs that much anyways, so fuck it
    functions = {
      # Emacs vterm integration

      # vterm_printf = ''
      #   if begin; [  -n "$TMUX" ]  ; and  string match -q -r "screen|tmux" "$TERM"; end
      #       # tell tmux to pass the escape sequences through
      #       printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
      #   else if string match -q -- "screen*" "$TERM"
      #       # GNU screen (screen, screen-256color, screen-256color-bce)
      #       printf "\eP\e]%s\007\e\\" "$argv"
      #   else
      #       printf "\e]%s\e\\" "$argv"
      #   end
      # '';

      # find_file = ''
      #   set -q argv[1]; or set argv[1] "."
      #   vterm_cmd find-file (realpath "$argv")
      # '';

      # say = ''
      #   vterm_cmd message "%s" "$argv"
      # '';

      # vterm_cmd = ''
      #   set -l vterm_elisp ()
      #   for arg in $argv
      #       set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
      #   end
      #   vterm_printf "51;E"(string join '' $vterm_elisp)
      # '';

      # vterm_prompt_end = ''
      #   vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
      # '';

      # # Override clear for vterm
      # clear = ''
      #   if [ "$INSIDE_EMACS" = 'vterm' ]
      #     vterm_printf "51;Evterm-clear-scrollback"
      #     tput clear
      #   else
      #     command clear
      #   end
      # '';

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

      ls = {
        description = "alias ls = eza";
        wraps = "eza --time-style=long-iso --group-directories-first --icons -l --color=always";
        body = "eza --time-style=long-iso --group-directories-first --icons -l --color=always $argv";
      };

      doas = {
        description = "alias doas = sudo";
        wraps = "sudo";
        body = "sudo $argv";
      };

      # Utility functions
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

      num = "ls -1 | wc -l";

      vim = {
        description = "alias vim=nvim";
        wraps = "nvim";
        body = "nvim $argv";
      };
    };

    # Shell initialization
    shellInit = ''
      # Go development setup
      set -gx GOPATH $HOME/go
      set -gx PATH $PATH $GOPATH/bin

      set -gx PATH $PATH $HOME/.cargo/bin
    '';

    # Fisher plugins converted to Home Manager
    plugins = [
      # Pure prompt theme
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

  # FZF configuration (integrated with Home Manager)
  # programs.fzf = {
  #  enable = true;
  #  enableFishIntegration = true;
  # };

  # Pure prompt configuration using environment variables
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

  # Copy any complex functions as separate files if needed
  home.file = {
    # ".config/fish/functions/complex_function.fish".source = ./functions/complex_function.fish;
  };
  programs.bash = {
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
}
