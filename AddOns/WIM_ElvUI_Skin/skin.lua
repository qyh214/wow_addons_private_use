-- Custom Skin handlers (In this situation, this must be declared before the skin table. If loaded after, it would not have a chance to load and an error would be thrown.)
local function formatDetails(window, guild, level, race, class)
		if (guild ~= "") then
			guild = "<"..guild.."> ";
    end
    return "|cffffffff"..guild..level.." "..race.." "..class.."|r";
end

--Default window skin
local WIM_Elvui = {
    title = "WIM ElvUI",
    version = "1.0.0",
    author = "fuba",
    website = "https://mods.curse.com/members/q3fuba",
    message_window = {
        texture = "Interface\\AddOns\\WIM_ElvUI_Skin\\images\\default\\message_window",
        min_width = 256,
        min_height = 128,
        backdrop = {
            top_left = {
                width = 64,
                height = 64,
                offset = {0, 0},
                texture_coord = {0, 0, 0, .25, .25, 0, .25, .25}
            },
            top_right = {
                width = 64,
                height = 64,
                offset = {0, 0},
                texture_coord = {.75, 0, .75, .25, 1, 0, 1, .25}
            },
            bottom_left = {
                width = 64,
                height = 64,
                offset = {0, 0},
                texture_coord = {0, .75, 0, 1, .25, .75, .25, 1}
            },
            bottom_right = {
                width = 64,
                height = 64,
                offset = {0, 0},
                texture_coord = {.75, .75, .75, 1, 1, .75, 1, 1}
            },
            top = {
                tile = false,
                texture_coord = {.25, 0, .25, .25, .75, 0, .75, .25}
            },
            bottom = {
                tile = false,
                texture_coord = {.25, .75, .25, 1, .75, .75, .75, 1}
            },
            left = {
                tile = false,
                texture_coord = {0, .25, 0, .75, .25, .25, .25, .75}
            },
            right = {
                tile = false,
                texture_coord = {.75, .25, .75, .75, 1, .25, 1, .75}
            },
            background = {
                tile = false,
                texture_coord = {.25, .25, .25, .75, .75, .25, .75, .75}
            }
        },
        widgets = {
            class_icon = {
                texture = "Interface\\AddOns\\WIM_ElvUI_Skin\\images\\default\\class_icons",
                chatAlphaMask = "Interface\\AddOns\\WIM_ElvUI_Skin\\images\\default\\chatAlphaMask",
                width = 16,
                height = 16,
                points = {
                    {"TOPLEFT", "window", "TOPLEFT", 4, -4}
                },
                is_round = false,
                blank = {.5, .5, .5, .75, .75, .5, .75, .75},
                druid = {0, 0, 0, .25, .25, 0, .25, .25},
                hunter = {.25, 0, .25, .25, .5, 0, .5, .25},
                mage = {.5, 0, .5, .25, .75, 0, .75, .25},
                paladin = {.75, 0, .75, .25, 1, 0, 1, .25},
                priest = {0, .25, 0, .5, .25, .25, .25, .5},
                rogue = {.25, .25, .25, .5, .5, .25, .5, .5},
                shaman = {.5, .25, .5, .5, .75, .25, .75, .5},
                warlock = {.75, .25, .75, .5, 1, .25, 1, .5},
                warrior = {0, .5, 0, .75, .25, .5, .25, .75},
                deathknight = {.75, .5, .75, .75, 1, .5, 1, .75},
                monk = {0, .75, 0, 1, .25, .75, .25, 1},
                gm = {.25, .5, .25, .75, .5, .5, .5, .75},
                demonhunter = {.75, .75, .75, 1, 1, .75, 1, 1},
                --d3 = {.5, .75, .5, 1, .75, .75, .75, 1},
                --bnd = {.25, .75, .25, 1, .5, .75, .5, 1}
            },
            client_icon = {
                texture = "Interface\\AddOns\\WIM_ElvUI_Skin\\images\\default\\client_icons",
                chatAlphaMask = "Interface\\AddOns\\WIM_ElvUI_Skin\\images\\default\\chatAlphaMask",
                width = 16,
                height = 16,
                points = {
                    {"TOPLEFT", "window", "TOPLEFT", 4, -4}
                },
                is_round = false,
                hots = {.5, .5, .5, .75, .75, .5, .75, .75},
                --druid = {0, 0, 0, .25, .25, 0, .25, .25},
                --hunter = {.25, 0, .25, .25, .5, 0, .5, .25},
                --mage = {.5, 0, .5, .25, .75, 0, .75, .25},
                --paladin = {.75, 0, .75, .25, 1, 0, 1, .25},
                --priest = {0, .25, 0, .5, .25, .25, .25, .5},
                --rogue = {.25, .25, .25, .5, .5, .25, .5, .5},
                --shaman = {.5, .25, .5, .5, .75, .25, .75, .5},
                --warlock = {.75, .25, .75, .5, 1, .25, 1, .5},
                --warrior = {0, .5, 0, .75, .25, .5, .25, .75},
								ow = {.75, .5, .75, .75, 1, .5, 1, .75},
                hs = {0, .75, 0, 1, .25, .75, .25, 1},
                --gm = {.25, .5, .25, .75, .5, .5, .5, .75},
                sc2 = {.75, .75, .75, 1, 1, .75, 1, 1},
                d3 = {.5, .75, .5, 1, .75, .75, .75, 1},
                bnd = {.25, .75, .25, 1, .5, .75, .5, 1}
            },
            from = {
                points = {
                    {"TOPLEFT", "window", "TOPLEFT", 24, -7}
                },
                font = "FriendsFont_Normal", --GameFontNormalLarge
                font_color = "ffffff",
                font_height = 11,
                font_flags = "",
                use_class_color = true
            },
            char_info = {
                format = formatDetails,
                points = {
                    {"TOPRIGHT", "window", "TOPRIGHT", -25, -7}
                },
                font = "FriendsFont_Normal", --GameFontNormal
                font_color = "1883d1"
            },
            close = {
                state_hide = {
                    NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\hide",
                    PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\hide_pushed",
                    HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_highlight",
                    HighlightAlphaMode = "ADD"
                },
                state_close = {
                    NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\close",
                    PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\close_pushed",
                    HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_highlight",
                    HighlightAlphaMode = "ADD"
                },
                width = 16,
                height = 16,
                points = {
                    {"TOPRIGHT", "window", "TOPRIGHT", -4, -4}
                }
            },
            history = {
                NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\history",
                PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\history_pushed",
                HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_highlight",
                HighlightAlphaMode = "ADD",
                width = 16,
                height = 16,
                points = {
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -3, 44}
                }
            },
            w2w = {
                NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\w2w",
                PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\w2w",
                HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\w2w",
                HighlightAlphaMode = "ADD",
                points = {
                    {"TOPLEFT", "class_icon", 14, -14},
                    {"BOTTOMRIGHT", "class_icon", -14, 14}
                }
            },
            chat_info = {
                NormalTexture = nil, -- by default we don't want a texture, but your skin is welcome to have one.
                PushedTexture = "Interface\\AddOns\\WIM_ElvUI_Skin\\Skins\\Default\\w2w",
                HighlightTexture = "Interface\\AddOns\\WIM_ElvUI_Skin\\Skins\\Default\\w2w",
                HighlightAlphaMode = "ADD",
                points = {
                    {"TOPLEFT", "class_icon", 14, -14},
                    {"BOTTOMRIGHT", "class_icon", -14, 14}
                }
            },
            chatting = {
                NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\chatting",
                PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\chatting",
                width = 16,
                height = 16,
                points = {
                    {"TOPLEFT", "window", -3, -23}
                }
            },
            scroll_up = {
                NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\scroll_up",
                PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\scroll_up_pushed",
                HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_highlight",
                DisabledTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_disabled",
                HighlightAlphaMode = "ADD",
                width = 16,
                height = 16,
                points = {
                    {"TOPRIGHT", "window", "TOPRIGHT", -3, -23}
                }
            },
            scroll_down = {
                NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\scroll_down",
                PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\scroll_down_pushed",
                HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_highlight",
                DisabledTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_disabled",
                HighlightAlphaMode = "ADD",
                width = 16,
                height = 16,
                points = {
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -3, 27}
                }
            },
            chat_display = {
                points = {
                    {"TOPLEFT", "window", "TOPLEFT", 4, -24},
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -22, 27}
                },
                font = "FriendsFont_UserText",
					font_height = 12,
					font_flags = "",
            },
           msg_box = {
					font = "FriendsFont_UserText",
					font_height = 14,
					font_color = {1,1,1},
					points = {
						{"TOPLEFT", "window", "BOTTOMLEFT", 6, 25},
						{"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -3, 1}
                },
            },
            resize = {
                NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\resize",
                PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\resize",
                HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\resize",
                HighlightAlphaMode = "ADD",
                width = 16,
                height = 16,
                points = {
                    {"BOTTOMLEFT", "window", "BOTTOMRIGHT", -16, 0}
                }
            },
            shortcuts = {
                stack = "DOWN",
                spacing = 1,
                points = {
                    {"TOPLEFT", "window", "TOPRIGHT", -19, -40},
                    {"BOTTOMRIGHT", "window", "BOTTOMRIGHT", -3, 105}
                },
                buttons = {
                    NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_frame",
                    PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_pushed",
                    HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_highlight",
                    HighlightAlphaMode = "ADD",
                    icons = {
                        location = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\location",
                        invite = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\invite",
                        friend = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\friend",
                        ignore = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\ignore",
                    }
                }
            }
        },
    },
    tab_strip = {
        textures = {
            tab = {
                NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\tab_normal",
                PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\tab_selected",
                HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\tab_flash",
                --HighlightTexture = "Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight",
                HighlightAlphaMode = "ADD"
            },
            prev = {
                NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\prev",
                PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\prev_pushed",
                DisabledTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\prev",
                HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_highlight",
                HighlightAlphaMode = "ADD",
                height = 16,
                width = 16,
            },
            next = {
                NormalTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\next",
                PushedTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\next_pushed",
                DisabledTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\next",
                HighlightTexture = "Interface\\Addons\\WIM_ElvUI_Skin\\images\\default\\icons\\button_highlight",
                HighlightAlphaMode = "ADD",
                height = 16,
                width = 16,
            },
        },
        height = 20,
        points = {
            {"BOTTOMLEFT", "window", "TOPLEFT", 18, 4},
            {"BOTTOMRIGHT", "window", "TOPRIGHT", -18, 4}
        },
        text = {
            font = "SystemFont_Small",
            font_color = {1, 1, 1},
            font_height = 11,
            font_flags = ""
        },
			vertical = false,
		},
	};



----------------------------------------------------------
--                  Register Skin                       --
----------------------------------------------------------

WIM.RegisterSkin(WIM_Elvui);
