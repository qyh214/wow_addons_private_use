local env              = select(2, ...)

local IsAddOnLoaded    = C_AddOns.IsAddOnLoaded

local Sound            = env.WPM:Import("wpm_modules/sound")
local CallbackRegistry = env.WPM:Import("wpm_modules/callback-registry")
local UIFont           = env.WPM:Import("wpm_modules/ui-font")
local CVarUtil         = env.WPM:Import("wpm_modules/cvar-util")
local SavedVariables   = env.WPM:Import("wpm_modules/saved-variables")
local SlashCommand     = env.WPM:Import("wpm_modules/slash-command")
local Path             = env.WPM:Import("wpm_modules/path")
local Utils_InlineIcon = env.WPM:Import("wpm_modules/utils/inlineIcon")
local GenericEnum      = env.WPM:Import("wpm_modules/generic-enum")
local Support_TomTom   = env.WPM:Await("@/Support/TomTom")


env.NAME           = "Waypoint UI"
env.ICON           = Path.Root .. "/Art/Icon/Icon.png"
env.ICON_ALT       = Path.Root .. "/Art/Icon/IconAltLight.png"
env.VERSION_STRING = "1.2.3"
env.VERSION_NUMBER = 010203
env.DEBUG_MODE     = false


local L = {}; env.L = L -- Locales


local Enum = {}; env.Enum = Enum -- Add-on specific enum
do
    Enum.ColorRGB = {
        Other           = { r = 255 / 255, g = 241 / 255, b = 180 / 255 },
        QuestNormal     = { r = 255 / 255, g = 255 / 255, b = 156 / 255 },
        QuestRepeatable = { r = 158 / 255, g = 207 / 255, b = 245 / 255 },
        QuestImportant  = { r = 249 / 255, g = 196 / 255, b = 255 / 255 },
        QuestIncomplete = { r = 200 / 255, g = 200 / 255, b = 200 / 255 }
    }

    Enum.ColorHEX = {
        Other           = "|cffFFF1B4",
        QuestNormal     = "|cffFFEC9C",
        QuestRepeatable = "|cff9ECFF5",
        QuestImportant  = "|cffF9C4FF",
        QuestIncomplete = "|cffE1E1E1"
    }

    Enum.Sound = {
        WaypointShow      = SOUNDKIT.UI_RUNECARVING_OPEN_MAIN_WINDOW,
        PinpointShow      = SOUNDKIT.UI_RUNECARVING_CLOSE_MAIN_WINDOW,
        NewUserNavigation = 89712
    }
end


local Config = {}; env.Config = Config -- Configuration / Database
do
    Config.DBGlobal                      = nil
    Config.DBGlobalPersistent            = nil
    Config.DBLocal                       = nil
    Config.DBLocalPersistent             = nil

    local NAME_GLOBAL                    = "WaypointDB_Global"
    local NAME_GLOBAL_PERSISTENT         = "WaypointDB_Global_Persistent"
    local NAME_LOCAL                     = "WaypointDB_Local"
    local NAME_LOCAL_PERSISTENT          = "WaypointDB_Local_Persistent"

    local DB_GLOBAL_DEFAULTS             = {
        -- Cache
        lastLoadedVersion                      = nil,

        WaypointSystemType                     = 1,
        DistanceThresholdPinpoint              = 325,
        DistanceThresholdHidden                = 25,
        AlwaysShow                             = false,
        RightClickToClear                      = true,
        BackgroundPreview                      = true,
        PrefFont                               = 1,
        PrefMetric                             = false,
        WaypointScale                          = 1,
        WaypointScaleMin                       = .25,
        WaypointScaleMax                       = 1.5,
        WaypointBeam                           = true,
        WaypointBeamAlpha                      = 1,
        WaypointDistanceText                   = true,
        WaypointDistanceTextType               = 1,
        WaypointDistanceTextScale              = 1,
        WaypointDistanceTextAlpha              = .7,
        PinpointAllowInQuestArea               = false,
        PinpointScale                          = 1,
        PinpointInfo                           = true,
        PinpointInfoExtended                   = true,
        NavigatorShow                          = true,
        NavigatorScale                         = 1,
        NavigatorAlpha                         = 1,
        NavigatorDistance                      = 1,
        NavigatorDynamicDistance               = true,
        CustomColor                            = false,
        CustomColorQuestIncomplete             = { r = Enum.ColorRGB.QuestIncomplete.r, g = Enum.ColorRGB.QuestIncomplete.g, b = Enum.ColorRGB.QuestIncomplete.b, a = 1 },
        CustomColorQuestIncompleteTint         = false,
        CustomColorQuestComplete               = { r = Enum.ColorRGB.QuestNormal.r, g = Enum.ColorRGB.QuestNormal.g, b = Enum.ColorRGB.QuestNormal.b, a = 1 },
        CustomColorQuestCompleteTint           = false,
        CustomColorQuestCompleteRepeatable     = { r = Enum.ColorRGB.QuestRepeatable.r, g = Enum.ColorRGB.QuestRepeatable.g, b = Enum.ColorRGB.QuestRepeatable.b, a = 1 },
        CustomColorQuestCompleteRepeatableTint = false,
        CustomColorQuestCompleteImportant      = { r = Enum.ColorRGB.QuestImportant.r, g = Enum.ColorRGB.QuestImportant.g, b = Enum.ColorRGB.QuestImportant.b, a = 1 },
        CustomColorQuestCompleteImportantTint  = false,
        CustomColorOther                       = { r = Enum.ColorRGB.Other.r, g = Enum.ColorRGB.Other.g, b = Enum.ColorRGB.Other.b, a = 1 },
        CustomColorOtherTint                   = false,
        AudioGlobal                            = true,
        AudioCustom                            = false,
        AudioCustomShowWaypoint                = Enum.Sound.WaypointShow,
        AudioCustomShowPinpoint                = Enum.Sound.PinpointShow,
        AudioCustomNewUserNavigation           = Enum.Sound.NewUserNavigation,

        AutoTrackPlacedPinEnabled              = true,
        AutoTrackChatLinkPinEnabled            = true,
        GuidePinAssistantEnabled               = true,
        TomTomSupportEnabled                   = true,
        TomTomAutoReplaceWaypoint              = true
    }
    local DB_GLOBAL_PERSISTENT_DEFAULTS  = {}
    local DB_LOCAL_DEFAULTS              = {
        slashWayCache = nil
    }
    local DB_LOCAL_PERSISTENT_DEFAULTS   = {}

    local DB_GLOBAL_MIGRATION            = {
        -- < 1.0.0
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "WS_TYPE" },
            to            = "WaypointSystemType"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "WS_RIGHT_CLICK_TO_CLEAR" },
            to            = "RightClickToClear"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "WS_BACKGROUND_PREVIEW" },
            to            = "BackgroundPreview"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "WS_DISTANCE_TRANSITION" },
            to            = "DistanceThresholdPinpoint"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "WS_DISTANCE_HIDE" },
            to            = "DistanceThresholdHidden"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "WS_DISTANCE_TEXT_TYPE" },
            to            = "WaypointDistanceTextType"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "WS_PINPOINT_INFO" },
            to            = "PinpointInfo"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "WS_PINPOINT_INFO_EXTENDED" },
            to            = "PinpointInfoExtended"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "WS_NAVIGATOR" },
            to            = "NavigatorShow"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_WAYPOINT_SCALE" },
            to            = "WaypointScale"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_WAYPOINT_SCALE_MIN" },
            to            = "WaypointScaleMin"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_WAYPOINT_SCALE_MAX" },
            to            = "WaypointScaleMax"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_WAYPOINT_BEAM" },
            to            = "WaypointBeam"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_WAYPOINT_BEAM_ALPHA" },
            to            = "WaypointBeamAlpha"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_WAYPOINT_DISTANCE_TEXT" },
            to            = "WaypointDistanceText"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_WAYPOINT_DISTANCE_TEXT_SCALE" },
            to            = "WaypointDistanceTextScale"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_WAYPOINT_DISTANCE_TEXT_ALPHA" },
            to            = "WaypointDistanceTextAlpha"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_PINPOINT_SCALE" },
            to            = "PinpointScale"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_NAVIGATOR_SCALE" },
            to            = "NavigatorScale"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_NAVIGATOR_ALPHA" },
            to            = "NavigatorAlpha"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_NAVIGATOR_DISTANCE" },
            to            = "NavigatorDistance"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR" },
            to            = "CustomColor"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_QUEST_INCOMPLETE_TINT" },
            to            = "CustomColorQuestIncompleteTint"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_QUEST_INCOMPLETE" },
            to            = "CustomColorQuestIncomplete"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_QUEST_COMPLETE_TINT" },
            to            = "CustomColorQuestCompleteTint"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_QUEST_COMPLETE" },
            to            = "CustomColorQuestComplete"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_QUEST_COMPLETE_REPEATABLE_TINT" },
            to            = "CustomColorQuestCompleteRepeatableTint"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_QUEST_COMPLETE_REPEATABLE" },
            to            = "CustomColorQuestCompleteRepeatable"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_QUEST_COMPLETE_IMPORTANT_TINT" },
            to            = "CustomColorQuestCompleteImportantTint"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_QUEST_COMPLETE_IMPORTANT" },
            to            = "CustomColorQuestCompleteImportant"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_NEUTRAL_TINT" },
            to            = "CustomColorOtherTint"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "APP_COLOR_NEUTRAL" },
            to            = "CustomColorOther"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "AUDIO_GLOBAL" },
            to            = "AudioGlobal"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "AUDIO_CUSTOM" },
            to            = "AudioCustom"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "AUDIO_CUSTOM_WAYPOINT_SHOW" },
            to            = "AudioCustomShowWaypoint"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "AUDIO_CUSTOM_PINPOINT_SHOW" },
            to            = "AudioCustomShowPinpoint"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "AUDIO_CUSTOM_NEW_USER_NAVIGATION" },
            to            = "AudioCustomNewUserNavigation"
        },
        {
            migrationType = "variable",
            from          = { "profiles", "Default", "PREF_METRIC" },
            to            = "PrefMetric"
        },
        {
            migrationType = "delete",
            to            = "profiles"
        },
        {
            migrationType = "delete",
            to            = "profileKeys"
        }
    }
    local DB_GLOBAL_PERSISTENT_MIGRATION = {
        {
            migrationType = "delete",
            to            = "profileKeys"
        }
    }

    function Config.LoadDB()
        if WaypointDB_Global and WaypointDB_Global.lastLoadedVersion == env.VERSION_NUMBER then
            -- Same version, skip migration
            SavedVariables.RegisterDatabase(NAME_GLOBAL).defaults(DB_GLOBAL_DEFAULTS)
            SavedVariables.RegisterDatabase(NAME_GLOBAL_PERSISTENT).defaults(DB_GLOBAL_PERSISTENT_DEFAULTS)
        else
            -- Migrate if new version
            SavedVariables.RegisterDatabase(NAME_GLOBAL).defaults(DB_GLOBAL_DEFAULTS).migrationPlan(DB_GLOBAL_MIGRATION)
            SavedVariables.RegisterDatabase(NAME_GLOBAL_PERSISTENT).defaults(DB_GLOBAL_PERSISTENT_DEFAULTS)
                .migrationPlan(DB_GLOBAL_PERSISTENT_MIGRATION)
        end

        SavedVariables.RegisterDatabase(NAME_LOCAL).defaults(DB_LOCAL_DEFAULTS)
        SavedVariables.RegisterDatabase(NAME_LOCAL_PERSISTENT).defaults(DB_LOCAL_PERSISTENT_DEFAULTS)

        Config.DBGlobal = SavedVariables.GetDatabase(NAME_GLOBAL)
        Config.DBGlobalPersistent = SavedVariables.GetDatabase(NAME_GLOBAL_PERSISTENT)
        Config.DBLocal = SavedVariables.GetDatabase(NAME_LOCAL)
        Config.DBLocalPersistent = SavedVariables.GetDatabase(NAME_LOCAL_PERSISTENT)

        CallbackRegistry:Trigger("Preload.DatabaseReady")
    end
end


local SlashCmdRegister = {}
do -- Slash Command
    -- /way
    --------------------------------

    local GetBestMapForUnit    = C_Map.GetBestMapForUnit
    local GetPlayerMapPosition = C_Map.GetPlayerMapPosition

    local INLINE_ADDON_ICON    = Utils_InlineIcon.InlineIcon(env.ICON_ALT, 16, 16)
    local PATH_CHAT_DIVIDER    = Utils_InlineIcon.InlineIcon(Path.Root .. "/Art/Chat/Subdivider.png", 16, 16)

    local INVALID_WAY_MSG_1    = INLINE_ADDON_ICON ..
        " /way " .. GenericEnum.ColorHEX.Yellow .. "#<mapID> <x> <y> <name>" .. "|r"
    local INVALID_WAY_MSG_2    = PATH_CHAT_DIVIDER .. " /way " .. GenericEnum.ColorHEX.Yellow .. "<x> <y> <name>" .. "|r"
    local INVALID_WAY_MSG_3    = PATH_CHAT_DIVIDER .. " /way " .. GenericEnum.ColorHEX.Yellow .. "reset" .. "|r"


    local function printPosition()
        local playerMapID = GetBestMapForUnit("player")
        local playerPosition = playerMapID and GetPlayerMapPosition(playerMapID, "player") or nil

        local message1 =
            (playerMapID and
                PATH_CHAT_DIVIDER .. " " ..
                L["SlashCommand - /way - Map ID - Prefix"] .. playerMapID .. L["SlashCommand - /way - Map ID - Suffix"])
            or ""
        local message2 =
            (playerPosition and
                PATH_CHAT_DIVIDER .. " " ..
                L["SlashCommand - /way - Position - Axis (X) - Prefix"] .. math.ceil(playerPosition.x * 100) .. L["SlashCommand - /way - Position - Axis (X) - Suffix"] ..
                L["SlashCommand - /way - Position - Axis (Y) - Prefix"] .. math.ceil(playerPosition.y * 100) .. L["SlashCommand - /way - Position - Axis (Y) - Suffix"])
            or ""

        DEFAULT_CHAT_FRAME:AddMessage(message1)
        DEFAULT_CHAT_FRAME:AddMessage(message2)
    end

    local function throwSlashWayError()
        DEFAULT_CHAT_FRAME:AddMessage(INVALID_WAY_MSG_1)
        DEFAULT_CHAT_FRAME:AddMessage(INVALID_WAY_MSG_2)
        DEFAULT_CHAT_FRAME:AddMessage(INVALID_WAY_MSG_3)

        printPosition()
    end

    -- locale-aware decimal separator normalization (e.g. "50,5" -> "50.5" or vice versa)
    local localeUsesDecimalPoint = tonumber("1.1") ~= nil
    local invalidDecimalPattern = "(%d)" .. (localeUsesDecimalPoint and "," or ".") .. "(%d)"
    local validDecimalReplacement = "%1" .. (localeUsesDecimalPoint and "." or ",") .. "%2"
    local tokens = {}

    local function handleSlashCmd_Way(inputMessage)
        if IsAddOnLoaded("TomTom") then
            Support_TomTom.PlaceWaypointAtSession()
            return
        end
        if not inputMessage or inputMessage == "" then return throwSlashWayError() end

        -- normalize input: separate comma-joined coords and fix decimal separators
        local normalizedInput = inputMessage:gsub("(%d)[%.,] (%d)", "%1 %2"):gsub(invalidDecimalPattern,
                                                                                  validDecimalReplacement)

        wipe(tokens)
        for word in normalizedInput:gmatch("%S+") do tokens[#tokens + 1] = word end
        if #tokens == 0 then return throwSlashWayError() end

        -- handle reset/clear commands
        local commandLower = tokens[1]:lower()
        if commandLower == "reset" or commandLower == "clear" then
            return WaypointUIAPI.Navigation.ClearUserNavigation()
        end

        -- helper: safely convert token at index to number
        local function parseTokenAsNumber(index)
            return tokens[index] and tonumber(tokens[index])
        end

        local zoneMapId, coordX, coordY, labelName = nil, nil, nil, nil
        local firstToken = tokens[1]
        local tokenCount = #tokens

        -- format: #<mapID> <x> <y> [name]
        if firstToken:sub(1, 1) == "#" then
            zoneMapId = tonumber(firstToken:sub(2))
            coordX, coordY = parseTokenAsNumber(2), parseTokenAsNumber(3)
            if not (zoneMapId and coordX and coordY) then return throwSlashWayError() end
            if tokenCount > 3 then labelName = table.concat(tokens, " ", 4) end

            -- format: <x> <y> [name] OR <mapID> <x> <y> [name]
        elseif tonumber(firstToken) then
            local num1, num2, num3 = tonumber(firstToken), parseTokenAsNumber(2), parseTokenAsNumber(3)
            if not (num1 and num2) then return throwSlashWayError() end

            if num3 then
                zoneMapId, coordX, coordY = num1, num2, num3
                if tokenCount > 3 then labelName = table.concat(tokens, " ", 4) end
            else
                zoneMapId, coordX, coordY = GetBestMapForUnit("player"), num1, num2
                if tokenCount > 2 then labelName = table.concat(tokens, " ", 3) end
            end

            -- format: <name> <x> <y> (name prefix before coordinates)
        else
            local coordStartIndex = nil
            for i = 1, tokenCount do
                if tonumber(tokens[i]) then
                    coordStartIndex = i; break
                end
            end
            if not coordStartIndex then return throwSlashWayError() end

            coordX, coordY = parseTokenAsNumber(coordStartIndex), parseTokenAsNumber(coordStartIndex + 1)
            if not (coordX and coordY) then return throwSlashWayError() end

            zoneMapId = GetBestMapForUnit("player")
            labelName = coordStartIndex > 1 and table.concat(tokens, " ", 1, coordStartIndex - 1) or nil
        end

        if not (zoneMapId and coordX and coordY) then return throwSlashWayError() end
        WaypointUIAPI.Navigation.NewUserNavigation(labelName, zoneMapId, coordX, coordY)
    end


    -- /waypoint /wp
    --------------------------------

    local function handleSlashCmd_Waypoint(msg, tokens)
        if #tokens >= 1 then
            local firstToken = tokens[1]:lower()

            if firstToken == "reset" or firstToken == "clear" or firstToken == "r" or firstToken == "c" then
                WaypointUIAPI.Navigation.ClearDestination()
            end
        end
    end


    -- Load
    --------------------------------

    local Schema = {
        -- /way
        {
            name     = "WAYPOINT_UI_WAY",
            hook     = "TOMTOM_WAY",
            command  = "way",
            callback = handleSlashCmd_Way
        },
        -- /waypoint /wp
        {
            name     = "WAYPOINT_UI",
            hook     = nil,
            command  = { "waypoint", "wp" },
            callback = handleSlashCmd_Waypoint
        }
    }

    function SlashCmdRegister.LoadSchema()
        SlashCommand.AddFromSchema(Schema)
    end
end


local SoundHandler = {}
do -- Sound Handler
    local function updateMainSoundLayer()
        local Setting_AudioGlobal = Config.DBGlobal:GetVariable("AudioGlobal")

        if Setting_AudioGlobal == true then
            Sound.SetEnabled("Main", true)
        elseif Setting_AudioGlobal == false then
            Sound.SetEnabled("Main", false)
        end
    end

    SavedVariables.OnChange("WaypointDB_Global", "AudioGlobal", updateMainSoundLayer)

    function SoundHandler.Load()
        updateMainSoundLayer()
    end
end


local FontHandler = {}
do -- Font Handler
    local function updateFonts()
        UIFont.CustomFont:RefreshFontList()

        local selectedFontIndex = Config.DBGlobal:GetVariable("PrefFont")
        local fontPath = UIFont.CustomFont.GetFontPathForIndex(selectedFontIndex)

        UIFont.UIFontObjectNormal8:SetFontFile(fontPath)
        UIFont.UIFontObjectNormal10:SetFontFile(fontPath)
        UIFont.UIFontObjectNormal12:SetFontFile(fontPath)
        UIFont.UIFontObjectNormal14:SetFontFile(fontPath)
        UIFont.UIFontObjectNormal16:SetFontFile(fontPath)
        UIFont.UIFontObjectNormal18:SetFontFile(fontPath)
    end

    SavedVariables.OnChange("WaypointDB_Global", "PrefFont", updateFonts)

    function FontHandler.Load()
        updateFonts()
    end
end


local function OnAddonLoaded()
    Config.LoadDB()
    SlashCmdRegister.LoadSchema()
    SoundHandler.Load()
    C_Timer.After(0, FontHandler.Load)

    CVarUtil.SetCVar("showInGameNavigation", true, CVarUtil.Enum.TemporaryType.UntilLogout)
    Config.DBGlobal:SetVariable("lastLoadedVersion", env.VERSION_NUMBER)
    CallbackRegistry:Trigger("Preload.AddonReady")
end

CallbackRegistry:Add("WoWClient.OnAddonLoaded", OnAddonLoaded)
