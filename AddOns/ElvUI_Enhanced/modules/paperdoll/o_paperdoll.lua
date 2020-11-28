local E, L, V, P, G = unpack(ElvUI);
local EEL = E:GetModule("ElvuiEnhancedAgain");
local PD = E:GetModule("PaperDoll");

local tsort = table.sort

P["eel"]["paperdoll"] = {
	['itemlevel'] = {
        ['enable'] = false,
	},
	['durability'] = {
        ['enable'] = false,
        ['onlydamaged'] = false
	},
}



local function ConfigTable()
    E.Options.args.eel.args.paperdoll = {
        order = 50,
        type = 'group',
        name = L['Paperdoll'],
        childGroups = 'tab',
        get = function(info) return E.db.eel.paperdoll[ info[#info] ] end,
		set = function(info, value) E.db.eel.paperdoll[ info[#info] ] = value end,
        args = {
			header1 = {
				order = 1,
				type = 'description',
				fontSize = 'medium',
				name = "\n"..L["Equipment related addons"],
            },
            header2 = {
				order = 2,
				type = "header",
				name = "",
            },
            durability = {
                type = 'group',
                name = DURABILITY,
                guiInline = true,
                order = 5,
                get = function(info) return E.db.eel.paperdoll.durability[ info[#info] ] end,
                set = function(info, value) E.db.eel.paperdoll.durability[ info[#info] ] = value PD:UpdatePaperDoll() end,
                args = {
                    intro = {
                        type = "description",
                        name = L["DURABILITY_DESC"],
                        order = 1,
                    },	
                    enable = {
                        type = "toggle",
                        order = 2,
                        name = L["Enable"],
                        desc = L["Enable/Disable the display of durability information on the character screen."],
                    },
                    onlydamaged = {
                        type = "toggle",
                        order = 3,
                        name = L["Damaged Only"],
                        desc = L["Only show durabitlity information for items that are damaged."],
                        disabled = function() return not E.db.eel.paperdoll.durability.enable end,
                    },
                },
            },
            itemlevel = {
                type = 'group',
                name = STAT_AVERAGE_ITEM_LEVEL,
                guiInline = true,
                order = 7,
                get = function(info) return E.db.eel.paperdoll.itemlevel[ info[#info] ] end,
                set = function(info, value) E.db.eel.paperdoll.itemlevel[ info[#info] ] = value PD:UpdatePaperDoll() end,
                args = {
                    intro3 = {
                        type = "description",
                        name = L["ITEMLEVEL_DESC"],
                        order = 1,
                    },
                    enable = {
                        type = "toggle",
                        order = 2,
                        name = L["Enable"],
                        desc = L["Enable/Disable the display of item levels on the character screen."],
                    },
                },
            },
        }
    }
end

EEL.config["paperdoll"] = ConfigTable
