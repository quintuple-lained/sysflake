{ pkgs
, ...
}:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-git;
    extraPackages =
      epkgs: with epkgs; [
        use-package
        straight
        base16-theme
        dashboard
        all-the-icons

        ace-jump-mode
        smartparens
        rainbow-delimiters
        projectile
        ranger
        magit
        git-gutter
        git-gutter-fringe
        lsp-ui
        rustic
        flycheck
        eglot
        markdown-mode
        yaml-mode
        json-mode
        toml-mode
        org-roam
        vterm
        w3m
        vdiff
        latex-preview-pane
      ];
  };

  home.file = {
    ".emacs.d/init.el".source = ./config/init.el;
    ".emacs.d/basics.el".source = ./config/basics.el;
    ".emacs.d/modules/packages.el".source = ./config/packages.el;
    ".emacs.d/modules/org.el".source = ./config/org.el;
    ".emacs-autosaves/.keep".text = "";
    ".emacs-doc-backups/.keep".text = "";

    ".emacs.d/assets/nixos-black.png".source = ./assets/nixos-logomark-black-flat-minimal.png;
    ".emacs.d/assets/nixos-white.png".source = ./assets/nixos-logomark-white-flat-minimal.png;
    ".emacs.d/assets/nixos-default.png".source = ./assets/nixos-logomark-default-gradient-minimal.png;
    ".emacs.d/assets/nixos-queer.png".source = ./assets/nixos-logomark-rainbow-gradient-minimal.png;
  };

  home.packages = with pkgs; [
    cmake
    gnumake
    gcc
    pkg-config
    libtool
    nerd-fonts.symbols-only
    texlive.combined.scheme-basic
    rust-analyzer
    rustfmt
    clippy
    git
    w3m
    fish
  ];
}
