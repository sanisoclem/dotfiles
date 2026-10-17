def modifier:
  {Mod: "command", Super: "command", Cmd: "command",
   Ctrl: "control", Alt: "option", Shift: "shift", Fn: "fn"}[.]
  // error("unknown modifier \(.)");

def key_code:
  {Return: "return_or_enter", BackSpace: "delete_or_backspace", Delete: "delete_forward",
   Escape: "escape", Space: "spacebar", Tab: "tab",
   Left: "left_arrow", Right: "right_arrow", Up: "up_arrow", Down: "down_arrow",
   Home: "home", End: "end", Page_Up: "page_up", Page_Down: "page_down",
   BracketLeft: "open_bracket", BracketRight: "close_bracket", BackSlash: "backslash",
   Semicolon: "semicolon", Apostrophe: "quote", Grave: "grave_accent_and_tilde",
   Comma: "comma", Period: "period", Slash: "slash", Minus: "hyphen", Equal: "equal_sign",
   Print: "print_screen"}[.]
  // ascii_downcase;

def key_event: split("+") | {key_code: (last | key_code), modifiers: (.[:-1] | map(modifier))};

def press($chord): [$chord | key_event];
def run($command): [{shell_command: $command}];
def wm($command): run("/opt/homebrew/bin/omniwmctl command \($command)");
def script($name): run("~/.config/scripts/\($name)");
def shottr($grab): run("open 'shottr://grab/\($grab)?then=copy,save'");
def nothing: [{key_code: "vk_none"}];

def bind($chord; $title; $to): {chord: $chord, title: $title, to: $to};

def window_manager:
  [ bind("Mod+Shift+Slash"; "Show hotkeys"; script("hotkeys")),

    bind("Mod+Return"; "Open a terminal: ghostty"; script("ghostty-window")),
    bind("Mod+D"; "Run an application: Spotlight"; press("Cmd+Space")),
    bind("Mod+E"; "File manager: Finder"; run("open ~")),
    bind("Super+Alt+L"; "Lock the screen"; press("Ctrl+Cmd+Q")),

    bind("Mod+Space"; "Launcher: Spotlight"; press("Cmd+Space")),
    bind("Mod+S"; "Toggle scratch workspace"; script("omniwm-scratch")),
    bind("Mod+Shift+S"; "Send window to scratch"; wm("move-to-workspace 10")),
    bind("Mod+Ctrl+S"; "Control centre"; press("Fn+C")),
    bind("Mod+Comma"; "System settings"; run("open -b com.apple.systempreferences")),
    bind("Mod+BackSpace"; "Session: lock, sleep, logout, reboot, shutdown"; script("session-menu")),
    bind("Mod+Shift+O"; "Pomodoro timer (not ported yet)"; nothing),
    bind("Mod+Ctrl+Shift+C"; "Calculator"; run("open -a Calculator")),
    bind("Mod+Shift+X"; "Next wallpaper (not ported yet)"; nothing),
    bind("Mod+Shift+C"; "Toggle idle inhibit (caffeine)"; script("caffeine")),

    bind("Mod+X"; "Overview"; wm("toggle-overview")),
    bind("Mod+W"; "Close window"; wm("close-focused-window")),

    bind("Mod+Left"; "Focus column left"; wm("focus left")),
    bind("Mod+Down"; "Focus window down"; wm("focus down")),
    bind("Mod+Up"; "Focus window up"; wm("focus up")),
    bind("Mod+Right"; "Focus column right"; wm("focus right")),
    bind("Mod+H"; "Focus column left"; wm("focus left")),
    bind("Mod+J"; "Focus window down"; wm("focus down")),
    bind("Mod+K"; "Focus window up"; wm("focus up")),
    bind("Mod+L"; "Focus column right"; wm("focus right")),

    bind("Mod+Shift+Left"; "Move column left"; wm("move-column left")),
    bind("Mod+Shift+Down"; "Move window down"; wm("move-window-down")),
    bind("Mod+Shift+Up"; "Move window up"; wm("move-window-up")),
    bind("Mod+Shift+Right"; "Move column right"; wm("move-column right")),
    bind("Mod+Shift+H"; "Move column left"; wm("move-column left")),
    bind("Mod+Shift+J"; "Move window down"; wm("move-window-down")),
    bind("Mod+Shift+K"; "Move window up"; wm("move-window-up")),
    bind("Mod+Shift+L"; "Move column right"; wm("move-column right")),

    bind("Mod+Home"; "Focus first column"; wm("focus-column first")),
    bind("Mod+End"; "Focus last column"; wm("focus-column last")),
    bind("Mod+Shift+Home"; "Move column to first"; wm("move-column-to-first")),
    bind("Mod+Shift+End"; "Move column to last"; wm("move-column-to-last")),

    bind("Mod+Page_Down"; "Focus workspace down"; wm("switch-workspace next")),
    bind("Mod+Page_Up"; "Focus workspace up"; wm("switch-workspace prev")),
    bind("Mod+U"; "Focus workspace down"; wm("switch-workspace next")),
    bind("Mod+I"; "Focus workspace up"; wm("switch-workspace prev")),
    bind("Mod+Ctrl+Page_Down"; "Move column to workspace down"; wm("move-column-to-workspace down")),
    bind("Mod+Ctrl+Page_Up"; "Move column to workspace up"; wm("move-column-to-workspace up")),
    bind("Mod+Ctrl+U"; "Move column to workspace down"; wm("move-column-to-workspace down")),
    bind("Mod+Ctrl+I"; "Move column to workspace up"; wm("move-column-to-workspace up")),
    bind("Mod+Shift+Page_Down"; "Move workspace down (OmniWM can't)"; nothing),
    bind("Mod+Shift+Page_Up"; "Move workspace up (OmniWM can't)"; nothing),
    bind("Mod+Shift+U"; "Move workspace down (OmniWM can't)"; nothing),
    bind("Mod+Shift+I"; "Move workspace up (OmniWM can't)"; nothing),

    (range(1; 10) | tostring | (
      bind("Mod+\(.)"; "Focus workspace \(.)"; wm("switch-workspace \(.)")),
      bind("Mod+Shift+\(.)"; "Move column to workspace \(.)"; wm("move-column-to-workspace \(.)")))),

    bind("Mod+BracketLeft"; "Consume or expel window left"; wm("consume-or-expel-window-left")),
    bind("Mod+BracketRight"; "Consume or expel window right"; wm("consume-or-expel-window-right")),
    bind("Mod+Shift+Comma"; "Consume window into column"; wm("consume-window-into-column")),
    bind("Mod+Shift+Period"; "Expel window from column"; wm("consume-or-expel-window-right")),

    bind("Mod+R"; "Switch preset column width"; wm("cycle-size forward")),
    bind("Mod+Shift+R"; "Switch preset window height"; wm("cycle-window-secondary-span forward")),
    bind("Mod+Ctrl+R"; "Reset window height"; wm("reset-window-secondary-span")),
    bind("Mod+F"; "Maximize column"; wm("toggle-container-full-primary-span")),
    bind("Mod+Shift+F"; "Fullscreen window"; wm("toggle-fullscreen")),
    bind("Mod+Ctrl+F"; "Expand column to available width"; wm("expand-container-to-available-primary-span")),
    bind("Mod+C"; "Center column"; wm("center-column")),
    bind("Mod+Ctrl+C"; "Center visible columns"; wm("center-visible-columns")),

    bind("Mod+Minus"; "Column width -10%"; wm("set-container-primary-span -10%")),
    bind("Mod+Equal"; "Column width +10%"; wm("set-container-primary-span +10%")),
    bind("Mod+Shift+Minus"; "Window height -10%"; wm("set-window-secondary-span -10%")),
    bind("Mod+Shift+Equal"; "Window height +10%"; wm("set-window-secondary-span +10%")),

    bind("Mod+T"; "Toggle window floating"; wm("toggle-focused-window-floating")),
    bind("Mod+Shift+T"; "Switch focus between floating and tiling"; wm("toggle-floating-focus")),
    bind("Mod+V"; "Toggle column tabbed display"; wm("toggle-column-tabbed")),

    bind("Print"; "Screenshot a region"; shottr("area")),
    bind("Ctrl+Print"; "Screenshot the screen"; shottr("fullscreen")),
    bind("Alt+Print"; "Screenshot a window"; shottr("window")),

    bind("Mod+Shift+E"; "Log out"; script("session-menu 'Log out'")),
    bind("Ctrl+Alt+Delete"; "Log out"; script("session-menu 'Log out'")),
    bind("Mod+Shift+P"; "Power off monitors"; run("pmset displaysleepnow"))
  ];

def inhibited: {type: "variable_if", name: "shortcuts_inhibited", value: 1};
def not_inhibited: {type: "variable_unless", name: "shortcuts_inhibited", value: 1};
def inhibit($value): [{set_variable: {name: "shortcuts_inhibited", value: $value}}];

def from($chord; $optional):
  $chord | key_event | {key_code, modifiers: {mandatory: .modifiers, optional: $optional}};

def manipulator($conditions): {type: "basic", from: from(.chord; []), to, conditions: $conditions};

def escape_hatch:
  [ ({chord: "Mod+Escape", to: inhibit(1)} | manipulator([not_inhibited])),
    ({chord: "Mod+Escape", to: inhibit(0)} | manipulator([inhibited])) ];

def outside_terminals: {type: "frontmost_application_unless", bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"]};
def in_zen: {type: "frontmost_application_if", bundle_identifiers: ["^app\\.zen-browser\\.zen$"]};

def remap($from; $optional; $to; $where):
  {type: "basic", from: from($from; $optional), to: press($to), conditions: [$where]};

def click_as_command_click($where):
  {type: "basic",
   from: {pointing_button: "button1", modifiers: {mandatory: ["control"], optional: ["shift"]}},
   to: [{pointing_button: "button1", modifiers: ["command"]}],
   conditions: [$where]};

def zen_shortcuts:
  [ (range(1; 10) | tostring | remap("Alt+\(.)"; []; "Cmd+\(.)"; in_zen)),
    remap("Alt+D"; []; "Cmd+L"; in_zen),
    remap("Alt+Left"; []; "Cmd+BracketLeft"; in_zen),
    remap("Alt+Right"; []; "Cmd+BracketRight"; in_zen),
    remap("Ctrl+F5"; []; "Cmd+Shift+R"; in_zen),
    click_as_command_click(in_zen) ];

def text_navigation:
  [ ("Left", "Right", "Up", "Down") as $arrow
    | remap("Ctrl+\($arrow)"; ["shift"]; "Alt+\($arrow)"; outside_terminals) ]
  + [ remap("Ctrl+BackSpace"; []; "Alt+BackSpace"; outside_terminals),
      remap("Ctrl+Delete"; []; "Alt+Delete"; outside_terminals) ];

def hide_minimize_and_cycle_windows: ["h", "m", "Grave"];

def command_keys:
  ("abcdefghijklmnopqrstuvwxyz1234567890" | split(""))
  + ["Minus", "Equal", "BracketLeft", "BracketRight", "BackSlash", "Semicolon",
     "Apostrophe", "Grave", "Comma", "Period", "Slash", "Return"]
  - hide_minimize_and_cycle_windows;

def control_as_command:
  [ command_keys[] as $key | remap("Ctrl+\($key)"; ["shift", "option"]; "Cmd+\($key)"; outside_terminals) ]
  + [ remap("Ctrl+Alt+Left"; ["shift"]; "Cmd+Alt+Left"; outside_terminals),
      remap("Ctrl+Alt+Right"; ["shift"]; "Cmd+Alt+Right"; outside_terminals),
      remap("Ctrl+Shift+Delete"; []; "Cmd+Shift+Delete"; outside_terminals) ];

def rules:
  [ {description: "Mod+Escape toggles the window manager shortcuts, like niri's inhibit escape hatch",
     manipulators: escape_hatch},
    {description: "Window manager: the niri keybinds",
     manipulators: [window_manager[] | manipulator([not_inhibited])]},
    {description: "Zen: Linux shortcuts macOS has no equivalent for",
     manipulators: zen_shortcuts},
    {description: "Linux keyboard: Ctrl moves by word",
     manipulators: text_navigation},
    {description: "Linux keyboard: Ctrl shortcuts outside the terminal are Cmd shortcuts",
     manipulators: control_as_command} ];

def with_rules: .profiles |= map(.complex_modifications.rules = rules);

def cheatsheet: window_manager[] | "\(.chord | . + " " * ([28 - length, 1] | max))\(.title)";
