local E, L, V, P, G = unpack(ElvUI);
local EEL = E:GetModule("ElvuiEnhancedAgain");
local RM = E:GetModule("RaidMarkerBar");

P["eel"]["raidmarkerbar"] = {
    ['enable'] = false,
	['visibility'] = 'DEFAULT',
	['backdrop'] = false,
	['buttonSize'] = 22,
	['spacing'] = 2,
	['orientation'] = 'HORIZONTAL',
	['modifier'] = 'shift-'
}

local raidmarkerVisibility = {
	DEFAULT = L['Use Default'],
	INPARTY = AGGRO_WARNING_IN_PARTY,
	ALWAYS  = L['Always Display'],
}

local function ConfigTable()
	E.Options.args.eel.args.raidmarkerbar = {
        order = 30,
        type = 'group',
        name =L['Raid Marker Bar'],
        childGroups = 'tab',
        get = function(info) return E.db.eel.raidmarkerbar[ info[#info] ] end,	
		set = function(info, value) E.db.eel.raidmarkerbar[ info[#info] ] = value; RM:ToggleSettings() end,
        args = {
			header1 = {
				order = 1,
				type = 'description',
				fontSize = 'medium',
				name = "\n"..L["Enables easy access to raidmarkers and targetmarkers"],
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
				desc = L['Display a quick action bar for raid targets and world markers.'],	
            },
            settings = {
                order = 1,
                type = 'group',
                name =L['Options'],
                childGroups = 'tab',
                args = {
                    visibility = {		
                        type = 'select',
                        order = 3,
                        name = L["Visibility"],
                        disabled = function() return not E.db.eel.raidmarkerbar.enable end,
                        values = raidmarkerVisibility,
                    },
                    backdrop = {
                        type = 'toggle',
                        order = 4,
                        name = L["Backdrop"],
                        disabled = function() return not E.db.eel.raidmarkerbar.enable end,			
                    },
                    buttonSize = {
                        order = 5,
                        type = 'range',
                        name = L['Button Size'],
                        min = 16, max = 40, step = 1,
                        disabled = function() return not E.db.eel.raidmarkerbar.enable end,
                    },
                    spacing = {
                        order = 6,
                        type = 'range',
                        name = L["Button Spacing"],
                        min = 0, max = 10, step = 1,
                        disabled = function() return not E.db.eel.raidmarkerbar.enable end,
                    },
                    orientation = {
                        order = 7,
                        type = 'select',
                        name = L['Orientation'],
                        disabled = function() return not E.db.eel.raidmarkerbar.enable end,
                        values = {
                            ['HORIZONTAL'] = L['Horizontal'],
                            ['VERTICAL'] = L['Vertical'],
                        },
                    },
                    modifier = {
                        order = 8,
                        type = 'select',
                        name = L['Modifier Key'],
                        desc = L['Set the modifier key for placing world markers.'],
                        disabled = function() return not E.db.eel.raidmarkerbar.enable end,
                        values = {
                            ['shift-'] = L['Shift Key'],
                            ['ctrl-'] = L['Ctrl Key'],
                            ['alt-'] = L['Alt Key'],
                        }
                    }
                }
            }
        }
    }
end

EEL.config["raidmarkerbar"] = ConfigTable
