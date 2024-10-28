local opt = vim.opt

-- dont display mode (lualine does it instead)
opt.showmode = false

-- line numbers
opt.relativenumber = true
opt.number         = true

-- tabs and indentations
opt.expandtab = false   -- Use tab characters instead of spaces
opt.tabstop = 4        -- Number of spaces that a <Tab> in the file counts for
opt.shiftwidth = 4     -- Number of spaces to use for each step of (auto)indent
opt.softtabstop = 4    -- Number of spaces that a <Tab> counts for while editing
opt.autoindent = true

-- line wapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase  = true

-- cursor line
opt.cursorline = true

-- appearance
opt.termguicolors = true
opt.background    = "dark"
opt.signcolumn    = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

