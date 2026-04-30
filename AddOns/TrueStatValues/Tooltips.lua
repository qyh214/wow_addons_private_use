local name, addon = ...

local function RGBPercToHex(r, g, b)
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end
local masteryName = nil;

local statLabelMap = {
    [CR_MASTERY] = function()
        local primaryTalentTree = GetSpecialization()
        if (primaryTalentTree) then
            local masterySpell, masterySpell2 = GetSpecializationMasterySpells(primaryTalentTree)
            if (masterySpell) then
                local name = C_Spell.GetSpellName(masterySpell)
                masteryName = name;
                return name
            end
        end
        return nil
    end,
    [CR_CRIT_SPELL] = function()
        return format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE)
    end,
    [CR_VERSATILITY_DAMAGE_DONE] = function()
        return format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_VERSATILITY)
    end,
    [CR_HASTE_SPELL] = function()
        return format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE)
    end,
    [CR_LIFESTEAL] = function()
		return format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL)
	end,
	[CR_AVOIDANCE] = function()
		return format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE)
	end,
	[CR_SPEED] = function()
		return format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPEED)
	end
}

local extraStatLabelMap = {
    [CR_MASTERY] = function()
        return format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MASTERY)
    end
}

local statEventMap = {
    [CR_MASTERY] = "OnTooltipSetSpell",
    [CR_CRIT_SPELL] = "OnShow",
    [CR_VERSATILITY_DAMAGE_DONE] = "OnShow",
    [CR_HASTE_SPELL] = "OnShow",
    [CR_LIFESTEAL] = "OnShow",
	[CR_AVOIDANCE] = "OnShow",
	[CR_SPEED] = "OnShow"
}
-- added an extra statevent map and label generator 
-- since mastery events are onShow then OnTooltipSetSpell
-- so certain addons / weakauras that re display this data tend to break.
local extraStatEventMap = {
    [CR_MASTERY] = "OnShow"
}

local patterns = {
    [CR_MASTERY] = {"%s([,0-9]+)%s*" .. STAT_MASTERY, STAT_MASTERY .. " by%s*([,0-9]+)"},
    [CR_CRIT_SPELL] = {"%s([,0-9]+)%s*" .. STAT_CRITICAL_STRIKE, STAT_CRITICAL_STRIKE .. " by%s*([,0-9]+)"},
    [CR_VERSATILITY_DAMAGE_DONE] = {"%s([,0-9]+)%s*" .. STAT_VERSATILITY, STAT_VERSATILITY .. " by%s*([,0-9]+)"},
    [CR_HASTE_SPELL] = {"%s([,0-9]+)%s*" .. STAT_HASTE, STAT_HASTE .. " by%s*([,0-9]+)"},
    [CR_LIFESTEAL] = {"%s([,0-9]+)%s*" .. STAT_LIFESTEAL, STAT_LIFESTEAL .. " by%s*([,0-9]+)"},
	[CR_AVOIDANCE] = {"%s([,0-9]+)%s*" .. STAT_AVOIDANCE, STAT_AVOIDANCE .. " by%s*([,0-9]+)"},
	[CR_SPEED] = {"%s([,0-9]+)%s*" .. STAT_SPEED, STAT_SPEED .. " by%s*([,0-9]+)"}
}

local blackList = {
    ["Leeching Poison"] = true,
    ["Thief's Versatility"] = true,
    ["Voodoo Mastery"] = true,
    ["Alchemical Mastery"] = true,
    ["Metamorphic Mastery"] = true,
	["闪避药剂"] = true, -- Delves
	["预见精通"] = true,
	["炼金精通"] = true,
	["转化精通"] = true
}

-- Custom progress bar to avoid taint from GameTooltip_ShowProgressBar/GameTooltip_InsertFrame
local tsvBarFrame = nil
local function TSV_ShowProgressBar(tooltip, min, max, value, barLabel, r, g, b)
    if not tsvBarFrame then
        tsvBarFrame = CreateFrame("Frame", "TSVProgressBarFrame", tooltip)
        tsvBarFrame:SetHeight(18)

        local bar = CreateFrame("StatusBar", nil, tsvBarFrame)
        bar:SetAllPoints()
        bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
        bar:SetStatusBarColor(1, 1, 1, 1)
        tsvBarFrame.Bar = bar

        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

        local label = bar:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        label:SetPoint("CENTER", bar, "CENTER", 0, 0)
        tsvBarFrame.Label = label
    end

    tsvBarFrame:SetParent(tooltip)
    tsvBarFrame:SetFrameStrata("TOOLTIP")
    tsvBarFrame:SetFrameLevel(tooltip:GetFrameLevel() + 1)
    tsvBarFrame.Bar:SetMinMaxValues(min, max)
    tsvBarFrame.Bar:SetValue(value)
    tsvBarFrame.Bar:SetStatusBarColor(r, g, b, 1)
    tsvBarFrame.Label:SetText(barLabel)

    -- Add a blank line to reserve space, then overlay our bar on top of it
    tooltip:AddLine(" ")
    tooltip:Show()

    local numLines = tooltip:NumLines()
    local lastLine = _G["GameTooltipTextLeft" .. numLines]
    if lastLine then
        local padding = 12
        tsvBarFrame:ClearAllPoints()
        tsvBarFrame:SetPoint("TOPLEFT", lastLine, "TOPLEFT", 0, 0)
        tsvBarFrame:SetPoint("RIGHT", tooltip, "RIGHT", -padding, 0)
        tsvBarFrame:Show()
    end
end

-- Hide custom bar when tooltip hides
GameTooltip:HookScript("OnHide", function()
    if tsvBarFrame then
        tsvBarFrame:Hide()
    end
end)

function addon.tsv:OnTooltip(ev, tooltip, ...)
    if (addon.tsv.db.global.showStatTooltips) then
        local tt1 = GameTooltipTextLeft1
        if (tt1) then
            local text = tt1:GetText()
            if (not issecretvalue(text) and text and not blackList[text]) then
                for statId, labelGenerator in pairs(statLabelMap) do
                    if (statEventMap[statId] == ev) then
                        local label = labelGenerator()
                        self:HandleLabel(label, tooltip, statId, text)
                    elseif (extraStatEventMap[statId] == ev) then
                        if(statId == CR_MASTERY and text ~= masteryName) then
                            local label = extraStatLabelMap[statId]();
                            self:HandleLabel(label, tooltip, statId, text)
                        end
                    end
                end
            end
        end
    end
    if (addon.tsv.db.global.showItemTooltips and ev == "OnTooltipSetItem") then
        local name, link = tooltip:GetItem()

        if (name ~= nil and link ~= nil) then
            local isEquipped = C_Item.IsEquippedItem(name)
            local itemString = select(3, string.find(link, "|H(.+)|h"))

            for i = 1, 20, 1 do
                local textleft = "GameTooltipTextLeft" .. tostring(i)
                if (_G[textleft] and _G[textleft].GetText) then
                    local text = _G[textleft]:GetText()
                    if (text and type(text) == "string" and not issecretvalue(text) and text ~= "") then
                        -- Skip lines containing percentage signs (exclude percentage values)
                        if (not string.find(text, "%%")) then
                            for statId, patternTable in pairs(patterns) do
                                local patternList = type(patternTable) == "table" and patternTable or {patternTable}
                                for _, pattern in ipairs(patternList) do
                                    local amount = string.match(text, pattern)
                                    if (amount) then
                                        local trueAmount = self:GetTrueStatRatingAdded(statId, amount)
                                        if trueAmount ~= nil then
                                            local s, e = string.find(text, pattern)
                                            local r, g, b =
                                                addon.tsv.db.global.fontColor.r,
                                                addon.tsv.db.global.fontColor.g,
                                                addon.tsv.db.global.fontColor.b
                                            local hexStr = RGBPercToHex(r, g, b)

                                            local trueText =
                                                text:sub(1, e) ..
                                                " |cff" .. hexStr .. "(" .. tostring(trueAmount) .. ")|r" .. text:sub(e + 1)
                                            _G[textleft]:SetText(trueText)
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        _G["FRM"] = tooltip
    end
end

function addon.tsv:AddTrueStatValuesTooltip(tooltip, statId)
    local statInfo = addon.TrueStatInfo and addon.TrueStatInfo[statId]
    if not statInfo
        or statInfo.bracketPenalty   == nil
        or statInfo.bracketRating    == nil
        or statInfo.bracketMaxRating == nil
        or statInfo.baseRating       == nil
        or statInfo.trueRating       == nil then
        return
    end
    local pctLabel = (statInfo.bracketPenalty > 0) and ("-" .. tostring(statInfo.bracketPenalty * 100) .. "%") or ("0%")
    local barLabel =
        tostring(statInfo.bracketRating) ..
        "/" .. tostring(statInfo.bracketMaxRating) .. " [" .. pctLabel .. " penalty]"
    local r, g, b = addon.tsv.db.global.fontColor.r, addon.tsv.db.global.fontColor.g, addon.tsv.db.global.fontColor.b

    -- barLabel = "|cff0000ff"..barLabel.."|r";
    local lostRating = (statInfo.baseRating - statInfo.trueRating)
    lostRating = math.floor(0.005 + 100 * lostRating) / 100

    tooltip:AddDoubleLine("True Rating:", statInfo.trueRating, r, g, b, r, g, b)
    tooltip:AddDoubleLine("Lost Rating:", lostRating, r, g, b, r, g, b)

    TSV_ShowProgressBar(tooltip, 0, statInfo.bracketMaxRating, statInfo.bracketRating, barLabel, r, g, b)

    tooltip:AddLine("\n")
    tooltip:Show()
end

function addon.tsv:HandleLabel(label, tooltip, statId, text)
    if (label) then
        label = label:gsub("%-", "%%-")
        local s, e = text:find(label)
        if (s and s <= 11) then
            self:AddTrueStatValuesTooltip(tooltip, statId)
        end
    end
end
