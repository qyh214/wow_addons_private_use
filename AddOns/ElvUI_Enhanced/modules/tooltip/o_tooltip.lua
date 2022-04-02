local E, L, V, P, G = unpack(ElvUI);
local EEL = E:GetModule("ElvuiEnhancedAgain");
local PT = E:GetModule("ProgressTooltip");

P["eel"]["progression"] = {
    ['enable'] = false,
    ["NameStyle"] = "SHORT",
    ["raids"] = {
        ["uldir"] = false,
        ["bod"] = false,
        ["cos"] = false,
        ["ep"] = false,
        ["nya"] = false,
        ["nathria"] = false,
        ["sanctum"] = true,
        ["sepul"] = true,
    },
}

local function ConfigTable()
	E.Options.args.eel.args.progression = {
        order = 30,
        type = 'group',
        name =L['Progression'],
        childGroups = 'tab',
        get = function(info) return E.db.eel.progression[ info[#info] ] end,	
        set = function(info, value) E.db.eel.progression[ info[#info] ] = value; end,
        disabled = function() return not E.private.tooltip.enable end,
        args = {
			header1 = {
				order = 1,
				type = 'description',
				fontSize = 'medium',
				name = "\n"..L['Display the players raid progression in the tooltip, this may not immediately update when mousing over a unit.'],
            },
            header2 = {
				order = 2,
				type = "header",
				name = "",
            },
            enable = {
				type = 'toggle',
				order = 3,
				name = L['Enable'],
				desc = L['Enable progression info in the tooltip'],	
            },
            NameStyle = {
                order = 4,
                name = L["Name Style"],
                type = "select",
                set = function(info, value) E.db.eel.progression[ info[#info] ] = value; wipe(PT.progressCache) end,
                disabled = function() return not E.db.eel.progression.enable end,
                values = {
                    ["LONG"] = L["Full"],
                    ["SHORT"] = L["Short"],
                },
            },
            raids = {
                order = 5,
                type = "group",
                name = RAIDS,
                guiInline = true,
                disabled = function() return not E.db.eel.progression.enable end,
                args = {
                    bfa = {
                        order = 6,
                        type = "group",
                        name = "Battle for Azeroth",
                        guiInline = true,
                        get = function(info) return E.db.eel.progression.raids[ info[#info] ] end,
                        set = function(info, value) E.db.eel.progression.raids[ info[#info] ] = value end,
                        disabled = function() return not E.db.eel.progression.enable end,
                        args = {
                            uldir = { order = -45, type = "toggle", name = "Uldir" },
                            bod = { order = -44, type = "toggle", name = "Battle of Dazar'Alor" },
                            cos = { order = -43, type = "toggle", name = "Crucible of Storms" },
                            ep = { order = -42, type = "toggle", name = "The Eternal Palace" },
                            nya = { order = -41, type = "toggle", name = "Ny'alotha, the Waking City" },
                        }
                    },
                    sl = {
                        order = 7,
                        type = "group",
                        name = "Shadowlands",
                        guiInline = true,
                        get = function(info) return E.db.eel.progression.raids[ info[#info] ] end,
                        set = function(info, value) E.db.eel.progression.raids[ info[#info] ] = value end,
                        disabled = function() return not E.db.eel.progression.enable end,
                        args = {
                            nathria = { order = -40, type = "toggle", name = "Castle Nathria" },
                            sanctum = { order = -39, type = "toggle", name = "Sanctum of Domination" },
                            sepul = { order = -38, type = "toggle", name = "Sepulcher of the First Ones" },
                        }
                    }
                },
            }
        }
    }
end

EEL.config["progression"] = ConfigTable
