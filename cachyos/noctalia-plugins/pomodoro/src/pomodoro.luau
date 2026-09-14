local config = (function()
    return {
        workDuration = noctalia.getConfig("work-duration") or 25,
        shortBreakDuration = noctalia.getConfig("short-break-duration") or 5,
        longBreakDuration = noctalia.getConfig("long-break-duration") or 15,
        sessionsBeforeLongBreak = noctalia.getConfig("sessions-before-long-break") or 4,
        autoStartBreaks = noctalia.getConfig("auto-start-breaks") == true,
        autoStartWork = noctalia.getConfig("auto-start-work") == true,
        useBundledAlarmSound = noctalia.getConfig("use-bundled-alarm-sound") == true,
        enableWorkTimerSound = noctalia.getConfig("enable-work-timer-sound") == true,
        bypassNoctaliaSoundGlobals = noctalia.getConfig("bypass-noctalia-sound-globals") ~= false,
        openPanelOnExpiry = noctalia.getConfig("open-panel-on-expiry") ~= false,
        notifyOnExpiry = noctalia.getConfig("notify-on-expiry") ~= false,
    }
end)()
noctalia.state.set("mel-pomodoro.config", config)

local sessionData = {}
for i = 1, config.sessionsBeforeLongBreak do
    local breakDuration = if i < config.sessionsBeforeLongBreak then config.shortBreakDuration else config.longBreakDuration
    table.insert(sessionData, { config.workDuration * 60, breakDuration * 60 })
end
noctalia.state.set("mel-pomodoro.sessionData", sessionData)

local PANEL_ID = "mel/pomodoro:panel"
-- How long to wait after telling the panel to close before reopening it. The
-- close is asynchronous and does not report completion; at 300ms the reopen
-- still raced it and the panel ended up shut, 800ms is reliable.
local PANEL_REOPEN_DELAY_MS = 800
local alarmPing = 0
-- Set when the panel has been told to close and is due to be reopened.
local pendingPanelOpenAt = nil

local sounds = require("./src/sounds.luau")
sounds.init({
    bypassNoctaliaSoundGlobals = config.bypassNoctaliaSoundGlobals,
    useBundledAlarmSound = config.useBundledAlarmSound,
    enableWorkTimerSound = config.enableWorkTimerSound,
})

local isRunning = false
local sessionPtr = { session = 1, stage = 1 }
local isDirty = false
local secondsLeft = 0
local tickAnchorSecond = nil
local lastProcessedSecond = nil

local function resetTickClock()
    tickAnchorSecond = nil
    lastProcessedSecond = nil
end

local function getStateSnapshot()
    return {
        isRunning = isRunning,
        secondsLeft = secondsLeft,
        sessionPtr = sessionPtr,
        isDirty = isDirty,
    }
end

local function getStageTotalSeconds()
    local sessionNumber = sessionPtr.session
    local session = sessionData[sessionNumber]
    local stageNumber = sessionPtr.stage
    return session[stageNumber]
end

--- main
secondsLeft = getStageTotalSeconds()

noctalia.state.watch("mel-pomodoro.nextCommand", function(command)
    if command == "toggle" then
        isDirty = true
        isRunning = not isRunning
        resetTickClock()
    elseif command == "skip" then
        isRunning = false
        resetTickClock()
        if sessionPtr.stage == 1 then
            sessionPtr.stage = 2
        elseif sessionPtr.session < #sessionData then
            sessionPtr.session += 1
            sessionPtr.stage = 1
        elseif sessionPtr.session == #sessionData then
            sessionPtr = { session = 1, stage = 1 }
        end
        secondsLeft = getStageTotalSeconds()
    elseif command == "reset" then
        isRunning = false
        resetTickClock()
        secondsLeft = getStageTotalSeconds()
    elseif command == "resetAll" then
        isRunning = false
        resetTickClock()
        sessionPtr = { session = 1, stage = 1 }
        secondsLeft = getStageTotalSeconds()
        isDirty = false
    end

    local state = getStateSnapshot()
    noctalia.state.set("mel-pomodoro.state", state)
end)

local state = getStateSnapshot()
noctalia.state.set("mel-pomodoro.state", state)

noctalia.setUpdateInterval(250)
function update()
    if pendingPanelOpenAt ~= nil and noctalia.nowMs() >= pendingPanelOpenAt then
        pendingPanelOpenAt = nil
        noctalia.togglePanel(PANEL_ID)
    end

    if not isRunning then
        return
    end

    local second = math.floor(noctalia.nowMs() / 1000)
    if tickAnchorSecond == nil then
        tickAnchorSecond = second
        lastProcessedSecond = second
        return
    end

    if second <= lastProcessedSecond then
        return
    end

    local stateChanged = false
    for s = lastProcessedSecond + 1, second do
        if s > tickAnchorSecond and secondsLeft > 0 then
            secondsLeft -= 1

            local offset = s - tickAnchorSecond
            if offset > 0 and config.enableWorkTimerSound and sessionPtr.stage == 1 then
                if offset % 2 == 1 then
                    sounds.playTick()
                else
                    sounds.playTock()
                end
            end
            stateChanged = true
        end
    end
    lastProcessedSecond = second

    if stateChanged then
        noctalia.state.set("mel-pomodoro.state", getStateSnapshot())
    end
end

--- Puts the panel on screen regardless of whether it is already open: tell it to
--- close itself, then reopen it once that has landed (see the panel's alarmPing
--- watcher for why it has to go the long way round).
local function popPanel()
    alarmPing += 1
    noctalia.state.set("mel-pomodoro.alarmPing", alarmPing)
    pendingPanelOpenAt = noctalia.nowMs() + PANEL_REOPEN_DELAY_MS
end

local function notifyStageFinished(state, sessionData)
    local sessionNumber = state.sessionPtr.session
    local stageNumber = state.sessionPtr.stage
    local body =
        if stageNumber == 1 then
            noctalia.tr("notification.work-complete")
        elseif sessionNumber < #sessionData then
            noctalia.tr("notification.short-break-complete")
        else
            noctalia.tr("notification.long-break-complete")

    if config.useBundledAlarmSound then
        sounds.playAlarm()
    end

    -- A notification alone is too easy to miss (and may be muted outright), so
    -- put the panel on screen too. togglePanel is the only open primitive the
    -- plugin API exposes, so skip it when the panel is already up rather than
    -- toggling a visible panel shut.
    if config.openPanelOnExpiry then
        popPanel()
    end

    if config.notifyOnExpiry then
        noctalia.notify("Pomodoro Timer", body)
    end
end

--- Same commands the panel buttons issue, reachable from the CLI or a compositor
--- keybind:  noctalia msg plugin mel/pomodoro:pomodoro all toggle
function onIpc(event, _payload)
    if event == "toggle" or event == "skip" or event == "reset" or event == "resetAll" then
        noctalia.state.set("mel-pomodoro.nextCommand", event)
    end
end

noctalia.state.watch("mel-pomodoro.state", function(state)
    if state.secondsLeft == 0 then
        notifyStageFinished(state, sessionData)
        noctalia.state.set("mel-pomodoro.nextCommand", "skip")
        if (config.autoStartWork and state.sessionPtr.stage == 2) or (config.autoStartBreaks and state.sessionPtr.stage == 1) then
            noctalia.state.set("mel-pomodoro.nextCommand", "toggle")
        end
    end
end)
