local W, F, L, P, G, O = unpack(select(2, ...))

local codeSnippet =
    [[
local C = _G.WindChatFilter[1]:GetModule("Core")

C:TestWithAllFilters({
    channel = "Say",
    message = "This is a test message.",
    sender = "CoolName",
    guid = UnitGUID("player")
})
]]

O.advanced = {
    order = 100,
    name = L["Advanced"],
    type = "group",
    args = {
        description = {
            order = 0,
            name = L["Description"],
            type = "group",
            inline = true,
            args = {
                title = {
                    order = 0,
                    type = "description",
                    fontSize = "medium",
                    name = L["Here are some options for advanced users."],
                    width = "full"
                }
            }
        },
        general = {
            order = 1,
            name = L["General"],
            type = "group",
            inline = true,
            args = {
                includeMyself = {
                    order = 1,
                    type = "toggle",
                    name = L["Include Myself"],
                    desc = L["Filter the messages from you."],
                    get = function(info)
                        return W.global.advanced.includeMyself
                    end,
                    set = function(info, value)
                        W.global.advanced.includeMyself = value
                    end,
                    width = 1.5
                }
            }
        },
        cache = {
            order = 2,
            name = L["Cache"],
            type = "group",
            inline = true,
            args = {
                doNotUseGUIDCache = {
                    order = 2,
                    type = "toggle",
                    name = L["Do Not Use GUID Cache"],
                    desc = L[
                        "Disable GUID cache to reduce memory usage, but it will cause the performance drop when you are in a crowed server."
                    ],
                    get = function(info)
                        return W.global.advanced.doNotUseGUIDCache
                    end,
                    set = function(info, value)
                        W.global.advanced.doNotUseGUIDCache = value
                    end,
                    width = 1.5
                },
                clearAllCache = {
                    order = 3,
                    type = "execute",
                    name = L["Clear All Cache"],
                    desc = L["Clear all cache data, including GUID cache, name cache, and rule cache."],
                    width = "full",
                    func = function()
                        F.CleanupPlayerInfoCache()
                        W:GetModule("Core"):RebuildRules()
                    end,
                    width = 1.5
                }
            }
        },
        developer = {
            order = 10,
            name = L["Developer"],
            type = "group",
            inline = true,
            args = {
                logLevel = {
                    order = 1,
                    type = "select",
                    name = L["Log Level"],
                    desc = L["Only display log message that the level is higher than you choose."] ..
                        "\n|cffff3860" .. L["Set to 2 if you do not understand the meaning of log level."] .. "|r",
                    get = function(info)
                        return W.global.advanced.logLevel
                    end,
                    set = function(info, value)
                        W.global.advanced.logLevel = value
                    end,
                    hidden = function()
                    end,
                    values = {
                        [1] = "1 - |cffff3860[ERROR]|r",
                        [2] = "2 - |cffffdd57[WARNING]|r",
                        [3] = "3 - |cff209cee[INFO]|r",
                        [4] = "4 - |cff00d1b2[DEBUG]|r"
                    }
                },
                filterStatus = {
                    order = 2,
                    type = "execute",
                    name = L["Filter Status"],
                    desc = L["Print the status of all filters."],
                    func = function()
                        F.Print("Filter Status:")
                        W:GetModule("Core"):GetRunningFilterStatus()
                    end
                }
            }
        },
        codeSnippet = {
            order = 20,
            name = L["Code Snippet"],
            type = "group",
            inline = true,
            args = {
                title = {
                    order = 0,
                    type = "description",
                    fontSize = "medium",
                    name = L["Here is a code snippet for you to test your filter."],
                    width = "full"
                },
                code = {
                    order = 1,
                    type = "input",
                    name = L["Code"],
                    multiline = 9,
                    width = "full",
                    get = function(info)
                        return codeSnippet
                    end,
                    set = function(info, value)
                        codeSnippet = value
                    end
                },
                execute = {
                    order = 2,
                    type = "execute",
                    name = L["Execute"],
                    func = function()
                        local func, err = loadstring(codeSnippet)
                        if not func then
                            F.Developer.LogError("Code snippet error: " .. err)
                            return
                        end
                        func()
                    end
                }
            }
        }
    }
}
