{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Import the general config as base
  imports = [ ./default.nix ];

  programs.nixvim = {
    # Development-specific plugins
    plugins = {
      # LSP configuration
      lsp = {
        enable = true;
        servers = {
          # Nix
          nixd.enable = true;

          gopls.enable = true; # Go
          pyright.enable = true; # Python
          lua_ls.enable = true; # Lua
          marksman.enable = true; # Markdown
          taplo.enable = true; # TOML
        };
      };

      # Rust development
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

      # Code formatting
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            rust = [ "rustfmt" ];
          };
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
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

    # Development-specific extra plugins
    extraPlugins = with pkgs.vimPlugins; [
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          name = "hex-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "RaafatTurki";
            repo = "hex.nvim";
            rev = "master";
            sha256 = "sha256-m/B4y6GYGcOFPSoL2Z7Y+y+wP+sws7NHwfIilbptCPI=";
          };
        };
        config = ''
          lua << EOF
          require('hex').setup()
          EOF
        '';
      }
    ];

    # Development packages
    extraPackages = with pkgs; [
      # Rust toolchain
      cargo
      rustc
      rustfmt
      rust-analyzer
      clippy

      # Nix formatter
      nixfmt-rfc-style

      # Hex editor
      xxd
    ];

    # Development key mappings
    keymaps = [
      # Manual formatting
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua require('conform').format()<cr>";
        options.desc = "Format buffer";
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

      # Hex mappings
      {
        mode = "n";
        key = "<leader>hx";
        action = "<cmd>HexToggle<cr>";
        options.desc = "Toggle hex mode";
      }
      {
        mode = "n";
        key = "<leader>ha";
        action = "<cmd>HexAssemble<cr>";
        options.desc = "Assemble Hex";
      }
      {
        mode = "n";
        key = "<leader>hd";
        action = "<cmd>HexDump<cr>";
        options.desc = "Hex dump";
      }
    ];
  };
}
