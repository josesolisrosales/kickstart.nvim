-- Enhanced todo-comments with better functionality
-- TODO:
-- HACK:
-- WARN:
-- PERF:
-- NOTE:
-- TEST:
-- DONE:
-- IDEA:
-- QUESTION:.
-- FIX::
--
return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    signs = true, -- Enable signs in the gutter
    sign_priority = 8, -- Sign priority
    keywords = {
      FIX = {
        icon = ' ', -- Icon used for the sign, and in search results
        color = 'error', -- Can be a hex color, or a named color
        alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- A set of other keywords that all map to this FIX keywords
      },
      TODO = { icon = ' ', color = 'info' },
      HACK = { icon = ' ', color = 'warning' },
      WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
      PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
      NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
      TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      DONE = { icon = '✓ ', color = 'hint', alt = { 'COMPLETED', 'FINISHED' } },
      IDEA = { icon = '💡', color = 'info', alt = { 'CONCEPT', 'BRAINSTORM' } },
      QUESTION = { icon = '❓', color = 'info', alt = { 'ASK', 'DOUBT' } },
    },
    gui_style = {
      fg = 'NONE', -- The gui style to use for the fg highlight group.
      bg = 'BOLD', -- The gui style to use for the bg highlight group.
    },
    merge_keywords = true, -- Merge keywords with the defaults
    highlight = {
      multiline = true, -- Enable multine todo comments
      multiline_pattern = '^.', -- Lua pattern to match the next multiline from the start of the matched keyword
      multiline_context = 10, -- Extra lines of context to show around multilines
      before = '', -- "fg" or "bg" or empty
      keyword = 'wide', -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty
      after = 'fg', -- "fg" or "bg" or empty
      pattern = [[.*<(KEYWORDS)\s*:]], -- Pattern used to find todo comments
      comments_only = true, -- Only highlight inside comments using treesitter
      max_line_len = 400, -- Ignore lines longer than this
      exclude = {}, -- List of file types to exclude highlighting
    },
    colors = {
      error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
      warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
      info = { 'DiagnosticInfo', '#2563EB' },
      hint = { 'DiagnosticHint', '#10B981' },
      default = { 'Identifier', '#7C3AED' },
      test = { 'Identifier', '#FF006E' },
    },
    search = {
      command = 'rg',
      args = {
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
      },
      pattern = [[\b(KEYWORDS):]], -- Ripgrep regex pattern (raw, not Lua)
    },
  },
  keys = {
    -- Todo navigation
    {
      ']t',
      function()
        require('todo-comments').jump_next()
      end,
      desc = 'Next todo comment',
    },
    {
      '[t',
      function()
        require('todo-comments').jump_prev()
      end,
      desc = 'Previous todo comment',
    },

    -- Todo search with Telescope
    { '<leader>st', '<cmd>TodoTelescope<cr>', desc = '[S]earch [T]odos' },
    { '<leader>sT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>', desc = '[S]earch [T]odos (TODO/FIX only)' },

    -- Todo quickfix
    { '<leader>tq', '<cmd>TodoQuickFix<cr>', desc = '[T]odo [Q]uickfix list' },
    { '<leader>tl', '<cmd>TodoLocList<cr>', desc = '[T]odo [L]ocation list' },

    -- Todo management helpers
    {
      '<leader>ti',
      function()
        vim.ui.input({ prompt = 'Add TODO comment: ' }, function(input)
          if input then
            local line = vim.api.nvim_get_current_line()
            local comment_string = vim.bo.commentstring:gsub('%%s', '')
            local new_line = line .. ' ' .. comment_string .. ' TODO: ' .. input
            vim.api.nvim_set_current_line(new_line)
          end
        end)
      end,
      desc = '[T]odo [I]nsert',
    },

    {
      '<leader>tf',
      function()
        vim.ui.input({ prompt = 'Add FIXME comment: ' }, function(input)
          if input then
            local line = vim.api.nvim_get_current_line()
            local comment_string = vim.bo.commentstring:gsub('%%s', '')
            local new_line = line .. ' ' .. comment_string .. ' FIXME: ' .. input
            vim.api.nvim_set_current_line(new_line)
          end
        end)
      end,
      desc = '[T]odo [F]IXME',
    },

    {
      '<leader>tn',
      function()
        vim.ui.input({ prompt = 'Add NOTE comment: ' }, function(input)
          if input then
            local line = vim.api.nvim_get_current_line()
            local comment_string = vim.bo.commentstring:gsub('%%s', '')
            local new_line = line .. ' ' .. comment_string .. ' NOTE: ' .. input
            vim.api.nvim_set_current_line(new_line)
          end
        end)
      end,
      desc = '[T]odo [N]ote',
    },

    -- Todo toggle functionality
    {
      '<leader>tx',
      function()
        local line = vim.api.nvim_get_current_line()
        local line_num = vim.api.nvim_win_get_cursor(0)[1]
        local new_line = line

        -- Toggle TODO -> DONE
        if line:match 'TODO:' then
          new_line = line:gsub('TODO:', 'DONE:')
        -- Toggle DONE -> TODO
        elseif line:match 'DONE:' then
          new_line = line:gsub('DONE:', 'TODO:')
        -- Toggle FIXME -> DONE
        elseif line:match 'FIXME:' then
          new_line = line:gsub('FIXME:', 'DONE:')
        -- Toggle HACK -> DONE
        elseif line:match 'HACK:' then
          new_line = line:gsub('HACK:', 'DONE:')
        -- Toggle NOTE -> DONE
        elseif line:match 'NOTE:' then
          new_line = line:gsub('NOTE:', 'DONE:')
        else
          -- If no todo found, convert line to TODO
          local comment_string = vim.bo.commentstring:gsub('%%s', '')
          new_line = line .. ' ' .. comment_string .. ' TODO: '
        end

        vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { new_line })
      end,
      desc = '[T]odo Toggle [X] (TODO ↔ DONE)',
    },
  },
}
