
local addonId, advancedDeathLogs = ...
local Details = Details
local detailsFramework = DetailsFramework
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details_DeathGraphs")
local _

local GameCooltip = GameCooltip
local unpack = unpack
local wipe = table.wipe
local CreateFrame = CreateFrame

local CONST_ENDURANCE_BREAKLINE = 500
local CONST_ENDURANCE_FRAME_WIDTH = 738
local CONST_ENDURANCE_FRAME_HEIGHT = 518
local CONST_ENDURANCE_FRAME_XANCHOR = 185
local CONST_ENDURANCE_FRAME_YANCHOR = 0
local CONST_DIFFICULTY_SELECTION_YANCHOR = -50
local CONST_BUTTON_BACKGROUND_COLOR = {.3, .3, .3, .75}
local CONST_BUTTON_BACKGROUND_COLORHIGHLIGHT = {.5, .5, .5, .8}

local mode_buttons_height = 20
local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")

function advancedDeathLogs.mainFrame.BuildEnduranceFrames() --called at the end of the frames.lua
    local adlObject = advancedDeathLogs.pluginObject
    local pluginFrame = advancedDeathLogs.mainFrame

    local enduranceFrame = CreateFrame("frame", "AdvancedDeathLogsEnduranceFrame", pluginFrame, "BackdropTemplate")
    enduranceFrame:SetPoint("topleft", pluginFrame, "topleft", 2, advancedDeathLogs.tabFrameY)
    enduranceFrame:SetPoint("bottomright", pluginFrame, "bottomright", -2, advancedDeathLogs.tabFrameY * -1)
    enduranceFrame:SetSize(800, 400)
    adlObject.enduranceFrame = enduranceFrame

    --align the menus at the same point as the current deaths dropdown and timeline dropdowns
    local enduranceFrameMenuAnchor = CreateFrame("frame", "DeathGraphsEnduranceFrameMenuAnchor", enduranceFrame, "BackdropTemplate")
    enduranceFrameMenuAnchor:SetPoint("topleft", 10, -50)
    enduranceFrameMenuAnchor:SetSize(1, 1)
    adlObject.enduranceFrameMenuAnchor = enduranceFrameMenuAnchor

    --~endurance box
    local enduranceShowPlayersFrame = CreateFrame("frame", "ADL_PlayerEnduranceFrame", enduranceFrame, "BackdropTemplate")
    enduranceShowPlayersFrame:SetFrameLevel(pluginFrame:GetFrameLevel() + 5)
    enduranceShowPlayersFrame:SetPoint("topleft", enduranceFrameMenuAnchor, "topleft", CONST_ENDURANCE_FRAME_XANCHOR, CONST_ENDURANCE_FRAME_YANCHOR)
    enduranceShowPlayersFrame:SetSize(CONST_ENDURANCE_FRAME_WIDTH, CONST_ENDURANCE_FRAME_HEIGHT)
    enduranceShowPlayersFrame:SetResizable(false)
    enduranceShowPlayersFrame:SetMovable(true)

    enduranceShowPlayersFrame.labels = {}
    enduranceShowPlayersFrame:Hide()
    enduranceShowPlayersFrame.x = 0
    enduranceShowPlayersFrame.y = 0
    enduranceShowPlayersFrame.y_original = 0

    --get boss texture
    local defaultBossIcon, leftCoord, rightCoord, topCoord, bottomCoord = [[Interface\GossipFrame\IncompleteQuestIcon]], 0, 1, 0, 1
    local getBossTexture = function(enduranceTable)
        if (enduranceTable.boss_table) then
            return adlObject:GetBossIcon(enduranceTable.boss_table.mapid, enduranceTable.boss_table.index)
        else
            return leftCoord, rightCoord, topCoord, bottomCoord, defaultBossIcon
        end
    end

    local dropdownLabel_RaidFinder = detailsFramework:NewLabel(enduranceFrame, nil, "$parentRFLabel", "dropdownLabel_RaidFinder", "Raid Finder:", "GameFontNormal")
    local dropdownLabel_Normal = detailsFramework:NewLabel(enduranceFrame, nil, "$parentNormalLabel", "dropdownLabel_Normal", "Normal:", "GameFontNormal")
    local dropdownLabel_Heroic = detailsFramework:NewLabel(enduranceFrame, nil, "$parentHeroicLabel", "dropdownLabel_Heroic", "Heroic:", "GameFontNormal")
    local dropdownLabel_Mythic = detailsFramework:NewLabel(enduranceFrame, nil, "$parentMythicLabel", "dropdownLabel_Mythic", "Mythic:", "GameFontNormal")

    local onSelectBoss = function(_, _, boss)
        adlObject.db.last_boss = boss
        if (adlObject.db.showing_type == 2) then
            adlObject:ShowEndurance(boss, true)
        end

        adlObject:RefreshBossScroll()
    end

    --build a list of bosses for the dropdowns
    local buildRaidBossesList = function(self)
        local difficultyId = self.difficultyId
        local enduranceDB = adlObject.endurance_database or {}
        --the table which will be returned
        local resultTable = {}
        --store already added boss hashes to avoid duplicates
        local alreadyAdded = {}

        local segmentsTable = Details:GetCombatSegments()
        for segmentId = 1, #segmentsTable do
            ---@type combat
            local combatObject = segmentsTable[segmentId]
            local bossInfo = combatObject:GetBossInfo()
            if (bossInfo and combatObject.instance_type == "raid") then
                local bossCleuId = bossInfo.id
                local bossDifficulty = bossInfo.diff
                local bossHash = bossCleuId .. "-" .. bossDifficulty

                local enduranceTable = enduranceDB[bossHash]
                if (enduranceTable and not alreadyAdded[bossHash]) then
                    if (enduranceTable.diff == difficultyId) then
                        local encouterBossTexture = Details:GetBossEncounterTexture(enduranceTable.name or bossInfo.name or "Unknown")
                        table.insert(resultTable, {
                            value = enduranceTable.hash,
                            label = enduranceTable.name,
                            onclick = onSelectBoss,
                            icon = encouterBossTexture,
                            iconsize = advancedDeathLogs.dropdownIconSize,
                            texcoord = advancedDeathLogs.dropdownIconCoords
                        })

                        alreadyAdded[bossHash] = true
                    end
                end
            end
        end

        --add the other encounters which isn't present in the current details! database
        for bossHash, enduranceTable in pairs(enduranceDB) do
            if (not alreadyAdded[bossHash]) then
                if (enduranceTable.diff == difficultyId) then
                    local encouterBossTexture = Details:GetBossEncounterTexture(enduranceTable.name or "Unknown")
                    table.insert(resultTable, {
                        value = enduranceTable.hash,
                        label = enduranceTable.name,
                        onclick = onSelectBoss,
                        icon = encouterBossTexture,
                        iconsize = advancedDeathLogs.dropdownIconSize,
                        texcoord = advancedDeathLogs.dropdownIconCoords
                    })

                    alreadyAdded[bossHash] = true
                end
            end
        end

        return resultTable
    end

    --~dropdown
    local selectDropdown_RaidFinder = detailsFramework:NewDropDown(enduranceFrame, nil, "$parentRFDropdown", "selectDropdown_RaidFinder", advancedDeathLogs.dropdownWidth, 20, buildRaidBossesList, nil, options_dropdown_template)
    selectDropdown_RaidFinder.difficultyId = 17

    local selectDropdown_Normal = detailsFramework:NewDropDown(enduranceFrame, nil, "$parentNormalDropdown", "selectDropdown_Normal", advancedDeathLogs.dropdownWidth, 20, buildRaidBossesList, nil, options_dropdown_template)
    selectDropdown_Normal.difficultyId = 14

    local selectDropdown_Heroic = detailsFramework:NewDropDown(enduranceFrame, nil, "$parentHeroicDropdown", "selectDropdown_Heroic", advancedDeathLogs.dropdownWidth, 20, buildRaidBossesList, nil, options_dropdown_template)
    selectDropdown_Heroic.difficultyId = 15

    local selectDropdown_Mythic = detailsFramework:NewDropDown(enduranceFrame, nil, "$parentMythicDropdown", "selectDropdown_Mythic", advancedDeathLogs.dropdownWidth, 20, buildRaidBossesList, nil, options_dropdown_template)
    selectDropdown_Mythic.difficultyId = 16

    local x = 2
    local y = -5

    dropdownLabel_Mythic:SetPoint("topleft", enduranceFrame, "topleft", x, CONST_DIFFICULTY_SELECTION_YANCHOR)
    selectDropdown_Mythic:SetPoint("topleft", dropdownLabel_Mythic, "bottomleft", 0, y)

    dropdownLabel_Heroic:SetPoint("topleft", selectDropdown_Mythic, "bottomleft", 0, y)
    selectDropdown_Heroic:SetPoint("topleft", dropdownLabel_Heroic, "bottomleft", 0, y)

    dropdownLabel_Normal:SetPoint("topleft", selectDropdown_Heroic, "bottomleft", 0, y)
    selectDropdown_Normal:SetPoint("topleft", dropdownLabel_Normal, "bottomleft", 0, y)

    dropdownLabel_RaidFinder:SetPoint("topleft", selectDropdown_Normal, "bottomleft", 0, y)
    selectDropdown_RaidFinder:SetPoint("topleft", dropdownLabel_RaidFinder, "bottomleft", 0, y)

    function adlObject:RefreshBossScroll()
        selectDropdown_RaidFinder:Refresh()
        selectDropdown_Normal:Refresh()
        selectDropdown_Heroic:Refresh()
        selectDropdown_Mythic:Refresh()

        dropdownLabel_Mythic:SetTextColor(1, 1 , 1, 0.5)
        dropdownLabel_Heroic:SetTextColor(1, 1 , 1, 0.5)
        dropdownLabel_Normal:SetTextColor(1, 1 , 1, 0.5)
        dropdownLabel_RaidFinder:SetTextColor(1, 1 , 1, 0.5)

        local hash = adlObject.db.last_boss
        local diff

        if (hash) then
            diff = hash:gsub("%d+%-", "")
        end

        local value_RaidFinder = selectDropdown_RaidFinder.value
        local value_Normal = selectDropdown_Normal.value
        local value_Heroic = selectDropdown_Heroic.value
        local value_Mythic = selectDropdown_Mythic.value

        --[=[
            enduranceTable:
                bossHash:
                    hash = "2685-16"
                    type = "endurance"
                    name = "Scalecommander Sarkareth"
                    id = "2685-16"
                    diff = 16
                    player_db:
                    Arumm-Tichondrius<playername>:
                        encounters = 2,
                        points = 180,
                        deaths:
                                0, -- [1]
                                145.6500000000015, -- [2]
                                "Oblivion |cFFFF333326,906|r", -- [3]

                                0, -- [1]
                                145.6500000000015, -- [2]
                                "Oblivion |cFFFF333326,906|r", -- [3]
        --]=]

        local enduranceDB = adlObject.endurance_database

        if (not enduranceDB[value_RaidFinder]) then
            for _hash, enduranceTable in pairs(enduranceDB) do
                if (enduranceTable.diff == 17) then
                    selectDropdown_RaidFinder:Select(enduranceTable.hash)
                    break
                end
            end
        end

        if (not enduranceDB[value_Normal]) then
            for _hash, enduranceTable in pairs(enduranceDB) do
                if (enduranceTable.diff == 14) then
                    selectDropdown_Normal:Select(enduranceTable.hash)
                    break
                end
            end
        end

        if (not enduranceDB[value_Heroic]) then
            for _hash, enduranceTable in pairs(enduranceDB) do
                if (enduranceTable.diff == 15) then
                    selectDropdown_Heroic:Select(enduranceTable.hash)
                    break
                end
            end
        end

        if (not enduranceDB[value_Mythic]) then
            for _hash, enduranceTable in pairs(enduranceDB) do
                if (enduranceTable.diff == 16) then
                    selectDropdown_Mythic:Select(enduranceTable.hash)
                    break
                end
            end
        end

        if (diff == "14") then --normal
            selectDropdown_Normal:SetBackdropBorderColor(1, 1, 0, 1)
            selectDropdown_Normal:Select(hash)
            dropdownLabel_Normal:SetTextColor(1, 0.8 , 0, 1)

        elseif (diff == "15") then --heroic
            selectDropdown_Heroic:SetBackdropBorderColor(1, 1, 0, 1)
            selectDropdown_Heroic:Select(hash)
            dropdownLabel_Heroic:SetTextColor(1, 0.8 , 0, 1)

        elseif (diff == "16") then --mythic
            selectDropdown_Mythic:SetBackdropBorderColor(1, 1, 0, 1)
            selectDropdown_Mythic:Select(hash)
            dropdownLabel_Mythic:SetTextColor(1, 0.8 , 0, 1)

        elseif (diff == "17") then --rf
            selectDropdown_RaidFinder:SetBackdropBorderColor(1, 1, 0, 1)
            selectDropdown_RaidFinder:Select(hash)
            dropdownLabel_RaidFinder:SetTextColor(1, 0.8 , 0, 1)
        end
    end

    do  --tutorial texts
        local greenPercent = enduranceShowPlayersFrame:CreateTexture(nil, "overlay")
        greenPercent:SetColorTexture(.2, 1, .2, .7)
        greenPercent:SetSize(6, 20)
        greenPercent:SetPoint("topleft", dropdownLabel_RaidFinder.widget, "bottomleft", 0, -50)
        greenPercent:SetAlpha(advancedDeathLogs.tutorialWidgetsAlpha)

        local tutorialLabel3 = detailsFramework:CreateLabel(enduranceShowPlayersFrame)
        tutorialLabel3:SetPoint("topleft", greenPercent, "topright", 4, 1)
        tutorialLabel3.text = "Good, player never was one of the first three players dead"
        tutorialLabel3.width = 180
        tutorialLabel3.textsize = advancedDeathLogs.tutorialTextSize
        tutorialLabel3:SetAlpha(advancedDeathLogs.tutorialWidgetsAlpha)
        tutorialLabel3:SetJustifyV("top")

        local redPercent = enduranceShowPlayersFrame:CreateTexture(nil, "overlay")
        redPercent:SetColorTexture(1, .2, .2, .7)
        redPercent:SetSize(6, 20)
        redPercent:SetPoint("topleft", greenPercent, "bottomleft", 0, -5)
        redPercent:SetAlpha(advancedDeathLogs.tutorialWidgetsAlpha)

        local tutorialLabel4 = detailsFramework:CreateLabel(enduranceShowPlayersFrame)
        tutorialLabel4:SetPoint("topleft", redPercent, "topright", 4, 1)
        tutorialLabel4.text = "Bad, player often was one of the first three players dead"
        tutorialLabel4.width = 180
        tutorialLabel4.textsize = advancedDeathLogs.tutorialTextSize
        tutorialLabel4:SetJustifyV("top")
        tutorialLabel4:SetAlpha(advancedDeathLogs.tutorialWidgetsAlpha)
    end

    enduranceShowPlayersFrame:EnableMouse(false)

    --erase current endurance shown
    local clearEnduranceFunc = function()
        local bossHash = adlObject.db.last_boss
        if (not bossHash) then
            return
        end

        local enduranceDB = adlObject.endurance_database

        local enduranceTable = enduranceDB[bossHash]
        if (not enduranceTable) then
            return
        end

        wipe(enduranceTable.player_db)
        enduranceDB[bossHash] = nil
        enduranceShowPlayersFrame:Clear()

        for hash, _ in pairs(enduranceDB) do
            adlObject.db.last_boss = hash
            adlObject:Refresh()
            break
        end
    end

    local eraseButton = detailsFramework:NewButton(enduranceShowPlayersFrame, _, "$parentClearEnduranceButton", "ClearEnduranceButton", 120, mode_buttons_height, clearEnduranceFunc, nil, nil, nil, "Clear", 1, detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE")) --~clearButton resetButton
    eraseButton:SetPoint("topright", pluginFrame.ResetButton, "bottomright", 0, -2)
    eraseButton:SetIcon([[Interface\AddOns\Details\images\toolbar_icons]], 20, 20, nil, {128/256, 160/256, 0, 1})

    --report
    local reportEnduranceFunc = function()
        local bossHash = adlObject.db.last_boss
        if (not bossHash) then
            return
        end

        local enduranceTable = adlObject.endurance_database[bossHash]
        if (not enduranceTable) then
            return
        end

        local reportFunc = function(isCurrent, isReverse, amtLines)
            adlObject.report_lines = {"Details!: Endurance for " ..(enduranceTable.name or "Unknown") .. "(A.D.L(plugin)):"}
            for i = 1, math.min(#enduranceShowPlayersFrame.labels, amtLines) do
                local label = enduranceShowPlayersFrame.labels[i]
                if (label.panel:IsShown() and not label.gray_player) then
                    table.insert(adlObject.report_lines, label.name.text .. ": " .. label.points.text)
                end
            end
            adlObject:SendReportLines(adlObject.report_lines)
        end

        local bUseSlider = true
        adlObject:SendReportWindow(reportFunc, nil, nil, bUseSlider)
    end

    local reportEnduranceButton = detailsFramework:NewButton(enduranceShowPlayersFrame, _, "$parentReportEnduranceButton", "ReportEnduranceButton", 120, mode_buttons_height, reportEnduranceFunc, nil, nil, nil, "Report", 1, detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
    reportEnduranceButton:SetPoint("right", eraseButton, "left", -2, 0)
    reportEnduranceButton:SetIcon([[Interface\AddOns\Details\images\toolbar_icons]], 20, 20, nil, {96/256, 128/256, 0, 1})

    function enduranceShowPlayersFrame:Clear()
        for _, label in ipairs(self.labels) do
            label.points:Hide()
            label.name:Hide()
            label.panel:Hide()
        end
    end

    local playerLabel_OnMouseUp = function(self, button, capsule)
        if (button == "RightButton") then
            if (adlObject.Frame.isMoving) then
                return
            end
            adlObject:CloseWindow()
        end

        local reportFunc = function()
            adlObject.report_lines = {"Details!: Endurance Deaths for " .. capsule.label2.text .. "(Advanced Death Logs):"}
            local deaths = capsule.deaths
            if (deaths) then
                if (#deaths > 0) then
                    for i, death in ipairs(deaths) do
                        local minutos, segundos = math.floor(death[2]/60), math.floor(death[2]%60)
                        local damage = death[3]:gsub("|c%x?%x?%x?%x?%x?%x?%x?%x?", ""):gsub("|r", "")
                        adlObject.report_lines[#adlObject.report_lines+1] = "#" .. death[1] .. ": " .. damage .. " (" .. minutos .. "m " .. segundos .. "s)"
                    end
                end
            end
            adlObject:SendReportLines(adlObject.report_lines)
        end

        local use_slider = true
        adlObject:SendReportWindow(reportFunc, nil, nil, use_slider)

    end

    local playerLabel_OnEnter = function(self, capsule)
        self:SetBackdropColor(unpack(CONST_BUTTON_BACKGROUND_COLORHIGHLIGHT))
        capsule.label2:SetTextColor(1, 1, 1)

        GameCooltip:Preset(2)
        GameCooltip:SetOwner(self, "topleft", "topright")
        GameCooltip:SetOption("FixedWidth", 300)

        local total_encounters = capsule.encounters

        GameCooltip:AddLine("|cFFFFFF00Records: |r" .. total_encounters, "|cFFFFFF00Deaths: |r" .. #capsule.deaths ..(#capsule.deaths > 0 and " |cFFFFFF00(|r|cFFA0A0A01 each " .. string.format("%.1f", total_encounters / #capsule.deaths) .. " tries|r|cFFFFFF00)|r" or ""), 1, "orange", "orange", 12, SharedMedia:Fetch("font", "Friz Quadrata TT"))
        GameCooltip:AddLine(" ")

        local deaths = capsule.deaths
        if (deaths) then
            if (#deaths > 0) then
                for i, death in ipairs(deaths) do
                    --[1] = combat_id [2] = dead_at [3] = last_hit
                    local minutos, segundos = math.floor(death[2]/60), math.floor(death[2]%60)
                    GameCooltip:AddLine("|cFFFFFF00#" .. death[1] .. "|r  " .. minutos .. "m " .. segundos .. "s", death[3], 1, "orange", nil, 12, SharedMedia:Fetch("font", "Friz Quadrata TT"))
                end
            else
                GameCooltip:AddLine(Loc ["STRING_FLAWLESS"])
                GameCooltip:AddIcon([[Interface\COMMON\ReputationStar]], 1, 1, nil, nil, 0, 0.5, 0.03125, 0.5)
            end
        end

        GameCooltip:Show()
    end

    local playerLabel_OnLeave = function(self, capsule)
        if (capsule.ignored) then
            capsule.label2:SetTextColor(.5, .5, .5)
        else
            capsule.label2:SetTextColor(.9, .9, .9)
        end

        self:SetBackdropColor(unpack(CONST_BUTTON_BACKGROUND_COLOR))
        GameCooltip:Hide()
    end

    local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16}

    function enduranceShowPlayersFrame:SetPlayer(index, player_name, player_class, points, percent, encounters, deaths, min, max)
        local label = self.labels[index]

        if (not label) then
            local panel = detailsFramework:CreatePanel(enduranceShowPlayersFrame, 200, 18)
            panel:SetBackdrop(backdrop)
            panel:SetBackdropColor(unpack(CONST_BUTTON_BACKGROUND_COLOR))
            panel:SetPoint(self.x, self.y)
            panel:SetHook("OnEnter", playerLabel_OnEnter)
            panel:SetHook("OnLeave", playerLabel_OnLeave)
            panel:SetHook("OnMouseUp", playerLabel_OnMouseUp)

            local percentLabel = detailsFramework:NewLabel(panel, nil, "$parentLabel1" .. index, "label1", "", "GameFontHighlightSmall", 11)
            local playerNameLabel = detailsFramework:NewLabel(panel, nil, "$parentLabel2" .. index, "label2", "", "GameFontHighlightSmall", 11)
            local amountLabel = detailsFramework:NewLabel(panel, nil, "$parentLabel3" .. index, "label3", "", "GameFontHighlightSmall", 11)

            playerNameLabel:SetWidth(120)
            playerNameLabel:SetHeight(16)
            amountLabel:SetHeight(16)
            amountLabel:SetWidth(40)

            local icon1 = detailsFramework:NewImage(panel, nil, 14, 14, "artwork", nil, "icon")
            local icon1Background = detailsFramework:NewImage(panel, nil, 14, 14, "border", nil, "iconBackground")
            icon1Background:SetColorTexture(0.1, 0.1, 0.1, .93)
            icon1Background:SetAllPoints(icon1.widget)

            percentLabel:SetPoint("left", panel, "left", 0, 0)
            amountLabel:SetPoint("left", panel, "left", 54, 0)
            playerNameLabel:SetPoint("left", panel, "left", 106, 0)
            icon1:SetPoint("right", playerNameLabel, "left", -2, 0)

            enduranceShowPlayersFrame.y = enduranceShowPlayersFrame.y - 19
            if (enduranceShowPlayersFrame.y < -CONST_ENDURANCE_BREAKLINE) then
                enduranceShowPlayersFrame.y = enduranceShowPlayersFrame.y_original
                enduranceShowPlayersFrame.x = enduranceShowPlayersFrame.x + 220
            end
            self.labels[index] = {points = percentLabel, name = playerNameLabel, panel = panel, icon = icon1, recordsXdeaths = amountLabel}
            label = self.labels[index]
        end

        label.gray_player = nil

        if (percent == 101) then
            label.points:SetTextColor(.5, .5, .5)
            label.points.text = string.format("%.1f", math.abs((#deaths / encounters * 100) - 100)) .. "%"

            label.name.text = adlObject:GetOnlyName(player_name)
            local r, g, b = adlObject:GetClassColor(player_class)
            label.name:SetTextColor(.5, .5, .5)

            label.gray_player = true

            local file, l, r, t, b = adlObject:GetClassIcon(player_class)
            label.icon.texture = [[Interface\AddOns\Details\images\classes_small_alpha]]
            label.icon:SetTexCoord(l, r, t, b)
            label.icon:SetDesaturated(true)

            label.points:Show()
            label.name:Show()
            label.panel:Show()
            label.panel.deaths = deaths
            label.panel.encounters = encounters
            label.panel.points = points
            label.panel.ignored = true
        else
            local percent_scaled = adlObject:Scale(min, max, 0, 100, percent)

            local r, g
            if (percent_scaled < 50) then
                r = 255
            else
                r = math.floor( 255 -(percent_scaled * 2 - 100) * 255 / 100)
            end

            if (percent_scaled > 50) then
                g = 255
            else
                g = math.floor((percent_scaled * 2) * 255 / 100)
            end

            label.points:SetTextColor(r/255, g/255, 0)
            --label.recordsXdeaths:SetTextColor(r/255, g/255, 0)

            label.points.text = string.format("%.1f", percent) .. "%"

            label.name.text = adlObject:GetOnlyName(player_name)
            local r, g, b = adlObject:GetClassColor(player_class)
            label.name:SetTextColor(.9, .9, .9)

            local file, l, r, t, b = adlObject:GetClassIcon(player_class)
            label.icon.texture = [[Interface\AddOns\Details\images\classes_small_alpha]]
            label.icon:SetTexCoord(l, r, t, b)
            label.icon:SetDesaturated(false)

            label.points:Show()
            label.name:Show()
            label.panel:Show()

            label.panel.deaths = deaths
            label.panel.encounters = encounters
            label.panel.points = points
            label.panel.recordsXdeaths = #deaths .. " / " .. encounters

            label.recordsXdeaths.text = label.panel.recordsXdeaths
            label.recordsXdeaths:SetTextColor(.7, .7, .7)

            label.panel.ignored = nil
        end
    end

    function enduranceShowPlayersFrame:Cancel()
        enduranceShowPlayersFrame:Hide()
        adlObject.db.showing_type = 1
    end

    local reverseSort4 = function(t1, t2)
        return t1[4] < t2[4]
    end

    --if from dropdown, ignore all auto boss selection
    function adlObject:ShowEndurance(bossHash, fromDropdown)
        enduranceFrame.selectDropdown_RaidFinder:Show()
        enduranceFrame.selectDropdown_Normal:Show()
        enduranceFrame.selectDropdown_Heroic:Show()
        enduranceFrame.selectDropdown_Mythic:Show()
        enduranceFrame.dropdownLabel_RaidFinder:Show()
        enduranceFrame.dropdownLabel_Normal:Show()
        enduranceFrame.dropdownLabel_Heroic:Show()
        enduranceFrame.dropdownLabel_Mythic:Show()

        local enduranceDB = adlObject.endurance_database

        --refresh
        adlObject.db.showing_type = 2
        adlObject:RefreshBossScroll()
        enduranceShowPlayersFrame:Clear()

        --if the bossHash wan't passed, get the newest boss
        if (not bossHash) then
            local segmentsTable = Details:GetCombatSegments()
            for segmentId = 1, #segmentsTable do
                ---@type combat
                local combatObject = segmentsTable[segmentId]
                local bossInfo = combatObject:GetBossInfo()
                if (bossInfo and combatObject.instance_type == "raid") then
                    local bossCleuId = bossInfo.id
                    local bossDifficulty = bossInfo.diff
                    local thisBossHash = bossCleuId .. "-" .. bossDifficulty
                    if (enduranceDB[thisBossHash]) then
                        bossHash = thisBossHash
                        break
                    end
                end
            end
        end

        --get boss table
        bossHash = bossHash or adlObject.showing_endurance or adlObject.db.last_boss

        if (not bossHash) then
            for hash, _ in pairs(enduranceDB) do
                bossHash = hash
                if (bossHash) then
                    break
                end
            end
        end

        --get the boss from the latest segment
        if (not fromDropdown) then
            local currentCombat = Details:GetCurrentCombat()
            if (currentCombat) then
                if (currentCombat.is_boss) then
                    --get the map index
                    local mapID = currentCombat.is_boss.mapid
                    --get the boss index within the raid
                    local bossIndex = Details:GetBossIndex(mapID, currentCombat.is_boss.id, nil, currentCombat.is_boss.name)
                    if (bossIndex) then
                        --get the EJID
                        local EJID = Details.EncounterInformation[mapID] and Details.EncounterInformation[mapID].encounter_ids[bossIndex]
                        if (EJID) then
                            --if the EJID exists build the hash
                            local bossDificulty = currentCombat.is_boss.diff
                            local hash = tostring(EJID) .. tostring(bossDificulty)
                            if (hash) then
                                bossHash = hash
                            end
                        end
                    end
                end
            end
        end

        if (not bossHash) then
            return
        end

        local encounterTable = enduranceDB[bossHash]
        if (not encounterTable) then
            for hash, _ in pairs(enduranceDB) do
                bossHash = hash
                encounterTable = enduranceDB[hash]
                if (encounterTable) then
                    break
                end
            end
        end

        if (not encounterTable) then
            return
        end

        adlObject.db.last_boss = bossHash
        adlObject:RefreshBossScroll()

        local sorted = {}
        local minEncounters = 9999
        local maxEncounters = 0
        local minPoints = 999999
        local maxPoints = 0
        local minDeaths, maxDeaths = 999, 0

        --[=[
            playerInfo:
                class
                points
                encounters
                deaths{}
        --]=]

        for playerName, playerInfo in pairs(encounterTable.player_db) do
            table.insert(sorted, {playerName, playerInfo.class, playerInfo.points, 0, playerInfo.encounters, playerInfo.deaths})

            if (minEncounters > playerInfo.encounters) then
                minEncounters = playerInfo.encounters
            end

            if (maxEncounters < playerInfo.encounters) then
                maxEncounters = playerInfo.encounters
            end

            if (minPoints > playerInfo.points) then
                minPoints = playerInfo.points
            end

            if (maxPoints < playerInfo.points) then
                maxPoints = playerInfo.points
            end

            if (minDeaths > #playerInfo.deaths) then
                minDeaths = #playerInfo.deaths
            end

            if (maxDeaths < #playerInfo.deaths) then
                maxDeaths = #playerInfo.deaths
            end
        end

        for i, t in ipairs(sorted) do
            if (t[5] / maxEncounters * 100 < 35) then
                t[4] = 101
            else
                local d_percent = math.abs((#t[6] / t[5] * 100) - 100)
                t[4] = d_percent
            end
        end

        table.sort(sorted, reverseSort4)

        local min = sorted[1] and sorted[1][4]
        local max = sorted[#sorted] and sorted[#sorted][4]

        for index, t in ipairs(sorted) do
            enduranceShowPlayersFrame:SetPlayer(index, t[1], t[2], t[3], t[4], t[5], t[6], min, max)
        end

        --show
        enduranceFrame:Show()
        enduranceShowPlayersFrame:Show()
    end

    function adlObject:HideEndurance()
        adlObject.db.showing_type = 1
        enduranceShowPlayersFrame:Hide()

        adlObject:RefreshBossScroll()

        if (adlObject.db.last_segment) then
            adlObject.graphic_frame:Show()
            adlObject.overall_bg:Show()
        end
    end
end