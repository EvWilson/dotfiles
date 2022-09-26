-- TODO: check out generic debugging utilities:
    -- https://github.com/mfussenegger/nvim-dap
    -- https://github.com/theHamsta/nvim-dap-virtual-text
    -- https://github.com/rcarriga/nvim-dap-ui

-- Good Lua config reference materials:
  -- https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/
  -- https://github.com/nanotee/nvim-lua-guide
  -- https://github.com/ThePrimeagen/.dotfiles/tree/master/nvim/.config/nvim
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

-- Better default for case sensitvity when searching
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

--------------------------------------------------------------------------------
-- >>> Plugin Configuration <<<
--------------------------------------------------------------------------------
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
-- You may need this for a bit: https://github.com/wbthomason/packer.nvim
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Let Packer update itself
  use 'gruvbox-community/gruvbox' -- Ze best color scheme

  use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
  use { 'hrsh7th/nvim-cmp', requires = 'hrsh7th/cmp-nvim-lsp'  } -- Autocompletion plugin
  use { 'L3MON4D3/LuaSnip', requires = 'saadparwaiz1/cmp_luasnip' } -- Snippets plugin

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' } -- Tree-sitter
  use 'nvim-treesitter/nvim-treesitter-context' -- Show function, etc context
  use 'nvim-lualine/lualine.nvim' -- Status bar upgrade
  use 'tpope/vim-surround' -- 'cs{old}{new} to change surround, 'ys{motion}{char}' to add surround
  use 'tpope/vim-commentary' -- 'gc' in some permutation to toggle comments!
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically
  use 'kana/vim-textobj-user' -- Enables custom text objects in other plugins
  use 'thinca/vim-textobj-between' -- 'ci{motion}' to change between objects in motion
  use 'Julian/vim-textobj-brace' -- 'cij' to change between brace pair
  use {'fatih/vim-go', run = ':GoUpdateBinaries' } -- For all things Go (love this)
  -- Nursery - plugins I'm not fully sold on yet
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' } -- Magit style git management
  use 'ggandor/leap.nvim' -- Simplified motion plugin
  use { 'nvim-telescope/telescope.nvim', tag = '0.1.x', requires = { {'nvim-lua/plenary.nvim'} } }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use { 'rcarriga/nvim-dap-ui', requires = {'mfussenegger/nvim-dap'} }
  use { 'theHamsta/nvim-dap-virtual-text', requires = {'mfussenegger/nvim-dap'} }

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

-- Set colorsheme, imported as plugin
vim.cmd('colorscheme gruvbox')

-- Quick lualine configuration (mostly disabling extras)
require('lualine').setup {
  options = {
    icons_enabled = false,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  },
  tabline = { lualine_a = { 'buffers' } } -- Show open buffers in top line
}

-- Quick treesitter highlighting config
require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'go' }, -- A list of parser names, or 'all'
  sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
  auto_install = true, -- Automatically install missing parsers when entering buffer
  highlight = { enable = true },
}

require('leap').set_default_keymaps()

require('neogit').setup {}
vim.api.nvim_create_user_command('GIT', 'Neogit', {})

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

require('nvim-dap-virtual-text').setup {}
require('dapui').setup {}
local dapui_fn = function()
  vim.fn.echom('Here')
  require('dapui').open()
end
vim.keymap.set('n', '<leader>b', dapui_fn, {desc = 'Toggle dapui'})

-- Only open variables and stacktrace for Go debugging
-- Cheatsheet:
-- Start debug - :GoDebugStart
-- Start debug with flags - :GoDebugStart . -someflag value
-- Toggle breakpoint (can add line number) - :GoDebugBreakpoint <line_num>
-- Continue to breakpoint - :GoDebugContinue
-- Step execution (see help for differences) - :GoDebug[Next|Step|StepOver|StepOut]
-- Print variable (shouldn't need often) - :GoDebugPrint <variable>
-- Quit session - :GoDebugStop
-- Check vim-go itself - :h vim-go
vim.cmd [[
let g:go_debug_windows = {
      \ 'vars':       'rightbelow 60vnew',
      \ 'stack':      'rightbelow 10new',
\ }
]]

--------------------------------------------------------------------------------
-- >>> Key Mappings <<<
-- NOTE: keymaps are default non-recursive now, yay!
--------------------------------------------------------------------------------
vim.g.mapleader = ' '

-- My old faithfuls, you can't convince me these aren't right
vim.keymap.set('n', '<leader>w', ':w<cr>', {desc = 'Quicksave'})
vim.keymap.set('n', ';', ':', {desc = 'Enter command mode easier'})
vim.keymap.set('i', 'jh', '<esc>', {desc = 'Escape insert mode from home'})
vim.keymap.set('n', '<leader>d', ':bd<cr>', {desc = 'Delete current buffer'})
vim.keymap.set('n', '<c-n>', ':bnext<cr>', {desc = 'Cycle to next buffer', silent = true})
vim.keymap.set('n', '<c-p>', ':bprevious<cr>', {desc = 'Cycle to previous buffer', silent = true})

-- Make navigating, yanking, etc easier
vim.keymap.set({'n', 'v'}, 'H', '^', {desc = 'Navigate to line start'})
vim.keymap.set({'n', 'v'}, 'L', '$', {desc = 'Navigate to line end'})
vim.keymap.set('n', 'Y', 'yg_', {desc = 'Make Y behave sanely'})
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', {desc = 'Yank to clipboard'})
vim.keymap.set('n', '<leader>p', '"+p', {desc = 'Paste from clipboard'})

-- Niceties
vim.keymap.set('i', '{<cr>', '{<cr>}<esc>O', {desc = 'Automatically match brackets'})
vim.keymap.set('n', '<c-l>', ':noh<cr>', {desc = 'Clear search highlight'})
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggVG<cr>', {desc = 'Select all text in the current buffer'})

-- Set up telescope key mappings
local set_telescope_keymaps = function()
  local t = require('telescope.builtin')
  vim.keymap.set('n', '<leader>h', t.find_files, {desc = 'Telescope find files'})
  vim.keymap.set('n', '<leader>j', t.buffers, {desc = 'Telescope find buffers'})
  vim.keymap.set('n', '<leader>k', t.live_grep, {desc = 'Telescope live grep'})
end
set_telescope_keymaps()

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  callback = function(event)
    vim.highlight.on_yank({higroup = 'Visual', timeout = 500})
  end
})

--------------------------------------------------------------------------------
-- >>> Nvim LSP Config <<<
--------------------------------------------------------------------------------
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
-- Use an on_attach function to only map the following keys after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  -- vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end
local lsp_flags = {
  debounce_text_changes = 150, -- This is the default in Nvim 0.7+
}
-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
-- Per-LSP setup here, attach keybinds
local lspconfig = require('lspconfig')
local servers = { 'gopls' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  }
end

-- Autocomplete (nvim-cmp and friends) setup
local luasnip = require 'luasnip'
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
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
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}