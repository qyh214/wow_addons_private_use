local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

local _, private = ...
local _, gdbprivate = ...
local _, DCS_TableData = ...
local _, gdbprivate = ...
	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsItemLevelChecked = {
		ItemLevelEQ_AV_SetChecked = true,
		ItemLevelDecimalsSetChecked = false,
		ItemLevelTwoDecimalsSetChecked = true,
	}	


-----------------------
-- Item Level Checks --
-----------------------

	local DCS_ILvl_EQ_AV_Check = CreateFrame("CheckButton", "DCS_ILvl_EQ_AV_Check", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ILvl_EQ_AV_Check:RegisterEvent("PLAYER_LOGIN")
	DCS_ILvl_EQ_AV_Check:ClearAllPoints()
	DCS_ILvl_EQ_AV_Check:SetPoint("TOPLEFT", 25, -35)
	DCS_ILvl_EQ_AV_Check:SetScale(1.25)
	DCS_ILvl_EQ_AV_Check.tooltipText = 'Displays Equipped/Available item levels unless equal.' --Creates a tooltip on mouseover.
	_G[DCS_ILvl_EQ_AV_Check:GetName() .. "Text"]:SetText("Equipped/Available")
	
	DCS_ILvl_EQ_AV_Check:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
			local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked
			self:SetChecked(checked)
		end
	end)

	DCS_ILvl_EQ_AV_Check:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked = true
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked = false
		end
		PaperDollFrame_UpdateStats()
	end)

local DCS_ItemLevelDecimalPlacesCheck = CreateFrame("CheckButton", "DCS_ItemLevelDecimalPlacesCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemLevelDecimalPlacesCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemLevelDecimalPlacesCheck:ClearAllPoints()
	DCS_ItemLevelDecimalPlacesCheck:SetPoint("TOPLEFT", 65, -100)
	DCS_ItemLevelDecimalPlacesCheck:SetScale(1.00)
	DCS_ItemLevelDecimalPlacesCheck.tooltipText = 'Displays average item level to one decimal place.' --Creates a tooltip on mouseover.
	_G[DCS_ItemLevelDecimalPlacesCheck:GetName() .. "Text"]:SetText("Item Level 1 Decimal Place")
	
	DCS_ItemLevelDecimalPlacesCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked
			self:SetChecked(checked)
		end
	end)

	DCS_ItemLevelDecimalPlacesCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = true
			DCS_ItemLevelTwoDecimalsCheck:SetChecked(false)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = false
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = false
		end
		PaperDollFrame_UpdateStats()
	end)
	
local DCS_ItemLevelTwoDecimalsCheck = CreateFrame("CheckButton", "DCS_ItemLevelTwoDecimalsCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemLevelTwoDecimalsCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemLevelTwoDecimalsCheck:ClearAllPoints()
	DCS_ItemLevelTwoDecimalsCheck:SetPoint("TOPLEFT", 65, -120)
	DCS_ItemLevelTwoDecimalsCheck:SetScale(1.00)
	DCS_ItemLevelTwoDecimalsCheck.tooltipText = 'Displays average item level to two decimal places.' --Creates a tooltip on mouseover.
	_G[DCS_ItemLevelTwoDecimalsCheck:GetName() .. "Text"]:SetText("Item Level 2 Decimal Places")
	
	DCS_ItemLevelTwoDecimalsCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked
			self:SetChecked(checked)
		end
	end)

	DCS_ItemLevelTwoDecimalsCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = true
			DCS_ItemLevelDecimalPlacesCheck:SetChecked(false)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = false
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = false
		end
		PaperDollFrame_UpdateStats()
	end)

	
----------------------------
-- DCS Functions & Arrays --
----------------------------

function DCS_TableData:CopyTable(tab)
	local copy = {}
	for k, v in pairs(tab) do
        copy[k] = (type(v) == "table") and DCS_TableData:CopyTable(v) or v
	end
	return copy
end

function DCS_TableData:MergeTable(tab)
    local exists
	for i, v in ipairs(tab) do
        if (not self.StatData[v.statKey]) then
            table.remove(tab, i)
        end
    end
    for k in pairs(self.StatData) do
        exists = false 
        for _, v in ipairs(tab) do
            if (k == v.statKey) then exists = true end
        end
        if (not exists) then
            table.insert(tab, { statKey = k })
        end
    end
    return tab
end

function DCS_TableData:SwapStat(tab, statKey, dst)
    local src
    for i, v in ipairs(tab) do
        if (v.statKey == statKey) then
            src = v
            table.remove(tab, i)
        end
    end
    for i, v in ipairs(tab) do
        if (v.statKey == dst.statKey) then
            table.insert(tab, i, src or {statKey = statKey})
            break
        end
    end
    return tab
end

DCS_TableData.StatData = DCS_TableData:CopyTable(PAPERDOLL_STATINFO)

DCS_TableData.StatData.ItemLevelFrame = {
    category   = true,
    frame      = CharacterStatsPane.ItemLevelFrame,
    updateFunc = function(statFrame, unit)
		local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
		local DCS_DecimalPlaces
		
		if DCS_ItemLevelTwoDecimalsCheck:GetChecked(true) then
			DCS_DecimalPlaces = ("%.2f")
		elseif DCS_ItemLevelDecimalPlacesCheck:GetChecked(true) then
			DCS_DecimalPlaces = ("%.1f")
		else
			DCS_DecimalPlaces = ("%.0f")
		end
		
		if DCS_ILvl_EQ_AV_Check:GetChecked(true) then
			if (avgItemLevel == avgItemLevelEquipped) then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, format(DCS_DecimalPlaces,avgItemLevelEquipped), false, avgItemLevelEquipped)
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, format(DCS_DecimalPlaces .. ("/") .. DCS_DecimalPlaces,avgItemLevelEquipped,avgItemLevel), false, avgItemLevelEquipped)
			end
		else
			PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, format(DCS_DecimalPlaces,avgItemLevelEquipped), false, avgItemLevelEquipped)
		end
		statFrame:Show()
    end
}

DCS_TableData.StatData.AttributesCategory = {
    category   = true,
    frame      = CharacterStatsPane.AttributesCategory,
    updateFunc = function() end
}
DCS_TableData.StatData.EnhancementsCategory = {
    category   = true,
    frame      = CharacterStatsPane.EnhancementsCategory,
    updateFunc = function() end
}

DCS_TableData.StatData.GCD = {
    updateFunc = function(statFrame, unit)
        local haste = GetHaste()
        local gcd = max(0.75, 1.5 * 100 / (100+haste))
        PaperDollFrame_SetLabelAndText(statFrame, "Global Cooldown", format("%.2fs",gcd), false, gcd)
		
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, format("Global Cooldown %.2fs", gcd));
		statFrame.tooltip2 = ("General global cooldown for casters. Individual spells, set bonuses, talents, etc. not considered. Not suitable for melee. Improvements coming Soon(TM).");
    end
}

DCS_TableData.StatData.REPAIR_COST = {
    updateFunc = function(statFrame, unit)
        if (not statFrame.scanTooltip) then
            statFrame.scanTooltip = CreateFrame("GameTooltip", "StatRepairCostTooltip", statFrame, "GameTooltipTemplate")
            statFrame.scanTooltip:SetOwner(statFrame, "ANCHOR_NONE")
            statFrame.MoneyFrame = CreateFrame("Frame", "StatRepairCostMoneyFrame", statFrame, "TooltipMoneyFrameTemplate")
            MoneyFrame_SetType(statFrame.MoneyFrame, "TOOLTIP")
            statFrame.MoneyFrame:SetPoint("RIGHT", 3, -1)
            local font, size, flag = statFrame.Label:GetFont()
			--print (font, size, flag)
            statFrame.Label:SetFont(font, size, flag)
        end
        local totalCost = 0
        local _, repairCost
        for _, index in ipairs({1,3,5,6,7,8,9,10,16,17}) do
            statFrame.scanTooltip:ClearLines()
            _, _, repairCost = statFrame.scanTooltip:SetInventoryItem(unit, index)
            if (repairCost and repairCost > 0) then
                totalCost = totalCost + repairCost
            end
        end

        MoneyFrame_Update(statFrame.MoneyFrame, totalCost)
		statFrame.MoneyFrame:Hide()
		
		totalRepairCost = GetCoinTextureString(totalCost)
		
		local gold = floor(abs(totalCost / 10000))
		local silver = floor(abs(mod(totalCost / 100, 100)))
		local copper = floor(abs(mod(totalCost, 100)))
		--print(format("I have %d gold %d silver %d copper.", gold, silver, copper))

		local displayRepairTotal = format("%dg %ds %dc", gold, silver, copper);

		--STAT_FORMAT
		-- PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue) -- Formatting

		PaperDollFrame_SetLabelAndText(statFrame, ("Repair Total"), totalRepairCost, false, displayRepairTotal);
	
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, format("Repair Total %s", totalRepairCost));
		statFrame.tooltip2 = ("Total equipped item repair cost before discounts.");
    end
}
