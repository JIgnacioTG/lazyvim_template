local ruby = require("config.ruby")

local ruby_tools_group = vim.api.nvim_create_augroup("LazyVimRubyTools", { clear = true })

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      if not vim.tbl_contains(opts.ensure_installed, "ruby") then
        table.insert(opts.ensure_installed, "ruby")
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
        underline = true,
        virtual_text = true,
      })
      opts.servers = opts.servers or {}
      opts.setup = opts.setup or {}
      opts.servers.ruby_lsp = vim.tbl_deep_extend("force", opts.servers.ruby_lsp or {}, {
        cmd = { ruby.config_script("ruby-lsp") },
        filetypes = { "ruby", "eruby" },
        mason = false,
        root_dir = function(path_or_bufnr, on_dir)
          local root = ruby.project_root(path_or_bufnr)

          if type(on_dir) == "function" then
            on_dir(root)
          end

          return root
        end,
      })
      opts.setup.ruby_lsp = function(_, server_opts)
        vim.lsp.config("ruby_lsp", server_opts)
        vim.api.nvim_create_autocmd("FileType", {
          group = ruby_tools_group,
          pattern = { "ruby", "eruby" },
          callback = function(event)
            local root = ruby.project_root(event.buf)

            if not root then
              return
            end

            local config = vim.deepcopy(vim.lsp.config.ruby_lsp or server_opts)
            config.root_dir = root

            vim.lsp.start(config, { bufnr = event.buf, silent = true })
          end,
        })

        return true
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.ruby = { "rubocop" }
      opts.formatters = opts.formatters or {}
      opts.formatters.rubocop = {
        command = ruby.config_script("rubocop"),
        condition = function(_, ctx)
          return ruby.is_project(ctx.filename)
        end,
        cwd = function(_, ctx)
          return ruby.project_root(ctx.filename)
        end,
        inherit = true,
        require_cwd = true,
      }
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.ruby = { "ruby_rubocop" }
      opts.linters.ruby_rubocop = function()
        local linter = vim.deepcopy(require("lint.linters.rubocop"))

        linter.cmd = ruby.config_script("rubocop")
        linter.condition = function(ctx)
          return ruby.is_project(ctx.filename)
        end
        linter.cwd = ruby.project_root(vim.api.nvim_get_current_buf()) or vim.fn.getcwd()

        return linter
      end
    end,
  },
}
