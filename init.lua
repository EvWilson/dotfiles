--------------------------------------------------------------------------------
-- >>> Option Configuration <<<
--------------------------------------------------------------------------------
-- Show relative line number
vim.opt.relativenumber = true
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
-- >>> Plugin Configuration <<<
--------------------------------------------------------------------------------
-- Check this to make sure this stays up to date: https://github.com/wbthomason/packer.nvim
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Let Packer update itself
  -- My current color scheme
  -- use 'gruvbox-community/gruvbox'
  use 'folke/tokyonight.nvim'

  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- for file icons
    },
    tag = 'nightly' -- optional, updated every week
  }

  -- LSP configuration support
  -- See: https://github.com/VonHeikemen/lsp-zero.nvim
  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},

      -- Formatting
      {'mhartington/formatter.nvim'},
    }
  }

  -- Tree-sitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {
      {'nvim-treesitter/nvim-treesitter-context'},
    }
  }

  use 'nvim-lualine/lualine.nvim' -- Status bar upgrade
  use 'tpope/vim-surround' -- 'cs{old}{new} to change surround, 'ys{motion}{char}' to add surround
  use 'tpope/vim-commentary' -- 'gc' in some permutation to toggle comments!, NOTE: see Commentary.nvim for future
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically
  use 'kana/vim-textobj-user' -- Enables custom text objects in other plugins
  use 'thinca/vim-textobj-between' -- 'ci{motion}' to change between objects in motion
  -- use {'fatih/vim-go', run = ':GoUpdateBinaries' } -- For all things Go (love this)

  -- Fuzzy finder for all things
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.x',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
    }
  }

  -- SQL mgmt
  use {
    'tpope/vim-dadbod',
    requires = {
      {'tpope/vim-dotenv'},
      {'kristijanhusak/vim-dadbod-ui'},
      {'kristijanhusak/vim-dadbod-completion'},
    }
  }
  -- Nursery - plugins I'm not fully sold on yet
  use { 'rcarriga/nvim-dap-ui', requires = { 'mfussenegger/nvim-dap' } } -- Bring in generic debugger with associated UI
  use { 'theHamsta/nvim-dap-virtual-text', requires = { 'mfussenegger/nvim-dap' } } -- Display variable values during debug
  use 'leoluz/nvim-dap-go' -- dap configuration for Go

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)
if packer_bootstrap then
    print '=================================='
    print '    Plugins are being installed'
    print '    Wait until Packer completes,'
    print '       then restart nvim'
    print '=================================='
  return
end

-- Set colorscheme, imported as plugin
-- vim.cmd('colorscheme gruvbox')
vim.cmd('colorscheme tokyonight-night')

require("nvim-tree").setup()

-- Get a package manager set up for all our LSP, DAP, formatters, etc
require('mason').setup()

-- Get a default LSP setup
local lsp = require('lsp-zero')
lsp.preset('recommended')
lsp.setup()

-- Set up our formatters
require("formatter").setup {
  filetype = {
    go = {
      require('formatter.filetypes.go').goimports
    },
  }
}
vim.cmd([[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost * FormatWrite
augroup END
]])

-- Quick lualine configuration (mostly disabling extra/special characters)
require('lualine').setup {
  -- options = {
  --   icons_enabled = false,
  --   component_separators = { left = '', right = ''},
  --   section_separators = { left = '', right = ''},
  -- },
  sections = { lualine_c = { { 'filename', path = 1 } } },
  tabline = { lualine_a = { { 'buffers', show_filename_only = false } } } -- Show open buffers in top line
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'go' }, -- A list of parser names, or 'all'
  sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
  auto_install = true, -- Automatically install missing parsers when entering buffer
  highlight = { enable = true },
}

require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = 'smart_case',        -- or 'ignore_case' or 'respect_case', default is 'smart_case'
    }
  }
}
require('telescope').load_extension('fzf')

-- Open SQL mgmt pane, add completions, disable special keybinds, add save query
-- NOTE: config stored in ~/.dbenv, as DB_UI_SOMETHING_COOL="connection_string_here"
vim.api.nvim_create_user_command('OpenDB', function()
    require('cmp').setup.buffer { sources = { { name = 'vim-dadbod-completion' } } }
    -- vim.g.db_ui_disable_mappings = 1 -- This borks navigation for some reason
    vim.cmd [[ autocmd FileType dbui setlocal shiftwidth=2 tabstop=2 ]]
    vim.cmd [[ Dotenv ~/.dbenv ]]
    vim.cmd [[ DBUIToggle ]]
    vim.keymap.set('n', '<Leader>s', '<Plug>(DBUI_SaveQuery)')
  end
, {})

-- Set up dap generic debugging utilities, and add relevant keybinds/commands
require('nvim-dap-virtual-text').setup {}
require('dapui').setup {}
require('dap-go').setup {}
vim.keymap.set('n', '<F7>', require('dap').toggle_breakpoint, { desc = 'Set dap breakpoint' })
vim.keymap.set('n', '<F8>', require('dap').continue, { desc = 'Launch and continue dap session' })
vim.keymap.set('n', '<F9>', require('dap').step_over, { desc = 'Step over inside dap session' })
vim.keymap.set('n', '<F10>', require('dap').step_into, { desc = 'Step into inside dap session' })
vim.api.nvim_create_user_command('DbgUI', require('dapui').toggle, { desc = 'Toggle dap UI during session' })
vim.api.nvim_create_user_command('DbgTest', require('dap-go').debug_test, { desc = 'Test nearest Go test to cursor' })

--------------------------------------------------------------------------------
-- >>> Key Mappings <<<
-- NOTE: keymaps are default non-recursive now, yay!
--------------------------------------------------------------------------------
vim.g.mapleader = ' '

-- My old faithfuls, you can't convince me these aren't right
vim.keymap.set('n', '<leader>w', ':w<cr>', { desc = 'Quicksave' })
vim.keymap.set('n', ';', ':', { desc = 'Enter command mode easier' })
vim.keymap.set('i', 'jh', '<esc>', { desc = 'Escape insert mode from home' })
vim.keymap.set('n', '<leader>d', ':bd<cr>', { desc = 'Delete current buffer' })
vim.keymap.set('n', '<c-n>', ':bnext<cr>', { desc = 'Cycle to next buffer', silent = true })
vim.keymap.set('n', '<c-p>', ':bprevious<cr>', { desc = 'Cycle to previous buffer', silent = true })

-- Make navigating, yanking, etc easier
vim.keymap.set({'n', 'v'}, 'H', '^', { desc = 'Navigate to line start' })
vim.keymap.set({'n', 'v'}, 'L', '$', { desc = 'Navigate to line end' })
vim.keymap.set('n', 'Y', 'yg_', { desc = 'Make Y behave sanely' })

-- Filetree keybinds
vim.keymap.set('n', 'tt', ':NvimTreeToggle<CR>', { desc = 'Toggle filetree viewer' })
vim.keymap.set('n', 'tc', ':NvimTreeCollapseKeepBuffers<CR>', { desc = 'Close open folders in filetree viewer' })
vim.keymap.set('n', 'tf', ':NvimTreeFindFileToggle<CR>', { desc = 'Open filetree to current file' })
vim.keymap.set('n', 'to', ':lua require("nvim-tree.api").tree.expand_all()<CR>', { desc = 'Open filetree and expand all directories' })

-- Niceties
vim.keymap.set('i', '{<cr>', '{<cr>}<esc>O', { desc = 'Automatically match brackets' })
vim.keymap.set('n', '<c-l>', ':noh<cr>', { desc = 'Clear search highlight' })
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggVG<cr>', { desc = 'Select all text in the current buffer' })

-- Set up telescope key mappings
local set_telescope_keymaps = function()
  local t = require('telescope.builtin')
  vim.keymap.set('n', '<leader>h', t.find_files, { desc = 'Telescope find files' })
  vim.keymap.set('n', '<leader>j', t.buffers, { desc = 'Telescope find buffers' })
  vim.keymap.set('n', '<leader>k', t.live_grep, { desc = 'Telescope live grep' })
end
set_telescope_keymaps()

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  callback = function(event)
    vim.highlight.on_yank({higroup = 'Visual', timeout = 500})
  end
})
