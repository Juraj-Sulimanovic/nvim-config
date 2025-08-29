return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          "json", "javascript", "typescript", "yaml", "html", "css",
          "markdown", "markdown_inline", "bash", "lua", "vim", "ruby",
        },
        auto_install = true,
      })
    end,
  },
}
