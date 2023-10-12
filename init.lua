--------------------------------------------------------------------------------
-- >>> Option Configuration <<<
--------------------------------------------------------------------------------
-- Space leader best leader
vim.g.mapleader = ' '
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
-- Bootstrap lazy.nvim: https://github.com/folke/lazy.nvim#-installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim packages
require("lazy").setup({
  {
    -- Colorscheme
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
  {
    -- Filetree viewer
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    version = '*',
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set('n', 'tt', ':NvimTreeToggle<CR>', { desc = 'Toggle filetree viewer' })
      vim.keymap.set('n', 'tc', ':NvimTreeCollapse<CR>', { desc = 'Close open folders in filetree viewer' })
      vim.keymap.set('n', 'tf', ':NvimTreeFindFileToggle<CR>', { desc = 'Open filetree to current file' })
      vim.keymap.set('n', 'to', ':lua require("nvim-tree.api").tree.expand_all()<CR>',
        { desc = 'Open filetree and expand all directories' })
      vim.keymap.set('n', 'ts', ':NvimTreeResize -20<CR>', { desc = 'Make filetree window smaller' })
      vim.keymap.set('n', 'tb', ':NvimTreeResize +20<CR>', { desc = 'Make filetree window bigger' })
    end,
  },
  {
    -- LSP setup and config
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      {
        'williamboman/mason.nvim',
        build = function()
          vim.cmd([[MasonUpdate]])
        end,
      },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'L3MON4D3/LuaSnip' },
    },
    config = function()
      local lsp = require('lsp-zero').preset({
        name = "recommended",
      })

      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed = { 'gopls' },
        handlers = {
          lsp.default_setup,
          lua_ls = function()
            local lua_opts = lsp.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
          end,
        }
      })

      -- Keymaps ref: https://github.com/VonHeikemen/lsp-zero.nvim#keybindings
      lsp.on_attach(function(_, bufnr)
        lsp.default_keymaps({ buffer = bufnr })
        lsp.buffer_autoformat()
      end)
      lsp.format_on_save({
        format_opts = {
          async = false,
          timeout_ms = 10000,
        },
      })
      lsp.setup()

      local cmp = require('cmp')
      cmp.setup({
        preselect = 'item',
        completion = {
          completeopt = 'menu,menuone,noinsert'
        },
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
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
    -- Tree-sitter and related config
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-context' },
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'go' }, -- A list of parser names, or 'all'
        sync_install = false,        -- Install parsers synchronously (only applied to `ensure_installed`)
        auto_install = true,         -- Automatically install missing parsers when entering buffer
        highlight = { enable = true },
      }
    end,
  },
  {
    -- Fuzzy finder
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('telescope').setup {
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
      vim.keymap.set('n', '<leader>h', t.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>j', t.buffers, { desc = 'Telescope find buffers' })
      vim.keymap.set('n', '<leader>k', t.live_grep, { desc = 'Telescope live grep' })
    end,
  },
  {
    -- Debug Adapter Protocol with associated UI
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'theHamsta/nvim-dap-virtual-text',
      'leoluz/nvim-dap-go',
    },
    config = function()
      require("dapui").setup()
      require("nvim-dap-virtual-text").setup()
      require('dap-go').setup()

      vim.keymap.set('n', '<leader>gb', ':lua require("dap").toggle_breakpoint()<CR>', { desc = 'Toggle DAP breakpoint' })
      vim.keymap.set('n', '<leader>gc', ':lua require("dap").continue()<CR>', { desc = 'Continue in DAP' })
      vim.keymap.set('n', '<leader>go', ':lua require("dap").step_over()<CR>', { desc = 'Step over in DAP' })
      vim.keymap.set('n', '<leader>gi', ':lua require("dap").step_into()<CR>', { desc = 'Step into in DAP' })
      vim.keymap.set('n', '<leader>gq', ':lua require("dap").terminate()<CR>', { desc = 'Terminate DAP session' })
    end,
  },

  -- Assorted and miscellaneous
  {
    -- Status bar upgrade
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        sections = { lualine_c = { { 'filename', path = 1 } } },
        tabline = { lualine_a = { { 'buffers', show_filename_only = false } } } -- Show open buffers in top line
      }
    end
  },
  {
    -- Send text to tmux panes
    'EvWilson/slimux.nvim',
    config = function()
      local slimux = require('slimux')
      slimux.setup({
        target_socket = slimux.get_tmux_socket(),
        target_pane = string.format('%s.2', slimux.get_tmux_window()),
      })
      vim.keymap.set('v', '<leader>r', ':lua require("slimux").send_highlighted_text()<CR>',
        { desc = 'Send currently highlighted text to configured tmux pane' })
      vim.keymap.set('n', '<leader>r', ':lua require("slimux").send_paragraph_text()<CR>',
        { desc = 'Send paragraph under cursor to configured tmux pane' })
    end
  },
  'tpope/vim-surround',    -- 'cs{old}{new} to change surround, 'ys{motion}{char}' to add surround
  'tpope/vim-commentary',  -- 'gc' in some permutation to toggle comments!, NOTE: see Commentary.nvim for future
  'tpope/vim-sleuth',      -- Detect tabstop and shiftwidth automatically
  'kana/vim-textobj-user', -- Enables custom text objects in other plugins
})

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

--------------------------------------------------------------------------------
-- >>> Language-specific Config <<<
--------------------------------------------------------------------------------
-- Go
-- TODO: need "run test under cursor" next
local function go_tags(op, tagnames)
  local joined = string.gsub(tagnames, " ", ",")
  local cmd_args = { "gomodifytags", "-file", vim.fn.expand("%"), "-struct", vim.fn.expand("<cword>"), op, joined, "-w" }
  vim.fn.system(cmd_args)
  vim.cmd("edit")
end
-- Make sure to put the cursor over the struct definition line
vim.api.nvim_create_user_command('GoAddTag', function(names) go_tags('-add-tags', names.args) end,
  { desc = "Add tags to Go struct name under cursor", nargs = '*' })
vim.api.nvim_create_user_command('GoRmTag', function(names) go_tags('-remove-tags', names.args) end,
  { desc = "Remove tags from Go struct name under cursor", nargs = '*' })
