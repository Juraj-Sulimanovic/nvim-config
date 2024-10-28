local theme = require('lualine.themes.dracula')

-- transparrant lualine
theme.normal.c.bg = 'nil'

require('lualine').setup({
    options = {
        theme = theme,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = { 'filename' },

        lualine_x = { 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    tabline = {
        lualine_a = { {'filename', path = 1} }
    },
})
