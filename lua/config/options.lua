local function env_exists(name)
  local value = vim.env[name]
  return value ~= nil and value ~= ""
end

local function has_clipboard_tool()
  local executable = vim.fn.executable

  if executable("pbcopy") == 1 and executable("pbpaste") == 1 then
    return true
  end
  if env_exists("WAYLAND_DISPLAY") and executable("wl-copy") == 1 and executable("wl-paste") == 1 then
    return true
  end
  if env_exists("WAYLAND_DISPLAY") and executable("waycopy") == 1 and executable("waypaste") == 1 then
    return true
  end
  if env_exists("DISPLAY") and executable("xsel") == 1 then
    return true
  end
  if env_exists("DISPLAY") and executable("xclip") == 1 then
    return true
  end
  if env_exists("TMUX") and executable("tmux") == 1 then
    return true
  end
  if executable("termux-clipboard-set") == 1 and executable("termux-clipboard-get") == 1 then
    return true
  end

  return false
end

local function local_register_paste()
  return function()
    return vim.fn.getreg('"', 1, true), vim.fn.getregtype('"')
  end
end

local function osc52_clipboard()
  local osc52 = require("vim.ui.clipboard.osc52")
  local paste = local_register_paste()

  return {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end

if not has_clipboard_tool() then
  vim.g.clipboard = osc52_clipboard()
  vim.opt.clipboard = "unnamedplus"
end

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"
vim.opt.spell = false
vim.opt.wrap = true
