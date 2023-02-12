local W, F, L, P, G, O = unpack(select(2, ...))
local C = W.Utilities.Color

_G.StaticPopupDialogs["WIND_CHAT_FILTER_NEW_RULE"] = {
    text = L["New Rule Name"],
    button1 = L["Create"],
    button2 = L["Cancel"],
    hasEditBox = true,
    OnShow = function(self, data)
        self.editBox:SetAutoFocus(false)
        self.editBox.originalWidth = self.editBox:GetWidth()
        self.editBox:SetWidth(250)
        self.editBox:AddHistoryLine(L["New Rule"])
        self.editBox:SetText(L["New Rule"])
        self.editBox:HighlightText()
        self.editBox:SetJustifyH("CENTER")
    end,
    OnHide = function(self)
        self.editBox:SetWidth(self.editBox.originalWidth or 50)
        self.editBox.originalWidth = nil
    end,
    EditBoxOnEnterPressed = function(self, data)
        F.CreateNewRuleWithName(self.editBox:GetText(), data.table, data.optionTable)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnTextChanged = function(self)
        return
    end,
    OnAccept = function(self, data)
        F.CreateNewRuleWithName(self.editBox:GetText(), data.table, data.optionTable)
    end,
    whileDead = true,
    preferredIndex = 3,
    hideOnEscape = true
}

local function isDefaultRule(ruleID)
    return strsub(ruleID, 1, 2) == "__"
end

local function coloredToggleName(tbl, key)
    local k = key or "enabled"
    if tbl[k] then
        return C.StringByTemplate(L["Enabled"], "success")
    else
        return C.StringByTemplate(L["Disabled"], "danger")
    end
end

local function customArea(context, tbl, data)
    local addTemp = ""
    local addOptions = {
        type = "group",
        name = data.addTitle,
        order = data.order,
        inline = true,
        disabled = data.disabled,
        hidden = data.hidden,
        args = {
            inputPreview = {
                type = "description",
                name = function()
                    if addTemp ~= "" and data.previewWithString then
                        return L["Preview: "] .. data.previewWithString(addTemp)
                    end
                    return ""
                end,
                hidden = function()
                    return addTemp == "" or not data.previewWithString
                end,
                order = 9
            },
            inputArea = {
                type = "input",
                name = data.addInputTitle,
                order = 10,
                get = function(info)
                    return addTemp
                end,
                set = function(info, value)
                    addTemp = value
                end
            },
            addButton = {
                type = "execute",
                name = data.addButtonText,
                order = 11,
                func = function()
                    if tbl[addTemp] then
                        F.Print(data.addDuplicateMessage)
                    else
                        if data.customVerifier then
                            local result, message = data.customVerifier(addTemp)
                            if not result then
                                F.Print(message)
                                return
                            end
                        end
                        tbl[addTemp] = true
                        addTemp = ""
                        F.RefreshRuleOptions(context.dbTable, context.optionTable, context.ruleID, context.rule)
                        W:SendMessage("WCF_RULE_UPDATED")
                    end
                end
            }
        }
    }

    local customOptions = {
        type = "group",
        name = data.customTitle,
        order = data.order + 1,
        inline = true,
        disabled = data.disabled,
        hidden = data.hidden,
        args = {}
    }

    for object in pairs(tbl) do
        local name = data.objectToName(object)
        customOptions.args[object] = {
            type = "execute",
            name = name,
            func = function()
                tbl[object] = nil
                F.Print(format(L["%s has been removed."], C.StringByTemplate(name, "info")))

                F.RefreshRuleOptions(context.dbTable, context.optionTable, context.ruleID, context.rule)
                W:SendMessage("WCF_RULE_UPDATED")
                W:RefreshOptions()
            end,
            confirm = true,
            confirmText = format(L["Did you really want to remove %s?"], C.StringByTemplate(name, "info"))
        }
    end

    return addOptions, customOptions
end

local function mapOptions(context, order)
    local options = {
        type = "group",
        name = L["Map"],
        order = order,
        get = function(info)
            return context.rule.map[info[#info]]
        end,
        set = function(info, value)
            context.rule.map[info[#info]] = value
            W:SendMessage("WCF_RULE_UPDATED")
        end,
        args = {
            enabled = {
                type = "toggle",
                name = function(info)
                    return coloredToggleName(context.rule.map)
                end,
                desc = L["Filter by the map where player is in."],
                disabled = context.isDefault,
                order = 10
            },
            mainCity = {
                type = "toggle",
                name = L["Main City"],
                desc = L["Add all main cities to this rule."],
                order = 11,
                disabled = context.isDefault,
                hidden = function()
                    return not context.rule.map.enabled
                end
            },
            help = {
                type = "group",
                name = L["Help"],
                order = 12,
                inline = true,
                disabled = context.isDefault,
                hidden = function()
                    return context.isDefault or not context.rule.map.enabled
                end,
                args = {
                    currentMap = {
                        order = 1,
                        type = "description",
                        name = function()
                            local mapID = C_Map.GetBestMapForUnit("player")
                            local ok, info = pcall(C_Map.GetMapInfo, mapID)
                            if ok and info and info.name then
                                return format(
                                    L["Current Map:"] .. " %s (%s)",
                                    C.StringByTemplate(info.name, "info"),
                                    C.StringByTemplate(tostring(mapID), "info")
                                )
                            else
                                return C.StringByTemplate(L["Failed to get current map id."], "danger")
                            end
                        end,
                        width = "full"
                    }
                }
            }
        }
    }

    local addOptions, customOptions =
        customArea(
        context,
        context.rule.map.mapIDs,
        {
            previewWithString = function(value)
                local ok, info = pcall(C_Map.GetMapInfo, value)
                if ok and info and info.name then
                    return C.StringByTemplate(info.name, "info")
                else
                    return C.StringByTemplate(L["Invalid map ID."], "danger")
                end
            end,
            addTitle = L["Add Map"],
            addInputTitle = L["Map ID"],
            addButtonText = L["Add"],
            addDuplicateMessage = L["This map has already been added."],
            customVerifier = function(value)
                local ok, info = pcall(C_Map.GetMapInfo, value)
                if ok and info and info.name then
                    return true, info.name
                else
                    return false, L["Invalid map ID."]
                end
            end,
            customTitle = L["Custom Maps"],
            objectToName = function(object)
                local ok, info = pcall(C_Map.GetMapInfo, object)
                return info.name
            end,
            order = 13,
            disabled = context.isDefault,
            hidden = function()
                return not context.rule.map.enabled
            end
        }
    )

    options.args.addMap = addOptions
    options.args.customMaps = customOptions

    return options
end

local function messageOptions(context, order)
    local options = {
        type = "group",
        name = L["Message"],
        order = order,
        get = function(info)
            return context.rule.message[info[#info]]
        end,
        set = function(info, value)
            context.rule.message[info[#info]] = value
            W:SendMessage("WCF_RULE_UPDATED")
        end,
        args = {
            enabled = {
                type = "toggle",
                name = function(info)
                    return coloredToggleName(context.rule.message)
                end,
                desc = L["Filter by the specific keywords in the message."],
                disabled = context.isDefault,
                order = 10
            },
            help = {
                type = "group",
                name = L["Help"],
                order = 11,
                inline = true,
                disabled = context.isDefault,
                hidden = function()
                    return not context.rule.message.enabled
                end,
                args = {
                    regex = {
                        order = 1,
                        type = "description",
                        name = L[
                            "Regex is supported, however CJK support is not guaranteed because the Lua version embedded in WoW is 5.1."
                        ],
                        width = "full"
                    }
                }
            }
        }
    }

    local addOptions, customOptions =
        customArea(
        context,
        context.rule.message.keywords,
        {
            previewWithString = nil,
            addTitle = L["Add Keyword"],
            addInputTitle = L["Keyword"],
            addButtonText = L["Add"],
            addDuplicateMessage = L["This keyword has already been added."],
            customVerifier = nil,
            customTitle = L["Custom Keywords"],
            objectToName = function(object)
                return object
            end,
            order = 12,
            disabled = context.isDefault,
            hidden = function()
                return not context.rule.message.enabled
            end
        }
    )

    options.args.addMap = addOptions
    options.args.customMaps = customOptions

    return options
end

local function channelOptions(context, order)
    local options = {
        type = "group",
        name = L["Channel"],
        order = order,
        get = function(info)
            return context.rule.channel[info[#info]]
        end,
        set = function(info, value)
            context.rule.channel[info[#info]] = value
            W:SendMessage("WCF_RULE_UPDATED")
        end,
        args = {
            enabled = {
                type = "toggle",
                name = function(info)
                    return coloredToggleName(context.rule.channel)
                end,
                desc = L["Filter by the channel category or names."],
                disabled = context.isDefault,
                order = 10
            },
            help = {
                type = "group",
                name = L["Help"],
                order = 11,
                inline = true,
                disabled = context.isDefault,
                hidden = function()
                    return not context.rule.channel.enabled
                end,
                args = {
                    regex = {
                        order = 1,
                        type = "description",
                        name = L[
                            "Regex is supported, however CJK support is not guaranteed because the Lua version embedded in WoW is 5.1."
                        ],
                        width = "full"
                    }
                }
            },
            normalChannels = {
                type = "group",
                name = L["Normal Channels"],
                order = 12,
                inline = true,
                disabled = context.isDefault,
                hidden = function()
                    return not context.rule.channel.enabled
                end,
                get = function(info)
                    return context.rule.channel[info[#info]]
                end,
                set = function(info, value)
                    context.rule.channel[info[#info]] = value
                    W:SendMessage("WCF_RULE_UPDATED")
                end,
                args = {
                    say = {
                        type = "toggle",
                        name = L["Say"],
                        order = 1
                    },
                    yell = {
                        type = "toggle",
                        name = L["Yell"],
                        order = 2
                    },
                    whisper = {
                        type = "toggle",
                        name = L["Whisper"],
                        order = 3
                    },
                    emote = {
                        type = "toggle",
                        name = L["Emote"],
                        order = 4
                    },
                    guild = {
                        type = "toggle",
                        name = L["Guild"],
                        order = 5
                    },
                    party = {
                        type = "toggle",
                        name = L["Party"],
                        order = 6
                    },
                    raid = {
                        type = "toggle",
                        name = L["Raid"],
                        order = 7
                    },
                    trade = {
                        type = "toggle",
                        name = L["Trade"],
                        order = 8
                    },
                    general = {
                        type = "toggle",
                        name = L["General"],
                        order = 9
                    },
                    battleground = {
                        type = "toggle",
                        name = L["Battleground"],
                        order = 10
                    }
                }
            }
        }
    }

    local addOptions, customOptions =
        customArea(
        context,
        context.rule.channel.channelNames,
        {
            previewWithString = nil,
            addTitle = L["Add Channel"],
            addInputTitle = L["Channel Name"],
            addButtonText = L["Add"],
            addDuplicateMessage = L["This channel name has already been added."],
            customVerifier = nil,
            customTitle = L["Custom Channel Names"],
            objectToName = function(object)
                return object
            end,
            order = 13,
            disabled = context.isDefault,
            hidden = function()
                return not context.rule.channel.enabled
            end
        }
    )

    options.args.addMap = addOptions
    options.args.customMaps = customOptions

    return options
end

local englishRaceToID = {
    neutral = {
        Pandaren = 24,
        Dracthyr = 52
    },
    alliance = {
        Human = 1,
        Dwarf = 3,
        NightElf = 4,
        Gnome = 7,
        Draenei = 11,
        Worgen = 7,
        VoidElf = 29,
        LightforgedDraenei = 30,
        DarkIronDwarf = 34,
        KulTiran = 32,
        Mechagnome = 37
    },
    horde = {
        Orc = 2,
        Undead = 5,
        Tauren = 6,
        Troll = 8,
        BloodElf = 10,
        Goblin = 9,
        Nightborne = 27,
        HighmountainTauren = 28,
        MagharOrc = 36,
        ZandalariTroll = 31,
        Vulpera = 35
    }
}

local function playerInfoOptions(context, order)
    local options = {
        type = "group",
        name = L["Player Info"],
        order = order,
        get = function(info)
            return context.rule.playerInfo[info[#info]]
        end,
        set = function(info, value)
            context.rule.playerInfo[info[#info]] = value
            W:SendMessage("WCF_RULE_UPDATED")
        end,
        args = {
            enabled = {
                type = "toggle",
                name = function(info)
                    return coloredToggleName(context.rule.playerInfo)
                end,
                desc = L["Filter by the channel category or names."],
                disabled = context.isDefault,
                order = 10
            },
            class = {
                type = "group",
                name = L["Class"],
                order = 11,
                inline = true,
                disabled = context.isDefault,
                hidden = function()
                    return not context.rule.playerInfo.enabled
                end,
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = function(info)
                            return coloredToggleName(context.rule.playerInfo.config, "class")
                        end,
                        get = function(info)
                            return context.rule.playerInfo.config.class
                        end,
                        set = function(info, value)
                            context.rule.playerInfo.config.class = value
                            W:SendMessage("WCF_RULE_UPDATED")
                        end,
                        desc = L["Filter by the message sender's class."],
                        width = "full"
                    }
                }
            },
            race = {
                type = "group",
                name = L["Race"],
                order = 12,
                inline = true,
                get = function(info)
                    return context.rule.playerInfo.race[info[#info]]
                end,
                set = function(info, value)
                    context.rule.playerInfo.race[info[#info]] = value
                    W:SendMessage("WCF_RULE_UPDATED")
                end,
                disabled = context.isDefault,
                hidden = function()
                    return not context.rule.playerInfo.enabled
                end,
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = function(info)
                            return coloredToggleName(context.rule.playerInfo.config, "race")
                        end,
                        get = function(info)
                            return context.rule.playerInfo.config.race
                        end,
                        set = function(info, value)
                            context.rule.playerInfo.config.race = value
                            W:SendMessage("WCF_RULE_UPDATED")
                        end,
                        desc = L["Filter by the message sender's race."],
                        width = "full"
                    },
                    includeHostileFaction = {
                        order = 2,
                        type = "toggle",
                        name = L["Hostile Factions"],
                        desc = L["Enable this option will make the filter to match all races in hostile factions."],
                        hidden = function()
                            return not context.rule.playerInfo.config.race
                        end
                    },
                    includeNeutral = {
                        order = 3,
                        type = "toggle",
                        name = L["Neutral Factions"],
                        desc = L["Enable this option will make the filter to match all races in neutral factions."],
                        hidden = function()
                            return not context.rule.playerInfo.config.race
                        end
                    },
                    betterAlign = {
                        order = 4,
                        type = "description",
                        name = " ",
                        hidden = function()
                            return not context.rule.playerInfo.config.race
                        end
                    }
                }
            },
            name = {
                type = "group",
                name = L["Player Name"],
                order = 13,
                inline = true,
                hidden = function()
                    return not context.rule.playerInfo.enabled
                end,
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = function(info)
                            return coloredToggleName(context.rule.playerInfo.config, "name")
                        end,
                        get = function(info)
                            return context.rule.playerInfo.config.name
                        end,
                        set = function(info, value)
                            context.rule.playerInfo.config.name = value
                            W:SendMessage("WCF_RULE_UPDATED")
                        end,
                        desc = L["Filter by the message sender's name."],
                        width = "full"
                    }
                }
            },
            realm = {
                type = "group",
                name = L["Realm"],
                order = 14,
                inline = true,
                hidden = function()
                    return not context.rule.playerInfo.enabled
                end,
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = function(info)
                            return coloredToggleName(context.rule.playerInfo.config, "realm")
                        end,
                        get = function(info)
                            return context.rule.playerInfo.config.realm
                        end,
                        set = function(info, value)
                            context.rule.playerInfo.config.realm = value
                            W:SendMessage("WCF_RULE_UPDATED")
                        end,
                        desc = L["Filter by the message sender's realm."],
                        width = "full"
                    }
                }
            }
        }
    }

    for i = 1, GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(i)
        if classInfo.classFile then
            local hex = select(4, GetClassColor(classInfo.classFile))
            options.args.class.args[classInfo.classFile] = {
                type = "toggle",
                name = function()
                    local icon = F.GetClassIconStringWithStyle(classInfo.classFile, "flat", 16, 16)
                    icon = icon and icon .. " " or ""
                    return icon .. format("|c%s%s|r", hex, classInfo.className)
                end,
                order = i + 10,
                get = function(info)
                    return context.rule.playerInfo.class[info[#info]]
                end,
                set = function(info, value)
                    context.rule.playerInfo.class[info[#info]] = value
                    W:SendMessage("WCF_RULE_UPDATED")
                end,
                hidden = function()
                    return not context.rule.playerInfo.config.class
                end
            }
        end
    end

    local tempOrder = 10
    local addRaceOption = function(tbl, color, icon)
        for raceKey, raceID in pairs(tbl) do
            local raceInfo = C_CreatureInfo.GetRaceInfo(raceID)
            if raceInfo then
                options.args.race.args[raceKey] = {
                    type = "toggle",
                    name = (icon and F.GetIconString(icon, 16) .. " " or "") ..
                        format("|cff%s%s|r", color, raceInfo.raceName),
                    order = tempOrder,
                    get = function(info)
                        return context.rule.playerInfo.race[info[#info]]
                    end,
                    set = function(info, value)
                        context.rule.playerInfo.race[info[#info]] = value
                        W:SendMessage("WCF_RULE_UPDATED")
                    end,
                    hidden = function()
                        return not context.rule.playerInfo.config.race
                    end
                }
            end
            tempOrder = tempOrder + 1
        end
    end

    addRaceOption(englishRaceToID.neutral, "ffc500", "4238929")
    addRaceOption(englishRaceToID.alliance, "1390df", "132486")
    addRaceOption(englishRaceToID.horde, "c21816", "132485")

    local playerNameAddOptions, playerNameCustomOptions =
        customArea(
        context,
        context.rule.playerInfo.name,
        {
            previewWithString = nil,
            addTitle = L["Add Player Name"],
            addInputTitle = L["Player Name"],
            addButtonText = L["Add"],
            addDuplicateMessage = L["This player name has already been added."],
            customVerifier = nil,
            customTitle = L["Custom Player Names"],
            objectToName = function(object)
                return object
            end,
            order = 10,
            disabled = context.isDefault,
            hidden = function()
                return not context.rule.playerInfo.config.name
            end
        }
    )

    options.args.name.args.add = playerNameAddOptions
    options.args.name.args.custom = playerNameCustomOptions

    local playerRealmAddOptions, playerRealmCustomOptions =
        customArea(
        context,
        context.rule.playerInfo.realm,
        {
            previewWithString = nil,
            addTitle = L["Add Player Realm"],
            addInputTitle = L["Player Realm"],
            addButtonText = L["Add"],
            addDuplicateMessage = L["This player realm has already been added."],
            customVerifier = nil,
            customTitle = L["Custom Player Realms"],
            objectToName = function(object)
                return object
            end,
            order = 10,
            disabled = context.isDefault,
            hidden = function()
                return not context.rule.playerInfo.config.realm
            end
        }
    )

    options.args.realm.args.add = playerRealmAddOptions
    options.args.realm.args.custom = playerRealmCustomOptions

    return options
end

function F.RefreshRuleOptions(dbTable, optionTable, ruleID, rule)
    local context = {
        ruleID = ruleID,
        rule = rule,
        isDefault = isDefaultRule(ruleID),
        optionTable = optionTable,
        dbTable = dbTable
    }

    local options = {
        type = "group",
        name = function()
            local prefix = ""
            if context.isDefault then
                prefix = F.GetIconString(W.Media.Textures.smallLogo, 14) .. " "
            end
            return prefix .. C.StringByTemplate(rule.name, rule.enabled and "success" or "danger")
        end,
        desc = function()
            local desc = rule.description
            desc = desc and desc ~= "" and desc .. "\n\n" or ""

            if context.isDefault then
                desc =
                    desc ..
                    L["This is a default rule and cannot be deleted."] ..
                        "\n" ..
                            format(
                                L["Provided by %s"],
                                F.GetIconString(W.Media.Textures.smallLogo, 14) .. " " .. W.AddonName
                            )
            else
                desc = desc .. L["This is a custom rule."]

                local timestamp = tonumber(strsub(ruleID, 1, -3))
                if timestamp then
                    desc =
                        desc ..
                        "\n" ..
                            format(
                                L["Created on %s"],
                                C.StringByTemplate(date(L["%m-%d-%Y %H:%M:%S"], timestamp), "primary")
                            )
                end
            end
            return desc
        end,
        order = 1000 - rule.priority,
        args = {
            general = {
                type = "group",
                name = L["General"],
                order = 10,
                inline = true,
                args = {
                    ruleEnabled = {
                        type = "toggle",
                        name = function(info)
                            return coloredToggleName(rule)
                        end,
                        order = 10,
                        get = function(info)
                            return rule.enabled
                        end,
                        set = function(info, value)
                            rule.enabled = value
                            W:SendMessage("WCF_RULE_UPDATED")
                        end
                    },
                    rulePriority = {
                        type = "range",
                        name = L["Priority"],
                        order = 11,
                        min = 1,
                        max = 1000,
                        step = 1,
                        get = function(info)
                            return rule.priority
                        end,
                        set = function(info, value)
                            rule.priority = value
                            W:SendMessage("WCF_RULE_UPDATED")
                        end,
                        desc = function()
                            local tooltipText = L["The rule which has higher priority will be applied first."]
                            if context.isDefault then
                                tooltipText =
                                    "\n\n" .. C.StringByTemplate(L["Default rules cannot be changed."], "warning")
                            end

                            return tooltipText
                        end
                    },
                    ruleName = {
                        type = "input",
                        name = L["Rule Name"],
                        order = 12,
                        get = function(info)
                            return rule.name
                        end,
                        set = function(info, value)
                            rule.name = value
                        end,
                        width = "full"
                    },
                    ruleDescription = {
                        type = "input",
                        name = L["Rule Description"],
                        order = 13,
                        get = function(info)
                            return rule.description
                        end,
                        set = function(info, value)
                            rule.description = value
                        end,
                        width = "full"
                    }
                }
            },
            removeRule = {
                type = "execute",
                name = L["Remove Rule"],
                order = 11,
                func = function()
                    F.RemoveRule(dbTable, optionTable, ruleID)
                    W:SendMessage("WCF_RULE_UPDATED")
                end,
                confirm = true,
                confirmText = L["Are you sure to remove this rule?"],
                hidden = context.isDefault
            },
            copyRule = {
                type = "execute",
                name = L["Copy Rule"],
                order = 12,
                func = function()
                    F.CopyRule(context.rule, dbTable, optionTable)
                    W:SendMessage("WCF_RULE_UPDATED")
                end
            },
            channel = channelOptions(context, 20),
            map = mapOptions(context, 30),
            message = messageOptions(context, 40),
            playerInfo = playerInfoOptions(context, 50)
        }
    }

    if context.isDefault then
        options.args.general.args.rulePriority.hidden = true
        options.args.general.args.ruleName.disabled = true
        options.args.general.args.ruleDescription.disabled = true

        options.args.defualtRuleDescription = {
            type = "group",
            name = L["Notice"],
            order = 1,
            inline = true,
            args = {
                title = {
                    type = "description",
                    name = C.StringByTemplate(L["Some settings of default rules cannot be changed."], "warning"),
                    order = 1,
                    width = "full"
                }
            }
        }
    end

    optionTable["rule_" .. ruleID] = options
end

local emptyRule = {
    enabled = false,
    name = L["New Rule"],
    description = "",
    priority = 1,
    playerInfo = {
        enabled = false,
        config = {
            race = false,
            class = false,
            name = false,
            realm = false
        },
        class = {
            DEMONHUNTER = false,
            DEATHKNIGHT = false,
            WARRIOR = false,
            MAGE = false,
            ROGUE = false,
            DRUID = false,
            HUNTER = false,
            SHAMAN = false,
            PRIEST = false,
            WARLOCK = false,
            PALADIN = false,
            MONK = false,
            EVOKER = false
        },
        race = {
            Pandaren = false,
            Dracthyr = false,
            Human = false,
            Dwarf = false,
            NightElf = false,
            Gnome = false,
            Draenei = false,
            Worgen = false,
            VoidElf = false,
            LightforgedDraenei = false,
            DarkIronDwarf = false,
            KulTiran = false,
            Mechagnome = false,
            Orc = false,
            Scourge = false,
            Tauren = false,
            Troll = false,
            BloodElf = false,
            Goblin = false,
            Nightborne = false,
            HighmountainTauren = false,
            MagharOrc = false,
            ZandalariTroll = false,
            Vulpera = false,
            includeHostileFaction = false,
            includeNeutral = false
        },
        name = {},
        realm = {}
    },
    channel = {
        enabled = false,
        say = false,
        yell = false,
        whisper = false,
        emote = false,
        guild = false,
        party = false,
        raid = false,
        trade = false,
        general = false,
        battleground = false,
        channelNames = {}
    },
    map = {
        enabled = false,
        mainCity = false,
        mapIDs = {}
    },
    message = {
        enabled = false,
        keywords = {}
    }
}

function F.CreateNewRule(tbl, optTbl)
    StaticPopup_Show(
        "WIND_CHAT_FILTER_NEW_RULE",
        nil,
        nil,
        {
            table = tbl,
            optionTable = optTbl
        }
    )
end

function F.CreateNewRuleWithName(name, tbl, optTbl)
    local randomID = tostring(time()) .. tostring(random(11, 99))
    tbl[randomID] = CopyTable(emptyRule)
    tbl[randomID].name = name
    F.RefreshRuleOptions(tbl, optTbl, randomID, tbl[randomID])
    W:RefreshOptions()
end

function F.CopyRule(rule, tbl, optTbl)
    local randomID = tostring(time()) .. tostring(random(11, 99))
    tbl[randomID] = CopyTable(rule)
    tbl[randomID].name = rule.name .. " " .. L["Copy"]
    F.RefreshRuleOptions(tbl, optTbl, randomID, tbl[randomID])
    W:RefreshOptions()
end

function F.RemoveRule(tbl, optTbl, ruleID)
    tbl[ruleID] = nil
    optTbl["rule_" .. ruleID] = nil
    W:RefreshOptions()
end
