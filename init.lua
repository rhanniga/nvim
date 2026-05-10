-- VSCODE GUARD
if vim.g.vscode then
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
	return
end

-- bytecode cache for lua modules
vim.loader.enable()

-- disable unused builtin plugins
local disabled_builtins = {
	"gzip",
	"matchit",
	"matchparen",
	"netrwPlugin",
	"tarPlugin",
	"tohtml",
	"tutor",
	"zipPlugin",
}
for _, plugin in ipairs(disabled_builtins) do
	vim.g["loaded_" .. plugin] = 1
end

-- HELPER FUNCTIONS FOR LOADING
local add = vim.pack.add
add({ "https://github.com/nvim-mini/mini.nvim" })
local misc = require("mini.misc")
local now = function(f)
	misc.safely("now", f)
end
local later = function(f)
	misc.safely("later", f)
end
local now_if_args = vim.fn.argc(-1) > 0 and now or later

local dagroup = vim.api.nvim_create_augroup("dagroup", { clear = true })

local new_autocmd = function(event, pattern, callback, desc)
	local opts = { group = dagroup, pattern = pattern, callback = callback, desc = desc }
	vim.api.nvim_create_autocmd(event, opts)
end

local on_packchanged = function(plugin_name, kinds, callback, desc)
	if vim.fn.has("nvim-0.12") == 0 then
		return
	end
	local f = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
			return
		end
		if not ev.data.active then
			vim.cmd.packadd(plugin_name)
		end
		callback()
	end
	new_autocmd("PackChanged", "*", f, desc)
end

local k = function(modes, keys, fn, desc, opts)
	opts = opts or {}
	opts.desc = desc
	vim.keymap.set(modes, keys, fn, opts)
end

-- OPTIONS
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.g.have_nerd_font = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.winborder = "rounded"

-- KEYMAPS
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- AUTOCMDS
-- highlighting on yank for practical aesthetics!
new_autocmd("TextYankPost", "*", function()
	vim.hl.on_yank()
end, "Highlight when yanking (copying) text")

-- Disable lsp-semantic-highlighting for rust
new_autocmd("LspAttach", "*.rs", function(args)
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if client and client.name == "rust_analyzer" then
		client.server_capabilities.semanticTokensProvider = nil
	end
end, "Disable semantic tokens for rust_analyzer")

local annoying_windows = {
	"PlenaryTestPopup",
	"checkhealth",
	"dbout",
	"gitsigns-blame",
	"grug-far",
	"help",
	"lspinfo",
	"neotest-output",
	"neotest-output-panel",
	"neotest-summary",
	"notify",
	"qf",
	"spectre_panel",
	"startuptime",
	"tsplayground",
}
local close_helper = function(event)
	vim.bo[event.buf].buflisted = false
	vim.schedule(function()
		vim.keymap.set("n", "q", function()
			vim.cmd("close")
			pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
		end, {
			buffer = event.buf,
			silent = true,
			desc = "Quit buffer",
		})
	end)
end
new_autocmd("FileType", annoying_windows, close_helper, "Easier to close certain files with q")

local manback = function(event)
	vim.bo[event.buf].buflisted = false
end
new_autocmd("FileType", "man", manback, "Close man-files when opened inline")

local wrapcheck = function()
	vim.opt_local.wrap = true
	vim.opt_local.spell = true
end
local textybois = { "text", "plaintex", "typst", "gitcommit", "markdown" }
new_autocmd("FileType", textybois, wrapcheck, "Wrap and check spelling in text-like files")

local jsonconcpattern = { "json", "jsonc", "json5" }
local concealcallback = function()
	vim.opt_local.conceallevel = 0
end
new_autocmd("FileType", jsonconcpattern, concealcallback, "Fix json conceal")

local removeautocomment = function()
	vim.opt.formatoptions:remove({ "c", "r", "o" })
end
new_autocmd("FileType", "*", removeautocomment, "Disable autocomment on newline")

-- restore last cursor location when opening a buffer
local last_loc = function(event)
	local exclude = { "gitcommit" }
	local buf = event.buf
	if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].da_last_loc then
		return
	end
	vim.b[buf].da_last_loc = true
	local mark = vim.api.nvim_buf_get_mark(buf, '"')
	local lcount = vim.api.nvim_buf_line_count(buf)
	if mark[1] > 0 and mark[1] <= lcount then
		pcall(vim.api.nvim_win_set_cursor, 0, mark)
	end
end
new_autocmd("BufReadPost", "*", last_loc, "Restore last cursor location")

-- create dir when saving a file with intermediate dirs that don't exist
local auto_create_dir = function(event)
	if event.match:match("^%w%w+:[\\/][\\/]") then
		return
	end
	local file = vim.uv.fs_realpath(event.match) or event.match
	vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
end
new_autocmd("BufWritePre", "*", auto_create_dir, "Auto-create missing dirs on save")

-- COLOR
now(function()
	add({ "https://github.com/gbprod/nord.nvim" })
	vim.cmd.colorscheme("nord")
end)

-- MINI
later(function()
	require("mini.ai").setup({ n_lines = 500 })
	require("mini.surround").setup()
	local statusline = require("mini.statusline")
	statusline.setup({ use_icons = vim.g.have_nerd_font })
	statusline.section_location = function()
		return "%2l:%-2v"
	end
end)

-- BLINK.CMP (+ LuaSnip + friendly-snippets)
later(function()
	on_packchanged("LuaSnip", { "install", "update" }, function()
		if vim.fn.executable("make") == 1 then
			local cwd = vim.fn.stdpath("data") .. "/site/pack/core/opt/LuaSnip"
			vim.system({ "make", "install_jsregexp" }, { cwd = cwd })
		end
	end, "LuaSnip jsregexp build")

	on_packchanged("blink.cmp", { "install", "update" }, function()
		require("blink.cmp").build():wait(60000)
	end, "blink.cmp native build")

	add({
		"https://github.com/L3MON4D3/LuaSnip",
		"https://github.com/rafamadriz/friendly-snippets",
		"https://github.com/saghen/blink.lib",
		"https://github.com/saghen/blink.cmp",
	})

	require("luasnip.loaders.from_vscode").lazy_load()

	require("blink.cmp").setup({
		keymap = { preset = "default" },
		appearance = { nerd_font_variant = "mono" },
		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 500 },
		},
		sources = {
			default = { "lsp", "snippets", "path", "lazydev" },
			providers = {
				lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
			},
		},
		snippets = { preset = "luasnip" },
		fuzzy = { implementation = "prefer_rust_with_warning" },
		signature = { enabled = true },
	})
end)

-- TREESITTER
later(function()
	local ts_update = function()
		vim.cmd("TSUpdate")
	end
	on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")
	add({
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
		"https://github.com/windwp/nvim-ts-autotag",
		"https://github.com/rayliwell/tree-sitter-rstml",
	})

	local ensure_languages = {
		"bash",
		"c",
		"cpp",
		"css",
		"diff",
		"go",
		"html",
		"javascript",
		"json",
		"lua",
		"luadoc",
		"markdown",
		"markdown_inline",
		"php",
		"python",
		"query",
		"regex",
		"rust",
		"toml",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"yaml",
	}
	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, ensure_languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Ensure enabled
	local filetypes = vim.iter(ensure_languages):map(vim.treesitter.language.get_filetypes):flatten():totable()
	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end
	new_autocmd("FileType", filetypes, ts_start, "Ensure enabled tree-sitter")

	require("nvim-ts-autotag").setup()
	pcall(function()
		require("tree-sitter-rstml").setup()
	end)
end)

-- LSP
later(function()
	vim.diagnostic.config({
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = { severity = vim.diagnostic.severity.ERROR },
		signs = vim.g.have_nerd_font and {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚 ",
				[vim.diagnostic.severity.WARN] = "󰀪 ",
				[vim.diagnostic.severity.INFO] = "󰋽 ",
				[vim.diagnostic.severity.HINT] = "󰌶 ",
			},
		} or {},
		virtual_text = {
			source = "if_many",
			spacing = 2,
			format = function(diagnostic)
				local diagnostic_message = {
					[vim.diagnostic.severity.ERROR] = diagnostic.message,
					[vim.diagnostic.severity.WARN] = diagnostic.message,
					[vim.diagnostic.severity.INFO] = diagnostic.message,
					[vim.diagnostic.severity.HINT] = diagnostic.message,
				}
				return diagnostic_message[diagnostic.severity]
			end,
		},
	})

	add({ "https://github.com/mason-org/mason.nvim" })
	require("mason").setup()
	add({ "https://github.com/mason-org/mason-lspconfig.nvim" })
	add({ "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" })
	add({ "https://github.com/neovim/nvim-lspconfig" })
	add({ "https://github.com/j-hui/fidget.nvim" })
	require("fidget").setup({})

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local ok_blink, blink = pcall(require, "blink.cmp")
	if ok_blink then
		capabilities = blink.get_lsp_capabilities(capabilities)
	end

	local servers = {
		clangd = {},
		gopls = {},
		basedpyright = {},
		rust_analyzer = {
			settings = {
				cargo = {
					allFeatures = true,
				},
				procMacro = {
					ignored = {
						leptos_macro = {
							"server",
						},
					},
				},
				rustfmt = {
					overrideCommand = { "leptosfmt", "--stdin", "--rustfmt" },
				},
			},
		},
		ts_ls = {
			root_dir = require("lspconfig").util.root_pattern({ "package.json", "tsconfig.json" }),
			single_file_support = false,
			settings = {},
		},
		denols = {
			root_dir = require("lspconfig").util.root_pattern({ "deno.json", "deno.jsonc" }),
			single_file_support = false,
			settings = {},
		},
		lua_ls = {
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		},
	}

	local ensure_installed = vim.tbl_keys(servers or {})
	local extra_tools = { "stylua" }
	local tool_list = {}
	vim.list_extend(tool_list, ensure_installed)
	vim.list_extend(tool_list, extra_tools)
	require("mason-tool-installer").setup({ ensure_installed = tool_list })

	require("mason-lspconfig").setup({
		ensure_installed = {},
		automatic_installation = false,
		handlers = {
			function(server_name)
				local server = servers[server_name] or {}
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				require("lspconfig")[server_name].setup(server)
			end,
		},
	})
end)

-- CONFORM (formatting)
later(function()
	add({ "https://github.com/stevearc/conform.nvim" })

	require("conform").setup({
		default_format_opts = {
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			javascript = { "prettier" },
			json = { "prettier" },
			lua = { "stylua" },
			python = { "black" },
			rust = { "leptosfmt" },
		},
	})
end)

-- LAZYDEV (lua LSP for nvim config)
later(function()
	add({ "https://github.com/folke/lazydev.nvim" })
	require("lazydev").setup({
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})
end)

-- GITSIGNS
later(function()
	add({ "https://github.com/lewis6991/gitsigns.nvim" })
	require("gitsigns").setup({
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
	})
end)

-- WHICH-KEY
later(function()
	add({ "https://github.com/folke/which-key.nvim" })
	require("which-key").setup({
		delay = 0,
		icons = {
			mappings = vim.g.have_nerd_font,
			keys = vim.g.have_nerd_font and {} or {
				Up = "<Up> ",
				Down = "<Down> ",
				Left = "<Left> ",
				Right = "<Right> ",
				C = "<C-…> ",
				M = "<M-…> ",
				D = "<D-…> ",
				S = "<S-…> ",
				CR = "<CR> ",
				Esc = "<Esc> ",
				ScrollWheelDown = "<ScrollWheelDown> ",
				ScrollWheelUp = "<ScrollWheelUp> ",
				NL = "<NL> ",
				BS = "<BS> ",
				Space = "<Space> ",
				Tab = "<Tab> ",
				F1 = "<F1>",
				F2 = "<F2>",
				F3 = "<F3>",
				F4 = "<F4>",
				F5 = "<F5>",
				F6 = "<F6>",
				F7 = "<F7>",
				F8 = "<F8>",
				F9 = "<F9>",
				F10 = "<F10>",
				F11 = "<F11>",
				F12 = "<F12>",
			},
		},
		spec = {
			mode = { "n", "v", "x" },
			{ "<leader>c", group = "[c]ode" },
			{ "<leader>f", group = "[f]ind" },
			{ "<leader>g", group = "[g]it" },
			{ "<leader>s", group = "[s]earch" },
			{ "<leader>u", group = "[u]i" },
			{ "<leader>l", group = "[l]atex" },
			{ "<leader>b", group = "[b]uffer" },
		},
	})
end)

-- SNACKS (setup eagerly so bigfile/quickfile take effect on first BufRead)
now(function()
	add({ "https://github.com/folke/snacks.nvim" })
	require("snacks").setup({
		bigfile = { enabled = true },
		picker = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		image = { enabled = true },
		words = { enabled = true },
	})
end)

-- snacks keymaps + toggles (deferred — not needed for startup)
later(function()
	-- Pickers
	k("n", "<leader><space>", function() Snacks.picker.smart() end, "smart find")
	k("n", "<leader>/", function() Snacks.picker.grep() end, "grep workspace")
	k("n", "<leader>:", function() Snacks.picker.command_history() end, "command history")
	k("n", "<leader>fb", function() Snacks.picker.buffers() end, "[f]ind [b]uffers")
	k("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, "[f]ind [c]onfig")
	k("n", "<leader>ff", function() Snacks.picker.files() end, "[f]ind [f]iles")
	k("n", "<leader>fg", function() Snacks.picker.git_files() end, "[f]ind [g]it")
	k("n", "<leader>fp", function() Snacks.picker.projects() end, "[f]ind [p]rojects")
	k("n", "<leader>fr", function() Snacks.picker.recent() end, "[f]ind [r]ecent")

	-- git
	k("n", "<leader>gb", function() Snacks.picker.git_branches() end, "[g]it [b]ranches")
	k("n", "<leader>gl", function() Snacks.picker.git_log() end, "[g]it [l]og")
	k("n", "<leader>gL", function() Snacks.picker.git_log_line() end, "[g]it [L]og Line")
	k("n", "<leader>gs", function() Snacks.picker.git_status() end, "[g]it [s]tatus")
	k("n", "<leader>gS", function() Snacks.picker.git_stash() end, "[g]it [S]tash")
	k("n", "<leader>gd", function() Snacks.picker.git_diff() end, "[g]it [d]iff")
	k("n", "<leader>gf", function() Snacks.picker.git_log_file() end, "[g]it [f]ile log")

	-- search
	k("n", "<leader>sB", function() Snacks.picker.grep_buffers() end, "Grep Open Buffers")
	k("n", "<leader>sg", function() Snacks.picker.grep() end, "[s]earch [g]rep")
	k({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, "[s]earch for selected [w]ord")
	k("n", '<leader>s"', function() Snacks.picker.registers() end, '[s]earch ["] (registers)')
	k("n", "<leader>s/", function() Snacks.picker.search_history() end, "[s]earch [/]")
	k("n", "<leader>sa", function() Snacks.picker.autocmds() end, "[s]earch [a]utocmds")
	k("n", "<leader>sb", function() Snacks.picker.lines() end, "[s]earch [b]uffer lines")
	k("n", "<leader>sc", function() Snacks.picker.command_history() end, "[s]earch [c]ommand history")
	k("n", "<leader>sC", function() Snacks.picker.commands() end, "[s]earch [C]ommands")
	k("n", "<leader>sd", function() Snacks.picker.diagnostics() end, "[s]earch [d]iagnostics")
	k("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, "[s]earch [D]iagnostics Buffer")
	k("n", "<leader>sh", function() Snacks.picker.help() end, "[s]earch [h]elp")
	k("n", "<leader>sH", function() Snacks.picker.highlights() end, "[s]earch [H]ighlight groups")
	k("n", "<leader>si", function() Snacks.picker.icons() end, "[s]earch [i]cons")
	k("n", "<leader>sj", function() Snacks.picker.jumps() end, "[s]earch [j]umps")
	k("n", "<leader>sk", function() Snacks.picker.keymaps() end, "[s]earch [k]eymaps")
	k("n", "<leader>sl", function() Snacks.picker.loclist() end, "[s]earch [l]oclist")
	k("n", "<leader>sm", function() Snacks.picker.marks() end, "[s]earch [m]arks")
	k("n", "<leader>sM", function() Snacks.picker.man() end, "[s]earch [M]an pages")
	k("n", "<leader>sp", function() Snacks.picker.lazy() end, "[s]earch [p]lugins")
	k("n", "<leader>sq", function() Snacks.picker.qflist() end, "[s]earch [q]uickfix list")
	k("n", "<leader>sR", function() Snacks.picker.resume() end, "[s]earch [R]esume")
	k("n", "<leader>su", function() Snacks.picker.undo() end, "[s]earch [u]ndo history")
	k("n", "<leader>uC", function() Snacks.picker.colorschemes() end, "[C]olorschemes")

	-- LSP
	k("n", "gd", function() Snacks.picker.lsp_definitions() end, "[g]oto [d]efinition")
	k("n", "gD", function() Snacks.picker.lsp_declarations() end, "[g]oto [D]eclaration")
	k("n", "gA", function() Snacks.picker.lsp_references() end, "[g]oto [A]ll References", { nowait = true })
	k("n", "gI", function() Snacks.picker.lsp_implementations() end, "[g]oto [I]mplementation")
	k("n", "gy", function() Snacks.picker.lsp_type_definitions() end, "[g]oto t[y]pe def")
	k("n", "g.", function() vim.lsp.buf.code_action() end, "[g]oto [.]action")
	k("n", "<leader>gs", function() Snacks.picker.lsp_symbols() end, "[g]oto [s]ymbols")
	k("n", "<leader>gS", function() Snacks.picker.lsp_workspace_symbols() end, "[g]oto [S]ymbols (workspace)")

	-- Other
	k("n", "<leader>z", function() Snacks.zen() end, "toggle [z]en")
	k("n", "<leader>Z", function() Snacks.zen.zoom() end, "toggle [Z]oom")
	k("n", "<leader>.", function() Snacks.scratch() end, "toggle scratch")
	k("n", "<leader>S", function() Snacks.scratch.select() end, "select scratch")
	k("n", "<leader>n", function() Snacks.notifier.show_history() end, "notifications")
	k("n", "<leader>bd", function() Snacks.bufdelete() end, "[b]uffer [d]elete")
	k("n", "cR", function() Snacks.rename.rename_file() end, "[c]hange filename ([R]ename)")
	k("n", "cd", function() vim.lsp.buf.rename() end, "[c]hange [d]efinition")
	k("n", "<leader>cd", function() vim.diagnostic.open_float() end, "[c]ode [d]iagnostics")
	k({ "n", "v" }, "<leader>gB", function() Snacks.gitbrowse() end, "[g]it [B]rowse")
	k("n", "<leader>gg", function() Snacks.lazygit() end, "[g]azy [g]it")
	k("n", "<leader>un", function() Snacks.notifier.hide() end, "[u]i [n]o more notifications")
	k({ "n", "t" }, "]]", function() Snacks.words.jump(vim.v.count1) end, "next ref")
	k({ "n", "t" }, "[[", function() Snacks.words.jump(-vim.v.count1) end, "prev ref")

	-- toggles
	Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
	Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
	Snacks.toggle.option("linebreak", { name = "Linebreak" }):map("<leader>ul")
	Snacks.toggle.diagnostics():map("<leader>ud")
	Snacks.toggle
		.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
		:map("<leader>uc")
	Snacks.toggle.treesitter():map("<leader>ut")
	Snacks.toggle.inlay_hints():map("<leader>uh")

	-- debug helpers
	_G.dd = function(...)
		Snacks.debug.inspect(...)
	end
	_G.bt = function()
		Snacks.debug.backtrace()
	end
	vim.print = _G.dd
end)

-- OIL
now_if_args(function()
	add({ "https://github.com/stevearc/oil.nvim" })
	add({ "https://github.com/nvim-tree/nvim-web-devicons" })

	require("oil").setup({
		default_file_explorer = true,
		columns = {
			"icon",
		},
	})
end)

local conf = function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end
vim.keymap.set("n", "<leader>f", conf, { desc = "[F]ormat buffer" })
vim.keymap.set("n", "<leader>e", function()
	require("oil").toggle_float()
end, { desc = "[E]xplore" })
