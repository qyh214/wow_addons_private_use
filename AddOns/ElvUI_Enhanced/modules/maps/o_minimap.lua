local E, L, V, P, G = unpack(ElvUI);
local EEL = E:GetModule("ElvuiEnhancedAgain");
local MB = E:GetModule("MinimapButtons");

P["eel"]["minimap"] = {
	['minimapcords'] = {
        ['enable'] = false,
        ['locationdigits'] = 1
    },
    ['minimapbar'] = {
        ['enable'] = false,
        ['skinStyle'] = 'HORIZONTAL',
        ['layoutDirection'] = 'NORMAL',
        ['backdrop'] = false,
        ['buttonSize'] = 28,
        ['mouseover'] = false,
        ['mbcalendar'] =  false,
        ['mbgarrison'] = false,
        ['buttonsPerRow'] = 5,
    }
}

local function setMinimapAbove()
    if E.db.eel.minimap.minimapcords.enable then
        E.db.general.minimap.locationText = 'ABOVE'
        E:GetModule('MinimapLocation'):Initialize()
        E:GetModule('Minimap'):UpdateSettings()
    elseif not E.db.eel.minimap.minimapcords.enable then
        E.db.general.minimap.locationText = 'SHOW'
        E:GetModule('Minimap'):UpdateSettings()
    end
end

local function ConfigTable()
	E.Options.args.eel.args.minimap = {
        order = 20,
        type = 'group',
        name = L['Minimap'],
        childGroups = 'tab',
        args = {
			header1 = {
				order = 1,
				type = 'description',
				fontSize = 'medium',
				name = "\n"..L["This module can enhance the ElvUI minimap"],
            },
            alert = {
				order = 2,
				type = 'description',
				fontSize = 'medium',
                name = "\n"..L["|cffff8000!!! When ElvUI MiniMap is disabled the MiniMap Coordinates feature is also disabled!!!|r"],
                hidden = function() return E.private.general.minimap.enable end,
            },
            header2 = {
				order = 3,
				type = "header",
				name = "",
            },
            minimapcords = {
                order = 5,
                type = 'group',
                name = L["MiniMap Coordinates"],
                get = function(info) return E.db.eel.minimap.minimapcords[ info[#info] ] end,
                disabled = function() return not E.private.general.minimap.enable end,
                args = {
                    enable = {
                        order = 1,
                        type = 'toggle',
                        name = L["Enable"],
                        desc = L["Show minimap locatation and cords on top of the minimap"],
                        get = function(info) return E.db.eel.minimap.minimapcords[ info[#info] ] end,
				        set = function(info, value) E.db.eel.minimap.minimapcords[ info[#info] ] = value; setMinimapAbove() end
                    },
                    locationdigits = {
                        order = 4,
                        type = 'range',
                        name =L['Location Digits'],
                        desc = L['Number of digits for map location.'],
                        min = 0, max = 2, step = 1,
                        get = function(info) return E.db.eel.minimap.minimapcords.locationdigits end,
                        set = function(info, value) E.db.eel.minimap.minimapcords.locationdigits = value; E:GetModule('Minimap'):UpdateSettings() end,					
                        disabled = function() return E.db.general.minimap.locationText ~= 'ABOVE' end,
                    },
                },
            },
            minimapbar = {
                order = 6,
                type = 'group',
                name = L["Minimap Button Bar"],
                get = function(info) return E.db.eel.minimap.minimapbar[ info[#info] ] end,
                set = function(info, value) E.db.eel.minimap.minimapbar[ info[#info] ] = value; MB:UpdateLayout() end,
                args = {
                    enable = {
                        order = 1,
                        type = 'toggle',
                        name = L["Enable"],
                        desc = L['Skins the minimap buttons in ElvUI style.'],
                        set = function(info, value) E.db.eel.minimap.minimapbar.enable = value; E:StaticPopup_Show("CONFIG_RL") end,					
                    },
                    spacer = {
                        order = 2,
                        type = "header",
                        name = "",
                    },
                    skinStyle = {
                        order = 2,
                        type = 'select',
                        name = L['Skin Style'],
                        desc = L['Change settings for how the minimap buttons are skinned.'],
                        disabled = function() return not E.db.eel.minimap.minimapbar.enable end,
                        set = function(info, value) E.db.eel.minimap.minimapbar[ info[#info] ] = value; MB:UpdateSkinStyle() end,
                        values = {
                            ['NOANCHOR'] = L['No Anchor Bar'],
                            ['HORIZONTAL'] = L['Horizontal Anchor Bar'],
                            ['VERTICAL'] = L['Vertical Anchor Bar'],
                        },
                    },
                    layoutDirection = {
                        order = 3,
                        type = 'select',
                        name = L['Layout Direction'],
                        desc = L['Normal is right to left or top to bottom, or select reversed to switch directions.'],
                        disabled = function() return not E.db.eel.minimap.minimapbar.enable or E.db.eel.minimap.minimapbar.skinstyle == 'NOANCHOR' end,
                        values = {
                            ['NORMAL'] = L['Normal'],
                            ['REVERSED'] = L['Reversed'],
                        },
                    },
                    buttonSize = {
                        order = 4,
                        type = 'range',
                        name = L['Button Size'],
                        desc = L['The size of the minimap buttons.'],
                        min = 16, max = 40, step = 1,
                        disabled = function() return not E.db.eel.minimap.minimapbar.enable or E.db.eel.minimap.minimapbar.skinstyle == 'NOANCHOR' end,
                    },
                    buttonsPerRow = {
                        order = 5,
                        type = 'range',
                        name = L['Buttons per row'],
                        desc = L['The max number of buttons when a new row starts.'],
                        min = 2, max = 20, step = 1,
                        disabled = function() return not E.db.eel.minimap.minimapbar.enable or E.db.eel.minimap.minimapbar.skinstyle == 'NOANCHOR' end,
                    },
                    backdrop = {
                        type = 'toggle',
                        order = 6,
                        name = L["Backdrop"],
                        disabled = function() return not E.db.eel.minimap.minimapbar.enable or E.db.eel.minimap.minimapbar.skinstyle == 'NOANCHOR' end,
                    },			
                    mouseover = {
                        order = 7,
                        name = L['Mouse Over'],
                        desc = L['The frame is not shown unless you mouse over the frame.'],
                        type = "toggle",
                        set = function(info, value) E.db.eel.minimap.minimapbar.mouseover = value; MB:ChangeMouseOverSetting() end,
                        disabled = function() return not E.db.eel.minimap.minimapbar.enable or E.db.eel.minimap.minimapbar.skinstyle == 'NOANCHOR' end,
                    },
                    mmbuttons = {
                        order = 8,
                        type = "group",
                        name = L["Minimap Buttons"],
                        guiInline = true,
                        args = {
                            mbgarrison = {
                                order = 1,
                                name = GARRISON_LOCATION_TOOLTIP,
                                desc = L['TOGGLESKIN_DESC'],
                                type = "toggle",
                                disabled = function() return not E.db.eel.minimap.minimapbar.enable or E.db.eel.minimap.minimapbar.skinstyle == 'NOANCHOR' end,
                                set = function(info, value) E.db.eel.minimap.minimapbar.mbgarrison = value; E:StaticPopup_Show("CONFIG_RL") end,
                            },
                            mbcalendar = {
                                order = 1,
                                name = L['Calendar'],
                                desc = L['TOGGLESKIN_DESC'],
                                type = "toggle",
                                disabled = function() return not E.db.eel.minimap.minimapbar.enable or E.db.eel.minimap.minimapbar.skinstyle == 'NOANCHOR' end,
                                set = function(info, value) E.db.eel.minimap.minimapbar.mbcalendar = value; E:StaticPopup_Show("CONFIG_RL") end,
                            }
                        }
                    }
                }
            }
        }
    }
    E.Options.args.maps.args.minimap.args.locationTextGroup.args.locationText.values = {
		['MOUSEOVER'] = L['Minimap Mouseover'],
		['SHOW'] = L['Always Display'],
		['ABOVE'] = L['Above Minimap'],
		['HIDE'] = L['Hide'],
	}
end



EEL.config["Minimap"] = ConfigTable
