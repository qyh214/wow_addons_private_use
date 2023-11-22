local L = LibStub("AceLocale-3.0"):GetLocale("Multishot")

local GetFonts = function()
    local fonts = {}
    fonts[STANDARD_TEXT_FONT] = "Standard"
    fonts[(NumberFontNormal:GetFont())] = "NumberFontNormal"
    fonts[(NumberFontNormalHuge:GetFont())] = "NumberFontNormalHuge"
    fonts[(ItemTextFontNormal:GetFont())] = "ItemTextFontNormal"

    local LSM3 = LSM3 or LibStub("LibSharedMedia-3.0")
    if LSM3 then
        for index, fontName in pairs(LSM3:List("font")) do
            fonts[LSM3:Fetch("font", fontName)] = fontName
        end
    end
    return fonts
end

local GetFontSizes = function()
    local sizes = {}
    for k, v in ipairs(CHAT_FONT_HEIGHTS) do
        sizes[v] = v
    end
    return sizes
end

-- categorized by instance type  Nukme@20220505
local diffcap = 300
function GetDifficulties(_T)
    local diffs = {}
    for i = 1, diffcap do
        local name, type = GetDifficultyInfo(i)
        if name and type == _T then
            diffs[i] = "[" .. i .. "] " .. name
        end
    end
    return diffs
end

function GetDiffDefaults()
    local pre_selected = {
        [8] = true,  -- Mythic Keystone
        [1] = true,  -- Normal Dungeon
        [2] = true,  -- Heroic Dungeon
        [23] = true, -- Mythic Dungeon
        [24] = true, -- Timewalking Dungeon
        [14] = true, -- Normal Raid
        [15] = true, -- Heroic Raid
        [16] = true, -- Mythic Raid
        [33] = true, -- Timewaling Raid
    }
    local diff_defaults = {}
    for i = 1, diffcap do
        local name = GetDifficultyInfo(i)
        if name then
            if pre_selected[i] == true then
                diff_defaults[i] = true
            else
                diff_defaults[i] = false
            end
        end
    end
    return diff_defaults
end

--[[ **********************************************************************
        Configuration Default Values
     **********************************************************************]]

local defaults = {
    global = {
        levelup = true,
        legendaryloot = true,
        achievement = true,
        groupstatus = {
            ["1solo"] = true,
            ["2party"] = true,
            ["3raid"] = true
        },
        repchange = true,
        delay1 = 1.2,
        delay2 = 2,
        debug = false,
        trade = true,
        firstkill = false,
        difficulty = GetDiffDefaults(),
        close = false,
        uihide = false,
        played = false,
        charpane = false,
        -- guildlevelup = true,
        guildachievement = true,
        challengemode = true,
        mythicpluscompletion = true,
        encounter_success = true,
        battleground = true,
        arena = true,
        delay3 = 20,
        timeLineEnable = false,
        -- garissonbuild = true,
        watermark = false,
        watermarkformat = "$n($l) $c $b$z - $d$b$r",
        watermarkanchor = "TOP",
        watermarkfont = STANDARD_TEXT_FONT,
        watermarkfontsize = CHAT_FONT_HEIGHTS[3]
    }
}

local defaults_history = {
    char = {
        history = {},
    }
}

--[[ **********************************************************************
        Configuration Options Table
     **********************************************************************]]

local introOptions = {
    type = "group",
    name = "Multishot",
    args = {
        intro = {
            order = 0,
            type = "description",
            name = L["Auto-Screenshot Management Addon\n\n"]
        },
        version = {
            order = 1,
            type = "description",
            name = string.format("%s\n    %s\n\n", "|cFFFFD700" .. L["Version"] .. "|r",
                C_AddOns.GetAddOnMetadata("Multishot", "Version"))
        },
        author = {
            order = 2,
            type = "description",
            name = string.format("%s\n    %s\n\n", "|cFFFFD700" .. L["Author"] .. "|r", "dlui&dridzt (original), Nukme")
        },
        repo = {
            order = 3,
            type = "input",
            name = L["Github Repo"],
            width = "double",
            get = function()
                return C_AddOns.GetAddOnMetadata("Multishot", "X-Repository")
            end
        },
        feedback = {
            order = 4,
            type = "input",
            name = L["NGA Feedback"],
            width = "double",
            get = function()
                return C_AddOns.GetAddOnMetadata("Multishot", "X-NGA_Feedback")
            end
        }
    }
}

local generalOptions = {
    type = "group",
    name = L["General Settings"],
    args = {
        --------------------------------------------------------------------------------
        header0 = {
            order = 0,
            type = "header",
            name = L["Screenshot Events"]
        },
        -- intro = {
        --     order = 0,
        --     type = "description",
        --     name = L["intro"] .. ":\n"
        -- },
        levelups = {
            order = 1,
            type = "toggle",
            name = L["levelups"],
            get = function()
                return Multishot.configDB.global.levelup
            end,
            set = function(_, v)
                Multishot.configDB.global.levelup = v
            end
        },
        --[[
    guildlevelups = {
      order = 2,
      type = "toggle",
      name = L["guildlevelups"],
      get = function() return Multishot.configDB.global.guildlevelup end,
      set = function(_,v) Multishot.configDB.global.guildlevelup = v end },
	  --]]
        achievements = {
            order = 3,
            type = "toggle",
            name = L["achievements"],
            get = function()
                return Multishot.configDB.global.achievement
            end,
            set = function(_, v)
                Multishot.configDB.global.achievement = v
            end
        },
        guildachievements = {
            order = 4,
            type = "toggle",
            name = L["guildachievements"],
            get = function()
                return Multishot.configDB.global.guildachievement
            end,
            set = function(_, v)
                Multishot.configDB.global.guildachievement = v
            end
        },
        challengemode = {
            order = 5,
            type = "toggle",
            name = L["challengemode"],
            get = function()
                return Multishot.configDB.global.challengemode
            end,
            set = function(_, v)
                Multishot.configDB.global.challengemode = v
            end
        },
        battleground = {
            order = 6,
            type = "toggle",
            name = L["battleground"],
            get = function()
                return Multishot.configDB.global.battleground
            end,
            set = function(_, v)
                Multishot.configDB.global.battleground = v
            end
        },
        arena = {
            order = 7,
            type = "toggle",
            name = L["arena"],
            get = function()
                return Multishot.configDB.global.arena
            end,
            set = function(_, v)
                Multishot.configDB.global.arena = v
            end
        },
        repchange = {
            order = 8,
            type = "toggle",
            name = L["repchange"],
            get = function()
                return Multishot.configDB.global.repchange
            end,
            set = function(_, v)
                Multishot.configDB.global.repchange = v
            end
        },
        trade = {
            order = 9,
            type = "toggle",
            name = L["trade"],
            get = function()
                return Multishot.configDB.global.trade
            end,
            set = function(_, v)
                Multishot.configDB.global.trade = v
            end
        },
        --[[
    garissonbuild = {
    	order = 10,
    	type = "toggle",
    	name = L["garissonbuild"],
    	get = function() return Multishot.configDB.global.garissonbuild end,
    	set = function(_,v) Multishot.configDB.global.garissonbuild = v end },
	--]]
        legendaryloot = {
            order = 11,
            type = "toggle",
            name = L["legendaryloot"],
            get = function()
                return Multishot.configDB.global.legendaryloot
            end,
            set = function(_, v)
                Multishot.configDB.global.legendaryloot = v
            end
        },
        mythicpluscompletion = {
            order = 12,
            type = "toggle",
            name = L["mythicpluscompletion"],
            get = function()
                return Multishot.configDB.global.mythicpluscompletion
            end,
            set = function(_, v)
                Multishot.configDB.global.mythicpluscompletion = v
            end
        },
        encounter_success = {
            order = 13,
            type = "toggle",
            name = L["Encounter Success"],
            get = function()
                return Multishot.configDB.global.encounter_success
            end,
            set = function(_, v)
                Multishot.configDB.global.encounter_success = v
            end
        },
        --------------------------------------------------------------------------------
        header2 = {
            order = 400,
            type = "header",
            name = L["timeline"]
        },
        timeline = {
            order = 401,
            type = "toggle",
            name = L["timeLineEnable"],
            width = "double",
            get = function()
                return Multishot.configDB.global.timeLineEnable
            end,
            set = function(_, v)
                Multishot.configDB.global.timeLineEnable = v
                Multishot:TimeLineConfig(v)
            end
        },
        delay3 = {
            order = 402,
            type = "range",
            name = L["delayTimeline"],
            min = 5,
            max = 60,
            step = 5,
            get = function()
                return Multishot.configDB.global.delay3
            end,
            set = function(_, v)
                Multishot.configDB.global.delay3 = v
            end
        },
        --------------------------------------------------------------------------------

        header3 = {
            order = 500,
            type = "header",
            name = L["delay"]
        },
        delay1 = {
            order = 501,
            type = "range",
            name = L["delayother"],
            min = .1,
            max = 10,
            step = .1,
            get = function()
                return Multishot.configDB.global.delay1
            end,
            set = function(_, v)
                Multishot.configDB.global.delay1 = v
            end
        },
        delay2 = {
            order = 502,
            type = "range",
            name = L["delaykill"],
            min = .1,
            max = 10,
            step = .1,
            get = function()
                return Multishot.configDB.global.delay2
            end,
            set = function(_, v)
                Multishot.configDB.global.delay2 = v
            end
        },
        --------------------------------------------------------------------------------

        header4 = {
            order = 600,
            type = "header",
            name = L["capture"]
        },
        format = {
            order = 601,
            type = "select",
            name = L["format"],
            values = {
                ["jpeg"] = L["jpeg"],
                ["png"] = L["png"],
                ["tga"] = L["tga"]
            },
            get = function()
                return GetCVar("screenshotFormat")
            end,
            set = function(_, v)
                SetCVar("screenshotFormat", v)
            end
        },
        quality = {
            order = 602,
            type = "range",
            name = L["quality"],
            min = 0,
            max = 10,
            step = 1,
            get = function()
                return tonumber(GetCVar("screenshotQuality"))
            end,
            set = function(_, v)
                SetCVar("screenshotQuality", v)
            end
        },
        close = {
            order = 603,
            type = "toggle",
            name = L["close"],
            get = function()
                return Multishot.configDB.global.close
            end,
            set = function(_, v)
                Multishot.configDB.global.close = v
            end
        },
        uihide = {
            order = 604,
            type = "toggle",
            name = L["uihide"],
            get = function()
                return Multishot.configDB.global.uihide
            end,
            set = function(_, v)
                Multishot.configDB.global.uihide = v
            end
        },
        played = {
            order = 605,
            type = "toggle",
            name = L["played"],
            get = function()
                return Multishot.configDB.global.played
            end,
            set = function(_, v)
                Multishot.configDB.global.played = v
            end
        },
        charpane = {
            order = 606,
            type = "toggle",
            name = L["charpane"],
            get = function()
                return Multishot.configDB.global.charpane
            end,
            set = function(_, v)
                Multishot.configDB.global.charpane = v
            end
        },
        watermark = {
            order = 607,
            type = "toggle",
            name = L["watermark"],
            get = function()
                return Multishot.configDB.global.watermark
            end,
            set = function(_, v)
                Multishot.configDB.global.watermark = v
            end
        },
        watermarkformat = {
            order = 608,
            type = "input",
            name = L["watermarkformat"],
            desc = L["set the format for watermark text"] .. "\n" .. L["watermarkformattext"], -- "\n$n = name\n$c = class\n$l = level\n$z = zone\n$r = realm\n$d = date\n$b = line change"
            usage = L["clear the text and press Enter to restore defaults."],
            get = function()
                return Multishot.configDB.global.watermarkformat
            end,
            set = function(_, v)
                print(tostring(v))
                if v == "" or not (v):find("[%w%p]+") or (v):find("\\n") then -- or (v):find("$[^nclzrdb]")
                    v = "$n($l) $c $b$z - $d$b$r"
                end
                Multishot.configDB.global.watermarkformat = v
            end
        },
        watermarkanchor = {
            order = 609,
            type = "select",
            name = L["watermarkanchor"],
            values = {
                ["TOP"] = L["TOP"],
                ["TOPLEFT"] = L["TOPLEFT"],
                ["TOPRIGHT"] = L["TOPRIGHT"],
                ["BOTTOMLEFT"] = L["BOTTOMLEFT"],
                ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"]
            }, -- add to localization
            get = function()
                return Multishot.configDB.global.watermarkanchor
            end,
            set = function(_, v)
                Multishot.configDB.global.watermarkanchor = v
            end
        },
        watermarkfont = {
            order = 610,
            type = "select",
            name = L["watermarkfont"],
            values = GetFonts,
            get = function()
                return Multishot.configDB.global.watermarkfont
            end,
            set = function(_, v)
                Multishot.configDB.global.watermarkfont = v
            end
        },
        watermarkfontsize = {
            order = 611,
            type = "select",
            name = L["watermarkfontsize"],
            values = GetFontSizes,
            get = function()
                return Multishot.configDB.global.watermarkfontsize
            end,
            set = function(_, v)
                Multishot.configDB.global.watermarkfontsize = v
            end
        },
        watermarktest = {
            order = 612,
            type = "execute",
            name = L["Test"],
            desc = L["watermarktest"],
            func = function()
                Multishot.test_watermark = not Multishot.test_watermark
                Multishot:RefreshWatermark(Multishot.test_watermark)
            end
        },
        --------------------------------------------------------------------------------
        header5 = {
            order = 700,
            type = "header",
            name = L["various"]
        },
        debug = {
            order = 701,
            type = "toggle",
            name = L["debug"],
            get = function()
                return Multishot.configDB.global.debug
            end,
            set = function(_, v)
                Multishot.configDB.global.debug = v
            end
        },
        --------------------------------------------------------------------------------
        header6 = {
            order = 800,
            type = "header",
            name = L["Reset Character Kill History"],
        },
        resethistory = {
            order = 801,
            type = "execute",
            name = L["Click to Reset"],
            func = function()
                Multishot.historyDB.char.history = {}
            end
        },
        --------------------------------------------------------------------------------
        header7 = {
            order = 900,
            type = "header",
            name = L["Reset All General Settings"],
        },
        reset = {
            order = 901,
            type = "execute",
            name = L["Click to Reset"],
            func = function()
                Multishot.configDB:ResetDB("Default")
                LibStub("AceConfigRegistry-3.0"):NotifyChange("Multishot")
            end
        }

    }
}

local encounterOptions = {
    name = L["Encounter Settings"],
    type = "group",
    args = {
        --------------------------------------------------------------------------------
        header1 = {
            order = 0,
            type = "header",
            name = L["bosskillshots"]
        },
        firstkills = {
            order = 0.1,
            type = "toggle",
            name = L["firstkills"],
            get = function()
                return Multishot.configDB.global.firstkill
            end,
            set = function(_, v)
                Multishot.configDB.global.firstkill = v
            end
        },
        --------------------------------------------------------------------------------
        groupstatus = {
            order = 0.2,
            type = "multiselect",
            name = L["groupstatus"],
            values = {
                ["1solo"] = L["bosskillssolo"],
                ["2party"] = L["bosskillsparty"],
                ["3raid"] = L["bosskillsraid"]
            },
            get = function(_, k)
                return Multishot.configDB.global.groupstatus[k]
            end,
            set = function(_, k, v)
                Multishot.configDB.global.groupstatus[k] = v
            end
        },
        --------------------------------------------------------------------------------
        header2 = {
            order = 0.8,
            type = "header",
            name = L["Difficulty Settings"]
        },
        url = {
            order = 0.9,
            name = L["DifficultyID reference webpage:"],
            type = "input",
            width = 2.5,
            get = function()
                return "https://warcraft.wiki.gg/wiki/DifficultyID"
            end
        },
        party = {
            order = 1,
            name = L["PARTY"],
            type = "multiselect",
            values = GetDifficulties("party"),
            get = function(_, k)
                return Multishot.configDB.global.difficulty[k]
            end,
            set = function(_, k, v)
                Multishot.configDB.global.difficulty[k] = v
            end
        },
        raid = {
            order = 2,
            name = L["RAID"],
            type = "multiselect",
            values = GetDifficulties("raid"),
            get = function(_, k)
                return Multishot.configDB.global.difficulty[k]
            end,
            set = function(_, k, v)
                Multishot.configDB.global.difficulty[k] = v
            end
        },
        scenario = {
            order = 3,
            name = L["SCENARIO"],
            type = "multiselect",
            values = GetDifficulties("scenario"),
            get = function(_, k)
                return Multishot.configDB.global.difficulty[k]
            end,
            set = function(_, k, v)
                Multishot.configDB.global.difficulty[k] = v
            end
        },
        pvp = {
            order = 4,
            name = L["PVP"],
            type = "multiselect",
            values = GetDifficulties("pvp"),
            get = function(_, k)
                return Multishot.configDB.global.difficulty[k]
            end,
            set = function(_, k, v)
                Multishot.configDB.global.difficulty[k] = v
            end
        },
        none = {
            order = 5,
            name = L["NONE"],
            type = "multiselect",
            values = GetDifficulties("none"),
            get = function(_, k)
                return Multishot.configDB.global.difficulty[k]
            end,
            set = function(_, k, v)
                Multishot.configDB.global.difficulty[k] = v
            end
        }
    }
}

function Multishot:TimeLineConfig(enable)
    if enable then
        Multishot.timeLineTimer = Multishot:ScheduleRepeatingTimer("TimeLineProgress", 5)
    else
        if Multishot.timeLineTimer then
            Multishot:CancelTimer(Multishot.timeLineTimer)
        end
    end
end

function Multishot:OnInitialize()
    -- Register Config Values
    self:RegisterConfigs()

    -- Register Option Menus
    self:RegisterMenus()

    -- Register Slash Command
    self:RegisterChatCommand("multishot", function()
        InterfaceOptionsFrame_OpenToCategory(Multishot.ConfigPanel)
    end)
end

function Multishot:RegisterConfigs()
    -- General Settings Defaults DBObj
    self.configDB = LibStub("AceDB-3.0"):New("MultishotConfigDB", defaults, true)

    -- Encounter History Defaults DBObj
    self.historyDB = LibStub("AceDB-3.0"):New("MultishotHistoryDB", defaults_history, true)
end

function Multishot:RegisterMenus()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Multishot", introOptions)
    self.ConfigPanel = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Multishot", "Multishot")

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Multishot General Settings", generalOptions)
    self.GeneralSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Multishot General Settings",
        L["General Settings"], "Multishot")

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Multishot Encounter Settings", encounterOptions)
    self.DifficultySettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Multishot Encounter Settings",
        L["Encounter Settings"], "Multishot")
end
