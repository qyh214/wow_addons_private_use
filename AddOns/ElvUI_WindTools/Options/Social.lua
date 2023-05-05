local W, F, E, L, V, P, G = unpack((select(2, ...)))
local options = W.options.social.args
local LSM = E.Libs.LSM

local pairs = pairs
local print = print

local FriendsFrame_Update = FriendsFrame_Update

local customListSelected

local CB = W:GetModule("ChatBar")
local CL = W:GetModule("ChatLink")
local CT = W:GetModule("ChatText")
local WE = W:GetModule("Emote")
local FL = W:GetModule("FriendList")
local CM = W:GetModule("ContextMenu")
local ST = W:GetModule("SmartTab")

options.chatBar = {
    order = 1,
    type = "group",
    name = L["Chat Bar"],
    get = function(info)
        return E.db.WT.social.chatBar[info[#info]]
    end,
    set = function(info, value)
        E.db.WT.social.chatBar[info[#info]] = value
        CB:UpdateBar()
    end,
    args = {
        desc = {
            order = 0,
            type = "group",
            inline = true,
            name = L["Description"],
            args = {
                feature = {
                    order = 1,
                    type = "description",
                    name = L["Add a chat bar for switching channel."],
                    fontSize = "medium"
                }
            }
        },
        enable = {
            order = 1,
            type = "toggle",
            name = L["Enable"],
            set = function(info, value)
                E.db.WT.social.chatBar[info[#info]] = value
                CB:ProfileUpdate()
            end
        },
        general = {
            order = 2,
            type = "group",
            inline = true,
            name = L["General"],
            disabled = function()
                return not E.db.WT.social.chatBar.enable
            end,
            args = {
                autoHide = {
                    order = 1,
                    type = "toggle",
                    name = L["Auto Hide"],
                    desc = L["Hide channels that do not exist."]
                },
                mouseOver = {
                    order = 2,
                    type = "toggle",
                    name = L["Mouse Over"],
                    desc = L["Only show chat bar when you mouse over it."]
                },
                orientation = {
                    order = 3,
                    type = "select",
                    name = L["Orientation"],
                    values = {
                        HORIZONTAL = L["Horizontal"],
                        VERTICAL = L["Vertical"]
                    }
                }
            }
        },
        backdrop = {
            order = 3,
            type = "group",
            inline = true,
            name = L["Backdrop"],
            disabled = function()
                return not E.db.WT.social.chatBar.enable
            end,
            args = {
                backdrop = {
                    order = 1,
                    type = "toggle",
                    name = L["Bar Backdrop"],
                    desc = L["Show a backdrop of the bar."]
                },
                backdropSpacing = {
                    order = 2,
                    type = "range",
                    name = L["Backdrop Spacing"],
                    desc = L["The spacing between the backdrop and the buttons."],
                    min = 1,
                    max = 30,
                    step = 1
                }
            }
        },
        button = {
            order = 4,
            type = "group",
            inline = true,
            name = L["Button"],
            disabled = function()
                return not E.db.WT.social.chatBar.enable
            end,
            args = {
                buttonWidth = {
                    order = 1,
                    type = "range",
                    name = L["Button Width"],
                    desc = L["The width of the buttons."],
                    min = 2,
                    max = 80,
                    step = 1
                },
                buttonHeight = {
                    order = 2,
                    type = "range",
                    name = L["Button Height"],
                    desc = L["The height of the buttons."],
                    min = 2,
                    max = 60,
                    step = 1
                },
                spacing = {
                    order = 3,
                    type = "range",
                    name = L["Spacing"],
                    min = 0,
                    max = 80,
                    step = 1
                },
                style = {
                    order = 4,
                    type = "select",
                    name = L["Style"],
                    values = {
                        BLOCK = L["Block"],
                        TEXT = L["Text"]
                    }
                }
            }
        },
        blockStyle = {
            order = 5,
            type = "group",
            inline = true,
            hidden = function()
                return not (E.db.WT.social.chatBar.style == "BLOCK")
            end,
            disabled = function()
                return not E.db.WT.social.chatBar.enable
            end,
            name = L["Style"],
            args = {
                blockShadow = {
                    order = 1,
                    type = "toggle",
                    name = L["Block Shadow"]
                },
                tex = {
                    order = 2,
                    type = "select",
                    name = L["Texture"],
                    dialogControl = "LSM30_Statusbar",
                    values = LSM:HashTable("statusbar")
                }
            }
        },
        textStyle = {
            order = 6,
            type = "group",
            inline = true,
            disabled = function()
                return not E.db.WT.social.chatBar.enable
            end,
            hidden = function()
                return not (E.db.WT.social.chatBar.style == "TEXT")
            end,
            name = L["Style"],
            args = {
                color = {
                    order = 1,
                    type = "toggle",
                    name = L["Use Color"]
                },
                font = {
                    type = "group",
                    order = 2,
                    name = L["Font Setting"],
                    get = function(info)
                        return E.db.WT.social.chatBar.font[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.WT.social.chatBar.font[info[#info]] = value
                        CB:UpdateBar()
                    end,
                    args = {
                        name = {
                            order = 1,
                            type = "select",
                            dialogControl = "LSM30_Font",
                            name = L["Font"],
                            values = LSM:HashTable("font")
                        },
                        style = {
                            order = 2,
                            type = "select",
                            name = L["Outline"],
                            values = {
                                NONE = L["None"],
                                OUTLINE = L["OUTLINE"],
                                MONOCHROME = L["MONOCHROME"],
                                MONOCHROMEOUTLINE = L["MONOCROMEOUTLINE"],
                                THICKOUTLINE = L["THICKOUTLINE"]
                            }
                        },
                        size = {
                            order = 3,
                            name = L["Size"],
                            type = "range",
                            min = 5,
                            max = 60,
                            step = 1
                        }
                    }
                }
            }
        },
        channels = {
            order = 7,
            type = "group",
            inline = true,
            name = L["Channels"],
            disabled = function()
                return not E.db.WT.social.chatBar.enable
            end,
            args = {
                world = {
                    order = 100,
                    type = "group",
                    name = L["World"],
                    get = function(info)
                        return E.db.WT.social.chatBar.channels.world[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.WT.social.chatBar.channels.world[info[#info]] = value
                        CB:UpdateBar()
                    end,
                    args = {
                        enable = {
                            order = 1,
                            type = "toggle",
                            name = L["Enable"]
                        },
                        color = {
                            order = 2,
                            type = "color",
                            name = L["Color"],
                            hasAlpha = true,
                            get = function(info)
                                local colordb = E.db.WT.social.chatBar.channels.world.color
                                local default = P.social.chatBar.channels.world.color
                                return colordb.r, colordb.g, colordb.b, colordb.a, default.r, default.g, default.b, default.a
                            end,
                            set = function(info, r, g, b, a)
                                E.db.WT.social.chatBar.channels.world.color = {
                                    r = r,
                                    g = g,
                                    b = b,
                                    a = a
                                }
                                CB:UpdateBar()
                            end
                        },
                        abbr = {
                            order = 3,
                            type = "input",
                            hidden = function()
                                return not (E.db.WT.social.chatBar.style == "TEXT")
                            end,
                            name = L["Abbreviation"]
                        },
                        name = {
                            order = 4,
                            type = "input",
                            name = L["Channel Name"]
                        },
                        autoJoin = {
                            order = 5,
                            type = "toggle",
                            name = L["Auto Join"]
                        }
                    }
                },
                community = {
                    order = 101,
                    type = "group",
                    name = L["Community"],
                    get = function(info)
                        return E.db.WT.social.chatBar.channels.community[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.WT.social.chatBar.channels.community[info[#info]] = value
                        CB:UpdateBar()
                    end,
                    args = {
                        enable = {
                            order = 1,
                            type = "toggle",
                            name = L["Enable"]
                        },
                        color = {
                            order = 2,
                            type = "color",
                            name = L["Color"],
                            hasAlpha = true,
                            get = function(info)
                                local colordb = E.db.WT.social.chatBar.channels.community.color
                                local default = P.social.chatBar.channels.community.color
                                return colordb.r, colordb.g, colordb.b, colordb.a, default.r, default.g, default.b, default.a
                            end,
                            set = function(info, r, g, b, a)
                                E.db.WT.social.chatBar.channels.community.color = {
                                    r = r,
                                    g = g,
                                    b = b,
                                    a = a
                                }
                                CB:UpdateBar()
                            end
                        },
                        abbr = {
                            order = 3,
                            type = "input",
                            hidden = function()
                                return not (E.db.WT.social.chatBar.style == "TEXT")
                            end,
                            name = L["Abbreviation"]
                        },
                        name = {
                            order = 4,
                            type = "input",
                            name = L["Channel Name"]
                        },
                        communityDesc = {
                            order = 5,
                            type = "description",
                            width = "full",
                            name = L["Please use Blizzard Communities UI add the channel to your main chat frame first."]
                        }
                    }
                },
                emote = {
                    order = 102,
                    type = "group",
                    name = "Wind" .. L["Emote"],
                    get = function(info)
                        return E.db.WT.social.chatBar.channels.emote[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.WT.social.chatBar.channels.emote[info[#info]] = value
                        CB:UpdateBar()
                    end,
                    args = {
                        enable = {
                            order = 1,
                            type = "toggle",
                            name = L["Enable"]
                        },
                        color = {
                            order = 2,
                            type = "color",
                            name = L["Color"],
                            hasAlpha = true,
                            get = function(info)
                                local colordb = E.db.WT.social.chatBar.channels.emote.color
                                local default = P.social.chatBar.channels.emote.color
                                return colordb.r, colordb.g, colordb.b, colordb.a, default.r, default.g, default.b, default.a
                            end,
                            set = function(info, r, g, b, a)
                                E.db.WT.social.chatBar.channels.emote.color = {
                                    r = r,
                                    g = g,
                                    b = b,
                                    a = a
                                }
                                CB:UpdateBar()
                            end
                        },
                        icon = {
                            order = 3,
                            type = "toggle",
                            name = L["Use Icon"],
                            desc = L["Use a icon rather than text"],
                            hidden = function()
                                return not (E.db.WT.social.chatBar.style == "TEXT")
                            end
                        },
                        abbr = {
                            order = 4,
                            type = "input",
                            hidden = function()
                                return not (E.db.WT.social.chatBar.style == "TEXT")
                            end,
                            name = L["Abbreviation"]
                        }
                    }
                },
                roll = {
                    order = 103,
                    type = "group",
                    name = L["Roll"],
                    get = function(info)
                        return E.db.WT.social.chatBar.channels.roll[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.WT.social.chatBar.channels.roll[info[#info]] = value
                        CB:UpdateBar()
                    end,
                    args = {
                        enable = {
                            order = 1,
                            type = "toggle",
                            name = L["Enable"]
                        },
                        color = {
                            order = 2,
                            type = "color",
                            name = L["Color"],
                            hasAlpha = true,
                            get = function(info)
                                local colordb = E.db.WT.social.chatBar.channels.roll.color
                                local default = P.social.chatBar.channels.roll.color
                                return colordb.r, colordb.g, colordb.b, colordb.a, default.r, default.g, default.b, default.a
                            end,
                            set = function(info, r, g, b, a)
                                E.db.WT.social.chatBar.channels.roll.color = {
                                    r = r,
                                    g = g,
                                    b = b,
                                    a = a
                                }
                                CB:UpdateBar()
                            end
                        },
                        icon = {
                            order = 3,
                            type = "toggle",
                            name = L["Use Icon"],
                            desc = L["Use a icon rather than text"],
                            hidden = function()
                                return not (E.db.WT.social.chatBar.style == "TEXT")
                            end
                        },
                        abbr = {
                            order = 4,
                            type = "input",
                            hidden = function()
                                return not (E.db.WT.social.chatBar.style == "TEXT")
                            end,
                            name = L["Abbreviation"]
                        }
                    }
                }
            }
        }
    }
}

do -- 普通频道
    local channels = {"SAY", "YELL", "EMOTE", "PARTY", "INSTANCE", "RAID", "RAID_WARNING", "GUILD", "OFFICER"}
    local locales = {
        SAY = L["Say"],
        YELL = L["Yell"],
        EMOTE = L["Emote"],
        PARTY = L["Party"],
        INSTANCE = L["Instance"],
        RAID = L["Raid"],
        RAID_WARNING = L["Raid Warning"],
        GUILD = L["Guild"],
        OFFICER = L["Officer"]
    }
    for index, name in ipairs(channels) do
        options.chatBar.args.channels.args[name] = {
            order = index,
            type = "group",
            name = locales[name],
            get = function(info)
                return E.db.WT.social.chatBar.channels[name][info[#info]]
            end,
            set = function(info, value)
                E.db.WT.social.chatBar.channels[name][info[#info]] = value
                CB:UpdateBar()
            end,
            args = {
                enable = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable"]
                },
                color = {
                    order = 2,
                    type = "color",
                    name = L["Color"],
                    hasAlpha = true,
                    get = function(info)
                        local colordb = E.db.WT.social.chatBar.channels[name].color
                        local default = P.social.chatBar.channels[name].color
                        return colordb.r, colordb.g, colordb.b, colordb.a, default.r, default.g, default.b, default.a
                    end,
                    set = function(info, r, g, b, a)
                        E.db.WT.social.chatBar.channels[name].color = {
                            r = r,
                            g = g,
                            b = b,
                            a = a
                        }
                        CB:UpdateBar()
                    end
                },
                abbr = {
                    order = 3,
                    type = "input",
                    hidden = function()
                        return not (E.db.WT.social.chatBar.style == "TEXT")
                    end,
                    name = L["Abbreviation"]
                }
            }
        }
    end
end

options.chatLink = {
    order = 2,
    type = "group",
    name = L["Chat Link"],
    get = function(info)
        return E.db.WT.social.chatLink[info[#info]]
    end,
    set = function(info, value)
        E.db.WT.social.chatLink[info[#info]] = value
        CL:ProfileUpdate()
    end,
    args = {
        desc = {
            order = 0,
            type = "group",
            inline = true,
            name = L["Description"],
            args = {
                feature = {
                    order = 1,
                    type = "description",
                    name = L[
                        "Add extra information on the link, so that you can get basic information but do not need to click."
                    ],
                    fontSize = "medium"
                }
            }
        },
        enable = {
            order = 1,
            type = "toggle",
            name = L["Enable"]
        },
        general = {
            order = 2,
            type = "group",
            inline = true,
            name = L["Additional Information"],
            disabled = function()
                return not E.db.WT.social.chatLink.enable
            end,
            args = {
                level = {
                    order = 1,
                    type = "toggle",
                    name = L["Level"],
                    desc = L["Display the level of the item on the item link."],
                    width = 1.5
                },
                numbericalQualityTier = {
                    order = 2,
                    type = "toggle",
                    name = L["Numberical Quality Tier"],
                    desc = L["Use numberical quality tier rather the icon on the item link."],
                    width = 1.5
                },
                translateItem = {
                    order = 3,
                    type = "toggle",
                    name = L["Translate Item"],
                    desc = L["Translate the name in item links into your language."],
                    width = 1.5
                },
                icon = {
                    order = 4,
                    type = "toggle",
                    name = L["Icon"],
                    width = 1.5
                },
                armorCategory = {
                    order = 5,
                    type = "toggle",
                    name = L["Armor Category"],
                    width = 1.5
                },
                weaponCategory = {
                    order = 6,
                    type = "toggle",
                    name = L["Weapon Category"],
                    width = 1.5
                }
            }
        }
    }
}

local SampleStrings = {}
do
    local icons = ""
    icons = icons .. E:TextureString(W.Media.Icons.ffxivTank, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.ffxivHealer, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.ffxivDPS, ":16:16")
    SampleStrings.ffxiv = icons

    icons = ""
    icons = icons .. E:TextureString(W.Media.Icons.philModTank, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.philModHealer, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.philModDPS, ":16:16")
    SampleStrings.philMod = icons

    icons = ""
    icons = icons .. E:TextureString(W.Media.Icons.hexagonTank, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.hexagonHealer, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.hexagonDPS, ":16:16")
    SampleStrings.hexagon = icons

    icons = ""
    icons = icons .. CT.cache.blizzardRoleIcons.Tank .. " "
    icons = icons .. CT.cache.blizzardRoleIcons.Healer .. " "
    icons = icons .. CT.cache.blizzardRoleIcons.DPS
    SampleStrings.blizzard = icons

    icons = ""
    icons = icons .. E:TextureString(CT.cache.elvuiRoleIconsPath.Tank, ":16:16:0:0:64:64:2:56:2:56") .. " "
    icons = icons .. E:TextureString(CT.cache.elvuiRoleIconsPath.Healer, ":16:16:0:0:64:64:2:56:2:56") .. " "
    icons = icons .. E:TextureString(CT.cache.elvuiRoleIconsPath.DPS, ":16:16")
    SampleStrings.elvui = icons

    icons = ""
    icons = icons .. E:TextureString(W.Media.Icons.sunUITank, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.sunUIHealer, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.sunUIDPS, ":16:16")
    SampleStrings.sunui = icons

    icons = ""
    icons = icons .. E:TextureString(W.Media.Icons.lynUITank, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.lynUIHealer, ":16:16") .. " "
    icons = icons .. E:TextureString(W.Media.Icons.lynUIDPS, ":16:16")
    SampleStrings.lynui = icons
end

do
    local newRuleName, newRuleAbbr, selectedRule

    options.chatText = {
        order = 3,
        type = "group",
        name = L["Chat Text"],
        get = function(info)
            return E.db.WT.social.chatText[info[#info]]
        end,
        set = function(info, value)
            E.db.WT.social.chatText[info[#info]] = value
            CT:ProfileUpdate()
        end,
        args = {
            desc = {
                order = 0,
                type = "group",
                inline = true,
                name = L["Description"],
                args = {
                    feature = {
                        order = 1,
                        type = "description",
                        name = L["Modify the chat text style."],
                        fontSize = "medium"
                    }
                }
            },
            enable = {
                order = 1,
                type = "toggle",
                name = L["Enable"],
                width = "full"
            },
            general = {
                order = 2,
                type = "group",
                inline = true,
                name = L["General"],
                disabled = function()
                    return not E.db.WT.social.chatText.enable
                end,
                get = function(info)
                    return E.db.WT.social.chatText[info[#info]]
                end,
                set = function(info, value)
                    E.db.WT.social.chatText[info[#info]] = value
                    CT:ProfileUpdate()
                end,
                args = {
                    removeBrackets = {
                        order = 1,
                        type = "toggle",
                        name = L["Remove Brackets"]
                    },
                    classIcon = {
                        order = 2,
                        type = "toggle",
                        name = L["Class Icon"],
                        desc = L["Show the class icon before the player name."] ..
                            "\n" .. L["This feature only works for message that sent by this module."]
                    },
                    classIconStyle = {
                        order = 3,
                        type = "select",
                        name = L["Class Icon Style"],
                        desc = L["Select the style of class icon."],
                        values = function()
                            local v = {}
                            for _, style in pairs(F.GetClassIconStyleList()) do
                                local monkSample = F.GetClassIconStringWithStyle("MONK", style, 16, 16)
                                local druidSample = F.GetClassIconStringWithStyle("DRUID", style, 16, 16)
                                local paladinSample = F.GetClassIconStringWithStyle("PALADIN", style, 16, 16)

                                local sample = monkSample .. " " .. druidSample .. " " .. paladinSample
                                v[style] = sample
                            end
                            return v
                        end
                    },
                    factionIcon = {
                        order = 4,
                        type = "toggle",
                        name = L["Faction Icon"],
                        desc = L["Show the faction icon before the player name."] ..
                            "\n" .. L["This feature only works for message that sent by this module."]
                    }
                }
            },
            enhancements = {
                order = 3,
                type = "group",
                inline = true,
                name = L["Enhancements"],
                disabled = function()
                    return not E.db.WT.social.chatText.enable
                end,
                get = function(info)
                    return E.db.WT.social.chatText[info[#info]]
                end,
                set = function(info, value)
                    E.db.WT.social.chatText[info[#info]] = value
                    CT:ProfileUpdate()
                end,
                args = {
                    guildMemberStatus = {
                        order = 1,
                        type = "toggle",
                        name = L["Guild Member Status"],
                        desc = L["Enhance the message when a guild member comes online or goes offline."],
                        width = 1.2
                    },
                    guildMemberStatusInviteLink = {
                        order = 2,
                        type = "toggle",
                        name = L["Online Invite Link"],
                        desc = L["Add an invite link to the guild member online message."],
                        width = 1.2,
                        disabled = function()
                            return not E.db.WT.social.chatText.enable or not E.db.WT.social.chatText.guildMemberStatus
                        end
                    },
                    mergeAchievement = {
                        order = 3,
                        type = "toggle",
                        name = L["Merge Achievement"],
                        desc = L["Merge the achievement message into one line."],
                        width = 1.2
                    },
                    bnetFriendOnline = {
                        order = 4,
                        type = "toggle",
                        name = L["BNet Friend Online"],
                        desc = L["Show a message when a Battle.net friend's wow character comes online."] ..
                            "\n" ..
                                L[
                                    "The message will only be shown in the chat frame (or chat tab) with Blizzard service alert channel on."
                                ],
                        width = 1.2
                    },
                    bnetFriendOffline = {
                        order = 5,
                        type = "toggle",
                        name = L["BNet Friend Offline"],
                        desc = L["Show a message when a Battle.net friend's wow character goes offline."] ..
                            "\n" ..
                                L[
                                    "The message will only be shown in the chat frame (or chat tab) with Blizzard service alert channel on."
                                ],
                        width = 1.2
                    }
                }
            },
            characterName = {
                order = 4,
                type = "group",
                inline = true,
                name = L["Character Name"],
                disabled = function()
                    return not E.db.WT.social.chatText.enable
                end,
                get = function(info)
                    return E.db.WT.social.chatText[info[#info]]
                end,
                set = function(info, value)
                    E.db.WT.social.chatText[info[#info]] = value
                    CT:ProfileUpdate()
                end,
                args = {
                    removeRealm = {
                        order = 1,
                        type = "toggle",
                        name = L["Remove Realm"],
                        disabled = function()
                            return not E.db.WT.social.chatText.enable
                        end
                    },
                    roleIconStyle = {
                        order = 2,
                        type = "select",
                        name = L["Role Icon Style"],
                        desc = L["Change the icons that indicate the role."],
                        values = {
                            HEXAGON = SampleStrings.hexagon,
                            PHILMOD = SampleStrings.philMod,
                            FFXIV = SampleStrings.ffxiv,
                            SUNUI = SampleStrings.sunui,
                            LYNUI = SampleStrings.lynui,
                            BLIZZARD = SampleStrings.blizzard,
                            DEFAULT = SampleStrings.elvui
                        }
                    },
                    roleIconSize = {
                        order = 3,
                        type = "range",
                        name = L["Role Icon Size"],
                        min = 5,
                        max = 25,
                        step = 1
                    }
                }
            },
            channelAbbreviation = {
                order = 5,
                type = "group",
                inline = true,
                name = L["Abbreviation Customization"],
                disabled = function()
                    return not E.db.WT.social.chatText.enable
                end,
                args = {
                    abbreviation = {
                        order = 1,
                        type = "select",
                        name = L["Channel Abbreviation"],
                        desc = L["Modify the style of abbreviation of channels."],
                        disabled = function()
                            return not E.db.WT.social.chatText.enable
                        end,
                        get = function(info)
                            return E.db.WT.social.chatText[info[#info]]
                        end,
                        set = function(info, value)
                            E.db.WT.social.chatText[info[#info]] = value
                            CT:ProfileUpdate()
                        end,
                        values = {
                            NONE = L["None"],
                            SHORT = L["Short"],
                            DEFAULT = L["Default"]
                        }
                    },
                    newRule = {
                        order = 2,
                        type = "group",
                        inline = true,
                        name = L["New Channel Abbreviation Rule"],
                        args = {
                            channelName = {
                                order = 1,
                                type = "input",
                                name = L["Channel Name"],
                                get = function()
                                    return newRuleName
                                end,
                                set = function(_, value)
                                    newRuleName = value
                                end
                            },
                            abbrName = {
                                order = 2,
                                type = "input",
                                name = L["Abbreviation"],
                                get = function()
                                    return newRuleAbbr
                                end,
                                set = function(_, value)
                                    newRuleAbbr = value
                                end
                            },
                            addButton = {
                                order = 3,
                                type = "execute",
                                name = L["Add / Update"],
                                desc = L["Add or update the rule with custom abbreviation."],
                                func = function()
                                    if newRuleName and newRuleAbbr then
                                        E.db.WT.social.chatText.customAbbreviation[newRuleName] = newRuleAbbr
                                        newRuleAbbr = nil
                                        newRuleName = nil
                                    else
                                        print(L["Please set the channel and abbreviation first."])
                                    end
                                end
                            }
                        }
                    },
                    deleteRule = {
                        order = 3,
                        type = "group",
                        inline = true,
                        name = L["Delete Channel Abbreviation Rule"],
                        args = {
                            list = {
                                order = 1,
                                type = "select",
                                name = L["List"],
                                get = function()
                                    return selectedRule
                                end,
                                set = function(_, value)
                                    selectedRule = value
                                end,
                                values = function()
                                    return E.db.WT.social.chatText.customAbbreviation
                                end,
                                width = 2
                            },
                            deleteButton = {
                                order = 3,
                                type = "execute",
                                name = L["Remove"],
                                func = function()
                                    if selectedRule then
                                        E.db.WT.social.chatText.customAbbreviation[selectedRule] = nil
                                    end
                                end
                            }
                        }
                    }
                }
            }
        }
    }
end

options.contextMenu = {
    order = 4,
    type = "group",
    name = L["Context Menu"],
    get = function(info)
        return E.db.WT.social.contextMenu[info[#info]]
    end,
    set = function(info, value)
        E.db.WT.social.contextMenu[info[#info]] = value
        CM:ProfileUpdate()
    end,
    args = {
        desc = {
            order = 0,
            type = "group",
            inline = true,
            name = L["Description"],
            args = {
                feature = {
                    order = 1,
                    type = "description",
                    name = L["Add features to pop-up menu without taint."],
                    fontSize = "medium"
                }
            }
        },
        enable = {
            order = 1,
            type = "toggle",
            name = L["Enable"],
            width = "full"
        },
        normalConfig = {
            order = 2,
            type = "group",
            inline = true,
            name = L["General"],
            disabled = function()
                return not E.db.WT.social.contextMenu.enable
            end,
            args = {
                addFriend = {
                    order = 1,
                    type = "toggle",
                    name = L["Add Friends"]
                },
                guildInvite = {
                    order = 2,
                    type = "toggle",
                    name = L["Guild Invite"]
                },
                reportStats = {
                    order = 3,
                    type = "toggle",
                    name = L["Report Stats"]
                },
                who = {
                    order = 4,
                    type = "toggle",
                    name = L["Who"]
                }
            }
        },
        armoryConfig = {
            order = 3,
            type = "group",
            inline = true,
            name = L["Armory"],
            disabled = function()
                return not E.db.WT.social.contextMenu.enable
            end,
            args = {
                armory = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable"],
                    get = function(info)
                        return E.db.WT.social.contextMenu.armory
                    end,
                    set = function(info, value)
                        E.db.WT.social.contextMenu.armory = value
                        CM:ProfileUpdate()
                    end
                },
                setArea = {
                    order = 2,
                    type = "select",
                    name = L["Set Area"],
                    desc = L[
                        "If the game language is different from the primary language in this server, you need to specify which area you play on."
                    ],
                    get = function()
                        local list = E.db.WT.social.contextMenu.armoryOverride
                        if list[E.myrealm] then
                            return list[E.myrealm]
                        else
                            return "NONE"
                        end
                    end,
                    set = function(_, value)
                        local list = E.db.WT.social.contextMenu.armoryOverride
                        if value == "NONE" then
                            list[E.myrealm] = nil
                        else
                            list[E.myrealm] = value
                        end
                    end,
                    values = {
                        NONE = L["Auto-detect"],
                        tw = L["Taiwan"],
                        kr = L["Korea"],
                        us = L["Americas & Oceania"],
                        eu = L["Europe"]
                    }
                },
                list = {
                    order = 3,
                    type = "select",
                    name = L["Server List"],
                    get = function()
                        return customListSelected
                    end,
                    set = function(_, value)
                        customListSelected = value
                    end,
                    values = function()
                        local list = E.db.WT.social.contextMenu.armoryOverride

                        local displayName = {
                            tw = L["Taiwan"],
                            kr = L["Korea"],
                            us = L["Americas & Oceania"],
                            eu = L["Europe"]
                        }

                        local result = {}
                        for key, value in pairs(list) do
                            result[key] = key .. " > " .. displayName[value]
                        end

                        return result
                    end,
                    width = 2
                },
                deleteButton = {
                    order = 4,
                    type = "execute",
                    name = L["Delete"],
                    desc = L["Delete the selected NPC."],
                    func = function()
                        if customListSelected then
                            local list = E.db.WT.social.contextMenu.armoryOverride
                            if list[customListSelected] then
                                list[customListSelected] = nil
                            end
                        end
                    end
                }
            }
        }
    }
}

options.emote = {
    order = 5,
    type = "group",
    name = L["Emote"],
    get = function(info)
        return E.db.WT.social.emote[info[#info]]
    end,
    set = function(info, value)
        E.db.WT.social.emote[info[#info]] = value
        WE:ProfileUpdate()
    end,
    args = {
        desc = {
            order = 0,
            type = "group",
            inline = true,
            name = L["Description"],
            args = {
                feature = {
                    order = 1,
                    type = "description",
                    name = L["Parse emote expresstion from other players."],
                    fontSize = "medium"
                }
            }
        },
        enable = {
            order = 1,
            type = "toggle",
            name = L["Enable"],
            width = "full"
        },
        size = {
            name = L["Emote Icon Size"],
            order = 2,
            type = "range",
            disabled = function()
                return not E.db.WT.social.emote.enable
            end,
            min = 5,
            max = 35,
            step = 1
        },
        panel = {
            order = 3,
            type = "toggle",
            name = L["Use Emote Panel"],
            desc = L["Press { to active the emote select window."],
            disabled = function()
                return not E.db.WT.social.emote.enable
            end
        },
        chatBubbles = {
            order = 4,
            type = "toggle",
            name = L["Chat Bubbles"],
            disabled = function()
                return not E.db.WT.social.emote.enable
            end
        }
    }
}

options.friendList = {
    order = 6,
    type = "group",
    name = L["Friend List"],
    get = function(info)
        return E.db.WT.social.friendList[info[#info]]
    end,
    set = function(info, value)
        E.db.WT.social.friendList[info[#info]] = value
        FriendsFrame_Update()
    end,
    args = {
        desc = {
            order = 0,
            type = "group",
            inline = true,
            name = L["Description"],
            args = {
                feature1 = {
                    order = 1,
                    type = "description",
                    name = L["Add additional information to the friend frame."],
                    fontSize = "medium"
                },
                feature2 = {
                    order = 2,
                    type = "description",
                    name = L["Modify the texture of status and make name colorful."],
                    fontSize = "medium"
                }
            }
        },
        enable = {
            order = 1,
            type = "toggle",
            name = L["Enable"],
            set = function(info, value)
                E.db.WT.social.friendList[info[#info]] = value
                FL:ProfileUpdate()
            end
        },
        textures = {
            order = 2,
            type = "group",
            inline = true,
            name = L["Enhanced Texture"],
            get = function(info)
                return E.db.WT.social.friendList.textures[info[#info]]
            end,
            set = function(info, value)
                E.db.WT.social.friendList.textures[info[#info]] = value
                FriendsFrame_Update()
            end,
            disabled = function()
                return not E.db.WT.social.friendList.enable
            end,
            args = {
                client = {
                    name = L["Game Icons"],
                    order = 1,
                    type = "select",
                    values = {
                        blizzard = L["Blizzard"],
                        modern = L["Modern"]
                    }
                },
                status = {
                    name = L["Status Icon Pack"],
                    order = 2,
                    type = "select",
                    values = {
                        default = L["Default"],
                        d3 = L["Diablo 3"],
                        square = L["Square"]
                    }
                },
                factionIcon = {
                    order = 3,
                    type = "toggle",
                    name = L["Faction Icon"],
                    desc = L["Use faction icon instead of WoW icon."]
                }
            }
        },
        name = {
            order = 3,
            type = "group",
            inline = true,
            name = L["Name"],
            disabled = function()
                return not E.db.WT.social.friendList.enable
            end,
            args = {
                level = {
                    order = 1,
                    type = "toggle",
                    name = L["Level"]
                },
                hideMaxLevel = {
                    order = 2,
                    type = "toggle",
                    name = L["Hide Max Level"],
                    disabled = function()
                        return not E.db.WT.social.friendList.level
                    end
                },
                useNoteAsName = {
                    order = 3,
                    type = "toggle",
                    name = L["Use Note As Name"],
                    desc = L["Replace the Real ID or the character name of friends with your notes."]
                },
                useClientColor = {
                    order = 4,
                    type = "toggle",
                    name = L["Use Client Color"],
                    desc = L["Change the color of the name to the in-playing game style."]
                },
                useClassColor = {
                    order = 5,
                    type = "toggle",
                    name = L["Use Class Color"]
                },
                font = {
                    order = 6,
                    type = "group",
                    name = L["Font Setting"],
                    get = function(info)
                        return E.db.WT.social.friendList.nameFont[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.WT.social.friendList.nameFont[info[#info]] = value
                        FriendsFrame_Update()
                    end,
                    args = {
                        name = {
                            order = 1,
                            type = "select",
                            dialogControl = "LSM30_Font",
                            name = L["Font"],
                            values = LSM:HashTable("font")
                        },
                        style = {
                            order = 2,
                            type = "select",
                            name = L["Outline"],
                            values = {
                                NONE = L["None"],
                                OUTLINE = L["OUTLINE"],
                                MONOCHROME = L["MONOCHROME"],
                                MONOCHROMEOUTLINE = L["MONOCROMEOUTLINE"],
                                THICKOUTLINE = L["THICKOUTLINE"]
                            }
                        },
                        size = {
                            order = 3,
                            name = L["Size"],
                            type = "range",
                            min = 5,
                            max = 60,
                            step = 1
                        }
                    }
                }
            }
        },
        info = {
            order = 4,
            type = "group",
            inline = true,
            name = L["Information"],
            disabled = function()
                return not E.db.WT.social.friendList.enable
            end,
            args = {
                font = {
                    order = 2,
                    type = "group",
                    name = L["Font Setting"],
                    get = function(info)
                        return E.db.WT.social.friendList.infoFont[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.WT.social.friendList.infoFont[info[#info]] = value
                        FriendsFrame_Update()
                    end,
                    args = {
                        name = {
                            order = 1,
                            type = "select",
                            dialogControl = "LSM30_Font",
                            name = L["Font"],
                            values = LSM:HashTable("font")
                        },
                        style = {
                            order = 2,
                            type = "select",
                            name = L["Outline"],
                            values = {
                                NONE = L["None"],
                                OUTLINE = L["OUTLINE"],
                                MONOCHROME = L["MONOCHROME"],
                                MONOCHROMEOUTLINE = L["MONOCROMEOUTLINE"],
                                THICKOUTLINE = L["THICKOUTLINE"]
                            }
                        },
                        size = {
                            order = 3,
                            name = L["Size"],
                            type = "range",
                            min = 5,
                            max = 60,
                            step = 1
                        },
                        areaColor = {
                            order = 4,
                            type = "color",
                            name = L["Color"],
                            hasAlpha = false,
                            get = function()
                                local colordb = E.db.WT.social.friendList.areaColor
                                local default = P.social.friendList.areaColor
                                return colordb.r, colordb.g, colordb.b, nil, default.r, default.g, default.b
                            end,
                            set = function(_, r, g, b)
                                E.db.WT.social.friendList.areaColor = {r = r, g = g, b = b}
                                FriendsFrame_Update()
                            end
                        }
                    }
                }
            }
        }
    }
}

options.smartTab = {
    order = 7,
    type = "group",
    name = L["Smart Tab"],
    get = function(info)
        return E.db.WT.social.smartTab[info[#info]]
    end,
    set = function(info, value)
        E.db.WT.social.smartTab[info[#info]] = value
        ST:ProfileUpdate()
    end,
    args = {
        desc = {
            order = 0,
            type = "group",
            inline = true,
            name = L["Description"],
            args = {
                feature = {
                    order = 1,
                    type = "description",
                    name = L["This module will change the channel when Tab has been pressed."],
                    fontSize = "medium"
                }
            }
        },
        enable = {
            order = 1,
            type = "toggle",
            name = L["Enable"]
        },
        channelSetting = {
            order = 2,
            type = "group",
            inline = true,
            name = L["Channel"],
            get = function(info)
                return E.db.WT.social.smartTab[info[#info]]
            end,
            set = function(info, value)
                E.db.WT.social.smartTab[info[#info]] = value
                ST:ProfileUpdate()
            end,
            disabled = function()
                return not E.db.WT.social.smartTab.enable
            end,
            args = {
                yell = {
                    order = 1,
                    type = "toggle",
                    name = L["Yell"]
                },
                battleground = {
                    order = 2,
                    type = "toggle",
                    name = L["Battleground"]
                },
                raidWarning = {
                    order = 3,
                    type = "toggle",
                    name = L["Raid Warning"]
                },
                officer = {
                    order = 4,
                    type = "toggle",
                    name = L["Officer"]
                }
            }
        },
        whisperSetting = {
            order = 3,
            type = "group",
            inline = true,
            name = L["Whisper"],
            disabled = function()
                return not E.db.WT.social.smartTab.enable
            end,
            args = {
                whisperCycle = {
                    order = 1,
                    type = "toggle",
                    name = L["Whisper Cycle"]
                },
                historyLimit = {
                    order = 2,
                    type = "range",
                    name = L["Expiration time (min)"],
                    desc = L[
                        "This module will record whispers for switching.\n You can set the expiration time here for making a shortlist of recent targets."
                    ],
                    min = 1,
                    max = 2400,
                    step = 1
                }
            }
        }
    }
}
