def modifiers($names):
  {control: false, alt: false, shift: false, meta: false, accel: false}
  + ($names | map({(.): true}) | add);

def disabled($id; $group):
  {id: $id, key: "", keycode: "", group: $group, l10nId: null,
   modifiers: modifiers([]), action: null, disabled: true, reserved: false, internal: false};

def rebind:
  if (.id // "" | test("^key_select(Tab[1-8]|LastTab)$")) then .modifiers = modifiers(["accel"])
  elif .id == "goBackKb" or .id == "goForwardKb" then .modifiers = modifiers(["accel"])
  elif .id == "key_gotoHistory" or .id == "key_toggleMute" then .modifiers = modifiers(["control"])
  else . end;

def add_missing($shortcut):
  if any(.shortcuts[]; .id == $shortcut.id) then . else .shortcuts += [$shortcut] end;

.shortcuts |= map(rebind)
| add_missing(disabled("key_viewSourceSafari"; "other"))
| add_missing(disabled("key_inspectorMac"; "devTools"))
