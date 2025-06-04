{
    pkgs,
    ...
}:
{
    boot = {
        loader.timeout = 5;
        initrd.compressor = "zstd";

        consoleLogLevel = 0;
        kernelParams = [
            "quiet"
            "systemd.show_status=auto"
        ];
    };
    i18n.defaultLocale = "en_US.UTF-8";
    
    time.timeZone = "Europe/Berlin";

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };

    system.stateVersion = "25.05";
    system.autoUpgrade.enable = false;

    nix = {
        settings = {
            max-jobs = "auto";
            cores = 0;

            auto-optimise-store = true;
        };

        gc = { 
            automatic = true;
            dates = "weekly";
            options = ''
                --delete-older-than 56d
            '';
        };

        extraOptions = ''
            experimental-features = nix-command flakes
        '';
    };

    users.users.zoe = {
        shell = pkgs.bash;
        isNormalUser = true;
        autoSubUidGidRange = true;
        home = "/home/zoe";
        extraGroups = [
            "wheel"
            "networkmanager"
            "video"
            "audio"
        ];

        initialPassword = "ZoeZoe";
    };

    programs.nix-index-database.comma.enable = true;

    services.displayManager.sddm = {
        enable = true;

        wayland.enable = true;
    };

    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
            enable = true;
            #userServices = true;
        };
    };

    catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "pink";
    };

    programs.fish.enable = true;

    programs.appimage = {
        enable = true;
        binfmt = true;
    };

    # just the basics
    environment.systemPackages = with pkgs; [
    binutils
    coreutils
    git
    curl
    wget
    firefox
    neovim
  ];

  # doas my beloved
  security = {
    sudo.enable = false;
    doas.enable = true;
    doas.extraRules = [{
        users = ["zoe"];
        keepEnv = true;
        persist = true;
    }];
  };
}