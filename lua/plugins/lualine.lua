return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local theme = require('lualine.themes.dracula')
        local opts = {
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
        }
        
        require('lualine').setup(opts)
    end
}