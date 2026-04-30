local env = select(2, ...)
local SlashCommand = env.modules:New("packages\\slash-command")

local type = type
local getmetatable = getmetatable
local gmatch = string.gmatch

local commandIndexes = {}

local function ParseTokens(message)
    local tokens = {}
    local count = 0
    for token in gmatch(message, "%S+") do
        count = count + 1
        tokens[count] = token
    end
    return tokens
end

local function RegisterCommand(name, slashText, callback, slotIndex)
    _G["SLASH_" .. name .. slotIndex] = "/" .. slashText
    SlashCmdList[name] = function(message)
        callback(message, ParseTokens(message))
    end
end

local function HookCommand(name, callback)
    local existingHandler = SlashCmdList[name]
    if not existingHandler then return false end

    SlashCmdList[name] = function(message)
        existingHandler(message)
        callback(message, ParseTokens(message))
    end
    return true
end

local function RemoveCommand(name)
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

function SlashCommand.GetTokens(message)
    return ParseTokens(message)
end

function SlashCommand.GetSlashCommand(name)
    return SlashCmdList[name]
end

function SlashCommand.AddSlashCommand(name, slashText, callback, slotIndex)
    RegisterCommand(name, slashText, callback, slotIndex)
end

function SlashCommand.HookSlashCommand(name, callback)
    return HookCommand(name, callback)
end

function SlashCommand.RemoveSlashCommand(name)
    RemoveCommand(name)
end

function SlashCommand.AddFromSchema(schema)
    for i = 1, #schema do
        local entry = schema[i]
        assert(entry.name, "`AddFromSchema`: `name` is required")
        assert(entry.callback, "`AddFromSchema`: `callback` is required")

        if entry.hook and SlashCmdList[entry.hook] then
            HookCommand(entry.hook, entry.callback)
        else
            local commands = entry.command
            local name = entry.name
            if type(commands) == "table" then
                for _, cmd in ipairs(commands) do
                    commandIndexes[name] = (commandIndexes[name] or 0) + 1
                    RegisterCommand(name, cmd, entry.callback, commandIndexes[name])
                end
            else
                commandIndexes[name] = (commandIndexes[name] or 0) + 1
                RegisterCommand(name, commands, entry.callback, commandIndexes[name])
            end
        end
    end
end
