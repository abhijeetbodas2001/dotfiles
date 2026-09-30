local M = {}

function M.new(appBindings)
    local excluded = {}
    for _, bundleID in pairs(appBindings) do excluded[bundleID] = true end
    local function eligible(win)
        local app = win and win:application()
        return app and win:isStandard() and not excluded[app:bundleID()]
    end
    local wf = hs.window.filter.new(eligible)
    -- Keep focus history current even between cycling sessions.
    wf:subscribe(hs.window.filter.windowFocused, function() end)
    local state = {filter = wf}

    function state.reset()
        state.stack, state.index = nil, 0
    end

    function state.next()
        if not state.stack then
            state.stack, state.index = {}, 0
            local current = hs.window.focusedWindow()
            for _, win in ipairs(wf:getWindows(hs.window.filter.sortByFocusedLast)) do
                local id = win:id()
                if id and eligible(win) then
                    state.stack[#state.stack + 1] = id
                    if current and id == current:id() then
                        state.index = #state.stack
                    end
                end
            end
        end
        if #state.stack == 0 then
            hs.alert.show("No windows without app shortcuts")
            return
        end
        for _ = 1, #state.stack do
            state.index = (state.index % #state.stack) + 1
            local win = hs.window.get(state.stack[state.index])
            if eligible(win) then
                if pointerMemory then pointerMemory.beforeSwitch() end
                if win:isMinimized() then win:unminimize() end
                win:application():unhide()
                win:focus()
                return
            end
        end
        hs.alert.show("No windows without app shortcuts")
        state.reset()
    end

    state.reset()
    return state
end

return M
