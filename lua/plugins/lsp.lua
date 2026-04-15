return {
  -- Mason: LSP installer and manager
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end
  },

  -- Mason LSP Config: Bridge between Mason and lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",      -- Python
          "gopls",        -- Go
        },
        automatic_installation = true,
      })
    end
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    lazy = false, -- Ensure this loads immediately
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- LSP capabilities for autocompletion
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Disable conflicting LSP servers for Ruby files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "ruby",
        callback = function()
          for _, client in pairs(vim.lsp.get_clients()) do
            if client.name == "solargraph" or client.name == "rubocop" or client.name == "ruby_lsp" then
              vim.lsp.stop_client(client.id)
            end
          end
        end,
      })

      -- Global LSP keymaps function
      local on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- Navigation
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

        -- Information
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

        -- Code actions
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        -- Diagnostics
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        -- Workspace
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
      end

      -- Function to detect Python interpreter for different project types
      local function get_python_interpreter()
        local cwd = vim.fn.getcwd()

        -- Check for Poetry project
        if vim.fn.filereadable(cwd .. "/pyproject.toml") == 1 then
          local poetry_env = vim.fn.system("cd " .. cwd .. " && poetry env info --path 2>/dev/null")
          if vim.v.shell_error == 0 and poetry_env ~= "" then
            return vim.trim(poetry_env) .. "/bin/python"
          end
        end

        -- Check for pipenv project
        if vim.fn.filereadable(cwd .. "/Pipfile") == 1 then
          local pipenv_venv = vim.fn.system("cd " .. cwd .. " && pipenv --venv 2>/dev/null")
          if vim.v.shell_error == 0 and pipenv_venv ~= "" then
            return vim.trim(pipenv_venv) .. "/bin/python"
          end
        end

        -- Check for virtual environment in project root
        local venv_paths = {".venv/bin/python", "venv/bin/python", "env/bin/python"}
        for _, venv_path in ipairs(venv_paths) do
          if vim.fn.filereadable(cwd .. "/" .. venv_path) == 1 then
            return cwd .. "/" .. venv_path
          end
        end

        -- Fall back to system Python
        return nil
      end

      -- Python LSP (Pyright)
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
            pythonPath = get_python_interpreter(),
          }
        }
      })

      -- Go LSP (gopls)
      vim.lsp.config("gopls", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      })

      vim.lsp.config("ruby_lsp", {
        capabilities = capabilities,

        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          client.server_capabilities.semanticTokensProvider = nil
        end,

        cmd = { "/Users/jurajsulimanovic/.rbenv/versions/3.4.2/bin/ruby-lsp" },
        filetypes = { "ruby" },

        init_options = {
          enabledFeatures = {
            "codeActions",
            "diagnostics", 
            "documentHighlights",
            "documentLink",
            "documentSymbols",
            "foldingRanges",
            "formatting",
            "hover",
            "inlayHint",
            "onTypeFormatting",
            "selectionRanges",
            "semanticHighlighting",
            "completion",
            "codeLens",
            "definition",
            "workspaceSymbol",
            "signatureHelp",
            "typeHierarchy",
          },
          featuresConfiguration = {
            inlayHint = {
              implicitHashValue = false,
              implicitRescue = false,
            },
          },
          -- Handle version mismatches more gracefully
          experimentalFeaturesEnabled = false,
        },
        settings = {},
        root_dir = vim.fs.find({ "Gemfile", ".git", ".ruby-version" }, { path = vim.fn.getcwd(), upward = true })[1],
        single_file_support = true,
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          severity = { min = vim.diagnostic.severity.WARN }
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Diagnostic signs configuration
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
        },
      })
    end
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",       -- Buffer completions
      "hrsh7th/cmp-path",         -- Path completions
      "hrsh7th/cmp-cmdline",      -- Command line completions
      "hrsh7th/cmp-nvim-lsp",     -- LSP completions
      "L3MON4D3/LuaSnip",        -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
      "rafamadriz/friendly-snippets", -- Snippet collection
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Load friendly snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local kind_icons = {
              Text = "",
              Method = "m",
              Function = "",
              Constructor = "",
              Field = "",
              Variable = "",
              Class = "",
              Interface = "",
              Module = "",
              Property = "",
              Unit = "",
              Value = "",
              Enum = "",
              Keyword = "",
              Snippet = "",
              Color = "",
              File = "",
              Reference = "",
              Folder = "",
              EnumMember = "",
              Constant = "",
              Struct = "",
              Event = "",
              Operator = "",
              TypeParameter = "",
            }
            vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        experimental = {
          ghost_text = false,
          native_menu = false,
        },
      })
    end,
  },
}
