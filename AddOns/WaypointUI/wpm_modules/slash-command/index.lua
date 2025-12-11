local env          = select(2, ...)

local type         = type
local getmetatable = getmetatable
local gmatch       = string.gmatch

local SlashCommand = env.WPM:New("wpm_modules/slash-command")


-- Shared
--------------------------------

local commandIndexes = {}


-- Helpers
--------------------------------

local function parseTokens(message)
    local tokens = {}
    local count = 0
    for token in gmatch(message, "%S+") do
        count = count + 1
        tokens[count] = token
    end
    return tokens
end

local function registerCommand(name, slashText, callback, slotIndex)
    _G["SLASH_" .. name .. slotIndex] = "/" .. slashText
    SlashCmdList[name] = function(message)
        callback(message, parseTokens(message))
    end
end

local function hookCommand(name, callback)
    local existingHandler = SlashCmdList[name]
    if not existingHandler then return false end

    SlashCmdList[name] = function(message)
        existingHandler(message)
        callback(message, parseTokens(message))
    end
    return true
end

local function removeCommand(name)
    local slotIndex = 1
    local slashPrefix = "SLASH_" .. name
    while true do
        local globalKey = slashPrefix .. slotIndex
        local slashText = _G[globalKey]
        if not slashText then break end

        _G[globalKey] = nil
        if hash_SlashCmdList then
            hash_SlashCmdList[slashText] = nil
        end
        slotIndex = slotIndex + 1
    end

    SlashCmdList[name] = nil
    local slashMetatable = getmetatable(SlashCmdList)
    if slashMetatable and slashMetatable.__index then
        slashMetatable.__index[name] = nil
    end
    commandIndexes[name] = nil
end


-- API
--------------------------------

function SlashCommand.GetTokens(message)
    return parseTokens(message)
end

function SlashCommand.GetSlashCommand(name)
    return SlashCmdList[name]
end

function SlashCommand.AddSlashCommand(name, slashText, callback, slotIndex)
    registerCommand(name, slashText, callback, slotIndex)
end

function SlashCommand.HookSlashCommand(name, callback)
    return hookCommand(name, callback)
end

function SlashCommand.RemoveSlashCommand(name)
    removeCommand(name)
end

function SlashCommand.AddFromSchema(schema)
    for i = 1, #schema do
        local entry = schema[i]
        assert(entry.name, "`AddFromSchema`: `name` is required")
        assert(entry.callback, "`AddFromSchema`: `callback` is required")

        if entry.hook and SlashCmdList[entry.hook] then
            hookCommand(entry.hook, entry.callback)
        else
            local commands = entry.command
            local name = entry.name
            if type(commands) == "table" then
                for j = 1, #commands do
                    commandIndexes[name] = (commandIndexes[name] or 0) + 1
                    registerCommand(name, commands[j], entry.callback, commandIndexes[name])
                end
            else
                commandIndexes[name] = (commandIndexes[name] or 0) + 1
                registerCommand(name, commands, entry.callback, commandIndexes[name])
            end
        end
    end
end
