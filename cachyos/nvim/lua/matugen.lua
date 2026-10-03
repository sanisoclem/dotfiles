 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#1c1107',
    base01 = '#291d12',
    base02 = '#34281b',
    base03 = '#a88b71',
    base04 = '#e1c1a4',
    base05 = '#f5dfcc',
    base06 = '#f5dfcc',
    base07 = '#f5dfcc',
    base08 = '#ffb4ab',
    base09 = '#fcb974',
    base0A = '#ffb3b6',
    base0B = '#ffb3b6',
    base0C = '#fcb974',
    base0D = '#ffb3b6',
    base0E = '#ffb3b6',
    base0F = '#ffdada',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#f5dfcc',          bg = '#1c1107' })
  hi('TelescopeBorder',         { fg = '#a88b71',             bg = '#1c1107' })
  hi('TelescopePromptNormal',   { fg = '#f5dfcc',          bg = '#1c1107' })
  hi('TelescopePromptBorder',   { fg = '#a88b71',             bg = '#1c1107' })
  hi('TelescopePromptPrefix',   { fg = '#ffb3b6',             bg = '#1c1107' })
  hi('TelescopePromptCounter',  { fg = '#e1c1a4',  bg = '#1c1107' })
  hi('TelescopePromptTitle',    { fg = '#1c1107',             bg = '#ffb3b6' })
  hi('TelescopePreviewTitle',   { fg = '#1c1107',             bg = '#ffb3b6' })
  hi('TelescopeResultsTitle',   { fg = '#1c1107',             bg = '#fcb974' })
  hi('TelescopeSelection',      { fg = '#f5dfcc',          bg = '#34281b' })
  hi('TelescopeSelectionCaret', { fg = '#ffb3b6',             bg = '#34281b' })
  hi('TelescopeMatching',       { fg = '#ffb3b6',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#f5dfcc',          bg = '#1c1107' })
  hi('MiniPickBorder',         { fg = '#a88b71',             bg = '#1c1107' })
  hi('MiniPickPrompt',   { fg = '#f5dfcc',          bg = '#1c1107' })
  hi('MiniPickPromptPrefix',   { fg = '#ffb3b6',             bg = '#1c1107' })
  hi('MiniPickBorderText',    { fg = '#1c1107',             bg = '#ffb3b6' })
  hi('MiniPickMatchCurrent',      { fg = '#f5dfcc',          bg = '#34281b' })
  hi('MiniPickPromptCaret', { fg = '#ffb3b6',             bg = '#34281b' })
  hi('MiniPickMatchRanges',       { fg = '#ffb3b6',             bold = true })
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
