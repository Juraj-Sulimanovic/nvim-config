return {
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    lazy = true,
    config = false,
    init = function()
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },
  { "williamboman/mason.nvim", lazy = false, config = true },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "L3MON4D3/LuaSnip" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lua" },
      { "rafamadriz/friendly-snippets" },
    },
    config = function()
      local lsp_zero = require("lsp-zero")
      lsp_zero.extend_cmp()
      local cmp = require("cmp")
      local cmp_select = { behavior = cmp.SelectBehavior.Select }
      cmp.setup({
        formatting = lsp_zero.cmp_format(),
        sources = {
          { name = "path" },
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "luasnip", keyword_length = 2 },
          { name = "buffer", keyword_length = 3 },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
          ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "williamboman/mason-lspconfig.nvim" },
    },
    config = function()
      local lsp_zero = require("lsp-zero")
      lsp_zero.extend_lspconfig()
      lsp_zero.on_attach(function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>ll", vim.diagnostic.open_float, opts)
      end)
      vim.diagnostic.config({
        virtual_text = { severity = { min = vim.diagnostic.severity.INFO } },
        signs = { severity = { min = vim.diagnostic.severity.INFO } },
        float = { severity = { min = vim.diagnostic.severity.INFO } },
      })
      require("mason").setup({
        ensure_installed = {
          "eslint-lsp","prettierd","tailwindcss-language-server","typescript-language-server",
        },
      })
      require("mason-lspconfig").setup({
        ensure_installed = { "html","cssls","ts_ls","eslint","tailwindcss","yamlls","jsonls","lua_ls","gopls","pyright" },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({ capabilities = lsp_zero.get_capabilities() })
          end,
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require("lspconfig").lua_ls.setup(lua_opts)
          end,
          ts_ls = function()
            require("lspconfig").ts_ls.setup({
              capabilities = lsp_zero.get_capabilities(),
              settings = { typescript = { inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              }}}})
          end,
        },
      })
      require("lspconfig").solargraph.setup({
        capabilities = lsp_zero.get_capabilities(),
        cmd = { "bundle", "exec", "solargraph", "stdio" },
        settings = { solargraph = { diagnostics = true, useBundler = true, bundlerPath = "bundle", completion = true, hover = true, formatting = true, checkGemVersion = true, autoformat = false, plugins = { "solargraph-rails" } } },
        root_dir = require("lspconfig.util").root_pattern("Gemfile", ".git") or vim.loop.cwd(),
      })
      require("lspconfig").rubocop.setup({
        capabilities = lsp_zero.get_capabilities(),
        cmd = { "bundle", "exec", "rubocop", "--lsp" },
        root_dir = require("lspconfig.util").root_pattern("Gemfile", ".rubocop.yml", ".git") or vim.loop.cwd(),
      })
      lsp_zero.format_on_save({
        format_opts = { async = false, timeout_ms = 10000 },
        servers = { ["prettierd"] = { "typescript","typescriptreact","javascript","javascriptreact" }, ["rubocop"] = { "ruby" } },
      })
    end,
  },
}
