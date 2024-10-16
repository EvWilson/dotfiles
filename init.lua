--------------------------------------------------------------------------------
-- >>> Option Configuration <<<
--------------------------------------------------------------------------------
-- Space leader best leader
vim.g.mapleader = ' '
-- Show line numbers
vim.opt.number = true
-- Required for options modifying multiple buffers like rename
vim.opt.hidden = true
-- Prevent backups, which can cause issues for some servers (and I don't use)
vim.opt.backup = false
vim.opt.writebackup = false
-- Short update time, because I don't ssh much on this setup
vim.opt.updatetime = 50
-- Better default for case sensitivity when searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Set persistent undo
vim.opt.undofile = true
-- Enhanced tab completion
vim.opt.wildmenu = true
-- Maintain this many lines of context when scrolling, if possible
vim.opt.scrolloff = 15
-- Enable the mouse to set the cursor location
vim.opt.mouse = 'a'
-- Best of both worlds sign/number column
vim.opt.signcolumn = 'yes'
-- Allow filetree viewer to set colors properly
vim.opt.termguicolors = true
-- I like to see whitespace
vim.opt.list = true
vim.opt.listchars:append('space:·')
-- Bash, pls
vim.opt.shell = '/bin/bash'
-- Disable netrw, in favor of a more featureful filetree viewer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Some formatters insist on tabs, make them 4 spaces wide
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- Change line wrapping and such behavior in markdown, for legibility while writing
vim.cmd [[autocmd FileType markdown setlocal nolist wrap linebreak]]
-- Yank/put to/from system clipboard for convenience
vim.opt.clipboard:append('unnamedplus')

--------------------------------------------------------------------------------
-- >>> Non-Plugin Key Mappings <<<
-- NOTE: keymaps are default non-recursive now, yay!
--------------------------------------------------------------------------------
-- My old faithfuls, you can't convince me these aren't right
vim.keymap.set('n', '<leader>w', ':w<cr>', { desc = 'Quicksave' })
vim.keymap.set('n', ';', ':', { desc = 'Enter command mode easier' })
vim.keymap.set('i', 'jh', '<esc>', { desc = 'Escape insert mode from home' })
vim.keymap.set('n', '<leader>d', ':bd<cr>', { desc = 'Delete current buffer' })
vim.keymap.set('n', '<c-n>', ':bnext<cr>', { desc = 'Cycle to next buffer', silent = true })
vim.keymap.set('n', '<c-p>', ':bprevious<cr>', { desc = 'Cycle to previous buffer', silent = true })

-- Make navigating, yanking, etc easier
vim.keymap.set({ 'n', 'v' }, 'H', '^', { desc = 'Navigate to line start' })
vim.keymap.set({ 'n', 'v' }, 'L', '$', { desc = 'Navigate to line end' })
vim.keymap.set('n', 'Y', 'yg_', { desc = 'Make Y behave sanely' })

-- Niceties
vim.keymap.set('i', '{<cr>', '{<cr>}<esc>O', { desc = 'Automatically match brackets' })
vim.keymap.set('i', '(<cr>', '(<cr>)<esc>O', { desc = 'Automatically match parens' })
vim.keymap.set('n', '<c-l>', ':noh<cr>', { desc = 'Clear search highlight' })
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggVG<cr>', { desc = 'Select all text in the current buffer' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  callback = function(_)
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 500 })
  end
})

vim.api.nvim_create_user_command('BufOnly',
  'execute "%bd|e#|bd#"',
  { desc = 'Close all buffers (including filetree) other than the current' }
)

local lsp_keybinds = function(_, _)
  -- Other not-yet-explicitly-bound options:
  -- vim.lsp.buf.declaration
  -- vim.lsp.buf.add_workspace_folder
  -- vim.lsp.buf.remove_workspace_folder
  -- lsp.buf.list_workspace_folders
  -- vim.lsp.buf.type_definition
  -- vim.diagnostic.goto_prev
  -- vim.diagnostic.goto_next
  -- vim.diagnostic.setloclist
  local map = vim.keymap.set
  map('n', 'gd', vim.lsp.buf.definition)
  map('n', 'K', vim.lsp.buf.hover)
  map('n', 'gi', vim.lsp.buf.implementation)
  map('n', 'gr', vim.lsp.buf.references)
  -- map('n', 'gds', vim.lsp.buf.document_symbol)
  map('n', 'gws', vim.lsp.buf.workspace_symbol)
  map('n', '<leader>cl', vim.lsp.codelens.run)
  map('n', '<leader>sh', vim.lsp.buf.signature_help)
  map('n', '<leader>rn', vim.lsp.buf.rename)
  map('n', '<leader>f', vim.lsp.buf.format)
  map('n', '<leader>ca', vim.lsp.buf.code_action)
  map('n', '<leader>od', vim.diagnostic.open_float)

  vim.api.nvim_create_autocmd('BufWritePre', {
    command = 'silent! lua vim.lsp.buf.format({ async = false, timeout = 2000 })',
    desc = 'Format on save',
  })
  vim.lsp.inlay_hint.enable(true)
end

--------------------------------------------------------------------------------
-- >>> Plugin Configuration <<<
--------------------------------------------------------------------------------
-- Bootstrap lazy.nvim: https://github.com/folke/lazy.nvim#-installation
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    version = '*',
    config = function()
      require('nvim-tree').setup({
        renderer = {
          group_empty = true,
        }
      })
      local set = vim.keymap.set
      local api = require('nvim-tree.api')
      set('n', 'tt', api.tree.toggle, { desc = 'Toggle filetree viewer' })
      set('n', 'tc', api.tree.collapse_all, { desc = 'Close open folders in filetree viewer' })
      set('n', 'tf', api.tree.find_file, { desc = 'Open filetree to current file' })
      set('n', 'to', api.tree.expand_all, { desc = 'Open filetree and expand all directories' })
      set('n', 'ts', ':NvimTreeResize -20<CR>', { desc = 'Make filetree window smaller' })
      set('n', 'tb', ':NvimTreeResize +20<CR>', { desc = 'Make filetree window bigger' })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'L3MON4D3/LuaSnip' },
      { 'saadparwaiz1/cmp_luasnip' },
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        preselect = 'item',
        completion = {
          completeopt = 'menu,menuone,noinsert'
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                cmp.confirm({
                  select = true,
                })
              end
            else
              fallback()
            end
          end),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = lsp_keybinds,
        filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
      })

      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = lsp_keybinds,
        filetypes = { 'go' },
      })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = lsp_keybinds,
        filetypes = { 'lua' },
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
            },
          }
        }
      })

      -- Taken from: https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.go',
        callback = function()
          vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
        end
      })
    end,
  },
  {
    'scalameta/nvim-metals',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {},
      },
    },
    ft = { 'scala', 'sbt', 'java' },
    opts = function()
      local metals_config = require('metals').bare_config()
      metals_config.settings = {
        showImplicitArguments = true,
        showImplicitConversionsAndClasses = true,
        showInferredType = true,
      }
      metals_config.init_options.statusBarProvider = 'off'
      metals_config.on_attach = lsp_keybinds
      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = self.ft,
        callback = function()
          require('metals').initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
      vim.keymap.set('n', '<leader>gg', require('telescope').extensions.metals.commands,
        { desc = 'Pull up Metals commands in Telescope picker' })
    end
  },
  {
    'williamboman/mason.nvim',
    build = function()
      vim.cmd([[MasonUpdate]])
    end,
    config = function()
      require('mason').setup()
    end
  },
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' }
    }
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-context' },
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
        auto_install = true,  -- Automatically install missing parsers when entering buffer
        highlight = { enable = true },
      }
      require 'treesitter-context'.setup {
        enable = false, -- Default to false, because it can be annoying, but keeping it around in case I want it
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          layout_strategy = 'vertical'
        },
        extensions = {
          fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = 'smart_case',       -- or 'ignore_case' or 'respect_case', default is 'smart_case'
          }
        }
      }
      require('telescope').load_extension('fzf')
      local t = require('telescope.builtin')
      local set = vim.keymap.set
      set('n', '<leader>h', t.find_files, { desc = 'Telescope find files' })
      set('n', '<leader>j', t.buffers, { desc = 'Telescope find buffers' })
      set('n', '<leader>k', t.live_grep, { desc = 'Telescope live grep' })
    end,
  },
  {
    -- Debug Adapter Protocol with associated UI
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
      'leoluz/nvim-dap-go',
    },
    config = function()
      require('dapui').setup()
      require('nvim-dap-virtual-text').setup()
      require('dap-go').setup()

      local set = vim.keymap.set
      set('n', '<leader>gb', ':lua require("dap").toggle_breakpoint()<CR>', { desc = 'Toggle DAP breakpoint' })
      set('n', '<leader>gc', ':lua require("dap").continue()<CR>', { desc = 'Continue in DAP' })
      set('n', '<leader>go', ':lua require("dap").step_over()<CR>', { desc = 'Step over in DAP' })
      set('n', '<leader>gi', ':lua require("dap").step_into()<CR>', { desc = 'Step into in DAP' })
      set('n', '<leader>gq', ':lua require("dap").terminate()<CR>', { desc = 'Terminate DAP session' })
    end,
  },
  {
    'ruifm/gitlinker.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitlinker').setup()
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        sections = { lualine_c = { { 'filename', path = 1 } } },
        tabline = { lualine_a = { { 'buffers', show_filename_only = false } } } -- Show open buffers in top line
      }
    end
  },
  {
    'EvWilson/slimux.nvim',
    config = function()
      local slimux = require('slimux')
      slimux.setup({
        target_socket = slimux.get_tmux_socket(),
        target_pane = string.format('%s.2', slimux.get_tmux_window()),
      })
      local set = vim.keymap.set
      set('v', '<leader>r', ':lua require("slimux").send_highlighted_text()<CR>',
        { desc = 'Send currently highlighted text to configured tmux pane' })
      set('n', '<leader>r', ':lua require("slimux").send_paragraph_text()<CR>',
        { desc = 'Send paragraph under cursor to configured tmux pane' })
    end
  },
  {
    'EvWilson/spelunk.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('spelunk').setup()
    end
  },
  'tpope/vim-surround',    -- 'cs{old}{new} to change surround, 'ys{motion}{char}' to add surround
  'tpope/vim-sleuth',      -- Detect tabstop and shiftwidth automatically
  'kana/vim-textobj-user', -- Enables custom text objects in other plugins
  {
    -- See: https://github.com/yetone/avante.nvim?tab=readme-ov-file#installation
    'yetone/avante.nvim',
    cond = function()
      return os.getenv('LOAD_NVIM_AVANTE') == '1'
    end,
    keys = function(_, keys)
      local opts =
          require('lazy.core.plugin').values(require('lazy.core.config').spec.plugins['avante.nvim'], 'opts', false)

      local mappings = {
        {
          opts.mappings.ask,
          function() require('avante.api').ask() end,
          desc = 'avante: ask',
          mode = { 'n', 'v' },
        },
        {
          opts.mappings.refresh,
          function() require('avante.api').refresh() end,
          desc = 'avante: refresh',
          mode = 'v',
        },
        {
          opts.mappings.edit,
          function() require('avante.api').edit() end,
          desc = 'avante: edit',
          mode = { 'n', 'v' },
        },
      }
      mappings = vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        ask = '<leader>ua',
        edit = '<leader>ue',
        refresh = '<leader>ur',
      },
    },
    event = 'VeryLazy',
    lazy = false,
    version = false,
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      'zbirenbaum/copilot.lua',
      {
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'Avante' },
        },
        ft = { 'Avante' },
      },
    },
  }
})
