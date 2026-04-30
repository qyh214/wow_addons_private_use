--[[
    widgetName:                         string
    widgetDecsription:                  Settings_Define.Descriptor
    widgetType:                         Settings_Enum.WidgetType
    widgetTransparent:                  boolean

    Shared:
        key:                            string
        set:                            function

    Tab:
        widgetTab_isFooter:             boolean

    Title:
        widgetTitle_info:               Settings_Define.TitleInfo

    Container:
        widgetContainer_isNested:       boolean

    Text:

    Range:
        widgetRange_min:                number|function
        widgetRange_max:                number|function
        widgetRange_step:               number|function
        widgetRange_textFormatting      string (%s: value)
        widgetRange_textFormattingFunc: function

    Button:
        widgetButton_text:              string
        widgetButton_refreshOnClick:    boolean

    CheckButton:

    SelectionMenu:
        widgetSelectionMenu_data:       table|function
        widgetSelectionMenu_get:        function
        widgetSelectionMenu_set:        function

    Color Input:

    Input:
        widgetInput_placeholder:        string|function

    disableWhen:                        function
    showWhen:                           function
    indent:                             number
    children:                           table
]]

local env = select(2, ...)
local Config = env.Config
local L = env.L
local Sound = env.modules:Import("packages\\sound")
local UIFont = env.modules:Import("packages\\ui-font")
local SharedUtil = env.modules:Import("@\\SharedUtil")
local Waypoint_Enum = env.modules:Import("@\\Waypoint\\Enum")
local Settings_Define = env.modules:Import("@\\Settings\\Define")
local Settings_Enum = env.modules:Import("@\\Settings\\Enum")
local Settings_Preload = env.modules:Import("@\\Settings\\Preload")
local Settings_Schema = env.modules:New("@\\Settings\\Schema")

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local SettingsPrompt = _G[Settings_Preload.FRAME_NAME].Prompt

local function HandleAccept()
    Config.DBGlobal:Wipe()
    ReloadUI()
end

local RESET_PROMPT = {
    text         = L["CONFIG_GENERAL_OTHER_RESETPROMPT"],
    options      = {
        {
            text     = L["CONFIG_GENERAL_OTHER_RESETPROMPT_YES"],
            callback = HandleAccept
        },
        {
            text     = L["CONFIG_GENERAL_OTHER_RESETPROMPT_NO"],
            callback = nil
        }
    },
    hideOnEscape = true,
    timeout      = 10
}

do -- Schema
    local function CalculateDistance(yds) return function() return SharedUtil:CalculateDistance(yds) end end
    local function FormatDistance(value) return SharedUtil:FormatDistance(value) end
    local function FormatPercentage(value) return string.format("%0.0f", value * 100) .. "%" end

    Settings_Schema.SCHEMA = {
        {
            widgetName = L["CONFIG_GENERAL"],
            widgetType = Settings_Enum.WidgetType.Tab,
            children   = {
                {
                    widgetName = L["CONFIG_GENERAL_PREFERENCES"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName               = L["CONFIG_GENERAL_PREFERENCES_FONT"],
                            widgetType               = Settings_Enum.WidgetType.SelectionMenu,
                            widgetSelectionMenu_data = function()
                                UIFont.CustomFont:RefreshFontList()
                                return UIFont.CustomFont:GetFontNames()
                            end,
                            widgetSelectionMenu_get  = function(value)
                                return UIFont.CustomFont.GetFontIndexForPath(value)
                            end,
                            widgetSelectionMenu_set  = function(index)
                                return UIFont.CustomFont.GetFontPathForIndex(index)
                            end,
                            key                      = "fontPath"
                        },
                        {
                            widgetName        = L["CONFIG_GENERAL_PREFERENCES_METER"],
                            widgetDescription = Settings_Define.Descriptor{ imageType = nil, imagePath = nil, description = L["CONFIG_GENERAL_PREFERENCES_METER_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "PrefMetric"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_GENERAL_OTHER"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName        = nil,
                            widgetType        = Settings_Enum.WidgetType.Button,
                            widgetButton_text = L["CONFIG_GENERAL_OTHER_RESETBUTTON"],
                            set               = function() SettingsPrompt:Open(RESET_PROMPT) end
                        }
                    }
                }
            }
        },
        {
            widgetName = L["CONFIG_WAYPOINTSYSTEM"],
            widgetType = Settings_Enum.WidgetType.Tab,
            children   = {
                {

                    widgetType               = Settings_Enum.WidgetType.SelectionMenu,
                    widgetTransparent        = true,
                    widgetSelectionMenu_data = {
                        L["CONFIG_WAYPOINTSYSTEM_TYPE_BOTH"],
                        L["CONFIG_WAYPOINTSYSTEM_TYPE_WAYPOINT"],
                        L["CONFIG_WAYPOINTSYSTEM_TYPE_PINPOINT"]
                    },
                    key                      = "WaypointSystemType"
                },
                {
                    widgetName = L["CONFIG_WAYPOINTSYSTEM_GENERAL"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_GENERAL_ALWAYSSHOW"],
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_ALWAYSSHOW_DESCRIPTION"] },
                            key               = "AlwaysShow"
                        },
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_GENERAL_RIGHTCLICKTOCLEAR"],
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_RIGHTCLICKTOCLEAR_DESCRIPTION"] },
                            key               = "RightClickToClear"
                        },
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_GENERAL_BACKGROUNDPREVIEW"],
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_BACKGROUNDPREVIEW_DESCRIPTION"] },
                            key               = "BackgroundPreview"
                        },
                        {
                            widgetName                     = L["CONFIG_WAYPOINTSYSTEM_GENERAL_TRANSITION_DISTANCE"],
                            widgetDescription              = Settings_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_TRANSITION_DISTANCE_DESCRIPTION"] },
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetRange_min                = CalculateDistance(50),
                            widgetRange_max                = CalculateDistance(500),
                            widgetRange_step               = CalculateDistance(5),
                            widgetRange_textFormattingFunc = FormatDistance,
                            key                            = "DistanceThresholdPinpoint",
                            showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All end
                        },
                        {
                            widgetName                     = L["CONFIG_WAYPOINTSYSTEM_GENERAL_HIDE_DISTANCE"],
                            widgetDescription              = Settings_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_HIDE_DISTANCE_DESCRIPTION"] },
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetRange_min                = CalculateDistance(1),
                            widgetRange_max                = CalculateDistance(100),
                            widgetRange_step               = 1,
                            widgetRange_textFormattingFunc = FormatDistance,
                            key                            = "DistanceThresholdHidden"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_WAYPOINTSYSTEM_WAYPOINT"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Waypoint end,
                    children   = {
                        {
                            widgetName               = L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE"],
                            widgetType               = Settings_Enum.WidgetType.SelectionMenu,
                            widgetSelectionMenu_data = {
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_BOTH"],
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_DISTANCE"],
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_ARRIVALTIME"],
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_DESTINATIONNAME"],
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_NONE"]
                            },
                            key                      = "WaypointDistanceTextType"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_WAYPOINTSYSTEM_PINPOINT"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Pinpoint end,
                    children   = {
                        {
                            widgetName = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_INFO"],
                            widgetType = Settings_Enum.WidgetType.CheckButton,
                            key        = "PinpointInfo"
                        },
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_INFO_EXTENDED"],
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_INFO_EXTENDED_DESCRIPTION"] },
                            indent            = 1,
                            key               = "PinpointInfoExtended",
                            showWhen          = function() return Config.DBGlobal:GetVariable("PinpointInfo") == true end
                        },
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_SHOWINQUESTBLOB"],
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_SHOWINQUESTAREA_DESCRIPTION"] },
                            key               = "PinpointAllowInQuestArea"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_WAYPOINTSYSTEM_NAVIGATOR"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_NAVIGATOR_ENABLE"],
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_NAVIGATOR_ENABLE_DESCRIPTION"] },
                            indent            = 0,
                            key               = "NavigatorShow"
                        }
                    }
                }
            }
        },
        {
            widgetName = L["CONFIG_APPEARANCE"],
            widgetType = Settings_Enum.WidgetType.Tab,
            children   = {
                {
                    widgetName = L["CONFIG_APPEARANCE_WAYPOINT"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Waypoint or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All end,
                    children   = {
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_SCALE"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetDescription              = Settings_Define.Descriptor{ description = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_DESCRIPTION"] },
                            widgetRange_min                = 0.5,
                            widgetRange_max                = 5,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointScale"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_MIN"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetDescription              = Settings_Define.Descriptor{ description = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_MIN_DESCRIPTION"] },
                            widgetRange_min                = 0.125,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.125,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointScaleMin",
                            indent                         = 1
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_MAX"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetDescription              = Settings_Define.Descriptor{ description = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_MAX_DESCRIPTION"] },
                            widgetRange_min                = 1,
                            widgetRange_max                = 2,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointScaleMax",
                            indent                         = 1
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_ALPHA"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointAlpha"
                        },
                        {
                            widgetName = L["CONFIG_APPEARANCE_WAYPOINT_BEAM"],
                            widgetType = Settings_Enum.WidgetType.CheckButton,
                            key        = "WaypointBeam"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_BEAM_ALPHA"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            showWhen                       = function()
                                return Config.DBGlobal:GetVariable("WaypointBeam") ==
                                    true
                            end,
                            indent                         = 1,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointBeamAlpha"
                        },
                        {
                            widgetName               = L["FONT_FLAGS"],
                            widgetType               = Settings_Enum.WidgetType.SelectionMenu,
                            widgetSelectionMenu_data = function()
                                return {
                                    L["NONE"],
                                    L["OUTLINE"],
                                    L["THICKOUTLINE"],
                                    L["MONOCHROME"]
                                }
                            end,
                            widgetSelectionMenu_get  = function(value)
                                return Config.DBGlobal:GetVariable("WaypointDistanceTextFontFlags")
                            end,
                            widgetSelectionMenu_set  = function(index)
                                return Config.DBGlobal:SetVariable("WaypointDistanceTextFontFlags", index)
                            end,
                            key                      = "WaypointDistanceTextFontFlags"
                        },
                        {
                            widgetName = L["CONFIG_APPEARANCE_WAYPOINT_FOOTER"],
                            widgetType = Settings_Enum.WidgetType.CheckButton,
                            key        = "WaypointDistanceText",
                            showWhen   = function() return Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_FOOTER_SCALE"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointDistanceText") == true and Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end,
                            indent                         = 1,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 2,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointDistanceTextScale"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_FOOTER_ALPHA"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointDistanceText") == true and Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end,
                            indent                         = 1,
                            widgetRange_min                = 0,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointDistanceTextAlpha"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_FOOTER_SUBTEXTALPHA"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointDistanceText") == true and Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end,
                            indent                         = 1,
                            widgetRange_min                = 0,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointDistanceSubtextAlpha"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_APPEARANCE_PINPOINT"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Pinpoint or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All end,
                    children   = {
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_PINPOINT_SCALE"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetRange_min                = 0.5,
                            widgetRange_max                = 2,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "PinpointScale",
                            indent                         = 0
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_PINPOINT_ALPHA"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "PinpointAlpha"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_APPEARANCE_NAVIGATOR"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("NavigatorShow") == true end,
                    children   = {
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_NAVIGATOR_SCALE"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            indent                         = 0,
                            widgetRange_min                = 0.5,
                            widgetRange_max                = 2,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "NavigatorScale"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_NAVIGATOR_ALPHA"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "NavigatorAlpha"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_NAVIGATOR_DISTANCE"],
                            widgetType                     = Settings_Enum.WidgetType.Range,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 3,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "NavigatorDistance"
                        },
                        {
                            widgetName        = L["CONFIG_APPEARANCE_NAVIGATOR_DYNAMICDISTANCE"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_APPEARANCE_NAVIGATOR_DYNAMICDISTANCE_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "NavigatorDynamicDistance"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_APPEARANCE_COLOR"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR"],
                            widgetType = Settings_Enum.WidgetType.CheckButton,
                            key        = "CustomColor"
                        },
                        {
                            widgetName               = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COMPLETED_NORMAL_QUEST"],
                            widgetType               = Settings_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Settings_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorQuestComplete"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Settings_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorQuestCompleteTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorQuestComplete")
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteTint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COMPLETED_REPEATABLE_QUEST"],
                            widgetType               = Settings_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Settings_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorQuestCompleteRepeatable"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Settings_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorQuestCompleteRepeatableTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteRepeatable")
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteRepeatableTint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COMPLETED_IMPORTANT_QUEST"],
                            widgetType               = Settings_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Settings_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorQuestCompleteImportant"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Settings_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorQuestCompleteImportantTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteImportant")
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteImportantTint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_INCOMPLETE_QUEST"],
                            widgetType               = Settings_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Settings_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorQuestIncomplete"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Settings_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorQuestIncompleteTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorQuestIncomplete")
                                        Config.DBGlobal:ResetVariable("CustomColorQuestIncompleteTint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_OTHER"],
                            widgetType               = Settings_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Settings_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorOther"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Settings_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorOtherTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorOther")
                                        Config.DBGlobal:ResetVariable("CustomColorOtherTint")
                                    end
                                }
                            }
                        }
                    }
                }
            }
        },
        {
            widgetName = L["CONFIG_AUDIO"],
            widgetType = Settings_Enum.WidgetType.Tab,
            children   = {
                {
                    widgetName = L["CONFIG_AUDIO_GENERAL"],
                    widgetType = Settings_Enum.WidgetType.Container,

                    children   = {
                        {
                            widgetName = L["CONFIG_AUDIO_GENERAL_ENABLEGLOBALAUDIO"],
                            widgetType = Settings_Enum.WidgetType.CheckButton,
                            key        = "AudioGlobal"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_AUDIO_CUSTOMIZE"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("AudioGlobal") == true end,
                    children   = {
                        {
                            widgetName = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO"],
                            widgetType = Settings_Enum.WidgetType.CheckButton,
                            key        = "AudioCustom"
                        },
                        {
                            widgetName               = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_WAYPOINTSHOW"],
                            widgetType               = Settings_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("AudioCustom") == true end,
                            children                 = {
                                {
                                    widgetName              = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_SOUND_ID"],
                                    widgetType              = Settings_Enum.WidgetType.Input,
                                    widgetInput_placeholder = L
                                        ["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"],
                                    key                     = "AudioCustomShowWaypoint",
                                    set                     = function(_, value)
                                        if tonumber(value) then
                                            Config.DBGlobal:SetVariable("AudioCustomShowWaypoint", tonumber(value))
                                        else
                                            Config.DBGlobal:SetVariable("AudioCustomShowWaypoint", "")
                                        end
                                    end
                                },
                                {
                                    widgetType        = Settings_Enum.WidgetType.Button,
                                    widgetButton_text = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_PREVIEW"],
                                    set               = function()
                                        Sound.PlaySound("Preview",
                                            Config.DBGlobal:GetVariable("AudioCustomShowWaypoint"))
                                    end
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable(
                                            "AudioCustomShowWaypoint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_PINPOINTSHOW"],
                            widgetType               = Settings_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("AudioCustom") == true end,
                            children                 = {
                                {
                                    widgetName              = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_SOUND_ID"],
                                    widgetType              = Settings_Enum.WidgetType.Input,
                                    widgetInput_placeholder = L
                                        ["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"],
                                    key                     = "AudioCustomShowPinpoint",
                                    set                     = function(_, value)
                                        if tonumber(value) then
                                            Config.DBGlobal:SetVariable("AudioCustomShowPinpoint", tonumber(value))
                                        else
                                            Config.DBGlobal:SetVariable("AudioCustomShowPinpoint", "")
                                        end
                                    end
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_PREVIEW"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Sound.PlaySound("Preview",
                                            Config.DBGlobal:GetVariable("AudioCustomShowPinpoint"))
                                    end
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable(
                                            "AudioCustomShowPinpoint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_NEWUSERNAVIGATION"],
                            widgetType               = Settings_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("AudioCustom") == true end,
                            children                 = {
                                {
                                    widgetName              = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_SOUND_ID"],
                                    widgetType              = Settings_Enum.WidgetType.Input,
                                    widgetInput_placeholder = L
                                        ["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"],
                                    key                     = "AudioCustomNewUserNavigation",
                                    set                     = function(_, value)
                                        if tonumber(value) then
                                            Config.DBGlobal:SetVariable("AudioCustomNewUserNavigation", tonumber(value))
                                        else
                                            Config.DBGlobal:SetVariable("AudioCustomNewUserNavigation", "")
                                        end
                                    end
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_PREVIEW"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Sound.PlaySound("Preview",
                                            Config.DBGlobal:GetVariable("AudioCustomNewUserNavigation"))
                                    end
                                },
                                {
                                    widgetType                  = Settings_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable(
                                            "AudioCustomNewUserNavigation")
                                    end
                                }
                            }
                        }
                    }
                }
            }
        },
        {
            widgetName = L["CONFIG_EXTENSIONS"],
            widgetType = Settings_Enum.WidgetType.Tab,
            children   = {
                {
                    widgetName = L["CONFIG_EXTENSIONS_PIN"],
                    widgetType = Settings_Enum.WidgetType.Container,

                    children   = {
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_PIN_AUTOTRACKPLACEDPIN"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_PIN_AUTOTRACKPLACEDPIN_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "AutoTrackPlacedPinEnabled"
                        },
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_PIN_AUTOTRACKCHATLINKPIN"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_PIN_AUTOTRACKCHATLINKPIN_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "AutoTrackChatLinkPinEnabled",
                            showWhen          = function() return Config.DBGlobal:GetVariable("AutoTrackPlacedPinEnabled") == false end,
                            indent            = 1
                        },
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_PIN_GUIDEPINASSISTANT"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_PIN_GUIDEPINASSISTANT_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "GuidePinAssistantEnabled"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_EXTENSIONS_TOMTOMSUPPORT"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return IsAddOnLoaded("TomTom") end,

                    children   = {
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_TOMTOMSUPPORT_ENABLE"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_TOMTOMSUPPORT_ENABLE_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "TomTomSupportEnabled"
                        },
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_TOMTOMSUPPORT_AUTOREPLACEWAYPOINT"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_TOMTOMSUPPORT_AUTOREPLACEWAYPOINT_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "TomTomAutoReplaceWaypoint",
                            showWhen          = function() return Config.DBGlobal:GetVariable("TomTomSupportEnabled") == true end,
                            indent            = 1
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_EXTENSIONS_DUGISSUPPORT"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return IsAddOnLoaded("DugisGuideViewerZ") end,

                    children   = {
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_DUGISSUPPORT_ENABLE"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_DUGISSUPPORT_ENABLE_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "DugisSupportEnabled"
                        },
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_DUGISSUPPORT_AUTOREPLACEWAYPOINT"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_DUGISSUPPORT_AUTOREPLACEWAYPOINT_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "DugisAutoReplaceWaypoint",
                            showWhen          = function() return Config.DBGlobal:GetVariable("DugisSupportEnabled") == true end,
                            indent            = 1
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_EXTENSIONS_APRSUPPORT"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return IsAddOnLoaded("APR") end,

                    children   = {
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_APRSUPPORT_ENABLE"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_APRSUPPORT_ENABLE_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "APRSupportEnabled"
                        },
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_APRSUPPORT_AUTOREPLACEWAYPOINT"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_APRSUPPORT_AUTOREPLACEWAYPOINT_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "APRAutoReplaceWaypoint",
                            showWhen          = function() return Config.DBGlobal:GetVariable("APRSupportEnabled") == true end,
                            indent            = 1
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_EXTENSIONS_SILVERDRAGONSUPPORT"],
                    widgetType = Settings_Enum.WidgetType.Container,
                    showWhen   = function() return IsAddOnLoaded("SilverDragon") end,

                    children   = {
                        {
                            widgetName        = L["CONFIG_EXTENSIONS_SILVERDRAGONSUPPORT_ENABLE"],
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONFIG_EXTENSIONS_SILVERDRAGONSUPPORT_ENABLE_DESCRIPTION"] },
                            widgetType        = Settings_Enum.WidgetType.CheckButton,
                            key               = "SilverDragonSupportEnabled"
                        }
                    }
                }
            }
        },
        {
            widgetName         = L["CONFIG_ABOUT"],
            widgetType         = Settings_Enum.WidgetType.Tab,
            widgetTab_isFooter = true,
            children           = {
                {
                    widgetName       = L["CONFIG_ABOUT"],
                    widgetType       = Settings_Enum.WidgetType.Title,
                    widgetTitle_info = Settings_Define.TitleInfo{ imagePath = env.LOGO_ALT, text = env.NAME, subtext = env.VERSION_STRING }
                },
                {
                    widgetName        = L["CONFIG_ABOUT_CONTRIBUTORS"],
                    widgetType        = Settings_Enum.WidgetType.Container,
                    widgetTransparent = true,
                    children          = {
                        {
                            widgetName        = L["CONTRIBUTORS_ZAMESTOTV"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_ZAMESTOTV_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_HUCHANG47"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_HUCHANG47_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_BLUENIGHTSKY"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_BLUENIGHTSKY_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_CRAZYYOUNGS"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_CRAZYYOUNGS_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_KLEP"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_KLEP_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_KROFFY"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_KROFFY_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_CATHTAIL"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_CATHTAIL_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_LARSJ02"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_LARSJ02_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_DABEAR78"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_DABEAR78_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_GOTZIKO"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_GOTZIKO_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_Y45853160"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_Y45853160_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_LEMIESZEK"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_LEMIESZEK_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_BADBOYBARNY"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_BADBOYBARNY_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_CHRISTINXA"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_CHRISTINXA_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_HECTORZAGA"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_HECTORZAGA_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_SYVERGISWOLD"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetDescription = Settings_Define.Descriptor{ description = L["CONTRIBUTORS_SYVERGISWOLD_DESCRIPTION"] },
                            widgetTransparent = true
                        }
                    }
                },
                {
                    widgetName        = L["CONFIG_ABOUT_DEVELOPER"],
                    widgetType        = Settings_Enum.WidgetType.Container,
                    widgetTransparent = true,
                    children          = {
                        {
                            widgetName        = L["CONFIG_ABOUT_DEVELOPER_ADAPTIVEX"],
                            widgetType        = Settings_Enum.WidgetType.Text,
                            widgetTransparent = true
                        }
                    }
                }
            }
        }
    }
end
