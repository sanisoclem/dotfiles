 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#0e141c',
    base01 = '#1a2028',
    base02 = '#252a33',
    base03 = '#8691a4',
    base04 = '#bcc7db',
    base05 = '#dee2ee',
    base06 = '#dee2ee',
    base07 = '#dee2ee',
    base08 = '#ffb4ab',
    base09 = '#a3c9fe',
    base0A = '#81d3de',
    base0B = '#4ed8e8',
    base0C = '#a3c9fe',
    base0D = '#4ed8e8',
    base0E = '#81d3de',
    base0F = '#9df0fb',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#dee2ee',          bg = '#0e141c' })
  hi('TelescopeBorder',         { fg = '#8691a4',             bg = '#0e141c' })
  hi('TelescopePromptNormal',   { fg = '#dee2ee',          bg = '#0e141c' })
  hi('TelescopePromptBorder',   { fg = '#8691a4',             bg = '#0e141c' })
  hi('TelescopePromptPrefix',   { fg = '#4ed8e8',             bg = '#0e141c' })
  hi('TelescopePromptCounter',  { fg = '#bcc7db',  bg = '#0e141c' })
  hi('TelescopePromptTitle',    { fg = '#0e141c',             bg = '#4ed8e8' })
  hi('TelescopePreviewTitle',   { fg = '#0e141c',             bg = '#81d3de' })
  hi('TelescopeResultsTitle',   { fg = '#0e141c',             bg = '#a3c9fe' })
  hi('TelescopeSelection',      { fg = '#dee2ee',          bg = '#252a33' })
  hi('TelescopeSelectionCaret', { fg = '#4ed8e8',             bg = '#252a33' })
  hi('TelescopeMatching',       { fg = '#4ed8e8',             bold = true })
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
