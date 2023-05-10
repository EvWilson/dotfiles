--- explore treesitter highlighting
--	- I'd love a query to highlight matching brackets for the current paragraph/block/context
--	- this was a bit of an inspiration: https://github.com/lukas-reineke/indent-blankline.nvim
--- better wrangle DAP
--- better wrangle SQL-mode
--	- write own plugin?

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
vim.cmd[[autocmd FileType markdown setlocal nolist wrap linebreak]]
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
  { -- Colorscheme
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  { -- Filetree viewer
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
      vim.keymap.set('n', 'to', ':lua require("nvim-tree.api").tree.expand_all()<CR>', { desc = 'Open filetree and expand all directories' })
    end,
  },
  { -- LSP setup and config
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {
        'williamboman/mason.nvim',
        build = function()
          vim.cmd([[MasonUpdate]])
        end,
      },
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'L3MON4D3/LuaSnip'},
    },
    config = function()
      local lsp = require('lsp-zero').preset({})
      lsp.on_attach(function(_, bufnr)
        lsp.default_keymaps({buffer = bufnr})
      end)
      -- (Optional) Configure lua language server for neovim
      require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
      lsp.setup()
    end,
  },
  { -- Tree-sitter and related config
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      {'nvim-treesitter/nvim-treesitter-context'},
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'go' }, -- A list of parser names, or 'all'
        sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
        auto_install = true, -- Automatically install missing parsers when entering buffer
        highlight = { enable = true },
      }
    end,
  },
  { -- Fuzzy finder
    'nvim-telescope/telescope.nvim',
    version = '0.1.1',
    dependencies = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    },
    config = function()
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
      local t = require('telescope.builtin')
      vim.keymap.set('n', '<leader>h', t.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>j', t.buffers, { desc = 'Telescope find buffers' })
      vim.keymap.set('n', '<leader>k', t.live_grep, { desc = 'Telescope live grep' })
    end,
  },
  { -- SQL utilities
    'tpope/vim-dadbod',
    dependencies = {
      {'tpope/vim-dotenv'},
      {'kristijanhusak/vim-dadbod-ui'},
      {'kristijanhusak/vim-dadbod-completion'},
    },
    config = function()
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
    end,
  },

  -- Assorted and miscellaneous
  { -- Status bar upgrade
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        sections = { lualine_c = { { 'filename', path = 1 } } },
        tabline = { lualine_a = { { 'buffers', show_filename_only = false } } } -- Show open buffers in top line
      }
    end
  },
  'tpope/vim-surround', -- 'cs{old}{new} to change surround, 'ys{motion}{char}' to add surround
  'tpope/vim-commentary', -- 'gc' in some permutation to toggle comments!, NOTE: see Commentary.nvim for future
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'kana/vim-textobj-user', -- Enables custom text objects in other plugins
  -- 'thinca/vim-textobj-between', -- 'ci{motion}' to change between objects in motion

  -- Nursery - plugins I'm not fully sold on yet
  { 'rcarriga/nvim-dap-ui', -- Bring in generic debugger with associated UI
    dependencies = {
      'mfussenegger/nvim-dap',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      -- TODO: configure DAP key mappings
      require("dapui").setup()
      require("nvim-dap-virtual-text").setup()
    end,
  },
  'leoluz/nvim-dap-go', -- dap configuration for Go
  'jpalardy/vim-slime', -- send file contents to listening REPL
})

--------------------------------------------------------------------------------
-- >>> Key Mappings <<<
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
vim.keymap.set({'n', 'v'}, 'H', '^', { desc = 'Navigate to line start' })
vim.keymap.set({'n', 'v'}, 'L', '$', { desc = 'Navigate to line end' })
vim.keymap.set('n', 'Y', 'yg_', { desc = 'Make Y behave sanely' })

-- Niceties
vim.keymap.set('i', '{<cr>', '{<cr>}<esc>O', { desc = 'Automatically match brackets' })
vim.keymap.set('i', '(<cr>', '(<cr>)<esc>O', { desc = 'Automatically match parens' })
vim.keymap.set('n', '<c-l>', ':noh<cr>', { desc = 'Clear search highlight' })
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggVG<cr>', { desc = 'Select all text in the current buffer' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  callback = function(_)
    vim.highlight.on_yank({higroup = 'Visual', timeout = 500})
  end
})

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
vim.api.nvim_create_user_command('GoAddTag', function(names) go_tags('-add-tags', names.args) end, { desc = "Add tags to Go struct name under cursor", nargs='*' })
vim.api.nvim_create_user_command('GoRmTag', function(names) go_tags('-remove-tags', names.args) end, { desc = "Remove tags from Go struct name under cursor", nargs='*' })

-- Lisp
-- TODO: paren/bracket closer next
-- See: https://github.com/jpalardy/vim-slime#tmux
-- TODO: just rewrite the portion of this plugin I'm using in Lua
vim.cmd [[
let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":0.2"}
]]
