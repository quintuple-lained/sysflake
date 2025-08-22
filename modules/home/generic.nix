{ pkgs
, inputs
, system
, ...
}:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./fish
  ];

  programs.home-manager.enable = true;

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  services = {
    lorri.enable = true;
    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gtk2;
      defaultCacheTtl = 1800;
      defaultCacheTtlSsh = 1800;
    };
    ssh-agent.enable = true;
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    gpg = {
      enable = true;
      settings = {
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        fixed-list-mode = true;
        no-comments = true;
        no-emit-version = true;
        keyid-format = "0xlong";
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        with-fingerprint = true;
        require-cross-certification = true;
        no-symkey-cache = true;
        use-agent = true;

      };
    };
    nix-index.enable = true;
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages =
    let
      development = with pkgs; [
        fd
        bat
        dua
        du-dust
        yazi
        fselect
        ripgrep-all
        eza
        tree
        file
        git
        ripgrep
        nil
        onefetch
        git-filter-repo
        age
        sops
        pkg-config
        nix-prefetch-git
        nix-prefetch-github
        detox
        ncdu
        uutils-coreutils-noprefix
        efibootmgr
        unrar-free
        killall
      ];

      fonts = with pkgs; [
        source-code-pro
        source-sans-pro
        noto-fonts-cjk-sans
        noto-fonts-emoji
        font-awesome
      ];

      misc-packages = with pkgs; [
        bottom
        hyfetch
        fastfetch
        nix-index
        nix-search-cli
        openvpn
        wireguard-tools
        htop
        nh
      ];
    in
    development ++ fonts ++ misc-packages;
}
