 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#121408',
    base01 = '#1f2113',
    base02 = '#292b1d',
    base03 = '#8f9374',
    base04 = '#c6c9a7',
    base05 = '#e3e4cf',
    base06 = '#e3e4cf',
    base07 = '#e3e4cf',
    base08 = '#ffb4ab',
    base09 = '#c1cd7d',
    base0A = '#f8bb71',
    base0B = '#ffb962',
    base0C = '#c1cd7d',
    base0D = '#ffb962',
    base0E = '#f8bb71',
    base0F = '#ffddb9',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e3e4cf',          bg = '#121408' })
  hi('TelescopeBorder',         { fg = '#8f9374',             bg = '#121408' })
  hi('TelescopePromptNormal',   { fg = '#e3e4cf',          bg = '#121408' })
  hi('TelescopePromptBorder',   { fg = '#8f9374',             bg = '#121408' })
  hi('TelescopePromptPrefix',   { fg = '#ffb962',             bg = '#121408' })
  hi('TelescopePromptCounter',  { fg = '#c6c9a7',  bg = '#121408' })
  hi('TelescopePromptTitle',    { fg = '#121408',             bg = '#ffb962' })
  hi('TelescopePreviewTitle',   { fg = '#121408',             bg = '#f8bb71' })
  hi('TelescopeResultsTitle',   { fg = '#121408',             bg = '#c1cd7d' })
  hi('TelescopeSelection',      { fg = '#e3e4cf',          bg = '#292b1d' })
  hi('TelescopeSelectionCaret', { fg = '#ffb962',             bg = '#292b1d' })
  hi('TelescopeMatching',       { fg = '#ffb962',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e3e4cf',          bg = '#121408' })
  hi('MiniPickBorder',         { fg = '#8f9374',             bg = '#121408' })
  hi('MiniPickPrompt',   { fg = '#e3e4cf',          bg = '#121408' })
  hi('MiniPickPromptPrefix',   { fg = '#ffb962',             bg = '#121408' })
  hi('MiniPickBorderText',    { fg = '#121408',             bg = '#ffb962' })
  hi('MiniPickMatchCurrent',      { fg = '#e3e4cf',          bg = '#292b1d' })
  hi('MiniPickPromptCaret', { fg = '#ffb962',             bg = '#292b1d' })
  hi('MiniPickMatchRanges',       { fg = '#ffb962',             bold = true })
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
