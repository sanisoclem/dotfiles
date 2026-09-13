 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#0c141b',
    base01 = '#182028',
    base02 = '#232b32',
    base03 = '#8293a2',
    base04 = '#b8c8d9',
    base05 = '#dbe3ed',
    base06 = '#dbe3ed',
    base07 = '#dbe3ed',
    base08 = '#ffb4ab',
    base09 = '#97ccf9',
    base0A = '#80d5d1',
    base0B = '#4ddad6',
    base0C = '#97ccf9',
    base0D = '#4ddad6',
    base0E = '#80d5d1',
    base0F = '#9cf1ed',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#dbe3ed',          bg = '#0c141b' })
  hi('TelescopeBorder',         { fg = '#8293a2',             bg = '#0c141b' })
  hi('TelescopePromptNormal',   { fg = '#dbe3ed',          bg = '#0c141b' })
  hi('TelescopePromptBorder',   { fg = '#8293a2',             bg = '#0c141b' })
  hi('TelescopePromptPrefix',   { fg = '#4ddad6',             bg = '#0c141b' })
  hi('TelescopePromptCounter',  { fg = '#b8c8d9',  bg = '#0c141b' })
  hi('TelescopePromptTitle',    { fg = '#0c141b',             bg = '#4ddad6' })
  hi('TelescopePreviewTitle',   { fg = '#0c141b',             bg = '#80d5d1' })
  hi('TelescopeResultsTitle',   { fg = '#0c141b',             bg = '#97ccf9' })
  hi('TelescopeSelection',      { fg = '#dbe3ed',          bg = '#232b32' })
  hi('TelescopeSelectionCaret', { fg = '#4ddad6',             bg = '#232b32' })
  hi('TelescopeMatching',       { fg = '#4ddad6',             bold = true })
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
