--[[
    widgetName:                         string
    widgetDecsription:                  Setting_Define.Descriptor
    widgetType:                         Setting_Enum.WidgetType
    widgetTransparent:                  boolean

    Shared:
        key:                            string
        set:                            function

    Tab:
        widgetTab_isFooter:             boolean

    Title:
        widgetTitle_info:               Setting_Define.TitleInfo

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

    Color Input:

    Input:
        widgetInput_placeholder:        string|function

    disableWhen:                        function
    showWhen:                           function
    indent:                             number
    children:                           table
]]


local env            = select(2, ...)
local Config         = env.Config
local L              = env.L

local IsAddOnLoaded  = C_AddOns.IsAddOnLoaded

local Path           = env.WPM:Import("wpm_modules/path")
local Sound          = env.WPM:Import("wpm_modules/sound")
local UIFont         = env.WPM:Import("wpm_modules/ui-font")
local LocalUtil      = env.WPM:Import("@/LocalUtil")
local Waypoint_Enum  = env.WPM:Import("@/Waypoint/Enum")
local Setting_Define = env.WPM:Import("@/Setting/Define")
local Setting_Enum   = env.WPM:Import("@/Setting/Enum")
local Setting_Shared = env.WPM:Import("@/Setting/Shared")
local Setting_Schema = env.WPM:New("@/Setting/Schema")


-- Shared
--------------------------------

local SETTING_PROMPT = _G[Setting_Shared.FRAME_NAME].Prompt


local function handleAccept()
    Config.DBGlobal:Wipe()
    ReloadUI()
end

local RESET_SETTING_PROMPT_INFO = {
    text         = L["Config - General - Other - ResetPrompt"],
    options      = {
        {
            text     = L["Config - General - Other - ResetPrompt - Yes"],
            callback = handleAccept
        },
        {
            text     = L["Config - General - Other - ResetPrompt - No"],
            callback = nil
        }
    },
    hideOnEscape = true,
    timeout      = 10
}


-- Schema
--------------------------------

local function alwaysTrue() return true end
local function alwaysFalse() return false end
local function calculateDistance(yds) return function() return LocalUtil:CalculateDistance(yds) end end
local function formatDistance(value) return LocalUtil:FormatDistance(value) end
local function formatPercentage(value) return string.format("%.0f", value * 100) .. "%" end
local function getIcon(name) return Path.Root .. "/Art/Setting/Icon/" .. name .. ".png" end


Setting_Schema.SCHEMA = {
    {
        widgetName = L["Config - General"],
        widgetType = Setting_Enum.WidgetType.Tab,
        children   = {
            {
                widgetName       = L["Config - General - Title"],
                widgetType       = Setting_Enum.WidgetType.Title,
                widgetTitle_info = Setting_Define.TitleInfo{ imagePath = getIcon("Cog"), text = L["Config - General - Title"], subtext = L["Config - General - Title - Subtext"] }
            },
            {
                widgetName = L["Config - General - Preferences"],
                widgetType = Setting_Enum.WidgetType.Container,
                children   = {
                    {
                        widgetName               = L["Config - General - Preferences - Font"],
                        widgetType               = Setting_Enum.WidgetType.SelectionMenu,
                        widgetSelectionMenu_data = function()
                            UIFont.CustomFont:RefreshFontList()
                            return UIFont.CustomFont:GetFontNames()
                        end,
                        key                      = "PrefFont"
                    },
                    {
                        widgetName        = L["Config - General - Preferences - Meter"],
                        widgetDescription = Setting_Define.Descriptor{ imageType = nil, imagePath = nil, description = L["Config - General - Preferences - Meter - Description"] },
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        key               = "PrefMetric"
                    }
                }
            },
            {
                widgetName = L["Config - General - Other"],
                widgetType = Setting_Enum.WidgetType.Container,
                children   = {
                    {
                        widgetName        = nil,
                        widgetType        = Setting_Enum.WidgetType.Button,
                        widgetButton_text = L["Config - General - Other - ResetButton"],
                        set               = function() SETTING_PROMPT:Open(RESET_SETTING_PROMPT_INFO) end
                    }
                }
            }
        }
    },
    {
        widgetName = L["Config - WaypointSystem"],
        widgetType = Setting_Enum.WidgetType.Tab,
        children   = {
            {
                widgetName       = L["Config - WaypointSystem - Title"],
                widgetType       = Setting_Enum.WidgetType.Title,
                widgetTitle_info = Setting_Define.TitleInfo{ imagePath = getIcon("Waypoint"), text = L["Config - WaypointSystem - Title"], subtext = L["Config - WaypointSystem - Title - Subtext"] }
            },
            {

                widgetType               = Setting_Enum.WidgetType.SelectionMenu,
                widgetTransparent        = true,
                widgetSelectionMenu_data = {
                    L["Config - WaypointSystem - Type - Both"],
                    L["Config - WaypointSystem - Type - Waypoint"],
                    L["Config - WaypointSystem - Type - Pinpoint"]
                },
                key                      = "WaypointSystemType"
            },
            {
                widgetName = L["Config - WaypointSystem - General"],
                widgetType = Setting_Enum.WidgetType.Container,
                children   = {
                    {
                        widgetName        = L["Config - WaypointSystem - General - AlwaysShow"],
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - WaypointSystem - General - AlwaysShow - Description"] },
                        key               = "AlwaysShow"
                    },
                    {
                        widgetName        = L["Config - WaypointSystem - General - RightClickToClear"],
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - WaypointSystem - General - RightClickToClear - Description"] },
                        key               = "RightClickToClear"
                    },
                    {
                        widgetName        = L["Config - WaypointSystem - General - BackgroundPreview"],
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - WaypointSystem - General - BackgroundPreview - Description"] },
                        key               = "BackgroundPreview"
                    },
                    {
                        widgetName                     = L["Config - WaypointSystem - General - Transition Distance"],
                        widgetDescription              = Setting_Define.Descriptor{ description = L["Config - WaypointSystem - General - Transition Distance - Description"] },
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        widgetRange_min                = calculateDistance(50),
                        widgetRange_max                = calculateDistance(500),
                        widgetRange_step               = calculateDistance(5),
                        widgetRange_textFormattingFunc = formatDistance,
                        key                            = "DistanceThresholdPinpoint",
                        showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All end
                    },
                    {
                        widgetName                     = L["Config - WaypointSystem - General - Hide Distance"],
                        widgetDescription              = Setting_Define.Descriptor{ description = L["Config - WaypointSystem - General - Hide Distance - Description"] },
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        widgetRange_min                = calculateDistance(1),
                        widgetRange_max                = calculateDistance(100),
                        widgetRange_step               = 1,
                        widgetRange_textFormattingFunc = formatDistance,
                        key                            = "DistanceThresholdHidden"
                    }
                }
            },
            {
                widgetName = L["Config - WaypointSystem - Waypoint"],
                widgetType = Setting_Enum.WidgetType.Container,
                showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Waypoint end,
                children   = {
                    {
                        widgetName               = L["Config - WaypointSystem - Waypoint - Footer - Type"],
                        widgetType               = Setting_Enum.WidgetType.SelectionMenu,
                        widgetSelectionMenu_data = {
                            L["Config - WaypointSystem - Waypoint - Footer - Type - Both"],
                            L["Config - WaypointSystem - Waypoint - Footer - Type - Distance"],
                            L["Config - WaypointSystem - Waypoint - Footer - Type - ArrivalTime"],
                            L["Config - WaypointSystem - Waypoint - Footer - Type - DestinationName"],
                            L["Config - WaypointSystem - Waypoint - Footer - Type - None"]
                        },
                        key                      = "WaypointDistanceTextType"
                    }
                }
            },
            {
                widgetName = L["Config - WaypointSystem - Pinpoint"],
                widgetType = Setting_Enum.WidgetType.Container,
                showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Pinpoint end,
                children   = {
                    {
                        widgetName = L["Config - WaypointSystem - Pinpoint - Info"],
                        widgetType = Setting_Enum.WidgetType.CheckButton,
                        key        = "PinpointInfo"
                    },
                    {
                        widgetName        = L["Config - WaypointSystem - Pinpoint - Info - Extended"],
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - WaypointSystem - Pinpoint - Info - Extended - Description"] },
                        indent            = 1,
                        key               = "PinpointInfoExtended",
                        showWhen          = function() return Config.DBGlobal:GetVariable("PinpointInfo") == true end
                    },
                    {
                        widgetName        = L["Config - WaypointSystem - Pinpoint - ShowInQuestArea"],
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - WaypointSystem - Pinpoint - ShowInQuestArea - Description"] },
                        key               = "PinpointAllowInQuestArea"
                    }
                }
            },
            {
                widgetName = L["Config - WaypointSystem - Navigator"],
                widgetType = Setting_Enum.WidgetType.Container,
                children   = {
                    {
                        widgetName        = L["Config - WaypointSystem - Navigator - Enable"],
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - WaypointSystem - Navigator - Enable - Description"] },
                        indent            = 0,
                        key               = "NavigatorShow"
                    }
                }
            }
        }
    },
    {
        widgetName = L["Config - Appearance"],
        widgetType = Setting_Enum.WidgetType.Tab,
        children   = {
            {
                widgetName       = L["Config - Appearance - Title"],
                widgetType       = Setting_Enum.WidgetType.Title,
                widgetTitle_info = Setting_Define.TitleInfo{ imagePath = getIcon("Brush"), text = L["Config - Appearance - Title"], subtext = L["Config - Appearance - Title - Subtext"] }
            },
            {
                widgetName = L["Config - Appearance - Waypoint"],
                widgetType = Setting_Enum.WidgetType.Container,
                showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Waypoint or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All end,
                children   = {
                    {
                        widgetName                     = L["Config - Appearance - Waypoint - Scale"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        widgetDescription              = Setting_Define.Descriptor{ description = L["Config - Appearance - Waypoint - Scale - Description"] },
                        widgetRange_min                = .5,
                        widgetRange_max                = 5,
                        widgetRange_step               = .1,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "WaypointScale"
                    },
                    {
                        widgetName                     = L["Config - Appearance - Waypoint - Scale - Min"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        widgetDescription              = Setting_Define.Descriptor{ description = L["Config - Appearance - Waypoint - Scale - Min - Description"] },
                        widgetRange_min                = .125,
                        widgetRange_max                = 1,
                        widgetRange_step               = .125,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "WaypointScaleMin",
                        indent                         = 1
                    },
                    {
                        widgetName                     = L["Config - Appearance - Waypoint - Scale - Max"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        widgetDescription              = Setting_Define.Descriptor{ description = L["Config - Appearance - Waypoint - Scale - Max - Description"] },
                        widgetRange_min                = 1,
                        widgetRange_max                = 2,
                        widgetRange_step               = .1,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "WaypointScaleMax",
                        indent                         = 1
                    },
                    {
                        widgetName = L["Config - Appearance - Waypoint - Beam"],
                        widgetType = Setting_Enum.WidgetType.CheckButton,
                        key        = "WaypointBeam"
                    },
                    {
                        widgetName                     = L["Config - Appearance - Waypoint - Beam - Alpha"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        showWhen                       = function()
                            return Config.DBGlobal:GetVariable("WaypointBeam") ==
                                true
                        end,
                        indent                         = 1,
                        widgetRange_min                = .1,
                        widgetRange_max                = 1,
                        widgetRange_step               = .1,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "WaypointBeamAlpha"
                    },
                    {
                        widgetName = L["Config - Appearance - Waypoint - Footer"],
                        widgetType = Setting_Enum.WidgetType.CheckButton,
                        key        = "WaypointDistanceText",
                        showWhen   = function() return Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end
                    },
                    {
                        widgetName                     = L["Config - Appearance - Waypoint - Footer - Scale"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointDistanceText") == true and Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end,
                        indent                         = 1,
                        widgetRange_min                = .1,
                        widgetRange_max                = 2,
                        widgetRange_step               = .1,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "WaypointDistanceTextScale"
                    },
                    {
                        widgetName                     = L["Config - Appearance - Waypoint - Footer - Alpha"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointDistanceText") == true and Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end,
                        indent                         = 1,
                        widgetRange_min                = 0,
                        widgetRange_max                = 1,
                        widgetRange_step               = .1,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "WaypointDistanceTextAlpha"
                    }
                }
            },
            {
                widgetName = L["Config - Appearance - Pinpoint"],
                widgetType = Setting_Enum.WidgetType.Container,
                showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Pinpoint or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All end,
                children   = {
                    {
                        widgetName                     = L["Config - Appearance - Pinpoint - Scale"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        widgetRange_min                = .5,
                        widgetRange_max                = 2,
                        widgetRange_step               = .1,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "PinpointScale",
                        indent                         = 0
                    }
                }
            },
            {
                widgetName = L["Config - Appearance - Navigator"],
                widgetType = Setting_Enum.WidgetType.Container,
                showWhen   = function() return Config.DBGlobal:GetVariable("NavigatorShow") == true end,
                children   = {
                    {
                        widgetName                     = L["Config - Appearance - Navigator - Scale"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        indent                         = 0,
                        widgetRange_min                = .5,
                        widgetRange_max                = 2,
                        widgetRange_step               = .1,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "NavigatorScale"
                    },
                    {
                        widgetName                     = L["Config - Appearance - Navigator - Alpha"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        widgetRange_min                = .1,
                        widgetRange_max                = 1,
                        widgetRange_step               = .1,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "NavigatorAlpha"
                    },
                    {
                        widgetName                     = L["Config - Appearance - Navigator - Distance"],
                        widgetType                     = Setting_Enum.WidgetType.Range,
                        widgetRange_min                = .1,
                        widgetRange_max                = 3,
                        widgetRange_step               = .1,
                        widgetRange_textFormattingFunc = formatPercentage,
                        key                            = "NavigatorDistance"
                    },
                    {
                        widgetName        = L["Config - Appearance - Navigator - DynamicDistance"],
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - Appearance - Navigator - DynamicDistance - Description"] },
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        key               = "NavigatorDynamicDistance"
                    }
                }
            },
            {
                widgetName = L["Config - Appearance - Color"],
                widgetType = Setting_Enum.WidgetType.Container,
                children   = {
                    {
                        widgetName = L["Config - Appearance - Color - CustomColor"],
                        widgetType = Setting_Enum.WidgetType.CheckButton,
                        key        = "CustomColor"
                    },
                    {
                        widgetName               = L
                            ["Config - Appearance - Color - CustomColor - Quest - Complete - Default"],
                        widgetType               = Setting_Enum.WidgetType.Container,
                        widgetContainer_isNested = true,
                        showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                        children                 = {
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - Color"],
                                widgetType = Setting_Enum.WidgetType.ColorInput,
                                key        = "CustomColorQuestComplete"
                            },
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - TintIcon"],
                                widgetType = Setting_Enum.WidgetType.CheckButton,
                                key        = "CustomColorQuestCompleteTint",
                                indent     = 1
                            },
                            {
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Appearance - Color - CustomColor - Reset"],
                                widgetButton_refreshOnClick = true,
                                set                         = function()
                                    Config.DBGlobal:ResetVariable("CustomColorQuestComplete")
                                    Config.DBGlobal:ResetVariable("CustomColorQuestCompleteTint")
                                end
                            }
                        }
                    },
                    {
                        widgetName               = L
                            ["Config - Appearance - Color - CustomColor - Quest - Complete - Repeatable"],
                        widgetType               = Setting_Enum.WidgetType.Container,
                        widgetContainer_isNested = true,
                        showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                        children                 = {
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - Color"],
                                widgetType = Setting_Enum.WidgetType.ColorInput,
                                key        = "CustomColorQuestCompleteRepeatable"
                            },
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - TintIcon"],
                                widgetType = Setting_Enum.WidgetType.CheckButton,
                                key        = "CustomColorQuestCompleteRepeatableTint",
                                indent     = 1
                            },
                            {
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Appearance - Color - CustomColor - Reset"],
                                widgetButton_refreshOnClick = true,
                                set                         = function()
                                    Config.DBGlobal:ResetVariable("CustomColorQuestCompleteRepeatable")
                                    Config.DBGlobal:ResetVariable("CustomColorQuestCompleteRepeatableTint")
                                end
                            }
                        }
                    },
                    {
                        widgetName               = L
                            ["Config - Appearance - Color - CustomColor - Quest - Complete - Important"],
                        widgetType               = Setting_Enum.WidgetType.Container,
                        widgetContainer_isNested = true,
                        showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                        children                 = {
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - Color"],
                                widgetType = Setting_Enum.WidgetType.ColorInput,
                                key        = "CustomColorQuestCompleteImportant"
                            },
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - TintIcon"],
                                widgetType = Setting_Enum.WidgetType.CheckButton,
                                key        = "CustomColorQuestCompleteImportantTint",
                                indent     = 1
                            },
                            {
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Appearance - Color - CustomColor - Reset"],
                                widgetButton_refreshOnClick = true,
                                set                         = function()
                                    Config.DBGlobal:ResetVariable("CustomColorQuestCompleteImportant")
                                    Config.DBGlobal:ResetVariable("CustomColorQuestCompleteImportantTint")
                                end
                            }
                        }
                    },
                    {
                        widgetName               = L["Config - Appearance - Color - CustomColor - Quest - Incomplete"],
                        widgetType               = Setting_Enum.WidgetType.Container,
                        widgetContainer_isNested = true,
                        showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                        children                 = {
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - Color"],
                                widgetType = Setting_Enum.WidgetType.ColorInput,
                                key        = "CustomColorQuestIncomplete"
                            },
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - TintIcon"],
                                widgetType = Setting_Enum.WidgetType.CheckButton,
                                key        = "CustomColorQuestIncompleteTint",
                                indent     = 1
                            },
                            {
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Appearance - Color - CustomColor - Reset"],
                                widgetButton_refreshOnClick = true,
                                set                         = function()
                                    Config.DBGlobal:ResetVariable("CustomColorQuestIncomplete")
                                    Config.DBGlobal:ResetVariable("CustomColorQuestIncompleteTint")
                                end
                            }
                        }
                    },
                    {
                        widgetName               = L["Config - Appearance - Color - CustomColor - Other"],
                        widgetType               = Setting_Enum.WidgetType.Container,
                        widgetContainer_isNested = true,
                        showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                        children                 = {
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - Color"],
                                widgetType = Setting_Enum.WidgetType.ColorInput,
                                key        = "CustomColorOther"
                            },
                            {
                                widgetName = L["Config - Appearance - Color - CustomColor - TintIcon"],
                                widgetType = Setting_Enum.WidgetType.CheckButton,
                                key        = "CustomColorOtherTint",
                                indent     = 1
                            },
                            {
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Appearance - Color - CustomColor - Reset"],
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
        widgetName = L["Config - Audio"],
        widgetType = Setting_Enum.WidgetType.Tab,
        children   = {
            {
                widgetName       = L["Config - Audio - Title"],
                widgetType       = Setting_Enum.WidgetType.Title,
                widgetTitle_info = Setting_Define.TitleInfo{ imagePath = getIcon("SpeakerOn"), text = L["Config - Audio - Title"], subtext = L["Config - Audio - Title - Subtext"] }
            },
            {
                widgetName = L["Config - Audio - General"],
                widgetType = Setting_Enum.WidgetType.Container,

                children   = {
                    {
                        widgetName = L["Config - Audio - General - EnableGlobalAudio"],
                        widgetType = Setting_Enum.WidgetType.CheckButton,
                        key        = "AudioGlobal"
                    }
                }
            },
            {
                widgetName = L["Config - Audio - Customize"],
                widgetType = Setting_Enum.WidgetType.Container,
                showWhen   = function() return Config.DBGlobal:GetVariable("AudioGlobal") == true end,
                children   = {
                    {
                        widgetName = L["Config - Audio - Customize - UseCustomAudio"],
                        widgetType = Setting_Enum.WidgetType.CheckButton,
                        key        = "AudioCustom"
                    },
                    {
                        widgetName               = L["Config - Audio - Customize - UseCustomAudio - WaypointShow"],
                        widgetType               = Setting_Enum.WidgetType.Container,
                        widgetContainer_isNested = true,
                        showWhen                 = function() return Config.DBGlobal:GetVariable("AudioCustom") == true end,
                        children                 = {
                            {
                                widgetName              = L["Config - Audio - Customize - UseCustomAudio - Sound ID"],
                                widgetType              = Setting_Enum.WidgetType.Input,
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
                                widgetType        = Setting_Enum.WidgetType.Button,
                                widgetButton_text = L["Config - Audio - Customize - UseCustomAudio - Preview"],
                                set               = function()
                                    Sound.PlaySound("Preview",
                                                    Config.DBGlobal:GetVariable("AudioCustomShowWaypoint"))
                                end
                            },
                            {
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Audio - Customize - UseCustomAudio - Reset"],
                                widgetButton_refreshOnClick = true,
                                set                         = function()
                                    Config.DBGlobal:ResetVariable(
                                        "AudioCustomShowWaypoint")
                                end
                            }
                        }
                    },
                    {
                        widgetName               = L["Config - Audio - Customize - UseCustomAudio - PinpointShow"],
                        widgetType               = Setting_Enum.WidgetType.Container,
                        widgetContainer_isNested = true,
                        showWhen                 = function() return Config.DBGlobal:GetVariable("AudioCustom") == true end,
                        children                 = {
                            {
                                widgetName              = L["Config - Audio - Customize - UseCustomAudio - Sound ID"],
                                widgetType              = Setting_Enum.WidgetType.Input,
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
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Audio - Customize - UseCustomAudio - Preview"],
                                widgetButton_refreshOnClick = true,
                                set                         = function()
                                    Sound.PlaySound("Preview",
                                                    Config.DBGlobal:GetVariable("AudioCustomShowPinpoint"))
                                end
                            },
                            {
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Audio - Customize - UseCustomAudio - Reset"],
                                widgetButton_refreshOnClick = true,
                                set                         = function()
                                    Config.DBGlobal:ResetVariable(
                                        "AudioCustomShowPinpoint")
                                end
                            }
                        }
                    },
                    {
                        widgetName               = L["Config - Audio - Customize - UseCustomAudio - NewUserNavigation"],
                        widgetType               = Setting_Enum.WidgetType.Container,
                        widgetContainer_isNested = true,
                        showWhen                 = function() return Config.DBGlobal:GetVariable("AudioCustom") == true end,
                        children                 = {
                            {
                                widgetName              = L["Config - Audio - Customize - UseCustomAudio - Sound ID"],
                                widgetType              = Setting_Enum.WidgetType.Input,
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
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Audio - Customize - UseCustomAudio - Preview"],
                                widgetButton_refreshOnClick = true,
                                set                         = function()
                                    Sound.PlaySound("Preview",
                                                    Config.DBGlobal:GetVariable("AudioCustomNewUserNavigation"))
                                end
                            },
                            {
                                widgetType                  = Setting_Enum.WidgetType.Button,
                                widgetButton_text           = L["Config - Audio - Customize - UseCustomAudio - Reset"],
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
        widgetName = L["Config - ExtraFeature"],
        widgetType = Setting_Enum.WidgetType.Tab,
        children   = {
            {
                widgetName       = L["Config - ExtraFeature - Title"],
                widgetType       = Setting_Enum.WidgetType.Title,
                widgetTitle_info = Setting_Define.TitleInfo{ imagePath = getIcon("List"), text = L["Config - ExtraFeature - Title"], subtext = L["Config - ExtraFeature - Title - Subtext"] }
            },
            {
                widgetName = L["Config - ExtraFeature - Pin"],
                widgetType = Setting_Enum.WidgetType.Container,

                children   = {
                    {
                        widgetName        = L["Config - ExtraFeature - Pin - AutoTrackPlacedPin"],
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - ExtraFeature - Pin - AutoTrackPlacedPin - Description"] },
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        key               = "AutoTrackPlacedPinEnabled"
                    },
                    {
                        widgetName        = L["Config - ExtraFeature - Pin - AutoTrackChatLinkPin"],
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - ExtraFeature - Pin - AutoTrackChatLinkPin - Description"] },
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        key               = "AutoTrackChatLinkPinEnabled",
                        showWhen          = function() return Config.DBGlobal:GetVariable("AutoTrackPlacedPinEnabled") == false end,
                        indent            = 1
                    },
                    {
                        widgetName        = L["Config - ExtraFeature - Pin - GuidePinAssistant"],
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - ExtraFeature - Pin - GuidePinAssistant - Description"] },
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        key               = "GuidePinAssistantEnabled"
                    }
                }
            },
            {
                widgetName = L["Config - ExtraFeature - TomTomSupport"],
                widgetType = Setting_Enum.WidgetType.Container,
                showWhen   = function() return IsAddOnLoaded("TomTom") end,

                children   = {
                    {
                        widgetName        = L["Config - ExtraFeature - TomTomSupport - Enable"],
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - ExtraFeature - TomTomSupport - Enable - Description"] },
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        key               = "TomTomSupportEnabled"
                    },
                    {
                        widgetName        = L["Config - ExtraFeature - TomTomSupport - AutoReplaceWaypoint"],
                        widgetDescription = Setting_Define.Descriptor{ description = L["Config - ExtraFeature - TomTomSupport - AutoReplaceWaypoint - Description"] },
                        widgetType        = Setting_Enum.WidgetType.CheckButton,
                        key               = "TomTomAutoReplaceWaypoint",
                        showWhen          = function() return Config.DBGlobal:GetVariable("TomTomSupportEnabled") == true end,
                        indent            = 1
                    }
                }
            }
        }
    },
    {
        widgetName         = L["Config - About"],
        widgetType         = Setting_Enum.WidgetType.Tab,
        widgetTab_isFooter = true,
        children           = {
            {
                widgetName       = L["Config - About"],
                widgetType       = Setting_Enum.WidgetType.Title,
                widgetTitle_info = Setting_Define.TitleInfo{ imagePath = env.ICON_ALT, text = env.NAME, subtext = env.VERSION_STRING }
            },
            {
                widgetName        = L["Config - About - Contributors"],
                widgetType        = Setting_Enum.WidgetType.Container,
                widgetTransparent = true,
                children          = {
                    {
                        widgetName        = L["Contributors - ZamestoTV"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - ZamestoTV - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - huchang47"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - huchang47 - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - BlueNightSky"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - BlueNightSky - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - Crazyyoungs"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - Crazyyoungs - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - Klep"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - Klep - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - Kroffy"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - Kroffy - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - cathtail"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - cathtail - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - Larsj02"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - Larsj02 - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - dabear78"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - dabear78 - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - Gotziko"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - Gotziko - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - y45853160"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - y45853160 - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - lemieszek"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - lemieszek - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - BadBoyBarny"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - BadBoyBarny - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - Christinxa"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - Christinxa - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - HectorZaGa"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - HectorZaGa - Description"] },
                        widgetTransparent = true
                    },
                    {
                        widgetName        = L["Contributors - SyverGiswold"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetDescription = Setting_Define.Descriptor{ description = L["Contributors - SyverGiswold - Description"] },
                        widgetTransparent = true
                    }
                }
            },
            {
                widgetName        = L["Config - About - Developer"],
                widgetType        = Setting_Enum.WidgetType.Container,
                widgetTransparent = true,
                children          = {
                    {
                        widgetName        = L["Config - About - Developer - AdaptiveX"],
                        widgetType        = Setting_Enum.WidgetType.Text,
                        widgetTransparent = true
                    }
                }
            }
        }
    }
}
