# modules/home/neovim/default.nix
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

    # Global options
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
      colorcolumn = "80";
    };

    # Global variables
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Color scheme - using global catppuccin theme
    # colorschemes.catppuccin is handled by the global catppuccin module

    # Plugins
    plugins = {
      # Treesitter
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          additional_vim_regex_highlighting = false;
        };
      };

      # LSP
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          nil_ls = {
            enable = true;
            settings = {
              nil = {
                formatting = {
                  command = [ "nixfmt" ];
                };
              };
            };
          };
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          gopls.enable = true;
          pyright.enable = true;
          marksman.enable = true;
          lua_ls = {
            enable = true;
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT";
                };
                diagnostics = {
                  globals = [ "vim" ];
                };
                workspace = {
                  library = "vim.api.nvim_get_runtime_file('', true)";
                };
                telemetry = {
                  enable = false;
                };
              };
            };
          };
        };
      };

      # Auto-completion
      cmp = {
        enable = true;
        settings = {
          snippet = {
            expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          };
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif require('luasnip').expand_or_jumpable() then
                  require('luasnip').expand_or_jump()
                else
                  fallback()
                end
              end, { 'i', 's' })
            '';
            "<S-Tab>" = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif require('luasnip').jumpable(-1) then
                  require('luasnip').jump(-1)      
                else
                  fallback()
                end
              end, { 'i', 's' })
            '';
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
        };
      };

      # Snippet engine
      luasnip.enable = true;

      # File explorer
      nvim-tree = {
        enable = true;
        sortBy = "case_sensitive";
        view.width = 30;
        renderer.groupEmpty = true;
        filters.dotfiles = true;
      };

      # Fuzzy finder
      telescope = {
        enable = true;
        settings = {
          defaults = {
            file_ignore_patterns = [
              "node_modules"
              ".git"
              "target"
            ];
          };
        };
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };
      };

      # Status line
      lualine = {
        enable = true;
        settings = {
          options = {
            component_separators = {
              left = "";
              right = "";
            };
            section_separators = {
              left = "";
              right = "";
            };
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [
              "branch"
              "diff"
              "diagnostics"
            ];
            lualine_c = [ "filename" ];
            lualine_x = [
              "encoding"
              "fileformat"
              "filetype"
            ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
        };
      };

      # Git integration
      gitsigns.enable = true;

      # Auto pairs
      nvim-autopairs.enable = true;

      # Comment toggling
      comment.enable = true;

      # Which key for keybinding help
      which-key.enable = true;

      # Web dev icons
      web-devicons.enable = true;
    };

    # Extra packages (formatters, etc.)
    extraPackages = with pkgs; [
      # Formatters & tools
      nixfmt-rfc-style
      rustfmt
      gofumpt
      black
      prettier

      # General tools
      ripgrep
      fd
      tree-sitter
    ];

    # Key mappings
    keymaps = [
      # File operations
      {
        mode = "n";
        key = "<leader>w";
        action = ":w<CR>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>q";
        action = ":q<CR>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>x";
        action = ":x<CR>";
        options = {
          silent = true;
        };
      }

      # File explorer
      {
        mode = "n";
        key = "<leader>e";
        action = ":NvimTreeToggle<CR>";
        options = {
          silent = true;
        };
      }

      # Window navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
      }

      # Buffer navigation
      {
        mode = "n";
        key = "<leader>bn";
        action = ":bnext<CR>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = ":bprev<CR>";
        options = {
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = ":bdelete<CR>";
        options = {
          silent = true;
        };
      }

      # Clear search highlighting
      {
        mode = "n";
        key = "<leader>h";
        action = ":nohlsearch<CR>";
        options = {
          silent = true;
        };
      }

      # Move lines up/down in visual mode
      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
      }

      # LSP workspace folder list
      {
        mode = "n";
        key = "<space>wl";
        action = "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>";
      }
    ];

    # Auto-commands
    autoCmd = [
      {
        event = [ "BufWritePre" ];
        pattern = [
          "*.nix"
          "*.lua"
          "*.rs"
          "*.go"
          "*.py"
          "*.md"
          "*.markdown"
          "*.dot"
          "*.gv"
        ];
        callback = {
          __raw = ''
            function()
              vim.lsp.buf.format({ async = false })
            end
          '';
        };
      }
    ];
  };
}
