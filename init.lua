-- TODO: show all open buffers
-- TODO: check out https://github.com/mfussenegger/nvim-dap for debugging

--------------------------------------------------------------------------------
-- >>> Option Configuration <<<
--------------------------------------------------------------------------------
-- Default tabs to four spaces
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

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
vim.opt.undodir = "~/.vimdid"
vim.opt.undofile = true

-- Enhanced tab completion
vim.opt.wildmenu = true

-- Maintain this many lines of context when scrolling, if possible
vim.opt.scrolloff = 15

-- Enable the mouse to set the cursor location
vim.opt.mouse = "a"

-- Best of both worlds sign/number column
vim.opt.signcolumn = "yes"

-- Allow filetree viewer to set colors properly
vim.opt.termguicolors = true

-- I like to see whitespace
vim.opt.list = true
vim.opt.listchars:append("space:·")

-- Bash, pls
vim.opt.shell = "/bin/bash"

-- Set colorsheme, imported as plugin
vim.cmd('colorscheme gruvbox')

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
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets plugin

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' } -- Tree-sitter
  use 'nvim-treesitter/nvim-treesitter-context'
  use 'nvim-lualine/lualine.nvim' -- Status bar upgrade
  use 'tpope/vim-fugitive' -- Mostly used for git status bar integration
  use 'machakann/vim-highlightedyank' -- Double check your yanks
  use 'tpope/vim-surround' -- Project page: https://github.com/tpope/vim-surround
  use 'tpope/vim-commentary' -- 'gc' in some permutation to toggle comments!
  use 'kana/vim-textobj-user' -- Enables custom text objects in other plugins
  use 'thinca/vim-textobj-between' -- 'ci{motion}' to change between objects in motion
  use 'Julian/vim-textobj-brace' -- 'cij' to change between brace pair
  use 'junegunn/fzf' -- Fuzzy finder
  use 'junegunn/fzf.vim' -- And helper friend
  use {'fatih/vim-go', run = ':GoUpdateBinaries' } -- For all things Go (love this)
  use 'udalov/kotlin-vim' -- Syntax highlight
  use 'ziglang/zig.vim' -- Syntax highlight

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)
if install_plugins then
  return
end

-- Quick lualine configuration (mostly disabling extras)
require('lualine').setup {
  options = {
    icons_enabled = false,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  },
}

-- Quick treesitter highlighting setup
require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'go' }, -- A list of parser names, or "all"
  sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
  auto_install = true, -- Automatically install missing parsers when entering buffer
  highlight = {
    enable = true,
  },
}

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
vim.keymap.set('n', '<leader>sop', ':source ~/.config/nvim/init.lua<cr>', {desc = 'Source config file'})

-- FZF keymap configuration
vim.keymap.set('n', '<leader>h', ':Files<cr>', {desc = 'Open file selection via fzf'})
vim.keymap.set('n', '<leader>j', ':Buffers<cr>', {desc = 'Open buffer selection via fzf'})
-- Make project ripgrep behave as expected when used as the backend to fzf
-- Stolen ages ago, need to figure out how to adapt to Lua future
vim.cmd [[
let g:rg_command = '
  \ rg --column --line-number --no-heading --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "!{.git,node_modules,vendor}/*" '
command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)
]]
vim.keymap.set('n', '<leader>k', ':F<CR>', {desc = 'Open line selection via fzf/rg'})

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
