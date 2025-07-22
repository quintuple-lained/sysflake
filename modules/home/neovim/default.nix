{ config
, pkgs
, lib
, ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Plugins
    plugins = with pkgs.vimPlugins; [
      # LSP and completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip

      # Treesitter for syntax highlighting
      nvim-treesitter.withAllGrammars

      # File explorer
      nvim-tree-lua

      # Fuzzy finder
      telescope-nvim
      plenary-nvim

      # Status line
      lualine-nvim
      nvim-web-devicons

      # Git integration
      gitsigns-nvim

      # Theme
      catppuccin-nvim

      # Auto pairs
      nvim-autopairs

      # Comment toggling
      comment-nvim

      # Which key for keybinding help
      which-key-nvim
    ];

    # Extra packages (LSP servers, formatters, etc.)
    extraPackages = with pkgs; [
      # Nix LSP
      nixd
      nil

      rust-analyzer # Rust LSP
      gopls # Go LSP
      pyright # Python LSP
      marksman # Markdown LSP
      dot-language-server # Graphviz DOT LSP

      # Other useful LSPs
      lua-language-server

      # Formatters & tools
      nixfmt-rfc-style # Nix formatter
      rustfmt # Rust formatter
      gofumpt # Go formatter
      black # Python formatter
      prettier # Markdown formatter

      # General tools
      ripgrep
      fd
      tree-sitter
    ];

    # Neovim configuration
    extraLuaConfig = ''
      -- Basic settings
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.hlsearch = false
      vim.opt.incsearch = true
      vim.opt.termguicolors = true
      vim.opt.scrolloff = 8
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 50
      vim.opt.colorcolumn = "80"

      -- Set leader key
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- Catppuccin theme
      require("catppuccin").setup({
        flavour = "mocha",
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = false,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
          which_key = true,
        },
      })

      vim.cmd.colorscheme "catppuccin"

      -- Treesitter configuration
      require('nvim-treesitter.configs').setup {
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      }

      -- LSP configuration
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Nix LSP
      lspconfig.nixd.setup({
        capabilities = capabilities,
      })

      lspconfig.nil_ls.setup({
        capabilities = capabilities,
        settings = {
          ['nil'] = {
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      })

      -- Rust LSP
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
      })

      -- Go LSP
      lspconfig.gopls.setup({
        capabilities = capabilities,
      })

      -- Python LSP
      lspconfig.pyright.setup({
        capabilities = capabilities,
      })

      -- Markdown LSP
      lspconfig.marksman.setup({
        capabilities = capabilities,
      })

      -- Graphviz DOT LSP
      lspconfig.dot_ls.setup({
        capabilities = capabilities,
      })

      -- Lua LSP
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              globals = {'vim'},
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      -- Global mappings for LSP
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })

      -- Completion setup
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })

      -- Telescope setup
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git", "target" },
        },
      })

      -- Telescope keymaps
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

      -- Nvim-tree setup
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
      })

      -- Nvim-tree keymaps
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })

      -- Lualine setup
            require('lualine').setup({
        options = {
          theme = 'catppuccin',
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      })

      -- Gitsigns setup
      require('gitsigns').setup()

      -- Autopairs setup
      require('nvim-autopairs').setup({})

      -- Comment setup
      require('Comment').setup()

      -- Which-key setup
      require('which-key').setup({})

      -- Basic keymaps
      vim.keymap.set('n', '<leader>w', ':w<CR>', { silent = true })
      vim.keymap.set('n', '<leader>q', ':q<CR>', { silent = true })
      vim.keymap.set('n', '<leader>x', ':x<CR>', { silent = true })

      -- Window navigation
      vim.keymap.set('n', '<C-h>', '<C-w>h')
      vim.keymap.set('n', '<C-j>', '<C-w>j')
      vim.keymap.set('n', '<C-k>', '<C-w>k')
      vim.keymap.set('n', '<C-l>', '<C-w>l')

      -- Buffer navigation
      vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { silent = true })
      vim.keymap.set('n', '<leader>bp', ':bprev<CR>', { silent = true })
      vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { silent = true })

      -- Clear search highlighting
      vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>', { silent = true })

      -- Move lines up/down in visual mode
      vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
      vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.nix", "*.lua", "*.rs", "*.go", "*.py", "*.md", "*.markdown", "*.dot", "*.gv" },
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    '';
  };
}
