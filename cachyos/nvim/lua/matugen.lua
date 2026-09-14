 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#091518',
    base01 = '#162125',
    base02 = '#202c2f',
    base03 = '#7d959c',
    base04 = '#b2cbd2',
    base05 = '#d8e5e9',
    base06 = '#d8e5e9',
    base07 = '#d8e5e9',
    base08 = '#ffb4ab',
    base09 = '#84d2e6',
    base0A = '#8dd5b3',
    base0B = '#6cdbac',
    base0C = '#84d2e6',
    base0D = '#6cdbac',
    base0E = '#8dd5b3',
    base0F = '#a8f2ce',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#d8e5e9',          bg = '#091518' })
  hi('TelescopeBorder',         { fg = '#7d959c',             bg = '#091518' })
  hi('TelescopePromptNormal',   { fg = '#d8e5e9',          bg = '#091518' })
  hi('TelescopePromptBorder',   { fg = '#7d959c',             bg = '#091518' })
  hi('TelescopePromptPrefix',   { fg = '#6cdbac',             bg = '#091518' })
  hi('TelescopePromptCounter',  { fg = '#b2cbd2',  bg = '#091518' })
  hi('TelescopePromptTitle',    { fg = '#091518',             bg = '#6cdbac' })
  hi('TelescopePreviewTitle',   { fg = '#091518',             bg = '#8dd5b3' })
  hi('TelescopeResultsTitle',   { fg = '#091518',             bg = '#84d2e6' })
  hi('TelescopeSelection',      { fg = '#d8e5e9',          bg = '#202c2f' })
  hi('TelescopeSelectionCaret', { fg = '#6cdbac',             bg = '#202c2f' })
  hi('TelescopeMatching',       { fg = '#6cdbac',             bold = true })
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
