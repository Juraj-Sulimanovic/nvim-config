vim.g.mapleader = " "

local keymap = vim.keymap
local cmd = vim.cmd

-- general
keymap.set("i", "jk", "<ESC>")
keymap.set("n", "<leader>nh", ":nohl<CR>")
keymap.set("n", "<leader>vw", ":set wrap!<CR>")
keymap.set("n", "x", "_x")

-- nvim- tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- undotree
keymap.set("n", "<leader>u", ":UndotreeToggle<CR>")

-- telescope
local builtin = require('telescope.builtin')
keymap.set('n', '<leader>ff', builtin.find_files, {})
keymap.set('n', '<leader>fg', builtin.live_grep, {})
keymap.set('n', '<leader>fb', builtin.buffers, {})
keymap.set('n', '<leader>fh', builtin.help_tags, {})

keymap.set("n", "<leader>gs", cmd.Git)
