 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#0b151a',
    base01 = '#172126',
    base02 = '#222b31',
    base03 = '#8094a0',
    base04 = '#b5c9d7',
    base05 = '#dae4ec',
    base06 = '#dae4ec',
    base07 = '#dae4ec',
    base08 = '#ffb4ab',
    base09 = '#8ecff2',
    base0A = '#83d5c5',
    base0B = '#56dbc5',
    base0C = '#8ecff2',
    base0D = '#56dbc5',
    base0E = '#83d5c5',
    base0F = '#9ff2e1',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#dae4ec',          bg = '#0b151a' })
  hi('TelescopeBorder',         { fg = '#8094a0',             bg = '#0b151a' })
  hi('TelescopePromptNormal',   { fg = '#dae4ec',          bg = '#0b151a' })
  hi('TelescopePromptBorder',   { fg = '#8094a0',             bg = '#0b151a' })
  hi('TelescopePromptPrefix',   { fg = '#56dbc5',             bg = '#0b151a' })
  hi('TelescopePromptCounter',  { fg = '#b5c9d7',  bg = '#0b151a' })
  hi('TelescopePromptTitle',    { fg = '#0b151a',             bg = '#56dbc5' })
  hi('TelescopePreviewTitle',   { fg = '#0b151a',             bg = '#83d5c5' })
  hi('TelescopeResultsTitle',   { fg = '#0b151a',             bg = '#8ecff2' })
  hi('TelescopeSelection',      { fg = '#dae4ec',          bg = '#222b31' })
  hi('TelescopeSelectionCaret', { fg = '#56dbc5',             bg = '#222b31' })
  hi('TelescopeMatching',       { fg = '#56dbc5',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#dae4ec',          bg = '#0b151a' })
  hi('MiniPickBorder',         { fg = '#8094a0',             bg = '#0b151a' })
  hi('MiniPickPrompt',   { fg = '#dae4ec',          bg = '#0b151a' })
  hi('MiniPickPromptPrefix',   { fg = '#56dbc5',             bg = '#0b151a' })
  hi('MiniPickBorderText',    { fg = '#0b151a',             bg = '#56dbc5' })
  hi('MiniPickMatchCurrent',      { fg = '#dae4ec',          bg = '#222b31' })
  hi('MiniPickPromptCaret', { fg = '#56dbc5',             bg = '#222b31' })
  hi('MiniPickMatchRanges',       { fg = '#56dbc5',             bold = true })
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
