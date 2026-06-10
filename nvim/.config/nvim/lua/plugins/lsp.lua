return {
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "html",
          "cssls",
          -- "tailwindcss",
          -- "lua_ls",
          "eslint",
          "jsonls",
          "clojure_lsp",
          "eslint",
          "gopls",
          -- "ruby_lsp",
          -- "rubocop"
        },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,
          rubocop = function()
            require("lspconfig").rubocop.setup({
              cmd = { "bundle", "exec", "rubocop", "--lsp" },
            })
          end,
        },
      })
    end,
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗",
            },
          },
        },
      },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "prettier", -- prettier formatter
        -- "stylua",   -- lua formatter
        "isort",    -- python formatter
        "black",    -- python formatter
        "pylint",
        "eslint_d",
      },
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
  "folke/trouble.nvim",
  {
    "nvimtools/none-ls.nvim",
    version = "*",
    lazy = false,
    config = function()
      local nls = require("null-ls")
      local formatting = nls.builtins.formatting
      local diagnostics = nls.builtins.diagnostics
      nls.setup {
        sources = {
          diagnostics.trail_space,
          diagnostics.todo_comments,
          diagnostics.yamllint,
          diagnostics.erb_lint,
        }
      }
    end,
  }
}
