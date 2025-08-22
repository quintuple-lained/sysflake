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
    ".emacs.d/basic.el".source = ./config/basics.el;
    ".emacs.d/packages.el".source = ./config/packages.el;
    ".emacs.d/org.el".source = ./config/org.el;
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
