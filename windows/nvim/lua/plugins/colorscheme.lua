local saved_colorscheme_path = vim.fn.stdpath("state") .. "/colorscheme"

local function saved_colorscheme()
  local ok, lines = pcall(vim.fn.readfile, saved_colorscheme_path)
  return ok and lines[1] or "tokyonight"
end

local function save_colorscheme_changes()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(event)
      vim.fn.writefile({ event.match }, saved_colorscheme_path)
    end,
  })
end

return {
  "LazyVim/LazyVim",
  opts = {
    colorscheme = function()
      save_colorscheme_changes()
      vim.cmd.colorscheme(saved_colorscheme())
    end,
  },
}
