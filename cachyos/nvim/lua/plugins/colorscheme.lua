local saved_colorscheme_path = vim.fn.stdpath("state") .. "/colorscheme"

local function saved_colorscheme()
  local ok, lines = pcall(vim.fn.readfile, saved_colorscheme_path)
  return ok and lines[1] or "tokyonight"
end

local function save_colorscheme(name)
  local unfinished_path = saved_colorscheme_path .. "." .. vim.fn.getpid()
  vim.fn.writefile({ name }, unfinished_path)
  vim.uv.fs_rename(unfinished_path, saved_colorscheme_path)
end

local function save_colorscheme_changes()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(event)
      save_colorscheme(event.match)
    end,
  })
end

return {
  "LazyVim/LazyVim",
  opts = {
    colorscheme = function()
      vim.cmd.colorscheme(saved_colorscheme())
      save_colorscheme_changes()
    end,
  },
}
