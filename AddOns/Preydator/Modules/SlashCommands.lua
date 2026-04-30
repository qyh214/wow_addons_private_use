local Preydator = _G.Preydator
if type(Preydator) ~= "table" then
    return
end

local SlashCommandsModule = {}
Preydator:RegisterModule("SlashCommands", SlashCommandsModule)

function SlashCommandsModule:HandleSlashCommand(message, ctx)
    local ensureDebugDB = ctx and ctx.ensureDebugDB
    local settings = ctx and ctx.settings
    local debugDB = ctx and ctx.debugDB
    local state = ctx and ctx.state
    local updateBarDisplay = ctx and ctx.updateBarDisplay
    local openOptionsPanel = ctx and ctx.openOptionsPanel
    local modules = (ctx and ctx.modules) or {}
    local printFn = (ctx and ctx.printFn) or print

    message = (message or ""):match("^%s*(.-)%s*$")
    local command, rest = message:match("^(%S+)%s*(.-)$")
    local text = string.lower(command or "")

    if text == "debug" then
        if type(ensureDebugDB) == "function" then
            ensureDebugDB()
        end
        local mode = string.lower(rest or "")

        if mode == "on" then
            if type(settings) == "table" then
                settings.debugSounds = true
            end
            if type(debugDB) == "table" then
                debugDB.enabled = true
            end
            printFn("Preydator: Debug logging enabled.")
            return
        end

        if mode == "off" then
            if type(settings) == "table" then
                settings.debugSounds = false
            end
            if type(debugDB) == "table" then
                debugDB.enabled = false
            end
            printFn("Preydator: Debug logging disabled.")
            return
        end

        if mode == "clear" then
            if type(debugDB) == "table" then
                debugDB.entries = {}
            end
            printFn("Preydator: Debug log cleared.")
            return
        end

        if mode == "show" or mode == "" then
            local entries = (type(debugDB) == "table" and type(debugDB.entries) == "table") and debugDB.entries or {}
            local total = #entries
            if total == 0 then
                printFn("Preydator: Debug log is empty.")
                return
            end

            local fromIndex = math.max(1, total - 19)
            printFn("Preydator: Debug log (last " .. (total - fromIndex + 1) .. " of " .. total .. ")")
            for index = fromIndex, total do
                printFn("  " .. entries[index])
            end
            return
        end

        printFn("Preydator: debug commands are 'debug on', 'debug off', 'debug show', 'debug clear'.")
        return
    end

    if text == "show" then
        if type(state) == "table" then
            state.forceShowBar = true
        end
        if type(updateBarDisplay) == "function" then
            updateBarDisplay()
        end
        printFn("Preydator: Progress bar forced visible.")
        return
    end

    if text == "hide" then
        if type(state) == "table" then
            state.forceShowBar = false
        end
        if type(updateBarDisplay) == "function" then
            updateBarDisplay()
        end
        printFn("Preydator: Progress bar auto mode restored.")
        return
    end

    if text == "toggle" then
        if type(state) == "table" then
            state.forceShowBar = not state.forceShowBar
        end
        if type(updateBarDisplay) == "function" then
            updateBarDisplay()
        end
        printFn("Preydator: Progress bar force show = " .. tostring(state and state.forceShowBar))
        return
    end

    if text == "options" then
        if type(openOptionsPanel) == "function" then
            openOptionsPanel()
        end
        return
    end

    local moduleHandled = false
    for _, module in pairs(modules) do
        local hook = module and module.OnSlashCommand
        if type(hook) == "function" then
            local ok, handled = pcall(hook, module, text, rest, nil)
            if ok and handled == true then
                moduleHandled = true
                break
            end
        end
    end

    if moduleHandled then
        return
    end

    printFn("Preydator commands: options | show | hide | toggle | debug <on|off|show|clear> | inspect [bs] | qinspect [questID] [bs] | hinspect [bs] | hinspectcopy [bs] | ainspect [bs]")
end