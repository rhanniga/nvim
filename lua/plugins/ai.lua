return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    build = ':Copilot auth',
    event = 'BufReadPost',
    opts = {
      suggestion = {
        enabled = false,
        auto_trigger = true,
      },
      keymap = {
        accept = '<C-y>',
        next = false,
        prev = false,
      },
    },
    panel = {
      false,
    },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
  {
    'giuxtaposition/blink-cmp-copilot',
    lazy = false,
  },
}
