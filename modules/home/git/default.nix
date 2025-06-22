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
      colorcolumn = "100"; # Rust standard line length
      conceallevel = 2; # For better symbol rendering
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldenable = false; # Start with folds open
      splitright = true;
      splitbelow = true;
      mouse = "a";
      clipboard = "unnamedplus";
    };

    # Global variables
    globals = {
      mapleader = " ";
      maplocalleader = " ";
      # Rust-specific globals
      rustfmt_autosave = 1;
      rustfmt_emit_files = 1;
      rustfmt_fail_silently = 0;
    };

    # Plugins
    plugins = {
      # Treesitter with enhanced Rust support
      treesitter = {
        enable = true;
        settings = {
          highlight = {
            enable = true;
            additional_vim_regex_highlighting = false;
          };
          indent.enable = true;
          incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<C-space>";
              node_incremental = "<C-space>";
              scope_incremental = false;
              node_decremental = "<bs>";
            };
          };
          textobjects = {
            select = {
              enable = true;
              lookahead = true;
              keymaps = {
                "af" = "@function.outer";
                "if" = "@function.inner";
                "ac" = "@class.outer";
                "ic" = "@class.inner";
                "aa" = "@parameter.outer";
                "ia" = "@parameter.inner";
              };
            };
            move = {
              enable = true;
              set_jumps = true;
              goto_next_start = {
                "]m" = "@function.outer";
                "]]" = "@class.outer";
              };
              goto_next_end = {
                "]M" = "@function.outer";
                "][" = "@class.outer";
              };
              goto_previous_start = {
                "[m" = "@function.outer";
                "[[" = "@class.outer";
              };
              goto_previous_end = {
                "[M" = "@function.outer";
                "[]" = "@class.outer";
              };
            };
          };
        };
      };

      # Enhanced LSP configuration (without rust_analyzer)
      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          # Rust analyzer is handled by rustaceanvim, so it's disabled here
          # rust_analyzer.enable = false;  # Explicitly disabled

          # Other LSP servers
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
          gopls.enable = true;
          pyright.enable = true;
          marksman.enable = true;
          taplo.enable = true; # TOML support for Cargo.toml
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

      # Enhanced completion
      cmp = {
        enable = true;
        settings = {
          snippet = {
            expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          };
          window = {
            completion = {
              winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
              col_offset = -3;
              side_padding = 0;
            };
          };
          formatting = {
            fields = [
              "kind"
              "abbr"
              "menu"
            ];
            format = ''
              function(entry, vim_item)
                local kind_icons = {
                  Text = "󰉿",
                  Method = "󰆧",
                  Function = "󰊕",
                  Constructor = "",
                  Field = "󰜢",
                  Variable = "󰀫",
                  Class = "󰠱",
                  Interface = "",
                  Module = "",
                  Property = "󰜢",
                  Unit = "󰑭",
                  Value = "󰎠",
                  Enum = "",
                  Keyword = "󰌋",
                  Snippet = "",
                  Color = "󰏘",
                  File = "󰈙",
                  Reference = "󰈇",
                  Folder = "󰉋",
                  EnumMember = "",
                  Constant = "󰏿",
                  Struct = "󰙅",
                  Event = "",
                  Operator = "󰆕",
                  TypeParameter = "",
                }
                vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
                vim_item.menu = ({
                  nvim_lsp = "[LSP]",
                  luasnip = "[Snippet]",
                  buffer = "[Buffer]",
                  path = "[Path]",
                  crates = "[Crates]",
                })[entry.source.name]
                return vim_item
              end
            '';
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
            {
              name = "nvim_lsp";
              priority = 1000;
            }
            {
              name = "luasnip";
              priority = 750;
            }
            {
              name = "crates";
              priority = 700;
            }
            {
              name = "buffer";
              priority = 500;
            }
            {
              name = "path";
              priority = 250;
            }
          ];
        };
      };

      # Rust-specific plugins
      crates = {
        enable = true;
      };

      # Enhanced rustaceanvim configuration
      rustaceanvim = {
        enable = true;
        settings = {
          tools = {
            hover_actions = {
              auto_focus = true;
            };
            inlay_hints = {
              show_parameter_hints = false;
              parameter_hints_prefix = "<- ";
              other_hints_prefix = "=> ";
            };
          };
          server = {
            on_attach = ''
              function(client, bufnr)
                -- Enable inlay hints
                if client.server_capabilities.inlayHintProvider then
                  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
              end
            '';
            default_settings = {
              "rust-analyzer" = {
                cargo = {
                  allFeatures = true;
                  loadOutDirsFromCheck = true;
                  buildScripts = {
                    enable = true;
                  };
                };
                checkOnSave = true;
                procMacro = {
                  enable = true;
                  ignored = {
                    async-trait = [ "async_trait" ];
                    napi-derive = [ "napi" ];
                    async-recursion = [ "async_recursion" ];
                  };
                };
                inlayHints = {
                  bindingModeHints = {
                    enable = false;
                  };
                  chainingHints = {
                    enable = true;
                  };
                  closingBraceHints = {
                    enable = true;
                    minLines = 25;
                  };
                  closureReturnTypeHints = {
                    enable = "never";
                  };
                  lifetimeElisionHints = {
                    enable = "never";
                    useParameterNames = false;
                  };
                  maxLength = 25;
                  parameterHints = {
                    enable = true;
                  };
                  reborrowHints = {
                    enable = "never";
                  };
                  renderColons = true;
                  typeHints = {
                    enable = true;
                    hideClosureInitialization = false;
                    hideNamedConstructor = false;
                  };
                };
                lens = {
                  enable = true;
                  run = {
                    enable = true;
                  };
                  debug = {
                    enable = true;
                  };
                  implementations = {
                    enable = true;
                  };
                  references = {
                    adt = {
                      enable = false;
                    };
                    enumVariant = {
                      enable = false;
                    };
                    method = {
                      enable = false;
                    };
                    trait = {
                      enable = false;
                    };
                  };
                };
                hover = {
                  actions = {
                    enable = true;
                    debug = {
                      enable = true;
                    };
                    gotoTypeDef = {
                      enable = true;
                    };
                    implementations = {
                      enable = true;
                    };
                    references = {
                      enable = true;
                    };
                    run = {
                      enable = true;
                    };
                  };
                };
                semanticHighlighting = {
                  strings = {
                    enable = true;
                  };
                };
              };
            };
          };
        };
      };

      # Snippet engine with Rust snippets
      luasnip = {
        enable = true;
        settings = {
          enable_autosnippets = true;
          store_selection_keys = "<Tab>";
        };
        fromVscode = [
          {
            lazyLoad = true;
            paths = "${pkgs.vimPlugins.friendly-snippets}";
          }
        ];
      };
      dap-virtual-text.enable = true;
      dap-ui.enable = true;

      # Testing support
      neotest = {
        enable = true;
        adapters.rust.enable = true;
        settings = {
          icons = {
            child_indent = "│";
            child_prefix = "├";
            collapsed = "─";
            expanded = "╮";
            failed = "";
            final_child_indent = " ";
            final_child_prefix = "╰";
            non_collapsible = "─";
            passed = "";
            running = "";
            running_animated = [
              "/"
              "|"
              "\\"
              "-"
              "/"
              "|"
              "\\"
              "-"
            ];
            skipped = "";
            unknown = "";
            watching = "";
          };
        };
      };

      # File explorer with better icons
      nvim-tree = {
        enable = true;
        sortBy = "case_sensitive";
        view = {
          width = 35;
          side = "left";
        };
        filters = {
          dotfiles = false;
          custom = [ ".DS_Store" ];
        };
        git = {
          enable = true;
          ignore = true;
          timeout = 400;
        };
      };

      # Enhanced fuzzy finder
      telescope = {
        enable = true;
        settings = {
          defaults = {
            file_ignore_patterns = [
              "node_modules"
              ".git"
              "target"
              "Cargo.lock"
            ];
            layout_config = {
              horizontal = {
                prompt_position = "top";
                preview_width = 0.55;
                results_width = 0.8;
              };
              vertical = {
                mirror = false;
              };
              width = 0.87;
              height = 0.80;
              preview_cutoff = 120;
            };
            prompt_prefix = "   ";
            selection_caret = "  ";
            entry_prefix = "  ";
            initial_mode = "insert";
            selection_strategy = "reset";
            sorting_strategy = "ascending";
            layout_strategy = "horizontal";
            file_sorter = "require('telescope.sorters').get_fuzzy_file";
            generic_sorter = "require('telescope.sorters').get_generic_fuzzy_sorter";
            path_display = [ "truncate" ];
            winblend = 0;
            border = true;
            borderchars = [
              "─"
              "│"
              "─"
              "│"
              "╭"
              "╮"
              "╯"
              "╰"
            ];
            color_devicons = true;
            use_less = true;
            set_env = {
              COLORTERM = "truecolor";
            };
          };
          pickers = {
            find_files = {
              find_command = [
                "rg"
                "--files"
                "--hidden"
                "--glob"
                "!**/.git/*"
              ];
            };
          };
        };
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fr" = "lsp_references";
          "<leader>fi" = "lsp_implementations";
          "<leader>fd" = "lsp_definitions";
          "<leader>ft" = "lsp_type_definitions";
          "<leader>fs" = "lsp_document_symbols";
          "<leader>fw" = "lsp_workspace_symbols";
        };
        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
        };
      };

      # Enhanced status line
      lualine = {
        enable = true;
        settings = {
          options = {
            icons_enabled = true;
            theme = "auto";
            component_separators = {
              left = "";
              right = "";
            };
            section_separators = {
              left = "";
              right = "";
            };
            disabled_filetypes = {
              statusline = [ ];
              winbar = [ ];
            };
            ignore_focus = [ ];
            always_divide_middle = true;
            globalstatus = false;
            refresh = {
              statusline = 1000;
              tabline = 1000;
              winbar = 1000;
            };
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [
              "branch"
              "diff"
              "diagnostics"
            ];
            lualine_c = [
              {
                __unkeyed = "filename";
                file_status = true;
                newfile_status = false;
                path = 1;
                shorting_target = 40;
                symbols = {
                  modified = "[+]";
                  readonly = "[-]";
                  unnamed = "[No Name]";
                  newfile = "[New]";
                };
              }
            ];
            lualine_x = [
              "encoding"
              "fileformat"
              "filetype"
            ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
          inactive_sections = {
            lualine_a = [ ];
            lualine_b = [ ];
            lualine_c = [ "filename" ];
            lualine_x = [ "location" ];
            lualine_y = [ ];
            lualine_z = [ ];
          };
          tabline = { };
          winbar = { };
          inactive_winbar = { };
          extensions = [ ];
        };
      };

      # Git integration
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add = {
              text = "│";
            };
            change = {
              text = "│";
            };
            delete = {
              text = "_";
            };
            topdelete = {
              text = "‾";
            };
            changedelete = {
              text = "~";
            };
            untracked = {
              text = "┆";
            };
          };
          signcolumn = true;
          numhl = false;
          linehl = false;
          word_diff = false;
          watch_gitdir = {
            follow_files = true;
          };
          attach_to_untracked = true;
          current_line_blame = false;
          current_line_blame_opts = {
            virt_text = true;
            virt_text_pos = "eol";
            delay = 1000;
            ignore_whitespace = false;
          };
          current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>";
          sign_priority = 6;
          update_debounce = 100;
          status_formatter = null;
          max_file_length = 40000;
          preview_config = {
            border = "single";
            style = "minimal";
            relative = "cursor";
            row = 0;
            col = 1;
          };
        };
      };

      # Comment toggling
      comment.enable = true;

      # Which key configuration
      which-key = {
        enable = true;
        settings = {
          icons = {
            breadcrumb = "»";
            separator = "➜";
            group = "+";
          };
          win = {
            border = "rounded";
            position = "bottom";
            margin = [
              1
              0
              1
              0
            ];
            padding = [
              2
              2
            ];
            winblend = 0;
          };
          layout = {
            height = {
              min = 4;
              max = 25;
            };
            width = {
              min = 20;
              max = 50;
            };
            spacing = 3;
            align = "left";
          };
          show_help = true;
          triggers = [
            {
              "<leader>" = {
                mode = "n";
              };
            }
          ];
        };
      };

      # Better syntax highlighting
      colorizer.enable = true;

      # Indentation guides
      indent-blankline = {
        enable = true;
        settings = {
          indent = {
            char = "│";
            tab_char = "│";
          };
          scope = {
            enabled = false;
          };
          exclude = {
            filetypes = [
              "help"
              "alpha"
              "dashboard"
              "neo-tree"
              "Trouble"
              "trouble"
              "lazy"
              "mason"
              "notify"
              "toggleterm"
              "lazyterm"
            ];
          };
        };
      };

      # Web dev icons
      web-devicons.enable = true;

      # Terminal integration
      toggleterm = {
        enable = true;
        settings = {
          size = 20;
          open_mapping = "[[<c-\\>]]";
          hide_numbers = true;
          shade_filetypes = [ ];
          shade_terminals = true;
          shading_factor = 2;
          start_in_insert = true;
          insert_mappings = true;
          persist_size = true;
          direction = "float";
          close_on_exit = true;
          shell = "vim.o.shell";
          float_opts = {
            border = "curved";
            winblend = 0;
            highlights = {
              border = "Normal";
              background = "Normal";
            };
          };
        };
      };

      # Trouble v3 configuration
      trouble = {
        enable = true;
        settings = {
          modes = {
            diagnostics = {
              mode = "diagnostics";
              preview = {
                type = "split";
                relative = "win";
                position = "right";
                size = 0.3;
              };
            };
          };
          icons = {
            indent = {
              top = "│ ";
              middle = "├╴";
              last = "└╴";
              fold_open = " ";
              fold_closed = " ";
              ws = "  ";
            };
            folder_closed = " ";
            folder_open = " ";
            kinds = {
              Array = " ";
              Boolean = "󰨙 ";
              Class = " ";
              Constant = "󰏿 ";
              Constructor = " ";
              Enum = " ";
              EnumMember = " ";
              Event = " ";
              Field = " ";
              File = " ";
              Function = "󰊕 ";
              Interface = " ";
              Key = " ";
              Method = "󰊕 ";
              Module = " ";
              Namespace = "󰦮 ";
              Null = " ";
              Number = "󰎠 ";
              Object = " ";
              Operator = " ";
              Package = " ";
              Property = " ";
              String = " ";
              Struct = "󰆼 ";
              TypeParameter = " ";
              Variable = "󰀫 ";
            };
          };
        };
      };
    };

    # Extra packages for Rust development
    extraPackages = with pkgs; [
      # Rust toolchain
      cargo
      rustc
      rustfmt
      rust-analyzer
      clippy

      # Formatters & linters
      nixfmt-rfc-style
      gofumpt
      black
      prettier
      taplo # TOML formatter

      # Development tools
      ripgrep
      fd
      tree-sitter
      gdb
      lldb

      # Additional tools
      cargo-edit
      cargo-watch
      cargo-expand
      cargo-outdated
      cargo-audit
      cargo-deny
      cargo-nextest
    ];

    # Enhanced key mappings for Rust development
    keymaps = [
      # File operations
      {
        mode = "n";
        key = "<leader>w";
        action = ":w<CR>";
        options = {
          silent = true;
          desc = "Save file";
        };
      }
      {
        mode = "n";
        key = "<leader>q";
        action = ":q<CR>";
        options = {
          silent = true;
          desc = "Quit";
        };
      }
      {
        mode = "n";
        key = "<leader>x";
        action = ":x<CR>";
        options = {
          silent = true;
          desc = "Save and quit";
        };
      }

      # File explorer
      {
        mode = "n";
        key = "<leader>e";
        action = ":NvimTreeToggle<CR>";
        options = {
          silent = true;
          desc = "Toggle file explorer";
        };
      }

      # Window navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options = {
          desc = "Go to left window";
        };
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options = {
          desc = "Go to lower window";
        };
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options = {
          desc = "Go to upper window";
        };
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options = {
          desc = "Go to right window";
        };
      }

      # Buffer navigation
      {
        mode = "n";
        key = "<leader>bn";
        action = ":bnext<CR>";
        options = {
          silent = true;
          desc = "Next buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = ":bprev<CR>";
        options = {
          silent = true;
          desc = "Previous buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = ":bdelete<CR>";
        options = {
          silent = true;
          desc = "Delete buffer";
        };
      }

      # LSP mappings
      {
        mode = "n";
        key = "gd";
        action = "<cmd>lua vim.lsp.buf.definition()<cr>";
        options = {
          desc = "Go to definition";
        };
      }
      {
        mode = "n";
        key = "gD";
        action = "<cmd>lua vim.lsp.buf.declaration()<cr>";
        options = {
          desc = "Go to declaration";
        };
      }
      {
        mode = "n";
        key = "gi";
        action = "<cmd>lua vim.lsp.buf.implementation()<cr>";
        options = {
          desc = "Go to implementation";
        };
      }
      {
        mode = "n";
        key = "gt";
        action = "<cmd>lua vim.lsp.buf.type_definition()<cr>";
        options = {
          desc = "Go to type definition";
        };
      }
      {
        mode = "n";
        key = "gr";
        action = "<cmd>lua vim.lsp.buf.references()<cr>";
        options = {
          desc = "Show references";
        };
      }
      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<cr>";
        options = {
          desc = "Show hover information";
        };
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
        options = {
          desc = "Code action";
        };
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = "<cmd>lua vim.lsp.buf.rename()<cr>";
        options = {
          desc = "Rename";
        };
      }
    ];
  };
}
