local function build_copy_targets(path)
  local targets = {}
  local seen = {}
  local home = vim.uv.os_homedir()

  local function add_target(label, value)
    if value == nil or value == "" or seen[value] then
      return
    end

    seen[value] = true
    targets[#targets + 1] = {
      label = label,
      value = value,
    }
  end

  add_target("Absolute path", path)
  add_target("Path relative to cwd", vim.fn.fnamemodify(path, ":."))

  if home and path:find(home, 1, true) == 1 then
    add_target("Path relative to home", "~" .. path:sub(#home + 1))
  end

  add_target("Filename", vim.fn.fnamemodify(path, ":t"))
  add_target("Basename", vim.fn.fnamemodify(path, ":t:r"))
  add_target("Extension", vim.fn.fnamemodify(path, ":e"))
  add_target("URI", vim.uri_from_fname(path))

  return targets
end

local function copy_selection_to_registers(selection)
  vim.fn.setreg('"', selection)
  vim.fn.setreg("+", selection)
  Snacks.notify.info(("Copied %s"):format(selection))
end

local function explorer_copy_selector(_, item)
  if not item or not item.file then
    return
  end

  local selections = build_copy_targets(item.file)
  if #selections == 0 then
    return
  end

  vim.ui.select(selections, {
    prompt = "Copy path as",
    kind = "explorer_copy_selector",
    format_item = function(choice)
      return choice.label
    end,
  }, function(choice)
    if choice then
      copy_selection_to_registers(choice.value)
    end
  end)
end

local function toggle_explorer_focus()
  local current = vim.api.nvim_get_current_win()
  local pickers = Snacks.picker.get({ source = "explorer", tab = true })
  local explorer = pickers[#pickers]

  for _, picker in ipairs(pickers) do
    if picker:current_win() or picker.main == current then
      explorer = picker
      break
    end
  end

  if not explorer then
    Snacks.explorer({ cwd = LazyVim.root() })
    return
  end

  if explorer:current_win() then
    if vim.api.nvim_win_is_valid(explorer.main) then
      vim.api.nvim_set_current_win(explorer.main)
    else
      vim.cmd.wincmd("p")
    end
    return
  end

  explorer:focus("list", { show = true })
end

return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 0,
        virt_text_pos = "right_align",
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.picker = opts.picker or {}
      opts.picker.actions = opts.picker.actions or {}
      opts.picker.actions.explorer_copy_selector = explorer_copy_selector
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.explorer = vim.tbl_deep_extend("force", opts.picker.sources.explorer or {}, {
        hidden = true,
        win = {
          list = {
            keys = {
              Y = "explorer_copy_selector",
            },
          },
        },
      })
      opts.picker.sources.files = vim.tbl_deep_extend("force", opts.picker.sources.files or {}, {
        hidden = true,
      })
      opts.picker.sources.grep = vim.tbl_deep_extend("force", opts.picker.sources.grep or {}, {
        hidden = true,
      })
    end,
    keys = {
      {
        "<leader>o",
        toggle_explorer_focus,
        desc = "Explorer Focus Toggle",
      },
    },
  },
}
