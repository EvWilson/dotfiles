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
vim.opt.shell = '/usr/bin/env bash'
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
local set = vim.keymap.set
-- My old faithfuls, you can't convince me these aren't right
set('n', '<leader>w', ':w<CR>', { desc = 'Quicksave' })
set('n', ';', ':', { desc = 'Enter command mode easier' })
set('i', 'jh', '<esc>', { desc = 'Escape insert mode from home' })
set('n', '<leader>yf', ':let @+ = expand("%")<CR>', { desc = 'Yank relative path of current buffer to clipboard' })

-- Make navigating, yanking, etc easier
set({ 'n', 'v' }, 'H', '^', { desc = 'Navigate to line start' })
set({ 'n', 'v' }, 'L', '$', { desc = 'Navigate to line end' })
set('n', 'Y', 'yg_', { desc = 'Make Y behave sanely' })

-- Niceties
set('i', '{<CR>', '{<CR>}<esc>O', { desc = 'Automatically match brackets' })
set('i', '(<CR>', '(<CR>)<esc>O', { desc = 'Automatically match parens' })
set('v', '<leader>x', ':lua<CR>', { desc = 'Execute selected Lua code (for plugin/config dev)' })

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
  set('n', 'gd', vim.lsp.buf.definition)
  set('n', 'K', vim.lsp.buf.hover)
  set('n', 'gi', vim.lsp.buf.implementation)
  set('n', 'gr', vim.lsp.buf.references)
  -- set('n', 'gds', vim.lsp.buf.document_symbol)
  set('n', 'gws', vim.lsp.buf.workspace_symbol)
  set('n', '<leader>cl', vim.lsp.codelens.run)
  set('n', '<leader>sh', vim.lsp.buf.signature_help)
  set('n', '<leader>rn', vim.lsp.buf.rename)
  set('n', '<leader>f', vim.lsp.buf.format)
  set('n', '<leader>ca', vim.lsp.buf.code_action)
  set('n', '<leader>od', vim.diagnostic.open_float)

  vim.api.nvim_create_autocmd('BufWritePre', {
    command = 'silent! lua vim.lsp.buf.format({ async = false, timeout = 2000 })',
    desc = 'Format on save',
  })
  vim.lsp.inlay_hint.enable(true)
end

--------------------------------------------------------------------------------
-- >>> Plugin Configuration <<<
--------------------------------------------------------------------------------
-- Bootstrap lazy.nvim: https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
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
      })

      lspconfig.basedpyright.setup {
        capabilities = capabilities,
        on_attach = lsp_keybinds,
        filetypes = { 'python' },
      }
      lspconfig.ruff.setup {
        cmd = { 'uv', 'run', 'ruff', 'server' },
        filetypes = { 'python' }
      }

      lspconfig.rust_analyzer.setup {
        capabilities = capabilities,
        on_attach = lsp_keybinds,
        filetypes = { 'rust' },
      }

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
    "mason-org/mason.nvim",
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
      local live_globular_grep = function(opts)
        opts = opts or {}
        opts.cwd = opts.cwd or vim.fn.getcwd()

        local finder = require('telescope.finders').new_async_job {
          command_generator = function(prompt)
            if not prompt or prompt == "" then
              return nil
            end
            local pieces = vim.split(prompt, '  ')
            local args = { 'rg' }
            if pieces[1] then
              table.insert(args, '-e')
              table.insert(args, pieces[1])
            end
            if pieces[2] then
              table.insert(args, '-g')
              table.insert(args, pieces[2])
            end
            --@diagnostic disable-next-line: deprecated
            return vim.tbl_flatten {
              args,
              { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' }
            }
          end,
          entry_maker = require('telescope.make_entry').gen_from_vimgrep(opts),
          cwd = opts.cwd,
        }

        require('telescope.pickers').new(
          opts,
          {
            debounce = 100,
            prompt_title = 'Globular Grep',
            finder = finder,
            previewer = require('telescope.config').values.grep_previewer(opts),
            sorter = require('telescope.sorters').empty(),
          }
        ):find()
      end

      local t = require('telescope.builtin')
      set('n', '<leader>h', t.find_files, { desc = 'Telescope find files' })
      set('n', '<leader>j', t.buffers, { desc = 'Telescope find buffers' })
      set('n', '<leader>k', live_globular_grep, { desc = 'Telescope - custom globular grep' })
      set('n', '<leader>qk', t.live_grep, { desc = 'Telescope live grep' })
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
        sections = {
          lualine_b = { 'branch', 'diff', 'diagnostics', 'spelunk' },
          lualine_c = {
            { 'filename', path = 1 }
          }
        },
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
      set('v', '<leader>r', ':lua require("slimux").send_highlighted_text()<CR>',
        { desc = 'Send currently highlighted text to configured tmux pane' })
      set('n', '<leader>r', ':lua require("slimux").send_paragraph_text()<CR>',
        { desc = 'Send paragraph under cursor to configured tmux pane' })
    end
  },
  {
    'EvWilson/spelunk.nvim',
    -- dir = '~/Documents/spelunk.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      local spelunk = require('spelunk')
      spelunk.setup({
        base_mappings = {
          toggle = '<C-h>',
          next_bookmark = '<C-j>',
          prev_bookmark = '<C-k>',
        },
        enable_persist = true,
        orientation = 'horizontal',
      })
      spelunk.display_function = function(mark)
        local ctx = require('spelunk.util').get_treesitter_context(mark)
        ctx = (ctx == '' and ctx) or (' - ' .. ctx)
        local filename = spelunk.filename_formatter(mark.file)
        return string.format("%s:%d%s", filename, mark.line, ctx)
      end
    end
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          delete = '<leader>ds'
        }
      })
    end
  },
  'tpope/vim-sleuth',
})
