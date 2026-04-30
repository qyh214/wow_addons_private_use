
-------------------------------------
-- 觀察目標裝備屬性統計
-- @Author: M
-- @DepandsOn: InspectUnit.lua
-------------------------------------

local locale = GetLocale()

if (locale == "koKR" or locale == "enUS" or locale == "zhCN" or locale == "zhTW") then
else return end

local LibItemInfo = LibStub:GetLibrary("LibItemInfo.7000")

local function GetStateValue(unit, state, value, default)
    return value or default
end

function ShowInspectItemStatsFrame(frame, unit)
    if (not frame.expandButton) then
        local expandButton = CreateFrame("Button", nil, frame)
        expandButton:SetSize(12, 12)
        expandButton:SetPoint("TOPRIGHT", -5, -5)
        expandButton:SetNormalTexture("Interface\\Cursor\\Item")
        expandButton:GetNormalTexture():SetTexCoord(12/32, 0, 0, 12/32)
        expandButton:SetScript("OnClick", function(self)
            local parent = self:GetParent()
            ToggleFrame(parent.statsFrame)
            if (parent.statsFrame:IsShown()) then
                ShowInspectItemStatsFrame(parent, parent.unit)
            end
        end)
        frame.expandButton = expandButton
    end
    if (not frame.statsFrame) then
        local statsFrame = CreateFrame("Frame", nil, frame, "InsetFrameTemplate3")
        statsFrame:SetSize(197, 157)
        statsFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, -1)
        for i = 1, 20 do
            statsFrame["stat"..i] = CreateFrame("FRAME", nil, statsFrame, "CharacterStatFrameTemplate")
            statsFrame["stat"..i]:EnableMouse(false)
            statsFrame["stat"..i]:SetWidth(197)
            statsFrame["stat"..i]:SetPoint("TOPLEFT", 0, -17*i+13)
            statsFrame["stat"..i].Background:SetVertexColor(0, 0, 0)
            statsFrame["stat"..i].Value:SetPoint("RIGHT", -64, 0)
            statsFrame["stat"..i].PlayerValue = statsFrame["stat"..i]:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
            statsFrame["stat"..i].PlayerValue:SetFontObject(statsFrame["stat"..i].Value:GetFontObject())
            statsFrame["stat"..i].PlayerValue:SetPoint("LEFT", statsFrame["stat"..i], "RIGHT", -54, 0)
        end
        local mask = statsFrame:CreateTexture()
        mask:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        mask:SetPoint("TOPLEFT", statsFrame, "TOPRIGHT", -58, -3)
        mask:SetPoint("BOTTOMRIGHT", statsFrame, "BOTTOMRIGHT", -3, 2)
        mask:SetBlendMode("ADD")
        --mask:SetGradientAlpha("VERTICAL", 0.1, 0.4, 0.4, 0.8, 0.1, 0.2, 0.2, 0.8)
        mask:SetAlpha(0.2)
        frame.statsFrame = statsFrame
    end
    if (not frame.statsFrame:IsShown()) then return end
    local allowedStats = {
        [ITEM_MOD_INTELLECT_SHORT] = true,
        [ITEM_MOD_STRENGTH_SHORT] = true,
        [ITEM_MOD_AGILITY_SHORT] = true,
        [ITEM_MOD_STAMINA_SHORT] = true,
        [STAT_HASTE] = true,
        [STAT_MASTERY] = true,
        [STAT_CRITICAL_STRIKE] = true,
        [STAT_VERSATILITY] = true,
        [STAT_AVOIDANCE] = true,
        [STAT_SPEED] = true,
        [STAT_LIFESTEAL] = true,
    }
    local statColor = { r = 0, g = 1, b = 0.2 }
    local mainStatColor = { r = 1, g = 0.82, b = 0 }
    local primaryStatToKey = {
        [1] = ITEM_MOD_STRENGTH_SHORT,
        [2] = ITEM_MOD_AGILITY_SHORT,
        [4] = ITEM_MOD_INTELLECT_SHORT,
    }
    local mainStatByClass = {
        DEATHKNIGHT = ITEM_MOD_STRENGTH_SHORT,
        DEMONHUNTER = ITEM_MOD_AGILITY_SHORT,
        DRUID = ITEM_MOD_AGILITY_SHORT,
        EVOKER = ITEM_MOD_INTELLECT_SHORT,
        HUNTER = ITEM_MOD_AGILITY_SHORT,
        MAGE = ITEM_MOD_INTELLECT_SHORT,
        MONK = ITEM_MOD_AGILITY_SHORT,
        PALADIN = ITEM_MOD_STRENGTH_SHORT,
        PRIEST = ITEM_MOD_INTELLECT_SHORT,
        ROGUE = ITEM_MOD_AGILITY_SHORT,
        SHAMAN = ITEM_MOD_INTELLECT_SHORT,
        WARLOCK = ITEM_MOD_INTELLECT_SHORT,
        WARRIOR = ITEM_MOD_STRENGTH_SHORT,
    }
    local mainStatBySpecID = {
        [65] = ITEM_MOD_INTELLECT_SHORT, -- Holy Paladin
        [1480] = ITEM_MOD_INTELLECT_SHORT, -- Devourer Demon Hunter
        [262] = ITEM_MOD_INTELLECT_SHORT, -- Elemental Shaman
        [263] = ITEM_MOD_AGILITY_SHORT, -- Enhancement Shaman
        [264] = ITEM_MOD_INTELLECT_SHORT, -- Restoration Shaman
        [270] = ITEM_MOD_INTELLECT_SHORT, -- Mistweaver Monk
        [102] = ITEM_MOD_INTELLECT_SHORT, -- Balance Druid
        [105] = ITEM_MOD_INTELLECT_SHORT, -- Restoration Druid
    }
    local function GetStatValueFromUnit(stats, key, unitToken)
        if (stats and stats[key] and stats[key].value) then
            return stats[key].value
        end
        if (key == ITEM_MOD_STAMINA_SHORT) then
            local _, value = UnitStat(unitToken, 3)
            return value
        elseif (key == ITEM_MOD_INTELLECT_SHORT) then
            local _, value = UnitStat(unitToken, 4)
            return value
        elseif (key == ITEM_MOD_STRENGTH_SHORT) then
            local _, value = UnitStat(unitToken, 1)
            return value
        elseif (key == ITEM_MOD_AGILITY_SHORT) then
            local _, value = UnitStat(unitToken, 2)
            return value
        end
    end
    local function GetMainStatKey(unitToken)
        if (unitToken == "player" and type(GetSpecialization) == "function" and type(GetSpecializationInfo) == "function") then
            local specIndex = GetSpecialization()
            if (specIndex) then
                local specID, _, _, _, _, primaryStat = GetSpecializationInfo(specIndex)
                if (primaryStatToKey[primaryStat]) then
                    return primaryStatToKey[primaryStat]
                end
                if (mainStatBySpecID[specID]) then
                    return mainStatBySpecID[specID]
                end
            end
        end
        local _, classFile = UnitClass(unitToken)
        return mainStatByClass[classFile]
    end
    local function EnsureStatRow(index)
        local row = frame.statsFrame["stat"..index]
        if (row) then
            return row
        end
        row = CreateFrame("FRAME", nil, frame.statsFrame, "CharacterStatFrameTemplate")
        row:EnableMouse(false)
        row:SetWidth(197)
        row:SetPoint("TOPLEFT", 0, -17*index+13)
        row.Background:SetVertexColor(0, 0, 0)
        row.Value:SetPoint("RIGHT", -64, 0)
        row.PlayerValue = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        row.PlayerValue:SetFontObject(row.Value:GetFontObject())
        row.PlayerValue:SetPoint("LEFT", row, "RIGHT", -54, 0)
        frame.statsFrame["stat"..index] = row
        return row
    end
    local inspectStats, playerStats = {}, {}
    local _, inspectItemLevel = LibItemInfo:GetUnitItemLevel(unit, inspectStats)
    local _, playerItemLevel  = LibItemInfo:GetUnitItemLevel("player", playerStats)
    local baseInfo = {}
    table.insert(baseInfo, {label = LEVEL, iv = UnitLevel(unit), pv = UnitLevel("player") })
    table.insert(baseInfo, {label = STAT_AVERAGE_ITEM_LEVEL, iv = format("%.1f",inspectItemLevel), pv = format("%.1f",playerItemLevel) })
    table.insert(baseInfo, {label = HEALTH, iv = AbbreviateLargeNumbers(UnitHealthMax(unit)), pv = AbbreviateLargeNumbers(UnitHealthMax("player")) })
    -- Disabled for now: querying inspected-unit mana in this paperdoll path can taint.
    -- local inspectMana = UnitPowerMax(unit, 0) or 0
    -- local playerMana = UnitPowerMax("player", 0) or 0
    -- table.insert(baseInfo, {label = MANA, iv = inspectMana > 0 and AbbreviateLargeNumbers(inspectMana) or "-", pv = playerMana > 0 and AbbreviateLargeNumbers(playerMana) or "-" })
    local index = 1
    for _, v in pairs(baseInfo) do
        local row = EnsureStatRow(index)
        row.Label:SetText(v.label)
        row.Label:SetTextColor(0.2, 1, 1)
        row.Value:SetText(v.iv)
        row.Value:SetTextColor(0, 0.7, 0.9)
        row.PlayerValue:SetText(v.pv)
        row.PlayerValue:SetTextColor(0, 0.7, 0.9)
        row.Background:SetShown(index%2~=0)
        row:Show()
        index = index + 1
    end
    local playerMain = GetMainStatKey("player")
    local inspectMain = playerMain
    local orderedKeys = {}
    if (playerMain) then
        table.insert(orderedKeys, playerMain)
    end
    local secondaryKeys = {
        STAT_CRITICAL_STRIKE,
        STAT_HASTE,
        STAT_MASTERY,
        STAT_VERSATILITY,
        STAT_AVOIDANCE,
        STAT_SPEED,
        STAT_LIFESTEAL,
    }
    for _, key in ipairs(secondaryKeys) do
        table.insert(orderedKeys, key)
    end
    for _, key in ipairs(orderedKeys) do
        if (allowedStats[key]) then
            local iv = GetStatValueFromUnit(inspectStats, key, unit)
            local pv = GetStatValueFromUnit(playerStats, key, "player")
            if (iv ~= nil or pv ~= nil) then
                local row = EnsureStatRow(index)
                row.Label:SetText(key)
                local color = (key == playerMain or key == inspectMain) and mainStatColor or statColor
                row.Label:SetTextColor(color.r, color.g, color.b)
                row.Value:SetText(iv ~= nil and iv or "-")
                row.Value:SetTextColor(color.r, color.g, color.b)
                row.PlayerValue:SetText(pv ~= nil and pv or "-")
                row.PlayerValue:SetTextColor(color.r, color.g, color.b)
                row.Background:SetShown(index%2~=0)
                row:Show()
                index = index + 1
            end
        end
    end
    frame.statsFrame:SetHeight(index*17-10)
    while (frame.statsFrame["stat"..index]) do
        frame.statsFrame["stat"..index]:Hide()
        index = index + 1
    end
end

hooksecurefunc("ShowInspectItemListFrame", function(unit, parent, itemLevel, maxLevel)
    local frame = parent.inspectFrame
    if (not frame) then return end
    if (unit == "player") then return end
    if (TinyInspectRemakeDB and not TinyInspectRemakeDB.ShowItemStats) then
        if (frame.statsFrame) then frame.statsFrame:Hide() end
        return
    end
    ShowInspectItemStatsFrame(frame, unit)
end)
