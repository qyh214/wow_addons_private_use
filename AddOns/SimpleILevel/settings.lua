--[[
ToDo:
    - 
]]

local L = LibStub("AceLocale-3.0"):GetLocale("SimpleILevel", true);

--[[
    MoP Colors:
        White 0, #FFFFFF, 255, 255, 255
        Yellow 333, #FFFF00, 255, 255, 0
        Green 463, #00FF00, 0, 255, 0
        Teal 516, #00FFFF, 0, 255, 255
        Blue H T15, #0066ff, 0, 102, 255 - Raw Blue was to dark
        Purple H T16, #FF00FF, 255, 0, 255
        Red H T17, #FF0000, 255, 0, 0
]]--
SIL_ColorIndex = {0,333,463,516,549,572,1000};
SIL_Colors = {
    -- White base color
    [0] =       {['r']=255,     ['g']=255,      ['b']=255,      ['rgb']='FFFFFF',   ['p']=0,},
    -- Yellow for Cata dungeon gear
    [333] =     {['r']=255,     ['g']=255,      ['b']=0,        ['rgb']='FFFF00',   ['p']=0,},
    -- Green for MoP dungeon gear
    [463] =     {['r']=0,       ['g']=255,      ['b']=0,        ['rgb']='00FF00',   ['p']=333,},
    -- Teal for Heroic T14
    [516] =     {['r']=0,       ['g']=255,      ['b']=255,      ['rgb']='00FFFF',   ['p']=463,},
    -- Blue for Heroic T15
    [549] =     {['r']=0,       ['g']=102,      ['b']=255,      ['rgb']='0066ff',   ['p']=516,},
    -- Purple for Heroic T16
    [572] =     {['r']=255,     ['g']=0,        ['b']=255,      ['rgb']='FF00FF',   ['p']=549,},
    -- Red for a max score
    [1000] =    {['r']=255,     ['g']=0,        ['b']=0,        ['rgb']='FF0000',   ['p']=572,},
};

-- Suported channel localization table
SIL_Channels = {
    SYSTEM = string.lower(CHAT_MSG_SYSTEM),
    GROUP = string.lower(GROUP),
    PARTY = string.lower(CHAT_MSG_PARTY),
    RAID = string.lower(CHAT_MSG_RAID),
    GUILD = string.lower(CHAT_MSG_GUILD),
    SAY = string.lower(CHAT_MSG_SAY),
    BATTLEGROUND = string.lower(CHAT_MSG_BATTLEGROUND),
    INSTANCE_CHAT = string.lower(INSTANCE_CHAT_MESSAGE),
    OFFICER = string.lower(CHAT_MSG_OFFICER),
}
SIL_GroupChannelString = '';
local i = 0;
for channel,name in pairs(SIL_Channels) do
    if i == 0 then
        SIL_GroupChannelString = name;
    else
        SIL_GroupChannelString = SIL_GroupChannelString..'/'..name;
    end
    i = i + 1;
end
L.group.options.groupDesc = format(L.group.options.groupDesc, SIL_GroupChannelString);

-- Options for AceOptions
SIL_Options = {
    name = L.core.options.name,
    desc = L.core.desc,
    type = "group",
    args = {
        general = {
            name = L.core.options.options,
            type = "group",
            inline = true,
            order = 1,
            args = {
                advanced = { -- Advanced Tooltip
                    name = L.core.options.ttAdvanced,
                    desc = L.core.options.ttAdvancedDesc,
                    type = "toggle",
                    set = function(i,v) SIL:SetAdvanced(v); end,
                    get = function(i) return SIL:GetAdvanced(); end,
                    order = 1,
                },
                combat = { -- Tooltip in Combat
                    name = L.core.options.ttCombat,
                    desc = L.core.options.ttCombatDesc,
                    type = "toggle",
                    get = function(i) return SIL:GetTTCombat(); end,
                    set = function(i,v) SIL:SetTTCombat(v);  end,
                    order = 2,
                },
                color = { -- Color Score
                    name = L.core.options.color,
                    desc = L.core.options.colorDesc,
                    type = "toggle",
                    get = function(i) return SIL:GetColorScore(); end,
                    set = function(i,v) SIL:SetColorScore(v);  end,
                    order = 3,
                },
                round = { -- Round Score
                    name = L.core.options.round,
                    desc = L.core.options.roundDesc,
                    type = "toggle",
                    get = function(i) return SIL:GetRoundScore(); end,
                    set = function(i,v) SIL:SetRoundScore(v);  end,
                    order = 3,
                },
                
                autoscan = { -- Autoscan Group Members
                    name = L.core.options.autoscan,
                    desc = L.core.options.autoscanDesc,
                    type = "toggle",
                    set = function(i,v) SIL:SetAutoscan(v); end,
                    get = function(i) return SIL:GetAutoscan(); end,
                    order = 5,
                },
                minimap = { -- Minimap Button
                    name = L.core.options.minimap,
                    desc = L.core.options.minimapDesc,
                    type = "toggle",
                    set = function(i,v) SIL:SetMinimap(v); end,
                    get = function(i) return SIL:GetMinimap(); end,
                    order = 6,
                },
                cinfo = { -- Paperdoll Information
                    name = L.core.options.paperdoll,
                    desc = L.core.options.paperdollDesc,
                    type = "toggle",
                    set = function(i,v) SIL:SetPaperdoll(v); end,
                    get = function(i) return SIL:GetPaperdoll(); end,
                    order = 7,
                },
                
                
                age = {
                    name = L.core.options.maxAge,
                    desc = L.core.options.maxAgeDesc,
                    type = "range",
                    min = 1,
                    softMax = 240,
                    step = 1,
                    get = function(i) return (SIL:GetAge() / 60); end,
                    set = function(i,v) v = tonumber(tonumber(v) * 60); SIL:SetAge(v); end,
                    order = 20,
                    width = "full",
                },
                
                autoPurge = {
                    name = L.core.options.purgeAuto,
                    desc = L.core.options.purgeAutoDesc,
                    type = "range",
                    min = 0,
                    softMax = 30,
                    step = 1,
                    get = function(i) return (SIL:GetPurge() / 24); end,
                    set = function(i,v) SIL:SetPurge(v * 24);  end,
                    order = 21,
                    width = "full",
                    cmdHidden = true,
                },
            },
        },
        
        ldbOpt = {
            name = L.core.options.ldb,
            type = "group",
            inline = true,
            order = 2,
            cmdHidden = true,
            args = {
                ldbText = {
                    name = L.core.options.ldbText,
                    desc = L.core.options.ldbTextDesc,
                    type = "toggle",
                    get = function(i) return SIL:GetLDB(); end,
                    set = function(i,v) SIL:SetLDB(v); end,
                    order = 1,
                },
                ldbLabel = {
                    name = L.core.options.ldbSource,
                    desc = L.core.options.ldbSourceDesc,
                    type = "toggle",
                    get = function(i) return SIL:GetLDBlabel(); end,
                    set = function(i,v) SIL:SetLDBlabel(v); end,
                    order = 2,
                },
                ldbRefresh = { -- Refreshrate of LDB
                    name = L.core.options.ldbRefresh,
                    desc = L.core.options.ldbRefreshDesc,
                    type = "range",
                    min = 1,
                    softMax = 300,
                    step = 1,
                    get = function(i) return SIL:GetLDBrefresh(); end,
                    set = function(i,v) SIL:SetLDBrefresh(v); end,
                    order = 20,
                    width = "full",
                },
            },
        },
        
        module = {
            name = L.core.options.modules,
            desc = L.core.options.modulesDesc,
            type = 'multiselect',
            values = function() return SIL:ModulesList(); end,
            get = function(s,m) return SIL:GetModule(m) end,
            set = function(s,m,v) return SIL:SetModule(m, v) end,
            order = 3,
        },
        
        purge = {
            name = L.core.options.purge,
            desc = L.core.options.purgeDesc,
            type = "execute",
            func = function(i) SIL:AutoPurge(false); end,
            confirm = true,
            order = 49,
        },
        clear = {
            name = L.core.options.clear,
            desc = L.core.options.clearDesc,
            type = "execute",
            func = function(i) SIL:SlashReset(); end,
            confirm = true,
            order = 50,
        },
        
        -- Console Only
        get = {
            name = L.core.options.get,
            desc = L.core.options.getDesc,
            type = "input",
            set = function(i,v) SIL:SlashGet(v); end,
            hidden = true,
            guiHidden = true,
            cmdHidden = false,
        },
        target = {
            name = L.core.options.target,
            desc = L.core.options.targetDesc,
            type = "input",
            set = function(i) SIL:SlashTarget(); end,
            hidden = true,
            guiHidden = true,
            cmdHidden = false,
        },
        options = {
            name = L.core.options.options,
            desc = L.core.options.open,
            type = "input",
            set = function(i) SIL:ShowOptions(); end,
            hidden = true,
            guiHidden = true,
            cmdHidden = false,
        },
        
        leveladj = {
            name = 'Level Adjustment',
            desc = "[item link], used to get the level adjustment id of a item link.",
            type = "input",
            set = function(i,link)
                    local itemLevel = select(4,GetItemInfo(link));

                    if itemLevel then
                        SIL:Print(link, "has a base item level", itemLevel, "with adjustment id", link:match(":(%d+)\124h%["));
                    end
                end,
            guiHidden = true,
            cmdHidden = false,
        },

        debug = {
            name = 'Debug Mode',
            type = "toggle",
            set = function(i,v) SIL:SetDebug(v); SIL:Print('Debug', SIL:GetDebug()); end,
            get = function(i) return SIL:GetDebug(); end,
            hidden = true,
            guiHidden = true,
            cmdHidden = true,
        },
    },
};

SIL_Defaults = {
    global = {
        age = 1800,             -- How long till information is refreshed
        purge = 360,            -- How often to automaticly purge
        advanced = false,       -- Display extra information in the tooltips
        autoscan = true,        -- Automaticly scan for changes
        cinfo = false,          -- Character Info/Paperdoll info
        minimap = {
            hide = false,       -- Minimap Icon
        },
        version = 1,            -- Version for future referance
        ldbText = true,         -- LDB Text
        ldbLabel = true,        -- LDB Label
        ldbRefresh = 30,        -- LDB Refresh Rate
        ttCombat = true,        -- Tooltip in combat
        color = true,           -- Color the score
        round = false,          -- Round the score
    },
    char = {
        module = {},            -- Module State
        debug = false,          -- Debug mode
    }
};

-- From http://www.wowhead.com/items?filter=qu=7;sl=16:18:5:8:11:10:1:23:7:21:2:22:13:24:15:28:14:4:3:19:25:12:17:6:9;minle=1;maxle=1;cr=166;crs=3;crv=0
SIL_Heirlooms = {
    [80] = {44102,42944,44096,42943,42950,48677,42946,42948,42947,42992,50255,44103,44107,44095,44098,44097,44105,42951,48683,48685,42949,48687,42984,44100,44101,44092,48718,44091,42952,48689,44099,42991,42985,48691,44094,44093,42945,48716},
};
