-- Bar widget: click to regenerate the Immich wallpaper pool.
--
-- The work is done by immich-wallpaper.service so a click and the daily timer
-- take exactly the same path. The script sends its own completion
-- notification, since runAsync is fire-and-forget and can't report back.

local BUSY_MS = 20000 -- how long to show the busy state before giving up on it

local busyUntil = 0

local function render()
    local busy = noctalia.nowMs() < busyUntil
    barWidget.render(ui.glyph({
        color = if busy then "primary" else "on_surface",
        name = if busy then "refresh" else "image",
    }))
end

local function refresh()
    if noctalia.nowMs() < busyUntil then
        return
    end
    busyUntil = noctalia.nowMs() + BUSY_MS
    render()
    noctalia.notify("Wallpapers", "Fetching a fresh pool from Immich…")
    noctalia.runAsync("systemctl --user start immich-wallpaper.service")
end

function onClick()
    refresh()
end

-- Same thing without the mouse, for a keybind:
--   noctalia msg plugin 'mel/wallpaper-refresh:widget' all refresh
function onIpc(event)
    if event == "refresh" then
        refresh()
    end
end

-- Tick so the busy glyph clears itself once the run has had time to finish.
-- The host calls the global update(); the interval has to be re-armed each time.
noctalia.setUpdateInterval(1000)
function update()
    noctalia.setUpdateInterval(1000)
    render()
end

render()
