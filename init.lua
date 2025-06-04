--------------------------------------------------------------------------------
-- >>> Option Configuration <<<
--------------------------------------------------------------------------------
-- Space leader best leader
vim.g.mapleader = " "
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
vim.opt.mouse = "a"
-- Best of both worlds sign/number column
vim.opt.signcolumn = "yes"
-- Allow filetree viewer to set colors properly
vim.opt.termguicolors = true
-- I like to see whitespace
vim.opt.list = true
vim.opt.listchars:append("space:·")
-- Bash, pls
vim.opt.shell = "/usr/bin/env bash"
-- Disable netrw, in favor of a more featureful filetree viewer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Some formatters insist on tabs, make them 4 spaces wide
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- Change line wrapping and such behavior in markdown, for legibility while writing
vim.cmd([[autocmd FileType markdown setlocal nolist wrap linebreak]])
-- Yank/put to/from system clipboard for convenience
vim.opt.clipboard:append("unnamedplus")

--------------------------------------------------------------------------------
-- >>> Non-Plugin Key Mappings <<<
-- NOTE: keymaps are default non-recursive now, yay!
--------------------------------------------------------------------------------
local set = vim.keymap.set
-- My old faithfuls, you can't convince me these aren't right
set("n", "<leader>w", ":w<CR>", { desc = "Quicksave" })
set("n", ";", ":", { desc = "Enter command mode easier" })
set("i", "jh", "<esc>", { desc = "Escape insert mode from home" })
set("n", "<leader>yf", ':let @+ = expand("%")<CR>', { desc = "Yank relative path of current buffer to clipboard" })

-- Make navigating, yanking, etc easier
set({ "n", "v" }, "H", "^", { desc = "Navigate to line start" })
set({ "n", "v" }, "L", "$", { desc = "Navigate to line end" })
set("n", "Y", "yg_", { desc = "Make Y behave sanely" })

-- Niceties
set("i", "{<CR>", "{<CR>}<esc>O", { desc = "Automatically match brackets" })
set("i", "(<CR>", "(<CR>)<esc>O", { desc = "Automatically match parens" })
set("v", "<leader>x", ":lua<CR>", { desc = "Execute selected Lua code (for plugin/config dev)" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	callback = function(_)
		vim.highlight.on_yank({ higroup = "Visual", timeout = 500 })
	end,
})

vim.api.nvim_create_user_command(
	"BufOnly",
	'execute "%bd|e#|bd#"',
	{ desc = "Close all buffers (including filetree) other than the current" }
)

local function run_go_test_command(cmd, success_title, fail_title)
	-- Run the command in the current file's directory
	local file_dir = vim.fn.expand("%:p:h") -- Get the directory of the current file
	local output = vim.fn.systemlist("cd " .. file_dir .. " && " .. cmd)
	local output_str = table.concat(output, "\n")
	local timeout = 5000
	if vim.v.shell_error == 0 then
		vim.notify(output_str, vim.log.levels.INFO, { title = success_title, timeout = timeout })
	else
		vim.notify(
			"Error running go test:\n" .. output_str,
			vim.log.levels.ERROR,
			{ title = fail_title, timeout = timeout }
		)
	end
end
local function run_nearest_go_test()
	-- Get the test name under the cursor
	local test_name = vim.fn.search("^func Test", "bnW")
	if test_name == 0 then
		vim.notify("No test function found near the cursor", vim.log.levels.WARN, { title = "Go Test" })
		return
	end
	-- Extract the name of the test function
	local line = vim.fn.getline(test_name)
	local test_func = line:match("^func%s+(Test%w+)")
	if not test_func then
		vim.notify("Failed to parse test function name", vim.log.levels.ERROR, { title = "Go Test" })
		return
	end
	-- Build and run the `go test` command
	local cmd = "go test -v -run " .. test_func
	run_go_test_command(cmd, "Go Test Success", "Go Test Failed")
end
vim.api.nvim_create_user_command("Gotest", run_nearest_go_test, {})

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
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		version = "*",
		config = function()
			require("nvim-tree").setup({
				renderer = {
					group_empty = true,
				},
			})
			local api = require("nvim-tree.api")
			set("n", "tt", api.tree.toggle, { desc = "Toggle filetree viewer" })
			set("n", "tc", api.tree.collapse_all, { desc = "Close open folders in filetree viewer" })
			set("n", "tf", api.tree.find_file, { desc = "Open filetree to current file" })
			set("n", "to", api.tree.expand_all, { desc = "Open filetree and expand all directories" })
			set("n", "ts", ":NvimTreeResize -20<CR>", { desc = "Make filetree window smaller" })
			set("n", "tb", ":NvimTreeResize +20<CR>", { desc = "Make filetree window bigger" })
		end,
	},
	{
		"saghen/blink.cmp",
		-- use a release tag to download pre-built binaries
		version = "1.*",
		opts = {
			keymap = {
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				preset = "enter",
			},
			completion = { documentation = { auto_show = true } },
		},
		opts_extend = { "sources.default" },
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Keybind cheatsheet:
			-- Goto def: C-]
			-- Back: C-t
			-- Next/prev diagnostic: ]d/[d
			-- Show diagnostic: C-w d
			vim.lsp.enable("gopls")
			vim.lsp.enable("ts_ls")
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("basedpyright")
			vim.lsp.enable("ruff")
			vim.lsp.enable("rust_analyzer")

			-- Additional keybinds I'm setting because the baseline aren't quite cutting it for me
			set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
			set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
			set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
			set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				go = { "gofumpt" },
				lua = { "stylua" },
			},
			format_on_save = { timeout_ms = 500 },
		},
	},
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-context" },
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
				auto_install = true, -- Automatically install missing parsers when entering buffer
				highlight = { enable = true },
			})
			require("treesitter-context").setup({
				enable = false, -- Default to false, because it can be annoying, but keeping it around in case I want it
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					layout_strategy = "vertical",
				},
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or 'ignore_case' or 'respect_case', default is 'smart_case'
					},
				},
			})
			require("telescope").load_extension("fzf")
			local live_globular_grep = function(opts)
				opts = opts or {}
				opts.cwd = opts.cwd or vim.fn.getcwd()

				local finder = require("telescope.finders").new_async_job({
					command_generator = function(prompt)
						if not prompt or prompt == "" then
							return nil
						end
						local pieces = vim.split(prompt, "  ")
						local args = { "rg" }
						if pieces[1] then
							table.insert(args, "-e")
							table.insert(args, pieces[1])
						end
						if pieces[2] then
							table.insert(args, "-g")
							table.insert(args, pieces[2])
						end
						--@diagnostic disable-next-line: deprecated
						return vim.tbl_flatten({
							args,
							{
								"--color=never",
								"--no-heading",
								"--with-filename",
								"--line-number",
								"--column",
								"--smart-case",
							},
						})
					end,
					entry_maker = require("telescope.make_entry").gen_from_vimgrep(opts),
					cwd = opts.cwd,
				})

				require("telescope.pickers")
					.new(opts, {
						debounce = 100,
						prompt_title = "Globular Grep",
						finder = finder,
						previewer = require("telescope.config").values.grep_previewer(opts),
						sorter = require("telescope.sorters").empty(),
					})
					:find()
			end

			local t = require("telescope.builtin")
			set("n", "<leader>h", t.find_files, { desc = "Telescope find files" })
			set("n", "<leader>j", t.buffers, { desc = "Telescope find buffers" })
			set("n", "<leader>k", live_globular_grep, { desc = "Telescope - custom globular grep" })
			set("n", "<leader>qk", t.live_grep, { desc = "Telescope live grep" })
		end,
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"leoluz/nvim-dap-go",
			"nvim-neotest/nvim-nio",
		},
		init = function()
			local function toggle_ui()
				require("dapui").toggle({ reset = true })
			end
			_G.toggle_ui = toggle_ui
		end,
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			require("dap-go").setup()
			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "stacks", size = 0.3 },
							{ id = "breakpoints", size = 0.3 },
						},
						size = 30,
						position = "right",
					},
					{
						elements = {
							{ id = "watches", size = 0.5 },
							{ id = "scopes", size = 0.5 },
						},
						size = 10,
						position = "bottom",
					},
				},
			})
			-- Clean up duplicate configs
			local unique_configs = {}
			local seen = {}
			for _, config in ipairs(dap.configurations.go or {}) do
				if not seen[config.name] then
					table.insert(unique_configs, config)
					seen[config.name] = true
				end
			end
			-- Add custom headless attach config
			table.insert(unique_configs, 1, {
				name = "Attach To Headless (127.0.0.1:2346)",
				type = "go",
				request = "attach",
				mode = "remote",
				host = "127.0.0.1",
				port = 2346,
			})
			table.insert(unique_configs, 1, {
				name = "Attach To Headless (127.0.0.1:2345)",
				type = "go",
				request = "attach",
				mode = "remote",
				host = "127.0.0.1",
				port = 2345,
			})
			dap.configurations.go = unique_configs
			-- Auto open/close UI when debugging starts/stops
			dap.listeners.after.event_initialized["dapui_config"] = function()
				_G.toggle_ui()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.after.event_stopped["dapui_config"] = function()
				dapui.open()
			end
		end,
		keys = function()
			local dap = require("dap")
			local dap_go = require("dap-go")
			return {
				{
					"<leader>du",
					function()
						_G.toggle_ui()
					end,
					desc = "Toggle Debug UI",
				},
				{
					"<leader>dc",
					function()
						dap.continue()
					end,
					desc = "Start/Continue Debugging",
				},
				{
					"<leader>dC",
					function()
						dap.clear_breakpoints()
					end,
					desc = "Clear breakpoints",
				},
				{
					"<leader>dn",
					function()
						dap.step_over()
					end,
					desc = "Step Over",
				},
				{
					"<leader>di",
					function()
						dap.step_into()
					end,
					desc = "Step Into",
				},
				{
					"<leader>do",
					function()
						dap.step_out()
					end,
					desc = "Step Out",
				},
				{
					"<leader>db",
					function()
						dap.toggle_breakpoint()
					end,
					desc = "Toggle Breakpoint",
				},
				{
					"<leader>df",
					function()
						dap.focus_frame()
					end,
					desc = "Focus",
				},
				{
					"<leader>dt",
					function()
						dap_go.debug_test()
					end,
					desc = "Debug test",
				},
			}
		end,
	},
	{
		"ruifm/gitlinker.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitlinker").setup()
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				sections = {
					lualine_b = { "branch", "diff", "diagnostics", "spelunk" },
					lualine_c = {
						{ "filename", path = 1 },
					},
				},
			})
		end,
	},
	{
		"EvWilson/slimux.nvim",
		config = function()
			local slimux = require("slimux")
			slimux.setup({
				target_socket = slimux.get_tmux_socket(),
				target_pane = string.format("%s.2", slimux.get_tmux_window()),
			})
			set(
				"v",
				"<leader>r",
				':lua require("slimux").send_highlighted_text()<CR>',
				{ desc = "Send currently highlighted text to configured tmux pane" }
			)
			set(
				"n",
				"<leader>r",
				':lua require("slimux").send_paragraph_text()<CR>',
				{ desc = "Send paragraph under cursor to configured tmux pane" }
			)
		end,
	},
	{
		-- "EvWilson/spelunk.nvim",
		dir = "~/Documents/spelunk.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			local spelunk = require("spelunk")
			spelunk.setup({
				base_mappings = {
					toggle = "<C-h>",
					next_bookmark = "<C-j>",
					prev_bookmark = "<C-k>",
				},
				enable_persist = true,
				orientation = "horizontal",
			})
			spelunk.display_function = function(mark)
				local ctx = require("spelunk.util").get_treesitter_context(mark)
				ctx = (ctx == "" and ctx) or (" - " .. ctx)
				local filename = spelunk.filename_formatter(mark.file)
				return string.format("%s:%d%s", filename, mark.line, ctx)
			end
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					delete = "<leader>ds",
				},
			})
		end,
	},
	"tpope/vim-sleuth",
})
