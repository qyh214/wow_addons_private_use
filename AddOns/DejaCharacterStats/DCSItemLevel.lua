-- Item Level Check

	local _, gdbprivate = ...
	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsItemLevelChecked = {
		ItemLevelSetChecked = true,
		ItemLevelDecimalsSetChecked = false,
	}	
	
local function DCS_ItemLevelShow(self)
	function PaperDollFrame_SetItemLevel(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end

		local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel();

		if gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked == true then
			-- print(avgItemLevel, avgItemLevelEquipped)
			if ( avgItemLevelEquipped == avgItemLevel ) then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, format("%.2f", avgItemLevelEquipped), false, avgItemLevelEquipped);
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, (format("%.2f", avgItemLevelEquipped).."/"..format("%.2f", avgItemLevel)), false, avgItemLevelEquipped);
			end
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevel;
			if ( avgItemLevelEquipped ~= avgItemLevel ) then
				statFrame.tooltip = statFrame.tooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped);
			end
			statFrame.tooltip = statFrame.tooltip .. FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP;
		else
			avgItemLevel = floor(avgItemLevel);
			avgItemLevelEquipped = floor(avgItemLevelEquipped);
			if ( avgItemLevelEquipped == avgItemLevel ) then
				PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, avgItemLevelEquipped, false, avgItemLevelEquipped);
			else
				PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, ((avgItemLevelEquipped).."/"..avgItemLevel), false, avgItemLevelEquipped);
			end
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevel;
			if ( avgItemLevelEquipped ~= avgItemLevel ) then
				statFrame.tooltip = statFrame.tooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped);
			end
			statFrame.tooltip = statFrame.tooltip .. FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP;
		end
	end	
	PaperDollFrame_UpdateStats()
end

local function DCS_ItemLevelHide(self)
	function PaperDollFrame_SetItemLevel(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end

		local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel();
		avgItemLevel = floor(avgItemLevel);
		avgItemLevelEquipped = floor(avgItemLevelEquipped);
		PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, avgItemLevelEquipped, false, avgItemLevelEquipped);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevel;
		if ( avgItemLevelEquipped ~= avgItemLevel ) then
			statFrame.tooltip = statFrame.tooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped);
		end
		statFrame.tooltip = statFrame.tooltip .. FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP;
	end
	PaperDollFrame_UpdateStats()
end

local DCS_ItemLevelCheck = CreateFrame("CheckButton", "DCS_ItemLevelCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemLevelCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemLevelCheck:ClearAllPoints()
	DCS_ItemLevelCheck:SetPoint("TOPLEFT", 25, -35)
	DCS_ItemLevelCheck:SetScale(1.25)
	DCS_ItemLevelCheck.tooltipText = 'Displays Equipped/Available item levels unless equal.' --Creates a tooltip on mouseover.
	_G[DCS_ItemLevelCheck:GetName() .. "Text"]:SetText("Equipped/Available")
	
	DCS_ItemLevelCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked
			self:SetChecked(checked.ItemLevelSetChecked)
			if self:GetChecked(true) then
				DCS_ItemLevelShow()
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelSetChecked = true
			else
				DCS_ItemLevelHide()
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelSetChecked = false
			end
		end
	end)

	DCS_ItemLevelCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked
		if self:GetChecked(true) then
			DCS_ItemLevelShow()
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelSetChecked = true
		else
			DCS_ItemLevelHide()
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelSetChecked = false
		end
	end)
	
local DCS_ItemLevelDecimalCheck = CreateFrame("CheckButton", "DCS_ItemLevelDecimalCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemLevelDecimalCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemLevelDecimalCheck:ClearAllPoints()
	DCS_ItemLevelDecimalCheck:SetPoint("TOPLEFT", 65, -100)
	DCS_ItemLevelDecimalCheck:SetScale(1.00)
	DCS_ItemLevelDecimalCheck.tooltipText = 'Displays average item level to two decimal places.' --Creates a tooltip on mouseover.
	_G[DCS_ItemLevelDecimalCheck:GetName() .. "Text"]:SetText("Ilvl Decimals")
	
	DCS_ItemLevelDecimalCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked
			self:SetChecked(checked.ItemLevelDecimalsSetChecked)
			if self:GetChecked(true) then
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = true
			else
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = false
			end
		end
	end)

	DCS_ItemLevelDecimalCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = true
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = false
		end
		PaperDollFrame_UpdateStats()
	end)