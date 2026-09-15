 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#12131c',
    base01 = '#1e1f29',
    base02 = '#292934',
    base03 = '#8f8fa6',
    base04 = '#c5c4dd',
    base05 = '#e3e1ef',
    base06 = '#e3e1ef',
    base07 = '#e3e1ef',
    base08 = '#ffb4ab',
    base09 = '#bec2ff',
    base0A = '#8ecff2',
    base0B = '#76d1ff',
    base0C = '#bec2ff',
    base0D = '#76d1ff',
    base0E = '#8ecff2',
    base0F = '#c2e8ff',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e3e1ef',          bg = '#12131c' })
  hi('TelescopeBorder',         { fg = '#8f8fa6',             bg = '#12131c' })
  hi('TelescopePromptNormal',   { fg = '#e3e1ef',          bg = '#12131c' })
  hi('TelescopePromptBorder',   { fg = '#8f8fa6',             bg = '#12131c' })
  hi('TelescopePromptPrefix',   { fg = '#76d1ff',             bg = '#12131c' })
  hi('TelescopePromptCounter',  { fg = '#c5c4dd',  bg = '#12131c' })
  hi('TelescopePromptTitle',    { fg = '#12131c',             bg = '#76d1ff' })
  hi('TelescopePreviewTitle',   { fg = '#12131c',             bg = '#8ecff2' })
  hi('TelescopeResultsTitle',   { fg = '#12131c',             bg = '#bec2ff' })
  hi('TelescopeSelection',      { fg = '#e3e1ef',          bg = '#292934' })
  hi('TelescopeSelectionCaret', { fg = '#76d1ff',             bg = '#292934' })
  hi('TelescopeMatching',       { fg = '#76d1ff',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
