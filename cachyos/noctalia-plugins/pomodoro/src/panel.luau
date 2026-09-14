local PANEL_ID = "mel/pomodoro:panel"

local timeFontFamily = noctalia.loadFont("resources/JetBrainsMono-Regular.ttf")

local function formatTime(seconds, total)
  local showingHours = total >= 3600 or seconds >= 3600
  local hours = math.floor(seconds / 3600)
  local mins = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60

  if showingHours then
    return string.format("%d:%02d:%02d", hours, mins, secs)
  else
    return string.format("%02d:%02d", mins, secs)
  end
end

--- Whether Skip would do anything right now. Shared by the Skip button and the
--- Ctrl+Space shortcut so the two can never disagree.
local function isSkipAllowed(state, sessionData)
  if not state or not state.sessionPtr or not sessionData then
    return false
  end

  local session = sessionData[state.sessionPtr.session]
  if not session then
    return false
  end

  local stageTotalSeconds = session[state.sessionPtr.stage]
  return state.isDirty and (if state.isRunning then state.secondsLeft > 0 else stageTotalSeconds > 0)
end

function onStartButtonClick()
    noctalia.state.set("mel-pomodoro.nextCommand", "toggle")
end

function onSkipButtonClick()
    noctalia.state.set("mel-pomodoro.nextCommand", "skip")
end

function onResetButtonClick()
    noctalia.state.set("mel-pomodoro.nextCommand", "reset")
end

function onResetAllButtonClick()
    noctalia.state.set("mel-pomodoro.nextCommand", "resetAll")
end

local function render(state, sessionData)
    if not state or not state.sessionPtr or not sessionData then
        panel.render(
            ui.column({ flexGrow = 1, align = "center", justify = "center", gap = 8 }, {
                ui.glyph({ name = "brain", color = "primary" }),
                ui.label({
                    text = "Pomodoro",
                    fontSize = 18,
                    fontWeight = "bold",
                    color = "on_surface",
                }),
            })
        )
        return
    end

    local sessionNumber = state.sessionPtr.session
    local session = sessionData[sessionNumber]
    local stageNumber = state.sessionPtr.stage
    local stageTotalSeconds = session[stageNumber]

    local stageName =
        if stageNumber == 1 then
            noctalia.tr("work")
        else if sessionNumber < #sessionData then 
            noctalia.tr("short-break")
        else 
            noctalia.tr("long-break")

    local startButtonText =
        if state.isRunning then
            noctalia.tr("button.pause")
        else if state.secondsLeft > 0 and state.secondsLeft < stageTotalSeconds then
            noctalia.tr("button.resume")
        else
            noctalia.tr("button.start")

    local startButtonGlyph = if state.isRunning then "player-pause" else "player-play"

    local skipButtonEnabled = isSkipAllowed(state, sessionData)

    local resetButtonEnabled = state.isDirty and state.secondsLeft > 0

    local resetAllButtonEnabled = state.isDirty and (state.isRunning or state.secondsLeft > 0 or (state.sessionPtr.session > 1 and state.sessionPtr.stage > 1))

    local stageIcon = if state.sessionPtr.stage == 1 then "brain" else "coffee"

    panel.render(
        ui.column({ flexGrow = 1, gap = 16 }, {
            -- header
            ui.row({ align = "center", gap = 8 }, {
                ui.glyph({ name = stageIcon, color = "primary" }),

                ui.label({
                    text = "Pomodoro",
                    fontSize = 18,
                    fontWeight = "bold",
                    color = "on_surface",
                    flexGrow = 1,
                }),

                ui.label({
                    text = string.format("%s %d/%d", noctalia.tr("session"), sessionNumber, #sessionData),
                    fontSize = 12,
                    color = "on_surface_variant",
                }),
            }),

            -- time
            ui.column({ flexGrow = 1, align = "center", justify = "center", }, {
                ui.label({
                    text = stageName,
                    fontSize = 18,
                    fontWeight = "medium",
                    color = "primary",
                }),

                ui.label({
                    text = formatTime(state.secondsLeft, stageTotalSeconds),
                    fontSize = 42,
                    fontWeight = "bold",
                    fontFamily = timeFontFamily,
                    color = "primary",
                }),
            }),

            -- buttons
            ui.column({ gap = 8 }, {
                ui.row({ gap = 8 }, {
                    ui.button({
                        variant = "primary",
                        text = startButtonText,
                        glyph = startButtonGlyph,
                        onClick = "onStartButtonClick",
                        width = 157,
                        height = 35
                    }),

                    ui.button({
                        text = noctalia.tr("button.skip"),
                        glyph = "player-skip-forward",
                        onClick = "onSkipButtonClick",
                        enabled = skipButtonEnabled,
                        width = 157,
                        height = 35
                    }),
                }),

                ui.row({ gap = 8 }, {
                    ui.button({
                        text = noctalia.tr("button.reset"),
                        glyph = "refresh",
                        onClick = "onResetButtonClick",
                        enabled = resetButtonEnabled,
                        width = 157,
                        height = 35
                    }),

                    ui.button({
                        text = noctalia.tr("button.reset-all"),
                        glyph = "rotate",
                        onClick = "onResetAllButtonClick",
                        enabled = resetAllButtonEnabled,
                        width = 157,
                        height = 35
                    }),
                }),
            }),
        }) -- column
    ) -- panel
end

local function refresh()
    render(noctalia.state.get("mel-pomodoro.state"), noctalia.state.get("mel-pomodoro.sessionData"))
end

function onOpen(context)
    refresh()
end

--- Space starts/pauses, Ctrl+Space skips. Declared in plugin.toml's capture_keys;
--- the panel only receives these while it holds keyboard focus.
function onKey(chord, pressed)
  if not pressed then
    return
  end

  -- The host echoes back the chord as declared in capture_keys, but normalise
  -- anyway so a difference in casing cannot silently swallow the shortcut.
  chord = string.lower(chord or "")

  if chord == "space" then
    onStartButtonClick()
  elseif chord == "ctrl+space" then
    if isSkipAllowed(noctalia.state.get("mel-pomodoro.state"), noctalia.state.get("mel-pomodoro.sessionData")) then
      onSkipButtonClick()
    end
  end
end

--- main
-- Half of the expiry pop-up. This API has no "open if closed" call and no way to
-- ask whether the panel is visible (onOpen/onClose are never invoked), so the
-- panel unconditionally closes itself - a no-op when it is already closed - and
-- the service reopens it a tick later, once the close has actually landed.
local lastAlarmPing = noctalia.state.get("mel-pomodoro.alarmPing")

noctalia.state.watch("mel-pomodoro.alarmPing", function(ping)
    if ping == nil or ping == lastAlarmPing then
        return
    end
    lastAlarmPing = ping

    panel.close()
end)

noctalia.state.watch("mel-pomodoro.state", function(state)
    refresh()
end)

noctalia.state.watch("mel-pomodoro.sessionData", function(_sessionData)
    refresh()
end)

refresh()

