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

if not has_clipboard_tool() then
  vim.g.clipboard = "osc52"
end

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"
vim.opt.spell = false
vim.opt.wrap = true
