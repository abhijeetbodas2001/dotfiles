-- Per-window positions are relative to the window and live until config reload.
local M = {}

function M.start()
    local state = {positions = {}}
    local filter = hs.window.filter

    local function contains(frame, point)
        return point.x >= frame.x and point.x < frame.x + frame.w
            and point.y >= frame.y and point.y < frame.y + frame.h
    end

    local function remember(win)
        if not win or not win:id() or not win:isStandard() then return end
        local frame, point = win:frame(), hs.mouse.absolutePosition()
        if contains(frame, point) then
            state.positions[win:id()] = {x = point.x - frame.x, y = point.y - frame.y}
        end
    end

    local function cancelRestore()
        if state.pending then state.pending:stop(); state.pending = nil end
    end

    local function focused(win)
        cancelRestore()
        if state.current and state.current:id() ~= win:id() then
            remember(state.current)
        end
        state.current = win
        -- Allow the focus/Space transition to settle; ignore stale callbacks.
        state.pending = hs.timer.doAfter(0.05, function()
            state.pending = nil
            local current = hs.window.focusedWindow()
            if not current or current:id() ~= win:id() or not win:isStandard() then return end
            local frame = win:frame()
            if frame.w <= 0 or frame.h <= 0 then return end
            if contains(frame, hs.mouse.absolutePosition()) then
                remember(win)
                return
            end
            -- Never warp during a click or drag.
            for _, pressed in pairs(hs.eventtap.checkMouseButtons()) do
                if pressed then return end
            end
            local saved = state.positions[win:id()]
            local x = saved and saved.x or frame.w / 2
            local y = saved and saved.y or frame.h / 2
            hs.mouse.absolutePosition({
                x = frame.x + math.max(0, math.min(x, frame.w - 1)),
                y = frame.y + math.max(0, math.min(y, frame.h - 1)),
            })
            remember(win)
        end)
    end

    state.watcher = filter.new()
    state.watcher:subscribe(filter.windowFocused, focused)
    state.watcher:subscribe(filter.windowUnfocused, function(win)
        if state.current and state.current:id() == win:id() then
            remember(win)
            state.current = nil
            cancelRestore()
        end
    end)
    state.watcher:subscribe(filter.windowDestroyed, function(win)
        local id = win:id()
        if id then state.positions[id] = nil end
        if state.current and state.current:id() == id then
            state.current = nil
            cancelRestore()
        end
    end)

    -- Tab bindings call this before launching, activating, or cycling a window.
    -- Focus events cover other switching methods without continuous polling.
    state.beforeSwitch = function()
        cancelRestore()
        remember(hs.window.focusedWindow())
    end
    state.current = hs.window.focusedWindow()
    remember(state.current)
    return state
end

return M
