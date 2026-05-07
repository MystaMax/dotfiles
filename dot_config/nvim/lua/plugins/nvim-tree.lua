-- File explorer (replaces NERDTree)
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
  },
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  config = function()
    require("nvim-tree").setup({
      view = { width = 30 },
      renderer = {
        group_empty = true,
        icons = { show = { git = true } },
      },
      filters = { dotfiles = false },
    })
  end,
}
