{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Basic options
    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      wrap = false;
      ignorecase = true;
      smartcase = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      splitright = true;
      splitbelow = true;
      mouse = "a";
      clipboard = "unnamedplus";
    };

    # Global variables
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Essential plugins
    plugins = {
      # Treesitter for syntax highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      # LSP configuration
      lsp = {
        enable = true;
        servers = {
          # Rust is handled by rustaceanvim, not here
          
          # Nix
          nixd.enable = true;
          
          # Other common languages
          gopls.enable = true;        # Go
          pyright.enable = true;      # Python
          lua_ls.enable = true;       # Lua
          marksman.enable = true;     # Markdown
          taplo.enable = true;        # TOML
        };
      };

      # Rust support via rustaceanvim
      rustaceanvim = {
        enable = true;
        settings = {
          server = {
            default_settings = {
              "rust-analyzer" = {
                cargo.allFeatures = true;
                checkOnSave = true;
              };
            };
          };
        };
      };

      # Completion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            # Use different keys to avoid conflicts, or remove these if you prefer the existing mappings
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
        };
      };

      # Auto pairs
      nvim-autopairs.enable = true;

      # Comment toggling
      comment.enable = true;

      # Indentation guides
      indent-blankline = {
        enable = true;
        settings = {
          indent = {
            char = "│";
          };
          scope = {
            enabled = false;
          };
        };
      };

      # Git integration
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "│";
            change.text = "│";
            delete.text = "_";
            topdelete.text = "‾";
            changedelete.text = "~";
            untracked.text = "┆";
          };
          current_line_blame = false;
        };
      };
    };

    # Essential packages
    extraPackages = with pkgs; [
      # Rust toolchain
      cargo
      rustc
      rustfmt
      rust-analyzer
      clippy

      # Basic tools
      ripgrep
      fd
    ];

    # Basic key mappings
    keymaps = [
      # File operations
      {
        mode = "n";
        key = "<leader>w";
        action = ":w<CR>";
        options.desc = "Save file";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = ":q<CR>";
        options.desc = "Quit";
      }

      # LSP mappings
      {
        mode = "n";
        key = "gd";
        action = "<cmd>lua vim.lsp.buf.definition()<cr>";
        options.desc = "Go to definition";
      }
      {
        mode = "n";
        key = "gr";
        action = "<cmd>lua vim.lsp.buf.references()<cr>";
        options.desc = "Show references";
      }
      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<cr>";
        options.desc = "Show hover information";
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
        options.desc = "Code action";
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = "<cmd>lua vim.lsp.buf.rename()<cr>";
        options.desc = "Rename";
      }

      # Git mappings
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Gitsigns blame_line<cr>";
        options.desc = "Git blame line";
      }
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Gitsigns preview_hunk<cr>";
        options.desc = "Preview git hunk";
      }
      {
        mode = "n";
        key = "<leader>gr";
        action = "<cmd>Gitsigns reset_hunk<cr>";
        options.desc = "Reset git hunk";
      }

      # Comment toggling (handled by comment.nvim automatically with gcc and gc)
    ];
  };
}
