-- cachyos/ghostty/config, for wezterm: ghostty has no Windows build.
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- A snapshot of cachyos/ghostty/themes/noctalia, which noctalia regenerates from
-- the wallpaper; nothing regenerates this one.
local noctalia = {
  background = '#0b151a',
  foreground = '#dae4ec',
  surface = '#364954',
  muted = '#8094a0',
  selection = '#b5c9d7',
  ansi = { '#364954', '#ffb4ab', '#56dbc5', '#83d5c5', '#8ecff2', '#56dbc5', '#83d5c5', '#dae4ec' },
  brights = { '#8094a0', '#ffb4ab', '#56dbc5', '#83d5c5', '#8ecff2', '#56dbc5', '#83d5c5', '#dae4ec' },
}

config.default_prog = { 'wsl.exe', '--cd', '~' }

config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 12
config.freetype_load_target = 'Light'
config.bold_brightens_ansi_colors = 'No'
config.warn_about_missing_glyphs = false

config.front_end = 'WebGpu'
config.max_fps = 120

config.window_decorations = 'RESIZE'
-- Points, as ghostty measures its padding; a bare 14 would be pixels.
config.window_padding = { left = '14pt', right = '14pt', top = '14pt', bottom = '14pt' }
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = 'NeverPrompt'
config.audible_bell = 'Disabled'
config.check_for_updates = false

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

config.default_cursor_style = 'SteadyBlock'

config.colors = {
  foreground = noctalia.foreground,
  background = noctalia.background,
  cursor_bg = noctalia.foreground,
  cursor_fg = noctalia.background,
  cursor_border = noctalia.foreground,
  selection_bg = noctalia.surface,
  selection_fg = noctalia.selection,
  split = noctalia.surface,
  ansi = noctalia.ansi,
  brights = noctalia.brights,
  tab_bar = {
    background = noctalia.background,
    active_tab = { bg_color = noctalia.surface, fg_color = noctalia.foreground },
    inactive_tab = { bg_color = noctalia.background, fg_color = noctalia.muted },
    inactive_tab_hover = { bg_color = noctalia.surface, fg_color = noctalia.foreground },
  },
}

local function copy_or_interrupt(window, pane)
  if window:get_selection_text_for_pane(pane) ~= '' then
    window:perform_action(act.CopyTo 'Clipboard', pane)
  else
    window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
  end
end

config.keys = {
  { key = 'c', mods = 'CTRL', action = wezterm.action_callback(copy_or_interrupt) },
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
}

return config
