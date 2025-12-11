
--mythic+ extension for Details! Damage Meter
--[[
    This file is responsible for the options windows
]]

---@type details
local Details = _G.Details
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon

--localization
local L = detailsFramework.Language.GetLanguageTable(addonName)

--templates
local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
local orange_font_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")

---@type mythic_plus_options_object
---@diagnostic disable-next-line: missing-fields
local mythicPlusOptions = {}

local function GetOptionsTable()
    local options = {
        ---
        --- General Options
        ---
        {type = "label", get = function() return L["OPTIONS_GENERAL_OPTIONS"] end, text_template = orange_font_template},
        {
            type = "toggle",
            get = function () return not addon.profile.minimap.hide end,
            set = function (_, _, value)
                addon.profile.minimap.hide = not value
                LDBIcon = LibStub("LibDBIcon-1.0", true)
                LDBIcon:Refresh("Details_MythicPlus", addon.profile.minimap)
                if (addon.profile.minimap.hide) then
                    LDBIcon:Hide("Details_MythicPlus")
                else
                    LDBIcon:Show("Details_MythicPlus")
                end
            end,
            name = L["OPTIONS_SHOW_MINIMAP_ICON_LABEL"],
            desc = L["OPTIONS_SHOW_MINIMAP_ICON_DESC"],
        },
        {
            type = "select",
            get = function() return addon.profile.when_to_automatically_open_scoreboard end,
            values = function()
                local set = function (_, _, value) addon.profile.when_to_automatically_open_scoreboard = value end
                return {
                    { label = L["OPTIONS_AUTO_OPEN_CHOICE_LOOT_CLOSED"], onclick = set, value = "LOOT_CLOSED" },
                    { label = L["OPTIONS_AUTO_OPEN_CHOICE_OVERALL_READY"], onclick = set, value = "COMBAT_MYTHICPLUS_OVERALL_READY" },
                } end,
            name = L["OPTIONS_AUTO_OPEN_LABEL"],
            desc = L["OPTIONS_AUTO_OPEN_DESC"],
        },
        {
            type = "range",
            get = function () return addon.profile.delay_to_open_mythic_plus_breakdown_big_frame end,
            set = function (_, _, value)
                addon.profile.delay_to_open_mythic_plus_breakdown_big_frame = value
                addon.RefreshOpenScoreBoard()
            end,
            min = 0,
            max = 10,
            step = 1,
            name = L["OPTIONS_OPEN_DELAY_LABEL"],
            desc = L["OPTIONS_OPEN_DELAY_DESC"],
        },
        {
            type = "range",
            get = function () return addon.profile.scoreboard_scale end,
            set = function (_, _, value)
                addon.profile.scoreboard_scale = value
                addon.RefreshOpenScoreBoard():SetScale(value)
            end,
            min = 0.6,
            max = 1.6,
            step = 0.1,
            usedecimals = true,
            name = L["OPTIONS_SCOREBOARD_SCALE_LABEL"],
            desc = L["OPTIONS_SCOREBOARD_SCALE_DESC"],
        },
        {
            type = "toggle",
            get = function () return addon.profile.show_column_summary_in_tooltip end,
            set = function (_, _, value)
                addon.profile.show_column_summary_in_tooltip = value
                addon.RefreshOpenScoreBoard()
            end,
            name = L["OPTIONS_SHOW_TOOLTIP_SUMMARY_LABEL"],
            desc = L["OPTIONS_SHOW_TOOLTIP_SUMMARY_DESC"],
        },
        {
            type = "toggle",
            get = function () return addon.profile.translit end,
            set = function (_, _, value)
                addon.profile.translit = value
                addon.RefreshOpenScoreBoard()
            end,
            name = L["OPTIONS_TRANSLIT_LABEL"],
            desc = L["OPTIONS_TRANSLIT_DESC"],
        },

        ---
        --- Tooltips
        ---
        {type = "label", get = function() return L["OPTIONS_TOOLTIPS"] end, text_template = orange_font_template},
        {
            type = "toggle",
            get = function () return addon.profile.show_interrupt_tooltip_percentage end,
            set = function (_, _, value)
                addon.profile.show_interrupt_tooltip_percentage = value
                addon.RefreshOpenScoreBoard()
            end,
            name = L["OPTIONS_SHOW_INTERRUPT_TOOLTIP_PERCENTAGE_LABEL"],
            desc = L["OPTIONS_SHOW_INTERRUPT_TOOLTIP_PERCENTAGE_DESC"],
        },
        {
            type = "toggle",
            get = function () return addon.profile.show_cc_cast_tooltip_percentage end,
            set = function (_, _, value)
                addon.profile.show_cc_cast_tooltip_percentage = value
                addon.RefreshOpenScoreBoard()
            end,
            name = L["OPTIONS_SHOW_CC_CAST_TOOLTIP_PERCENTAGE_LABEL"],
            desc = L["OPTIONS_SHOW_CC_CAST_TOOLTIP_PERCENTAGE_DESC"],
        },

        ---
        --- Saving options
        ---
        {type = "label", get = function() return L["OPTIONS_SAVING"] end, text_template = orange_font_template},
        {
            type = "range",
            get = function () return addon.profile.saved_runs_limit end,
            set = function (_, _, value)
                addon.profile.saved_runs_limit = value
                addon.RefreshOpenScoreBoard()
            end,
            min = 1,
            max = 1000,
            step = 1,
            name = L["OPTIONS_HISTORY_RUNS_TO_KEEP_LABEL"],
            desc = function ()
                if (not addon.profile.developer_mode) then
                    return string.format(
                        "%s\n\n%s: %d",
                        L["OPTIONS_HISTORY_RUNS_TO_KEEP_DESC"],
                        L["OPTIONS_HISTORY_RUNS_TO_KEEP_SAVED_RUNS"],
                        #addon.Compress.GetSavedRuns()
                    )
                end
                local savedRuns = addon.Compress.GetSavedRuns()
                local totalSize = 0
                for _, run in pairs(savedRuns) do
                    totalSize = totalSize + #run
                end

                return string.format(
                    "%s\n\n%s: %d\n%s: %.2f KB\n%s: %.2f KB",
                    L["OPTIONS_HISTORY_RUNS_TO_KEEP_DESC"],
                    L["OPTIONS_HISTORY_RUNS_TO_KEEP_SAVED_RUNS"],
                    #savedRuns,
                    L["OPTIONS_HISTORY_RUNS_TO_KEEP_TOTAL_STORAGE"],
                    totalSize / 1024,
                    L["OPTIONS_HISTORY_RUNS_TO_KEEP_AVERAGE_PER_RUN"],
                    (totalSize / #savedRuns) / 1024
                )
            end,
        },

        ---
        --- Timeline Options
        ---
        {type = "label", get = function() return L["OPTIONS_SECTION_TIMELINE"] end, text_template = orange_font_template},
        {
            type = "toggle",
            get = function () return addon.profile.show_time_sections end,
            set = function (_, _, value)
                addon.profile.show_time_sections = value
                addon.RefreshOpenScoreBoard()
            end,
            name = L["OPTIONS_SHOW_TIME_SECTIONS_LABEL"],
            desc = L["OPTIONS_SHOW_TIME_SECTIONS_DESC"],
        },
        {
            type = "toggle",
            get = function () return addon.profile.show_remaining_timeline_after_finish end,
            set = function (_, _, value)
                addon.profile.show_remaining_timeline_after_finish = value
                addon.RefreshOpenScoreBoard()
            end,
            name = L["OPTIONS_SHOW_REMAINING_TIME_LABEL"],
            desc = L["OPTIONS_SHOW_REMAINING_TIME_DESC"],
        },

        ---
        --- Scoreboard column options
        ---
        --{type = "label", get = function() return L["OPTIONS_SECTION_VISIBLE_COLUMNS"] end, text_template = orange_font_template},
    }

    --for _, column in pairs(addon.GetRegisteredColumns()) do
    --    table.insert(options, {
    --        type = "toggle",
    --        get = function () return addon.profile.visible_scoreboard_columns[column:GetId()] end,
    --        set = function (_, _, value)
    --            addon.profile.visible_scoreboard_columns[column:GetId()] = value
    --            addon.SignalHeadersChanged()
    --        end,
    --        name = column:GetHeaderText(),
    --    })
    --end

    ---
    --- Debug options
    ---
    table.insert(options, {type = "label", get = function() return L["OPTIONS_DEBUG"] end, text_template = orange_font_template})
    table.insert(options, {
        type = "toggle",
        get = function () return addon.profile.keep_information_for_debugging end,
        set = function (_, _, value)
            addon.profile.keep_information_for_debugging = value
            addon.RefreshOpenScoreBoard()
        end,
        name = L["OPTIONS_DEBUG_STORE_DEBUG_INFO_LABEL"],
        desc = L["OPTIONS_DEBUG_STORE_DEBUG_INFO_DESC"],
    })

    table.insert(options, {
        type = "toggle",
        get = function () return addon.profile.developer_mode end,
        set = function (_, _, value)
            addon.profile.developer_mode = value
            addon.RefreshOpenScoreBoard()
        end,
        name = L["OPTIONS_DEBUG_STORE_DEV_MODE_LABEL"],
        desc = L["OPTIONS_DEBUG_STORE_DEV_MODE_DESC"],
    })

    return options
end

local mainFrameName = "DetailsMythicPlusOptionsFrame"

function addon.ShowMythicPlusOptionsWindow()
    mythicPlusOptions.ShowOptions()
end

function mythicPlusOptions.ShowOptions()
    local options = mythicPlusOptions.InitializeOptionsWindow()
    options:Show()
end

function mythicPlusOptions.InitializeOptionsWindow()
    if (_G[mainFrameName]) then
        return _G[mainFrameName]
    end

    local optionsFrame = detailsFramework:CreateSimplePanel(UIParent, 360, 387, L["OPTIONS_WINDOW_TITLE"], mainFrameName, {UseScaleBar = false, NoScripts = true, NoTUISpecialFrame = true})
    detailsFramework:MakeDraggable(optionsFrame)
    optionsFrame:SetPoint("center", UIParent, "center", 160, -50)
    detailsFramework:ApplyStandardBackdrop(optionsFrame)
    optionsFrame:SetFrameStrata("DIALOG")
    optionsFrame:SetToplevel(true)
    optionsFrame:SetFrameLevel(5)

    --close button at the top right of the frame
    local closeButton = detailsFramework:CreateCloseButton(optionsFrame, "$parentCloseButton")
    closeButton:SetScript("OnClick", function()
        optionsFrame:Hide()
    end)
    closeButton:SetPoint("topright", optionsFrame, "topright", -5, -5)

    -- detailsFramework:CreateCloseButton looks better
    optionsFrame.Close:Hide()
    optionsFrame.Close = closeButton
    optionsFrame.closeButton = closeButton

    local optionsTemplate = GetOptionsTable()
    optionsTemplate.always_boxfirst = true
    optionsTemplate.align_as_pairs = true
    optionsTemplate.align_as_pairs_string_space = 180
    optionsTemplate.widget_width = 150

    local canvasFrame = detailsFramework:CreateCanvasScrollBox(optionsFrame, nil, mainFrameName .. "Canvas")
    canvasFrame:SetPoint("topleft", optionsFrame, "topleft", 6, -26)
    canvasFrame:SetPoint("bottomright", optionsFrame, "bottomright", -26, 6)
    optionsFrame.canvasFrame = canvasFrame

    detailsFramework:BuildMenu(canvasFrame, optionsTemplate, 0, 0, optionsFrame:GetHeight(), false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

    return optionsFrame
end
