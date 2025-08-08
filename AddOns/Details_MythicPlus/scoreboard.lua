
--mythic+ extension for Details! Damage Meter
--[[
    This file show a frame at the end of a mythic+ run with a breakdown of the players performance.
    It shows the player name, the score, deaths, damage taken, dps, hps, interrupts, dispels and cc casts.
]]

---@type details
---@diagnostic disable-next-line: undefined-field
local Details = _G.Details
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon
local _ = nil
local L = detailsFramework.Language.GetLanguageTable(addonName)
local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

---@class scoreboard_object : table
---@field lines scoreboard_line[]
---@field CreateScoreboardFrame fun():scoreboard_mainframe
---@field CreateLineForScoreboardFrame fun(parent:scoreboard_mainframe, header:scoreboard_header, index:number):scoreboard_line
---@field CreateActivityPanel fun(parent:scoreboard_mainframe):scoreboard_activityframe
---@field RefreshScoreboardFrame fun(mainFrame:scoreboard_mainframe, runData:runinfo):boolean true when it has data, false when it does not and probably should be hidden
---@field SetFontSettings fun() set the default font settings

---@class scoreboard_mainframe : frame
---@field HeaderFrame scoreboard_header
---@field ActivityFrame scoreboard_activityframe
---@field RunInfoDropdown df_dropdown
---@field DungeonNameFontstring fontstring
---@field DungeonBackdropTexture texture
---@field ElapsedTimeText fontstring
---@field OutOfCombatIcon texture
---@field OutOfCombatText fontstring
---@field ItemLevelIcon texture
---@field ItemLevelText fontstring
---@field ReloadedFrame frame
---@field SandTimeIcon texture
---@field StrongArmIcon texture
---@field RatingLabel fontstring
---@field LeftFiligree texture
---@field RightFiligree texture
---@field BottomFiligree texture
---@field YellowSpikeCircle texture
---@field YellowFlash texture
---@field Level fontstring
---@field ConfigButton df_button

---@class scoreboard_header : df_headerframe
---@field lines table<number, scoreboard_line>

---@class scoreboard_line : button, df_headerfunctions

---@class scoreboard_button : df_button
---@field PlayerData scoreboard_playerdata
---@field InterruptCasts fontstring
---@field SetPlayerData fun(self:scoreboard_button, playerData:scoreboard_playerdata)
---@field GetPlayerData fun(self:scoreboard_button):scoreboard_playerdata
---@field HasPlayerData fun(self:scoreboard_button):boolean returns true if data is attached
---@field MarkTop fun(self:scoreboard_button)
---@field OnMouseEnter fun(self:scoreboard_button)|nil
---@field GetActor fun(self:scoreboard_button, actorMainAttribute):actor|nil, combat|nil

---@class scoreboard_playerdata : table
---@field runId number
---@field name string
---@field unitName string same as 'name'
---@field class string
---@field spec number
---@field role string
---@field score number
---@field previousScore number
---@field scoreColor table
---@field deaths number
---@field damageTaken number
---@field dps number
---@field hps number
---@field interrupts number
---@field interruptCasts number
---@field dispels number
---@field ccCasts number
---@field unitId string
---@field combatUid number
---@field activityTimeDamage number
---@field activityTimeHeal number
---@field damageTakenFromSpells spell_hit_player[]
---@field loot string|nil
---@field keystoneLevel number
---@field keystoneIcon string|number
---@field keystoneMapId string|number
---@field likedBy table<string, boolean>

---@class timeline_event : table
---@field type string
---@field timestamp number
---@field arguments table

---@type scoreboard_object
---@field RegisteredColumns table<number, scoreboard_column>
---@diagnostic disable-next-line: missing-fields
local mythicPlusBreakdown = {
    lines = {},
    RegisteredColumns = {},
    HeaderNeedsRefresh = false,
}

--main frame settings
local mainFrameName = "DetailsMythicPlusBreakdownFrame"
local mainFrameHeight = 452
--the padding on the left and right side it should keep between the frame itself and the table
local mainFramePaddingHorizontal = 5
--amount of desaturation for the big dungeon image in the background of the main frame
local backdropDungeonTextureDesaturation = 0.5
--offset for the dungeon name y position related to the top of the frame
local dungeonNameY = -12
--where the header is positioned in the Y axis from the top of the frame
local headerY = -65
--the amount of lines to be created to show player data
local lineAmount = 5
local lineOffset = 2
--the height of each line
local lineHeight = 46
--two backdrop colors
local lineColor1 = {1, 1, 1, 0.05}
local lineColor2 = {1, 1, 1, 0.1}
local lineBackdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true}
--position of the activity timeline, it is positioned below the lines
local activityFrameY = headerY - 90 + (lineHeight * lineAmount * -1)
--player keystone icon, keystone text
local keystoneDefaultTexture = 4352494 --when no keystone is found, this texture is shown

--column registration is made at the file scoreboard_layout.lua
function addon.RegisterScoreboardColumn(column)
    table.insert(mythicPlusBreakdown.RegisteredColumns, column)
end

function addon.GetRegisteredColumns()
    return mythicPlusBreakdown.RegisteredColumns
end

function addon.SignalHeadersChanged()
    mythicPlusBreakdown.HeaderNeedsRefresh = true
    addon.RefreshOpenScoreBoard()
end

function addon.OpenScoreboardFrame()
    local mainFrame = mythicPlusBreakdown.CreateScoreboardFrame()
    if (mainFrame:IsVisible()) then
        return
    end

    local runData = addon.Compress.GetSelectedRun()
    if (not runData) then
        print(L["SCOREBOARD_NO_SCORE_AVAILABLE"])
        return
    end

    mythicPlusBreakdown.RefreshScoreboardFrame(mainFrame, runData)
    mainFrame:Show()
    mainFrame.YellowSpikeCircle.OnShowAnimation:Play()
end

function addon.RefreshOpenScoreBoard()
    local mainFrame = mythicPlusBreakdown.CreateScoreboardFrame()

    if (mainFrame:IsVisible()) then
        --stop all timers running
        for i = 1, #addon.temporaryTimers do
            local thisTimer = addon.temporaryTimers[i]
            if (not thisTimer:IsCancelled()) then
                thisTimer:Cancel()
            end
        end
        table.wipe(addon.temporaryTimers)

        --do the update
        mythicPlusBreakdown.RefreshScoreboardFrame(mainFrame, addon.Compress.GetSelectedRun())
    end

    return mainFrame
end

function addon.IsScoreboardOpen()
    if (_G[mainFrameName]) then
        return _G[mainFrameName]:IsShown()
    end
    return false
end

function addon.OpenScoreBoardAtEnd()
    if (not addon.profile.has_last_run) then
        -- workaround for the event not firing if reloaded in-between
        -- this change should be removed when COMBAT_MYTHICPLUS_OVERALL_READY is being triggered in reloaded runs
        addon.OnMythicPlusOverallReady()
    end
    if (not addon.profile.has_last_run) then
        private.log("No last run found while trying to open the scoreboard.")
        return
    end

    private.log("auto opening the mythic+ scoreboard", addon.profile.delay_to_open_mythic_plus_breakdown_big_frame, "seconds")
    detailsFramework.Schedules.After(addon.profile.delay_to_open_mythic_plus_breakdown_big_frame, addon.OpenScoreboardFrame)
end

function addon.CreateScoreboardFrame()
    return mythicPlusBreakdown.CreateScoreboardFrame()
end

local SaveLoot = function(itemLink, unitName)
    local playerName = Ambiguate(unitName, "none")
    local lastRun = addon.Compress.GetLastRun()
    if (not lastRun or not lastRun.combatData.groupMembers[playerName]) then
        return
    end

    local itemType = select(6, C_Item.GetItemInfoInstant(itemLink))
    if (itemType ~= Enum.ItemClass.Weapon and itemType ~= Enum.ItemClass.Armor) then
        return
    end

    if (C_Item.IsItemBindToAccountUntilEquip(itemLink)) then
        return
    end

    local effectiveILvl, _, baseItemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
    local averageItemLevel = addon.GetRunAverageItemLevel(lastRun)
    if (effectiveILvl < averageItemLevel * 0.75 or baseItemLevel < 6) then
        return
    end

    private.log("Loot Received:", playerName, itemLink)
    addon.Compress.SetValue(1, "combatData.groupMembers." .. playerName .. ".loot", itemLink)

    addon.RefreshOpenScoreBoard()
end

function mythicPlusBreakdown.GetVisibleColumns()
    local columns = {}
    for _, column in pairs(mythicPlusBreakdown.RegisteredColumns) do
        --if (addon.profile.visible_scoreboard_columns[column:GetId()] ~= false) then
            table.insert(columns, column)
        --end
    end

    return columns
end

function mythicPlusBreakdown.CreateScoreboardFrame()
    --quick exit if the frame already exists
    if (_G[mainFrameName]) then
        return _G[mainFrameName]
    end

    ---@type scoreboard_mainframe
    local readyFrame = CreateFrame("frame", mainFrameName, UIParent, "BackdropTemplate")
    readyFrame:SetHeight(mainFrameHeight)
    readyFrame:SetPoint("center", UIParent, "center", 0, 0)
    readyFrame:SetFrameStrata("HIGH")
    readyFrame:EnableMouse(true)
    readyFrame:SetMovable(true)
    readyFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    readyFrame:SetScript("OnEvent", function (self, event, ...)
        if (event == "LOOT_CLOSED") then
            self:UnregisterEvent("LOOT_CLOSED")
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
            self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
            if (addon.profile.when_to_automatically_open_scoreboard == "LOOT_CLOSED") then
                addon.OpenScoreBoardAtEnd()
            end
        elseif (event == "CHALLENGE_MODE_COMPLETED") then
            self:RegisterEvent("LOOT_CLOSED")
            self:RegisterEvent("PLAYER_ENTERING_WORLD")
            self:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
            self:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
        elseif (event == "PLAYER_ENTERING_WORLD") then
            local isLogin, isReload = ...
            if (not isLogin and not isReload) then
                self:UnregisterEvent("LOOT_CLOSED")
                self:UnregisterEvent("PLAYER_ENTERING_WORLD")
                self:UnregisterEvent("ENCOUNTER_LOOT_RECEIVED")
                self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
            end
        elseif (event == "ENCOUNTER_LOOT_RECEIVED") then
            local _, _, itemLink, _, unitName = ...
            SaveLoot(itemLink, unitName)
        end
    end)

    table.insert(UISpecialFrames, mainFrameName)

    readyFrame:SetBackdropColor(.1, .1, .1, 0)
    readyFrame:SetBackdropBorderColor(.1, .1, .1, 0)
    detailsFramework:AddRoundedCornersToFrame(readyFrame, Details.PlayerBreakdown.RoundedCornerPreset)

    local backgroundDungeonTexture = readyFrame:CreateTexture("$parentDungeonBackdropTexture", "background")
    backgroundDungeonTexture:SetPoint("topleft", readyFrame, "topleft", 3, -3)
    backgroundDungeonTexture:SetPoint("bottomright", readyFrame, "bottomright", -3, 3)
    readyFrame.DungeonBackdropTexture = backgroundDungeonTexture

    detailsFramework:MakeDraggable(readyFrame)

    --close button at the top right of the frame
    local closeButton = detailsFramework:CreateCloseButton(readyFrame, "$parentCloseButton")
    closeButton:SetScript("OnClick", function() readyFrame:Hide() end)
    closeButton:SetPoint("topright", readyFrame, "topright", -4, -7)

    local configButton = detailsFramework:CreateButton(readyFrame, addon.ShowMythicPlusOptionsWindow, 32, 32, "")
    configButton:SetAlpha(0.823)
    configButton:SetSize(closeButton:GetSize())
    configButton:ClearAllPoints()
    configButton:SetPoint("right", closeButton, "left", -3, 0)
    readyFrame.ConfigButton = configButton

    addon.CreateRunSelectorDropdown(readyFrame)

    local normalTexture = configButton:CreateTexture(nil, "overlay")
    normalTexture:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
    normalTexture:SetTexCoord(79/512, 113/512, 0/512, 36/512)
    normalTexture:SetDesaturated(true)

    local pushedTexture = configButton:CreateTexture(nil, "overlay")
    pushedTexture:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
    pushedTexture:SetTexCoord(114/512, 148/512, 0/512, 36/512)
    pushedTexture:SetDesaturated(true)

    local highlightTexture = configButton:CreateTexture(nil, "highlight")
    highlightTexture:SetTexture([[Interface\BUTTONS\redbutton2x]], nil, nil, "TRILINEAR")
    highlightTexture:SetTexCoord(116/256, 150/256, 0, 39/128)
    highlightTexture:SetDesaturated(true)

    configButton:SetTexture(normalTexture, highlightTexture, pushedTexture, normalTexture)
    configButton.widget:GetNormalTexture():Show()

    mythicPlusBreakdown.CreateActivityPanel(readyFrame)

    --dungeon name at the top of the frame
    local dungeonNameFontstring = readyFrame:CreateFontString("$parentTitle", "overlay", "GameFontNormalLarge")
    dungeonNameFontstring:SetPoint("top", readyFrame, "top", 0, dungeonNameY)
    DetailsFramework:SetFontSize(dungeonNameFontstring, 20)
    readyFrame.DungeonNameFontstring = dungeonNameFontstring

    local runTimeFontstring = readyFrame:CreateFontString("$parentRunTime", "overlay", "GameFontNormal")
    runTimeFontstring:SetPoint("top", dungeonNameFontstring, "bottom", 0, -8)
    DetailsFramework:SetFontSize(runTimeFontstring, 16)
    runTimeFontstring:SetText("00:00")
    readyFrame.ElapsedTimeText = runTimeFontstring

    do --create the orange circle with spikes and the level text
        local topFrame = CreateFrame("frame", "$parentTopFrame", readyFrame, "BackdropTemplate")
        topFrame:SetPoint("topleft", readyFrame, "topleft", 0, 0)
        topFrame:SetPoint("topright", readyFrame, "topright", 0, 0)
        topFrame:SetHeight(1)
        topFrame:SetFrameLevel(readyFrame:GetFrameLevel() - 1)

        --use the same textures from the original end of dungeon panel
        local spikes = topFrame:CreateTexture("$parentSkullCircle", "overlay")
        spikes:SetSize(100, 100)
        spikes:SetPoint("center", readyFrame, "top", 0, 27)
        spikes:SetAtlas("ChallengeMode-SpikeyStar")
        spikes:SetAlpha(1)
        spikes:SetIgnoreParentAlpha(true)
        readyFrame.YellowSpikeCircle = spikes

        local yellowFlash = topFrame:CreateTexture("$parentYellowFlash", "artwork")
        yellowFlash:SetSize(120, 120)
        yellowFlash:SetPoint("center", readyFrame, "top", 0, 27)
        yellowFlash:SetAtlas("BossBanner-RedFlash")
        yellowFlash:SetAlpha(0)
        yellowFlash:SetBlendMode("ADD")
        yellowFlash:SetIgnoreParentAlpha(true)
        readyFrame.YellowFlash = yellowFlash

        readyFrame.Level = topFrame:CreateFontString("$parentLevelText", "overlay", "GameFontNormalWTF2Outline")
        readyFrame.Level:SetPoint("center", readyFrame.YellowSpikeCircle, "center", 0, 0)
        readyFrame.Level:SetText("12")

        --create the animation for the yellow flash
        local flashAnimHub = detailsFramework:CreateAnimationHub(yellowFlash, function() yellowFlash:SetAlpha(0) end, function() yellowFlash:SetAlpha(0) end)
        local flashAnim1 = detailsFramework:CreateAnimation(flashAnimHub, "Alpha", 1, 0.5, 0, 1)
        local flashAnim2 = detailsFramework:CreateAnimation(flashAnimHub, "Alpha", 2, 0.5, 1, 0)

        --create the animation for the yellow spike circle
        local spikeCircleAnimHub = detailsFramework:CreateAnimationHub(spikes, function() spikes:SetAlpha(0); spikes:SetScale(1) end, function() flashAnimHub:Play(); spikes:SetSize(100, 100); spikes:SetScale(1); spikes:SetAlpha(1) end)
        local alphaAnim1 = detailsFramework:CreateAnimation(spikeCircleAnimHub, "Alpha", 1, 0.2960000038147, 0, 1)
        local scaleAnim1 = detailsFramework:CreateAnimation(spikeCircleAnimHub, "Scale", 1, 0.21599999070168, 5, 5, 1, 1, "center", 0, 0)
        readyFrame.YellowSpikeCircle.OnShowAnimation = spikeCircleAnimHub

        readyFrame.LeftFiligree = topFrame:CreateTexture("$parentLeftFiligree", "artwork")
        readyFrame.LeftFiligree:SetAtlas("BossBanner-LeftFillagree")
        readyFrame.LeftFiligree:SetSize(72, 43)
        readyFrame.LeftFiligree:SetPoint("bottom", readyFrame, "top", -50, -2)

        readyFrame.RightFiligree = topFrame:CreateTexture("$parentRightFiligree", "artwork")
        readyFrame.RightFiligree:SetAtlas("BossBanner-RightFillagree")
        readyFrame.RightFiligree:SetSize(72, 43)
        readyFrame.RightFiligree:SetPoint("bottom", readyFrame, "top", 50, -2)

        --create the bottom filligree using BossBanner-BottomFillagree atlas
        readyFrame.BottomFiligree = topFrame:CreateTexture("$parentBottomFiligree", "artwork")
        readyFrame.BottomFiligree:SetAtlas("BossBanner-BottomFillagree")
        readyFrame.BottomFiligree:SetSize(66, 28)
        readyFrame.BottomFiligree:SetPoint("bottom", readyFrame, "bottom", 0, -19)

    end

    --header frame
    local headerOptions = {
        padding = 2,
    }

    local headers = {}
    for _, column in ipairs(mythicPlusBreakdown.GetVisibleColumns()) do
        table.insert(headers, {name = column:GetId(), text = column:ShouldShowHeaderText() and column:GetHeaderText() or "", width = column:GetWidth()})
    end

    ---@type scoreboard_header
    local headerFrame = detailsFramework:CreateHeader(readyFrame, headers, headerOptions)
    headerFrame:SetPoint("topleft", readyFrame, "topleft", 5, headerY)
    headerFrame.lines = {}
    readyFrame.HeaderFrame = headerFrame

    readyFrame:SetWidth(headerFrame:GetWidth() + mainFramePaddingHorizontal * 2)

    do --mythic+ run data
        --clock texture and icon to show the wasted time (time out of combat)
        local outOfCombatIcon = readyFrame:CreateTexture("$parentOutOfCombatIcon", "artwork", nil, 2)
        outOfCombatIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
        outOfCombatIcon:SetTexCoord(172/512, 235/512, 84/512, 147/512)
        outOfCombatIcon:SetVertexColor(detailsFramework:ParseColors("silver"))
        outOfCombatIcon:SetSize(24, 24)
        --outOfCombatIcon:SetPoint("bottomleft", headerFrame, "topleft", 20, 12)
        outOfCombatIcon:SetPoint("topleft", readyFrame, "topleft", 5, -5)
        readyFrame.OutOfCombatIcon = outOfCombatIcon

        local outOfCombatText = readyFrame:CreateFontString("$parentOutOfCombatText", "artwork", "GameFontNormal")
        detailsFramework:SetFontSize(outOfCombatText, 11)
        detailsFramework:SetFontColor(outOfCombatText, "silver")
        outOfCombatText:SetText("00:00")
        outOfCombatText:SetPoint("left", outOfCombatIcon, "right", 6, -3)
        readyFrame.OutOfCombatText = outOfCombatText

        local itemLevelIcon = readyFrame:CreateTexture("$parentItemLevelIcon", "artwork", nil, 2)
        itemLevelIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
        itemLevelIcon:SetPoint("left", outOfCombatIcon, "right", 260, 0)
        do
            local left, right, top, bottom = 79, 131, 229, 271
            itemLevelIcon:SetTexCoord(left/512, right/512, top/512, bottom/512)
            itemLevelIcon:SetSize(right - left, bottom - top)
            itemLevelIcon:SetScale(0.5)
            itemLevelIcon:SetAlpha(0.834)
            itemLevelIcon:SetVertexColor(0.9, 0.9, 0.9)
        end

        local itemLevelText = readyFrame:CreateFontString("$parentItemLevelText", "artwork", "GameFontNormal")
        detailsFramework:SetFontSize(itemLevelText, 11)
        detailsFramework:SetFontColor(itemLevelText, "silver")
        itemLevelText:SetText("0.0")
        itemLevelText:SetPoint("left", itemLevelIcon, "right", 6, -3)
        readyFrame.ItemLevelText = itemLevelText

        local reloadedFrame = CreateFrame("frame", "$parentReloadedFrame", headerFrame, "BackdropTemplate")
        reloadedFrame:SetScript("OnEnter", function(self)
            GameCooltip:Preset(2)
            GameCooltip:SetOwner(self, "bottom", "top", 0, -4)
            GameCooltip:AddLine(L["SCOREBOARD_RELOADED_TOOLTIP"])
            GameCooltip:Show()
        end)
        reloadedFrame:SetScript("OnLeave", function()
            GameCooltip:Hide()
        end)
        readyFrame.ReloadedFrame = reloadedFrame

        local reloadedText = reloadedFrame:CreateFontString("$parentReloadedText", "artwork", "GameFontNormal")
        detailsFramework:SetFontSize(reloadedText, 11)
        detailsFramework:SetFontColor(reloadedText, "orange")
        reloadedText:SetText(L["SCOREBOARD_RELOADED_WARNING"])

        local reloadedIcon = reloadedFrame:CreateTexture("$parentReloadedIcon", "artwork", nil, 2)
        reloadedIcon:SetAtlas("Professions_Icon_Warning")
        reloadedIcon:SetSize(20, 15)

        reloadedText:SetPoint("bottomright", headerFrame, "bottomright", -4, 25)
        reloadedIcon:SetPoint("bottomright", reloadedText, "bottomleft", -2, 0)
        reloadedFrame:SetPoint("bottomright", reloadedText, "bottomright", 5, -5)
        reloadedFrame:SetPoint("topleft", reloadedIcon, "topleft", -5, 5)

        reloadedFrame.ReloadedText = reloadedText
        reloadedFrame.ReloadedIcon = reloadedIcon
    end

    --create 6 rows to show data of the player, it only require 5 lines, the last one can be used on exception cases.
    for i = 1, lineAmount do
        mythicPlusBreakdown.CreateLineForScoreboardFrame(readyFrame, headerFrame, i)
    end

    return readyFrame
end

--this function get the overall mythic+ segment created after a mythic+ run has finished
--then it fill the lines with data from the overall segment
---@param mainFrame scoreboard_mainframe
---@param runData runinfo
function mythicPlusBreakdown.RefreshScoreboardFrame(mainFrame, runData)
    local headerFrame = mainFrame.HeaderFrame
    local lines = headerFrame.lines

    if (mythicPlusBreakdown.HeaderNeedsRefresh) then
        mythicPlusBreakdown.HeaderNeedsRefresh = false
        local headers = {}
        local columns = mythicPlusBreakdown.GetVisibleColumns()
        for _, column in ipairs(columns) do
            table.insert(headers, {name = column:GetId(), text = column:ShouldShowHeaderText() and column:GetHeaderText() or "", width = column:GetWidth()})
        end

        headerFrame:SetHeaderTable(headers)
        for i = 1, lineAmount do
            local line = lines[i]
            line:ResetFramesToHeaderAlignment()
            for _, column in ipairs(columns) do
                line:AddFrameToHeaderAlignment(column:GetFrameObject())
            end
            line:AlignWithHeader(headerFrame, "left")
        end

        mainFrame:SetWidth(headerFrame:GetWidth() + mainFramePaddingHorizontal * 2)
    end

    mainFrame.RunInfoDropdown:Select(addon.GetSelectedRunIndex(), nil, nil, false)
    mythicPlusBreakdown.SetFontSettings()

    if (runData.reloaded) then
        mainFrame.ReloadedFrame:Show()
    else
        mainFrame.ReloadedFrame:Hide()
    end

    if (#addon.Compress.GetHeaders() > 1) then
        mainFrame.RunInfoDropdown:Show()
    else
        mainFrame.RunInfoDropdown:Hide()
    end

    local combatTime = runData.timeInCombat

    ---@type scoreboard_playerdata[]
    local data = {}
    ---@type timeline_event[]
    local events = {}

    local runPlayerData = runData.combatData.groupMembers

    do --code for filling the 5 player lines
        for playerName, playerInfo in pairs(runPlayerData) do
            local unitId
            for i = 1, #Details.PartyUnits do
                if (Details:GetFullName(Details.PartyUnits[i]) == playerName) then
                    unitId = Details.PartyUnits[i]
                end
            end
            unitId = unitId or playerName

            local score = playerInfo.score or 0
            local ratingColor = C_ChallengeMode.GetDungeonScoreRarityColor(score)
            if (not ratingColor) then
                ratingColor = _G["HIGHLIGHT_FONT_COLOR"]
            end

            ---@type scoreboard_playerdata
            local thisPlayerData = {
                runId = runData.runId,
                name = playerName,
                unitName = playerName,
                class = playerInfo.class,
                spec = playerInfo.spec,
                role = playerInfo.role or UnitGroupRolesAssigned(unitId),
                score = score,
                unitId = unitId,
                previousScore = playerInfo.scorePrevious or score or 0,
                scoreColor = ratingColor,
                damageTaken = playerInfo.totalDamageTaken or 0,
                damageTakenFromSpells = playerInfo.damageTakenFromSpells,
                damageDoneBySpells = playerInfo.damageDoneBySpells,
                healDoneBySpells = playerInfo.healDoneBySpells,
                dps = playerInfo.totalDamage / combatTime,
                hps = playerInfo.totalHeal / combatTime,
                activityTimeDamage = playerInfo.activityTimeDamage or combatTime,
                activityTimeHeal = playerInfo.activityTimeHeal or combatTime,
                interrupts = playerInfo.totalInterrupts or 0,
                interruptCastOverlapDone = playerInfo.interruptCastOverlapDone or 0,
                interruptCasts = playerInfo.totalInterruptsCasts or 0,
                dispels = playerInfo.totalDispels or 0,
                ccCasts = playerInfo.totalCrowdControlCasts,
                ccSpellsUsed = playerInfo.crowdControlSpells,
                deaths = playerInfo.totalDeaths,
                combatUid = runData.combatId,
                loot = playerInfo.loot,
                keystoneLevel = 0,
                keystoneIcon = keystoneDefaultTexture,
                keystoneMapId = 0,
                likedBy = playerInfo.likedBy
            }

            if (thisPlayerData.role == "NONE") then
                thisPlayerData.role = "DAMAGER"
            end

            local playerKeystoneInfo = openRaidLib.GetKeystoneInfo(unitId)
            if (playerKeystoneInfo) then
                thisPlayerData.keystoneLevel = playerKeystoneInfo.level or thisPlayerData.keystoneLevel --default zero
                thisPlayerData.keystoneMapId = playerKeystoneInfo.challengeMapID or thisPlayerData.keystoneMapId

                ---@type details_instanceinfo
                local instanceInfo = Details:GetInstanceInfo(playerKeystoneInfo.mapID)

                if (instanceInfo) then
                    thisPlayerData.keystoneIcon = instanceInfo.iconLore
                end
            end

            --to render the event for deaths, it is required 'playerInfo' into the playerInfo.deathEvents[x].arguments.'playerData' field
            --as the scoreboard cannot change the database (in this case assigning thisPlayerData to playerInfo.deathEvents[x].arguments.'playerData')
            --we need to copy the deathEvents table and assign the playerData to each event
            local deathEventsTableCopy = detailsFramework.table.copy({}, playerInfo.deathEvents)
            for i = 1, #deathEventsTableCopy do
                local thisDeathEventCopied = deathEventsTableCopy[i]
                thisDeathEventCopied.arguments.playerData = thisPlayerData
                thisDeathEventCopied.arguments.index = i
            end
            detailsFramework.table.append(events, deathEventsTableCopy)

            data[#data+1] = thisPlayerData
        end

        table.sort(data, function(t1, t2)
            if (t1.role ~= t2.role) then
                return t1.role > t2.role
            end

            return t1.name < t2.name
        end)

        for i = 1, lineAmount do
            lines[i]:Hide()
        end

        local bestCache = {}
        for i = 1, lineAmount do
            local scoreboardLine = lines[i]
            local frames = scoreboardLine:GetFramesFromHeaderAlignment()
            ---@type scoreboard_playerdata
            local playerData = data[i]

            --(re)set the line contents
            for j = 1, #frames do
                local frame = frames[j]
                if (frame.ColumnDefinition) then
                    if (not bestCache[j]) then
                        bestCache[j] = frame.ColumnDefinition:CalculateBestPlayerData(data)
                    end

                    local isBest = false
                    if (bestCache[j]) then
                        for _, bestData in pairs(bestCache[j]) do
                            if (playerData == bestData) then
                                isBest = true
                            end
                        end
                    end

                    if (playerData) then
                        xpcall(function (columnFrame, columnPlayerData, rowIsBest)
                            frame.ColumnDefinition:Render(columnFrame, columnPlayerData, rowIsBest)
                        end, geterrorhandler(), frame, playerData, isBest)
                    end
                end
            end

            if (playerData) then
                scoreboardLine:Show()
            end
        end
    end


    local runTime = runData.completionInfo.time
    if (runTime) then --runTime can be nil if the run is not completed
        runTime = runData.completionInfo.time / 1000
        local notInCombat = runTime - combatTime

        if (runData.endTime) then
            events[#events+1] = {
                type = addon.Enum.ScoreboardEventType.KeyFinished,
                timestamp = runData.endTime,
                arguments = {
                    onTime = runData.completionInfo.onTime,
                    timeLostToDeaths = runData.timeLostToDeaths or 0,
                },
            }
        end

        table.sort(events, function(t1, t2) return t1.timestamp < t2.timestamp end)
        local flooredRunTime = math.floor(runTime)

        mainFrame.ActivityFrame:SetActivity(events, runData)

        local timeLimitToCompletion = runData.timeLimit

        --mainFrame.ItemLevelText:SetText(runData.completionInfo.itemLevel or 0.0)
        --get the item level of all player in the run and sum all of them, and then divide by the total of players found, item level is stored here: runInfo.combatData.groupMembers[unitName].ilevel
        local totalItemLevel = 0
        local totalPlayers = 0
        for playerName, playerInfo in pairs(runData.combatData.groupMembers) do
            if (playerInfo.ilevel) then
                totalItemLevel = totalItemLevel + playerInfo.ilevel
                totalPlayers = totalPlayers + 1
            end
        end
        if (totalPlayers > 0) then
            mainFrame.ItemLevelText:SetText(math.floor(totalItemLevel / totalPlayers))
        else
            mainFrame.ItemLevelText:SetText("0.0")
        end

        if (detailsFramework.Math.IsNearlyEqual(timeLimitToCompletion, flooredRunTime, 2)) then
            mainFrame.ElapsedTimeText:SetText(detailsFramework:IntegerToTimer(flooredRunTime) .. WrapTextInColorCode("." .. math.floor((runTime - flooredRunTime) * 1000), "FFBA8E23"))
        else
            mainFrame.ElapsedTimeText:SetText(detailsFramework:IntegerToTimer(flooredRunTime))
        end

        mainFrame.OutOfCombatText:SetText(L["SCOREBOARD_NOT_IN_COMBAT_LABEL"] .. ": " .. detailsFramework:IntegerToTimer(notInCombat))
        mainFrame.Level:SetText(runData.completionInfo.level) --the level in the big circle at the top
        if (runData.completionInfo.onTime) then
            mainFrame.DungeonNameFontstring:SetText(runData.dungeonName .. " +" .. runData.completionInfo.keystoneUpgradeLevels)
        else
            mainFrame.DungeonNameFontstring:SetText(runData.dungeonName)
        end
    else
        mainFrame.ElapsedTimeText:SetText("00:00")
        mainFrame.OutOfCombatText:SetText("00:00")
        mainFrame.Level:SetText("0")
        mainFrame.DungeonNameFontstring:SetText(L["SCOREBOARD_UNKNOWN_DUNGEON_LABEL"])
    end

    ---@type details_instanceinfo
    local instanceInfo = runData and Details:GetInstanceInfo(runData.mapId)
    if (instanceInfo) then
        mainFrame.DungeonBackdropTexture:SetTexture(instanceInfo.iconLore)
    else
        mainFrame.DungeonBackdropTexture:SetTexture(runData.dungeonBackgroundTexture)
    end

    mainFrame.DungeonBackdropTexture:SetDesaturation(backdropDungeonTextureDesaturation)
    mainFrame.DungeonBackdropTexture:SetTexCoord(35/512, 291/512, 49/512, 289/512)

    return true
end

function mythicPlusBreakdown.SetFontSettings()
    for i = 1, #mythicPlusBreakdown.lines do
        local line = mythicPlusBreakdown.lines[i]

        ---@type fontstring[]
        local regions = {line:GetRegions()}
        for j = 1, #regions do
            local region = regions[j]
            if (region:GetObjectType() == "FontString") then
                detailsFramework:SetFontSize(region, addon.profile.font.row_size)
                detailsFramework:SetFontColor(region, addon.profile.font.regular_color)
                detailsFramework:SetFontOutline(region, addon.profile.font.regular_outline)
            end
        end

        --include framework buttons
        ---@type df_blizzbutton[]
        local children = {line:GetChildren()}
        for j = 1, #children do
            local blizzButton = children[j]
            if (blizzButton:GetObjectType() == "Button" and blizzButton.MyObject) then --.MyObject is a button from the framework
                local buttonObject = blizzButton.MyObject
                buttonObject:SetFontSize(addon.profile.font.row_size)
                buttonObject:SetTextColor(addon.profile.font.regular_color)
                detailsFramework:SetFontOutline(buttonObject.button.text, addon.profile.font.regular_outline)
            end
        end
    end
end

--search tags: ~create ~line
function mythicPlusBreakdown.CreateLineForScoreboardFrame(mainFrame, headerFrame, index)
    ---@type scoreboard_line
    local line = CreateFrame("button", "$parentLine" .. index, mainFrame, "BackdropTemplate")
    detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)
    mythicPlusBreakdown.lines[#mythicPlusBreakdown.lines+1] = line

    local yPosition = -((index-1)*(lineHeight+1)) - 1
    line:SetPoint("topleft", headerFrame, "bottomleft", lineOffset, yPosition)
    line:SetPoint("topright", headerFrame, "bottomright", -lineOffset - 1, yPosition)
    line:SetHeight(lineHeight)

    line:SetBackdrop(lineBackdrop)
    if (index % 2 == 0) then
        line:SetBackdropColor(unpack(lineColor1))
    else
        line:SetBackdropColor(unpack(lineColor2))
    end

    --add each widget create to the header alignment
    for _, column in pairs(mythicPlusBreakdown.RegisteredColumns) do
        line:AddFrameToHeaderAlignment(column:BindToLine(line))
    end

    line:AlignWithHeader(headerFrame, "left")

    headerFrame.lines[index] = line

    return line
end

function mythicPlusBreakdown.CreateActivityPanel(mainFrame)
    ---@type scoreboard_activityframe
    local activityFrame = CreateFrame("frame", "$parentActivityFrame", mainFrame)
    mainFrame.ActivityFrame = activityFrame
    addon.ActivityFrame = activityFrame

    activityFrame:SetHeight(4)
    activityFrame:SetPoint("topleft", mainFrame, "topleft", lineOffset * 2, activityFrameY)
    activityFrame:SetPoint("topright", mainFrame, "topright", -lineOffset * 2 - 1, activityFrameY)

    local backgroundTexture = activityFrame:CreateTexture("$parentBackgroundTexture", "border")
    backgroundTexture:SetColorTexture(0, 0, 0, 0.834)
    backgroundTexture:SetAllPoints()
    activityFrame.BackgroundTexture = backgroundTexture

    activityFrame.segmentTextures = {}
    activityFrame.nextTextureIndex = 1

    activityFrame.bossWidgets = {}


    --todo(tercio): show players activityTime some place in the mainFrame

    --functions
    ---@param runData runinfo
    activityFrame.SetActivity = function(self, events, runData)
        --reset the segment textures
        addon.activityTimeline.ResetSegmentTextures(self)

        ---@type table<string, table<number, number, number, number>>
        local eventColors = {
            fallback = {0.6, 0.6, 0.6, 0.5},
            enter_combat = {0.1, 0.7, 0.1, 0.5},
            leave_combat = {0.7, 0.1, 0.1, 0.5},
        }

        ---@type number[]
        local combatTimeline = runData.combatTimeline
        local timestamps = {}
        local last
        for i = 1, #combatTimeline do
            local timestamp = combatTimeline[i]
            if (timestamp >= runData.startTime) then
                last = {
                    time = timestamp - runData.startTime,
                    event = i % 2 == 0 and "enter_combat" or "leave_combat"
                }

                table.insert(timestamps, last)
            end
        end

        if (last == nil) then
            return
        end

        last.time = math.max(last.time, runData.endTime - runData.startTime)
        if (addon.profile.show_remaining_timeline_after_finish and runData.timeLimit and last.time < runData.timeLimit) then
            last = {
                time = runData.timeLimit,
                event = "time_limit",
            }

            timestamps[#timestamps+1] = last
        end

        local width = self:GetWidth()
        local multiplier = width / last.time

        addon.activityTimeline.UpdateBossWidgets(self, runData, multiplier)
        addon.activityTimeline.UpdateBloodlustWidgets(self, runData, multiplier)
        addon.activityTimeline.UpdateTimeSections(self, last.time, multiplier)

        for i = 1, #timestamps do
            local step = timestamps[i]
            local nextStep = timestamps[i+1]
            if (nextStep == nil) then
                break
            end

            local thisStepTexture = addon.activityTimeline.GetSegmentTexture(self)

            thisStepTexture:SetWidth((nextStep.time - step.time) * multiplier)
            thisStepTexture:SetPoint("left", activityFrame, "left", step.time * multiplier, 0)
            thisStepTexture:Show()

            if (nextStep.event == "time_limit") then
                thisStepTexture:SetColorTexture(unpack(eventColors.fallback))
            else
                thisStepTexture:SetColorTexture(unpack(eventColors[step.event] or eventColors.fallback))
            end
        end

        ---@class playerportrait : frame
        ---@field Portrait texture
        ---@field RoleIcon texture

        local reservedUntil = -100
        local up = true
        for event, marker in addon.activityTimeline.PrepareEventFrames(self, events) do
            local relativeTimestamp = event.timestamp - runData.startTime
            local pointOnBar = relativeTimestamp * multiplier

            detailsFramework:SetFontColor(marker.TimestampLabel, 1, 1, 1)
            detailsFramework:SetFontSize(marker.TimestampLabel, 12)
            marker.TimestampLabel:SetText(detailsFramework:IntegerToTimer(relativeTimestamp))

            ---@type activitytimeline_marker_data
            local markerData = {}
            if (event.type == addon.Enum.ScoreboardEventType.Death) then
                markerData = addon.activityTimeline.RenderDeathMarker(self, event, marker, runData)

            elseif (event.type == addon.Enum.ScoreboardEventType.KeyFinished) then
                markerData = addon.activityTimeline.RenderKeyFinishedMarker(self, event, marker, runData)
            end

            local offset = marker:GetWidth() * 0.4
            local before = pointOnBar - offset
            local after = pointOnBar + offset

            if (markerData.forceDirection) then
                up = markerData.forceDirection == "up" and true or false
            elseif (before < reservedUntil) then
                up = not up
            else
                up = markerData.preferUp and true or false
            end

            if (after > reservedUntil) then
                reservedUntil = after
            end

            marker:Show()
            marker:ClearAllPoints()
            marker.TimestampLabel:ClearAllPoints()
            marker.LineTexture:ClearAllPoints()
            if (up) then
                marker:SetPoint("bottom", activityFrame, "topleft", pointOnBar, 15)
                marker.LineTexture:SetPoint("top", marker, "bottom", 0, 0)
                marker.LineTexture:SetPoint("bottom", activityFrame, "top", 0, 0)
                marker.TimestampLabel:SetPoint("bottom", marker, "top", 0, 5)
            else
                marker:SetPoint("top", activityFrame, "bottomleft", pointOnBar, -15)
                marker.LineTexture:SetPoint("top", marker, "top", 0, 0)
                marker.LineTexture:SetPoint("bottom", activityFrame, "bottom", 0, 0)
                marker.TimestampLabel:SetPoint("top", marker, "bottom", 0, -5)
            end
        end

    end

    return activityFrame
end
