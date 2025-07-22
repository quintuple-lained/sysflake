{ config
, pkgs
, lib
, ...
}:

{
  # Import the general config as base
  imports = [ ./default.nix ];

  programs.nixvim = {
    # File type detection for Typst files
    filetype = {
      extension = {
        typ = "typst";
      };
    };

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

          # Typst language server
          tinymist = {
            enable = true;
            settings = {
              exportPdf = "onType";
              formatterMode = "typstyle";
            };
          };
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
            typst = [ "typstyle" ];
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
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          name = "typst-preview-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "chomosuke";
            repo = "typst-preview.nvim";
            rev = "master";
            sha256 = "sha256-BGNgGpg6ixvQ7bZl1pFRi3B1lqKDZqI4Ix3gFQVFxXg=";
          };
        };
        config = ''
          lua << EOF
          require('typst-preview').setup({})
          EOF
        '';
      }
    ];

    # Custom configuration for Typst
    extraConfigLua = ''
      -- Typst-specific configuration
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
          vim.bo.commentstring = "// %s"
        end,
      })

      -- Function to pin main file for multi-file projects
      local function pin_main_file()
        vim.lsp.buf.execute_command({
          command = 'tinymist.pinMain',
          arguments = { vim.api.nvim_buf_get_name(0) }
        })
      end

      -- Function to unpin main file
      local function unpin_main_file()
        vim.lsp.buf.execute_command({
          command = 'tinymist.pinMain',
          arguments = { vim.v.null }
        })
      end

      -- Create user commands for pinning
      vim.api.nvim_create_user_command('TypstPinMain', pin_main_file, {})
      vim.api.nvim_create_user_command('TypstUnpinMain', unpin_main_file, {})

      -- PDF opener command
      vim.api.nvim_create_user_command('TypstOpenPdf', function()
        local filepath = vim.api.nvim_buf_get_name(0)
        if filepath:match("%.typ$") then
          local pdf_path = filepath:gsub("%.typ$", ".pdf")
          vim.system({ "xdg-open", pdf_path })
        end
      end, {})
    '';

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

      # Typst tools
      tinymist
      typst
      typstyle
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

      # Typst-specific mappings
      {
        mode = "n";
        key = "<leader>tp";
        action = "<cmd>TypstPinMain<cr>";
        options.desc = "Pin main Typst file";
      }
      {
        mode = "n";
        key = "<leader>tu";
        action = "<cmd>TypstUnpinMain<cr>";
        options.desc = "Unpin main Typst file";
      }
      {
        mode = "n";
        key = "<leader>to";
        action = "<cmd>TypstOpenPdf<cr>";
        options.desc = "Open generated PDF";
      }
      {
        mode = "n";
        key = "<leader>tv";
        action = "<cmd>TypstPreview<cr>";
        options.desc = "Toggle Typst preview";
      }
    ];
  };
}
