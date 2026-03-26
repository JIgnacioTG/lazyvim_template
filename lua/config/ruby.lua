local M = {}

local ruby_markers = {
  "Gemfile",
  ".ruby-version",
  "config/application.rb",
}

local function normalize_filename(path_or_bufnr)
  local filename = path_or_bufnr

  if type(path_or_bufnr) == "number" then
    filename = vim.api.nvim_buf_get_name(path_or_bufnr)
  end

  if type(filename) == "string" and filename:match("^file://") then
    filename = vim.uri_to_fname(filename)
  end

  return filename
end

local function has_ruby_gemspec_file(path)
  local matches = vim.fn.globpath(path, "*.gemspec", false, true)
  return type(matches) == "table" and #matches > 0
end

local function is_ruby_project_root(path)
  for _, marker in ipairs(ruby_markers) do
    if vim.fn.filereadable(vim.fs.joinpath(path, marker)) == 1 then
      return true
    end
  end

  return has_ruby_gemspec_file(path)
end

function M.project_root(path_or_bufnr)
  local filename = normalize_filename(path_or_bufnr)

  if type(filename) ~= "string" or filename == "" then
    return nil
  end

  local directory = vim.fs.dirname(filename)

  if not directory then
    return nil
  end

  while directory do
    if is_ruby_project_root(directory) then
      return directory
    end

    local parent = vim.fs.dirname(directory)

    if parent == directory then
      break
    end

    directory = parent
  end

  return nil
end

function M.is_project(path_or_bufnr)
  return M.project_root(path_or_bufnr) ~= nil
end

function M.config_script(name)
  return vim.fs.joinpath(vim.fn.stdpath("config"), "scripts", name)
end

return M
