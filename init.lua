-- Set leader keys before anything else
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
require("config.lazy")

-- Load configuration
require("config.options")
require("config.keymaps")
