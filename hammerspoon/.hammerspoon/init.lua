-- ~/.hammerspoon/init.lua

-- Hold Tab + N -> Chrome
-- Hold Tab + M -> Firefox
-- Hold Tab + J -> Ghostty
-- Hold Tab + K -> Cursor
-- Hold Tab + L -> Zed
-- Hold Tab + O -> Slack
-- Hold Tab + P -> WhatsApp
-- Hold Tab + [ -> Left half
-- Hold Tab + ] -> Right half
-- Hold Tab + Space -> Maximize on the current desktop
-- Hold Tab + , -> Move to the display on the left
-- Hold Tab + . -> Move to the display on the right
-- Hold Tab + ; -> Next audio output
-- Hold Tab + ' -> Next audio input
-- Hold Tab + Enter -> Cycle unbound apps' windows, most recently used first
-- Tap Tab alone -> normal Tab, sent on release.
-- Globe/Fn + H/J/K/L -> Left/Down/Up/Right (additional modifiers preserved)
--
-- Behavior:
--   If app isn't running -> launch it.
--   If app isn't focused -> focus its most recent window.
--   If app is already focused -> cycle to its next window.

local appBindings = {
    ["n"] = "com.google.Chrome",
    ["m"] = "org.mozilla.firefox",
    ["j"] = "com.mitchellh.ghostty",
    ["k"] = "com.todesktop.230313mzl4w4u92",
    ["l"] = "dev.zed.Zed",
    ["o"] = "com.tinyspeck.slackmacgap",
    ["p"] = "net.whatsapp.WhatsApp",
}

local unboundWindows = require("unbound_windows").new(appBindings)

local function focusOrCycle(appID)
    if pointerMemory then pointerMemory.beforeSwitch() end
    local app = hs.application.get(appID)

    -- App isn't running.
    if not app then
        hs.application.launchOrFocusByBundleID(appID)
        return
    end

    -- Standard windows only, avoiding various hidden/helper windows.
    local windows = hs.fnutils.filter(app:allWindows(), function(win)
        return win:isStandard()
    end)

    if #windows == 0 then
        hs.application.launchOrFocusByBundleID(appID)
        return
    end

    -- Focus changes can reorder allWindows(); sort by ID so cycling visits
    -- every window instead of bouncing between the two most recent ones.
    table.sort(windows, function(a, b) return a:id() < b:id() end)

    local focusedWindow = hs.window.focusedWindow()

    -- If we're already inside this app, cycle to another window.
    if focusedWindow and focusedWindow:application() == app then
        local currentId = focusedWindow:id()

        for i, win in ipairs(windows) do
            if win:id() == currentId then
                local nextWindow = windows[(i % #windows) + 1]
                if nextWindow:isMinimized() then nextWindow:unminimize() end
                nextWindow:focus()
                return
            end
        end
    end

    -- Otherwise focus the app's most recently used window.
    app:activate()

    local mainWindow = app:focusedWindow() or app:mainWindow() or windows[1]
    if mainWindow then
        mainWindow:focus()
    end
end

local function nextAudioDevice(isInput)
    local kind = isInput and "input" or "output"
    local devices = isInput and hs.audiodevice.allInputDevices() or hs.audiodevice.allOutputDevices()
    if #devices == 0 then
        hs.alert.show("No audio " .. kind .. "s available")
        return
    end
    -- Stable order, refreshed each time so newly connected devices are included.
    table.sort(devices, function(a, b)
        local aName, bName = a:name() or "", b:name() or ""
        if aName == bName then return (a:uid() or "") < (b:uid() or "") end
        return aName < bName
    end)
    local current
    if isInput then current = hs.audiodevice.defaultInputDevice()
    else current = hs.audiodevice.defaultOutputDevice() end
    local nextIndex = 1
    for i, device in ipairs(devices) do
        if current and device:uid() == current:uid() then
            nextIndex = (i % #devices) + 1
            break
        end
    end
    local target = devices[nextIndex]
    local success
    if isInput then success = target:setDefaultInputDevice()
    else success = target:setDefaultOutputDevice() end
    if success then
        hs.alert.show("Audio " .. kind .. ": " .. (target:name() or "Unnamed device"))
    else
        hs.alert.show("Could not switch audio " .. kind)
    end
end

local pendingLayoutTimer
local function arrangeWindow(key)
    if pendingLayoutTimer then
        pendingLayoutTimer:stop()
        pendingLayoutTimer = nil
    end
    local win = hs.window.focusedWindow()
    if not win then return end
    local layout = key == "]" and hs.layout.right50 or hs.layout.left50
    local function applyLayout()
        if key == "," or key == "." then
            local screen = win:screen()
            if not screen then return end
            local target
            if key == "," then target = screen:toWest()
            else target = screen:toEast() end
            if target then win:moveToScreen(target, false, true) end
        elseif key == "space" then
            win:maximize()
        else
            win:moveToUnit(layout)
        end
    end
    if not win:isFullScreen() then
        applyLayout()
        return
    end

    -- macOS must finish leaving full screen before the window can be resized.
    win:setFullScreen(false)
    local attempts = 0
    pendingLayoutTimer = hs.timer.doEvery(0.1, function()
        attempts = attempts + 1
        if not win:id() or attempts >= 50 then
            pendingLayoutTimer:stop()
            pendingLayoutTimer = nil
        elseif not win:isFullScreen() then
            pendingLayoutTimer:stop()
            pendingLayoutTimer = nil
            applyLayout()
        end
    end)
end

-- Tab is a regular key, so defer it until release or an unrelated key.
local eventTypes = hs.eventtap.event.types
local eventProperties = hs.eventtap.event.properties
local tabCode = hs.keycodes.map.tab
local syntheticTag = 684271
local tabHeld, tabUsed, tabFallback = false, false, false
local capturedKeys = {}
local globeArrowKeys = {
    [hs.keycodes.map.h] = hs.keycodes.map.left,
    [hs.keycodes.map.j] = hs.keycodes.map.down,
    [hs.keycodes.map.k] = hs.keycodes.map.up,
    [hs.keycodes.map.l] = hs.keycodes.map.right,
}
local heldGlobeArrows = {}

local function hasModifiers(flags)
    return flags.cmd or flags.ctrl or flags.alt or flags.shift or flags.fn
end

local function markSynthetic(event)
    return event:setProperty(eventProperties.eventSourceUserData, syntheticTag)
end

local function normalTabEvents()
    return {
        markSynthetic(hs.eventtap.event.newKeyEvent({}, tabCode, true)),
        markSynthetic(hs.eventtap.event.newKeyEvent({}, tabCode, false)),
    }
end

-- Keep a global reference so the listener is not garbage collected.
appShortcutTap = hs.eventtap.new({
    eventTypes.keyDown,
    eventTypes.keyUp,
}, function(event)
    if event:getProperty(eventProperties.eventSourceUserData) == syntheticTag then
        return false
    end
    local code = event:getKeyCode()
    local isDown = event:getType() == eventTypes.keyDown
    local flags = event:getFlags()

    -- Rewrite both key-down and key-up, retaining native key repeat. Remember
    -- held mappings so releasing Globe before the letter still releases the arrow.
    local arrow = heldGlobeArrows[code]
    if isDown and not arrow and flags.fn and not tabHeld then
        arrow = globeArrowKeys[code]
        if arrow then heldGlobeArrows[code] = arrow end
    end
    if arrow then
        if not isDown then heldGlobeArrows[code] = nil end
        flags.fn = nil
        event:setKeyCode(arrow)
        event:setFlags(flags)
        return false
    end

    if code == tabCode then
        if isDown then
            if tabHeld then return true end -- Suppress held-Tab repeat.
            -- Preserve Cmd+Tab, Shift+Tab, Ctrl+Tab, and other modified Tabs.
            if hasModifiers(flags)
                or event:getProperty(eventProperties.keyboardEventAutorepeat) == 1 then
                return false
            end
            tabHeld, tabUsed, tabFallback = true, false, false
            unboundWindows.reset()
            return true
        elseif tabHeld then
            local sendTab = not tabUsed
            tabHeld, tabUsed, tabFallback = false, false, false
            unboundWindows.reset()
            if sendTab then return true, normalTabEvents() end
            return true
        end
        return false
    end

    if not isDown then
        local captured = capturedKeys[code]
        capturedKeys[code] = nil
        return captured == true
    end

    if capturedKeys[code] then return true end

    local key = hs.keycodes.map[code]
    local appID = appBindings[key]
    local isLayoutKey = key == "[" or key == "]" or key == "space"
        or key == "," or key == "."
    local isAudioKey = key == ";" or key == "'"
    local isCycleKey = key == "return" or key == "padenter"
    if tabHeld and not tabFallback and (appID or isLayoutKey or isAudioKey or isCycleKey) and not hasModifiers(flags) then
        tabUsed = true
        capturedKeys[code] = true
        if not isCycleKey then unboundWindows.reset() end
        if isCycleKey then
            unboundWindows.next()
        elseif appID then
            focusOrCycle(appID)
        elseif isAudioKey then
            nextAudioDevice(key == "'")
        else
            arrangeWindow(key)
        end
        return true
    end

    if tabHeld and not tabUsed then
        -- For Tab followed by another key, deliver Tab before that key.
        tabUsed, tabFallback = true, true
        local events = normalTabEvents()
        events[#events + 1] = markSynthetic(event:copy())
        return true, events
    end
    return false
end):start()

-- Reload config quickly.
-- Ctrl+Shift+R
hs.hotkey.bind({"ctrl", "shift"}, "R", function()
    hs.reload()
end)

-- Track pointer positions for ordinary application windows, across all apps.
pointerMemory = require("pointer_memory").start()

hs.alert.show("Hammerspoon config loaded")
