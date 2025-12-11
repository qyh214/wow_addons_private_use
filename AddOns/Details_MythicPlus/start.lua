
local Details = Details
local detailsFramework = DetailsFramework
local _

local CONST_MAX_LOGLINES = 100

---@type string, private
local tocFileName, private = ...

--localization
local L = detailsFramework.Language.GetLanguageTable(tocFileName)

---@type profile
local defaultSettings = {
    run_id = 0, --not in use
    when_to_automatically_open_scoreboard = "LOOT_CLOSED",
    delay_to_open_mythic_plus_breakdown_big_frame = 3,
    show_column_summary_in_tooltip = true,
    show_interrupt_tooltip_percentage = true,
    show_cc_cast_tooltip_percentage = true,
    show_remaining_timeline_after_finish = true,
    show_time_sections = true,
    saved_runs_compressed = {},
    saved_runs_compressed_headers = {},
    saved_runs_limit = 500,
    saved_runs_selected_index = 1,
    scoreboard_scale = 1.0,
    translit = GetLocale() ~= "ruRU",
    keep_information_for_debugging = false,
    developer_mode = false,
    migrations_done = {},
    migrations_data = {}, --used to store data for migrations
    logs = {},
    has_last_run = false,
    is_run_ongoing = false,
    last_run_id = 0,
    minimap = {
        hide = false,
    },
    visible_scoreboard_columns = {},

    likes_given = {},

    font = {
        row_size = 12,

        regular_color = "white",
        regular_outline = "NONE",

        hover_color = "orange",
        hover_outline = "NONE",

        standout_color = {230/255, 204/255, 128/255},
        standout_outline = "NONE",
    },
    logout_logs = {},
    last_run_data = {},
}

private.addon = detailsFramework:CreateNewAddOn(tocFileName, "Details_MythicPlusDB", defaultSettings)
local addon = private.addon


addon.eventCallbacks = {
    ["RunFinished"] = {}, --triggers right after the CreateRunInfo() and addon.OpenScoreBoardAtEnd(). Args: runId: number
    ["PlayerLiked"] = {}, --triggers right after a player is liked by someone. Args: runId: number, playerName: string
}

--[[GLOBAL]] DetailsMythicPlus = {}

---@diagnostic disable-next-line: missing-fields
addon.activityTimeline = {}

---@diagnostic disable-next-line: missing-fields
addon.Comm = {}

function addon.OnLoad(self, profile) --ADDON_LOADED
    --added has been loaded
end

function addon.GetVersionString()
    return C_AddOns.GetAddOnMetadata("Details_MythicPlus", "Version")
end

function addon.GetFullVersionString()
    return Details.GetVersionString() .. " | " .. addon.GetVersionString()
end

function addon.OnInit(self, profile) --PLAYER_LOGIN
    --logout logs register what happened to the addon when the player logged out
    if (not profile.logout_logs) then
        profile.logout_logs = {}
    end
    self:SetLogoutLogTable(profile.logout_logs)

    local detailsCoreVersion = Details:GetCoreVersion()
    if (detailsCoreVersion < 164) then
        print("Details! Mythic+: Update Details!, NOW!.")
        print("Details! Mythic+: Update Details!, NOW!.")
    end

    addon.data = {}
    addon.recentLikes = {}
    addon.LikesAmountFontString = {}
    addon.temporaryTimers = {}

    local detailsEventListener = Details:CreateEventListener()
    addon.detailsEventListener = detailsEventListener

    function private.log(...)
        local str = ""
        for i = 1, select("#", ...) do
            str = str .. tostring(select(i, ...)) .. " "
        end

        --insert year month day and hour min sec into str
        local date = date("%Y-%m-%d %H:%M:%S")
        str = date .. "| " .. str

        table.insert(profile.logs, 1, str)

        --limit to 50 entries, removing the oldest
        table.remove(profile.logs, CONST_MAX_LOGLINES+1)
    end

    --register details! events
    detailsEventListener:RegisterEvent("COMBAT_MYTHICDUNGEON_START")
    detailsEventListener:RegisterEvent("COMBAT_MYTHICDUNGEON_END")
    detailsEventListener:RegisterEvent("COMBAT_MYTHICDUNGEON_CONTINUE")
    detailsEventListener:RegisterEvent("COMBAT_MYTHICPLUS_OVERALL_READY")
    detailsEventListener:RegisterEvent("COMBAT_ENCOUNTER_START")
    detailsEventListener:RegisterEvent("COMBAT_ENCOUNTER_END")
    detailsEventListener:RegisterEvent("COMBAT_PLAYER_ENTER")
    detailsEventListener:RegisterEvent("COMBAT_PLAYER_LEAVE")

    --initialize enums
    addon.Enum = {
        --used to identify the type of run
        CombatType = {
            RunTime = 1,
            CombatTime = 2,
        },
        --used to identify the type of event
        ScoreboardEventType = {
            EncounterStart = "EncounterStart",
            EncounterEnd = "EncounterEnd",
            Death = "Death",
            KeyFinished = "KeyFinished",
        },
    }

    addon.InitializeEvents()
    addon.Comm.Initialize()
    addon.Comm.Register("L", addon.ProcessLikePlayer)
    addon.RegisterAddonCompartment()
    Details.SafeRun(addon.RegisterMinimap, "Register Minimap Icon", addon)

    -- always show the last run first
    addon.profile.saved_runs_selected_index = 1

    -- try to yeet broken saves and shrink history if the setting is lowered
    addon.Compress.YeetRunsOverStorageLimit()

    -- ensure people don't break the scale
    addon.profile.scoreboard_scale = math.max(0.6, math.min(1.6, addon.profile.scoreboard_scale))

    -- required to create early due to the frame events
    local scoreboard = addon.CreateScoreboardFrame()
    scoreboard:SetScale(addon.profile.scoreboard_scale)

    -- run migrations
    for i, migration in pairs(addon.Migrations) do
        if (not addon.profile.migrations_done[i]) then
            migration()
            addon.profile.migrations_done[i] = time()
        end
    end

    for migrationIndex, migration in pairs(addon.MigrationsPerCharacter) do
        migration(migrationIndex)
    end

    private.log("addon loaded")
end

local HandleMinimapClick = function(button)
    if (button == "LeftButton") then
        addon.OpenScoreboardFrame()
    elseif (button == "RightButton") then
        addon.ShowMythicPlusOptionsWindow()
    end
end

local HandleMinimapTooltip = function(tooltip)
    tooltip:AddLine(L["ADDON_MENU_ADDONS_TITLE"], 1, 1, 1)
    tooltip:AddLine(WrapTextInColorCode(L["ADDON_MENU_ADDONS_TOOLTIP_LEFT_CLICK"], "ffcfcfcf") .. ": " .. L["ADDON_MENU_ADDONS_TOOLTIP_OPEN_SCOREBOARD"])
    tooltip:AddLine(WrapTextInColorCode(L["ADDON_MENU_ADDONS_TOOLTIP_RIGHT_CLICK"], "ffcfcfcf") .. ": " .. L["ADDON_MENU_ADDONS_TOOLTIP_OPEN_OPTIONS"])
end

function addon.RegisterAddonCompartment()
    AddonCompartmentFrame:RegisterAddon({
        text = L["ADDON_MENU_ADDONS_TITLE"],
        icon = "4352494",
        notCheckable = true,
        func = function (button, data)
            HandleMinimapClick(data.buttonName)
        end,
        funcOnEnter = function(button)
            MenuUtil.ShowTooltip(button, function(tooltip)
                HandleMinimapTooltip(tooltip)
            end)
        end,
        funcOnLeave = function(button)
            MenuUtil.HideTooltip(button)
        end,
    })
end

function addon:RegisterMinimap()
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)

    if LDB then
        local dataBroker = LDB:NewDataObject("Details_MythicPlus", {
            type = "data source",
            icon = "4352494",
            text = L["ADDON_MENU_ADDONS_TITLE"],

            OnClick = function(self, button)
                HandleMinimapClick(button)
            end,
            OnTooltipShow = HandleMinimapTooltip,
        })

        if (dataBroker and not LDBIcon:IsRegistered("Details_MythicPlus")) then
            LDBIcon:Register("Details_MythicPlus", dataBroker, self.profile.minimap)
        end

        self.dataBroker = dataBroker
    end
end

function addon.FireEvent(eventName, ...)
    if (not addon.eventCallbacks[eventName]) then
        return
    end

    for _, callback in ipairs(addon.eventCallbacks[eventName]) do
        local success, errorText = pcall(callback, ...)
        if (not success) then
            print("Error firing event '" .. eventName .. "': " .. errorText)
        end
    end
end


function addon.ShowLogs()
    dumpt(addon.profile.logs)
end
