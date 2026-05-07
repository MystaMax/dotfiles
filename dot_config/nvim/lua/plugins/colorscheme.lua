-- VS Code dark colorscheme
return {
  "Mofiqul/vscode.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    local vscode = require("vscode")
    vscode.setup({
      style = "dark",
      transparent = false,
      italic_comments = true,
    })
    vscode.load()
  end,
}
