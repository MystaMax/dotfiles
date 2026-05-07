-- Editor options (migrated from nvim-config.vim)

local opt = vim.opt

-- Spaces and Tabs
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.autoindent = true
opt.smartindent = true

-- UI Layout
opt.number = true
opt.relativenumber = true
opt.showcmd = true
opt.cursorline = false
opt.showmatch = true
opt.showmode = true
opt.termguicolors = true
opt.signcolumn = "yes"

-- Searching
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- General
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.updatetime = 250
opt.splitright = true
opt.splitbelow = true
