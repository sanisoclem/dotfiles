-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local function paste_unnamed()
  return { vim.fn.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') }
end

vim.opt.clipboard = "unnamedplus"

-- Windows Terminal cannot answer OSC 52 reads; pasting via OSC 52 hangs. Paste from the terminal (Ctrl+Shift+V) instead.
if vim.env.SSH_TTY or vim.env.TMUX then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste_unnamed, ["*"] = paste_unnamed },
  }
end
