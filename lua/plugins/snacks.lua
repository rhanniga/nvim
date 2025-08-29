return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      image = { enabled = true },
      words = { enabled = true },
    },
    keys = {

      {
        '<leader><space>',
        function()
          require('snacks').picker.smart()
        end,
        desc = 'smart find',
      },

      {
        '<leader>/',
        function()
          Snacks.picker.grep()
        end,
        desc = 'grep workspace',
      },
      {
        '<leader>:',
        function()
          Snacks.picker.command_history()
        end,
        desc = 'command history',
      },
      {
        '<leader>n',
        function()
          Snacks.picker.notifications()
        end,
        desc = 'notfications',
      },
      {
        '<leader>fb',
        function()
          Snacks.picker.buffers()
        end,
        desc = '[f]ind [b]uffers',
      },
      {
        '<leader>fc',
        function()
          Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
        end,
        desc = '[f]ind [c]onfig',
      },
      {
        '<leader>ff',
        function()
          Snacks.picker.files()
        end,
        desc = '[f]ind [f]iles',
      },
      {
        '<leader>fg',
        function()
          Snacks.picker.git_files()
        end,
        desc = '[f]ind [g]it',
      },
      {
        '<leader>fp',
        function()
          Snacks.picker.projects()
        end,
        desc = '[f]ind [p]rojects',
      },
      {
        '<leader>fr',
        function()
          Snacks.picker.recent()
        end,
        desc = '[f]ind [r]ecent',
      },
      -- git
      {
        '<leader>gb',
        function()
          Snacks.picker.git_branches()
        end,
        desc = '[g]it [b]ranches',
      },
      {
        '<leader>gl',
        function()
          Snacks.picker.git_log()
        end,
        desc = '[g]it [l]og',
      },
      {
        '<leader>gL',
        function()
          Snacks.picker.git_log_line()
        end,
        desc = '[g]it [L]og Line',
      },
      {
        '<leader>gs',
        function()
          Snacks.picker.git_status()
        end,
        desc = '[g]it [s]tatus',
      },
      {
        '<leader>gS',
        function()
          Snacks.picker.git_stash()
        end,
        desc = '[g]it [S]tash',
      },
      {
        '<leader>gd',
        function()
          Snacks.picker.git_diff()
        end,
        desc = '[g]it [d]iff',
      },
      {
        '<leader>gf',
        function()
          Snacks.picker.git_log_file()
        end,
        desc = '[g]it [f]ile log',
      },
      -- Grep
      {
        '<leader>sb',
        function()
          Snacks.picker.lines()
        end,
        desc = 'Buffer Lines',
      },
      {
        '<leader>sB',
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = 'Grep Open Buffers',
      },
      {
        '<leader>sg',
        function()
          Snacks.picker.grep()
        end,
        desc = '[s]earch [g]rep',
      },
      {
        '<leader>sw',
        function()
          Snacks.picker.grep_word()
        end,
        desc = '[s]earch for selected [w]ord',
        mode = { 'n', 'x' },
      },
      -- search
      {
        '<leader>s"',
        function()
          Snacks.picker.registers()
        end,
        desc = '[s]earch ["] (registers)',
      },
      {
        '<leader>s/',
        function()
          Snacks.picker.search_history()
        end,
        desc = '[s]earch [/]',
      },
      {
        '<leader>sa',
        function()
          Snacks.picker.autocmds()
        end,
        desc = '[s]earch [a]utocmds',
      },
      {
        '<leader>sb',
        function()
          Snacks.picker.lines()
        end,
        desc = '[s]earch [b]uffer lines',
      },
      {
        '<leader>sc',
        function()
          Snacks.picker.command_history()
        end,
        desc = '[s]earch [c]ommand history',
      },
      {
        '<leader>sC',
        function()
          Snacks.picker.commands()
        end,
        desc = '[s]earch [C]ommands',
      },
      {
        '<leader>sd',
        function()
          Snacks.picker.diagnostics()
        end,
        desc = '[s]earch [d]iagnostics',
      },
      {
        '<leader>sD',
        function()
          Snacks.picker.diagnostics_buffer()
        end,
        desc = '[s]earch [D]iagnostics Buffer',
      },
      {
        '<leader>sh',
        function()
          Snacks.picker.help()
        end,
        desc = '[s]earch [h]elp',
      },
      {
        '<leader>sH',
        function()
          Snacks.picker.highlights()
        end,
        desc = '[s]earch [H]ighlight groups',
      },
      {
        '<leader>si',
        function()
          Snacks.picker.icons()
        end,
        desc = '[s]earch [i]cons',
      },
      {
        '<leader>sj',
        function()
          Snacks.picker.jumps()
        end,
        desc = '[s]earch [j]umps',
      },
      {
        '<leader>sk',
        function()
          Snacks.picker.keymaps()
        end,
        desc = '[s]earch [k]eymaps',
      },
      {
        '<leader>sl',
        function()
          Snacks.picker.loclist()
        end,
        desc = '[s]earch [l]oclist',
      },
      {
        '<leader>sm',
        function()
          Snacks.picker.marks()
        end,
        desc = '[s]earch [m]arks',
      },
      {
        '<leader>sM',
        function()
          Snacks.picker.man()
        end,
        desc = '[s]earch [M]an pages',
      },
      {
        '<leader>sp',
        function()
          Snacks.picker.lazy()
        end,
        desc = '[s]earch [p]lugins',
      },
      {
        '<leader>sq',
        function()
          Snacks.picker.qflist()
        end,
        desc = '[s]earch [q]uickfix list',
      },
      {
        '<leader>sR',
        function()
          Snacks.picker.resume()
        end,
        desc = '[s]earch [R]esume',
      },
      {
        '<leader>su',
        function()
          Snacks.picker.undo()
        end,
        desc = '[s]earch [u]ndo history',
      },
      {
        '<leader>uC',
        function()
          Snacks.picker.colorschemes()
        end,
        desc = '[C]olorschemes',
      },
      -- LSP
      {
        'gd',
        function()
          Snacks.picker.lsp_definitions()
        end,
        desc = '[g]oto [d]efinition',
      },
      {
        'gD',
        function()
          Snacks.picker.lsp_declarations()
        end,
        desc = '[g]oto [D]eclaration',
      },
      {
        'gA',
        function()
          Snacks.picker.lsp_references()
        end,
        nowait = true,
        desc = '[g]oto [A]ll References',
      },
      {
        'gI',
        function()
          Snacks.picker.lsp_implementations()
        end,
        desc = '[g]oto [I]mplementation',
      },

      {
        'gy',
        function()
          Snacks.picker.lsp_type_definitions()
        end,
        desc = '[g]oto t[y]pe def',
      },
      {
        'g.',
        function()
          vim.lsp.buf.code_action()
        end,
        desc = '[g]oto [.]action',
      },
      {
        '<leader>gs',
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = '[g]oto [s]ymbols',
      },
      {
        '<leader>gS',
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
        desc = '[g]oto [S]ymbols (workspace)',
      },
      -- Other
      {
        '<leader>z',
        function()
          Snacks.zen()
        end,
        desc = 'toggle [z]en',
      },
      {
        '<leader>Z',
        function()
          Snacks.zen.zoom()
        end,
        desc = 'toggle [Z]oom',
      },
      {
        '<leader>.',
        function()
          Snacks.scratch()
        end,
        desc = 'toggle scratch',
      },
      {
        '<leader>S',
        function()
          Snacks.scratch.select()
        end,
        desc = 'select scratch',
      },
      {
        '<leader>n',
        function()
          Snacks.notifier.show_history()
        end,
        desc = 'notifications',
      },
      {
        '<leader>bd',
        function()
          Snacks.bufdelete()
        end,
        desc = '[b]uffer [d]elete',
      },
      {
        'cR',
        function()
          Snacks.rename.rename_file()
        end,
        desc = '[c]hange filename ([R]ename)',
      },
      {
        'cd',
        function()
          vim.lsp.buf.rename()
        end,
        desc = '[c]hange [d]efinition',
      },
      {
        '<leader>cd',
        function()
          vim.diagnostic.open_float()
        end,
        desc = '[c]ode [d]iagnostics',
      },
      {
        '<leader>gB',
        function()
          Snacks.gitbrowse()
        end,
        desc = '[g]it [B]rowse',
        mode = { 'n', 'v' },
      },
      {
        '<leader>gg',
        function()
          Snacks.lazygit()
        end,
        desc = '[g]azy [g]it',
      },
      {
        '<leader>un',
        function()
          Snacks.notifier.hide()
        end,
        desc = '[u]i [n]o more notifications',
      },
      {
        ']]',
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = 'next ref',
        mode = { 'n', 't' },
      },
      {
        '[[',
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = 'prev ref',
        mode = { 'n', 't' },
      },
    },

    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
          Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
          Snacks.toggle.option('linebreak', { name = 'Linebreak' }):map '<leader>ul'
          Snacks.toggle.diagnostics():map '<leader>ud'
          Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
          Snacks.toggle.treesitter():map '<leader>ut'
          Snacks.toggle.inlay_hints():map '<leader>uh'
        end,
      })
    end,
  },
}
