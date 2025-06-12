{
  pkgs,
  inputs,
  system,
  ...
}:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./fish
    ./nixvim
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
    };
    ssh-agent.enable = true;
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    gpg.enable = true;
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
        nixfmt-rfc-style
        direnv
        fd
        tree
        file
        git
        ripgrep
        nil
        onefetch
        git-filter-repo
        age

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
      ];
    in
    development ++ fonts ++ misc-packages;
}
