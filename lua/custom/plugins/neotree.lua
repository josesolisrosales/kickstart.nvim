vim.cmd [[ let g:neo_tree_remove_legacy_commands =1 ]]

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup {}

    -- Your custom Neo-tree keymaps
    vim.keymap.set('n', '<leader>E', ':Neotree action=focus source=filesystem toggle=true<cr>', { desc = 'Show (E)xplorer' })
    vim.keymap.set('n', '<leader>B', ':Neotree action=focus source=buffers toggle=true<cr>', { desc = 'Show (B)uffer' })
    vim.keymap.set('n', '<leader>S', ':Neotree action=focus source=git_status toggle=true<cr>', { desc = 'Show Git (S)tatus' })
  end,
}
