-- Treesitter syntax highlighting and parser management
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Install parsers for your languages
    require("nvim-treesitter").install({
      "python", "javascript", "typescript", "go", "ruby",
      "markdown", "markdown_inline",
      "lua", "json", "yaml", "bash",
      "html", "css", "vim", "vimdoc",
    })

    -- Register zsh to use the bash parser
    vim.treesitter.language.register("bash", "zsh")

    -- Enable treesitter-based highlighting
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
