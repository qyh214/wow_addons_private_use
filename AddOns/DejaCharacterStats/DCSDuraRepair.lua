local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

-- ---------------------------
-- -- DCS Durability Frames --
-- ---------------------------

local DCSITEM_SLOT_FRAMES = {
	CharacterHeadSlot,CharacterShoulderSlot,CharacterChestSlot,CharacterWristSlot,CharacterSecondaryHandSlot,
	CharacterHandsSlot,CharacterWaistSlot,CharacterLegsSlot,CharacterFeetSlot,CharacterMainHandSlot,
}

local DCSITEM_SLOT_FRAMES_RIGHT = {
	CharacterHeadSlot,CharacterShoulderSlot,CharacterChestSlot,CharacterWristSlot,CharacterSecondaryHandSlot,
}

local DCSITEM_SLOT_FRAMES_LEFT = {
	CharacterHandsSlot,CharacterWaistSlot,CharacterLegsSlot,CharacterFeetSlot,CharacterMainHandSlot,
}

local duraMean
local duraTotal
local duraMaxTotal
local duraFinite = 0

--------------------
-- Create Objects --
--------------------
local duraMeanFS = CharacterShirtSlot:CreateFontString("FontString","OVERLAY","GameTooltipText")
	duraMeanFS:SetPoint("CENTER",CharacterShirtSlot,"CENTER",1,-2)
	duraMeanFS:SetFont("Fonts\\FRIZQT__.TTF", 15, "THINOUTLINE")
	duraMeanFS:SetFormattedText("")

local duraMeanTexture = CharacterShirtSlot:CreateTexture(nil,"ARTWORK")

local duraDurabilityFrameFS = DurabilityFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	duraDurabilityFrameFS:SetPoint("CENTER",DurabilityFrame,"CENTER",0,0)
	duraDurabilityFrameFS:SetFont("Fonts\\FRIZQT__.TTF", 16, "THINOUTLINE")
	duraDurabilityFrameFS:SetFormattedText("")
	
for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
	v.duratexture = duraColorTexture
	v.duratexture = v:CreateTexture(nil,"ARTWORK")

	v.durability = duraFS
    v.durability = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
    v.durability:SetFormattedText("")

    v.itemrepair = itemrepairFS
    v.itemrepair = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
    v.itemrepair:SetFormattedText("")
end

local function DCS_Set_Dura_Item_Positions()
	for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
		v.durability:ClearAllPoints()
		v.itemrepair:ClearAllPoints()
		if DCS_ShowDuraCheck:GetChecked(true) then
			if DCS_ShowItemRepairCheck:GetChecked(true) then
				v.durability:SetPoint("TOP",v,"TOP",3,-30)
				v.durability:SetFont("Fonts\\FRIZQT__.TTF", 11, "THINOUTLINE")
				v.itemrepair:SetPoint("BOTTOM",v,"BOTTOM",1,3)
				v.itemrepair:SetFont("Fonts\\FRIZQT__.TTF", 11, "THINOUTLINE")
			elseif not DCS_ShowItemRepairCheck:GetChecked(true) then
				v.durability:SetPoint("CENTER",v,"CENTER",1,-2)
				v.durability:SetFont("Fonts\\FRIZQT__.TTF", 15, "THINOUTLINE")
			end
		elseif DCS_ShowDuraCheck:GetChecked(false) then
			v.durability:SetPoint("TOP",v,"TOP",3,-3)
			v.durability:SetFont("Fonts\\FRIZQT__.TTF", 11, "THINOUTLINE")
		end
		if DCS_ShowItemRepairCheck:GetChecked(true) then
			if DCS_ShowDuraCheck:GetChecked(true) then
				v.durability:SetPoint("TOP",v,"TOP",3,-3)
				v.durability:SetFont("Fonts\\FRIZQT__.TTF", 11, "THINOUTLINE")
				v.itemrepair:SetPoint("BOTTOM",v,"BOTTOM",1,3)
				v.itemrepair:SetFont("Fonts\\FRIZQT__.TTF", 11, "THINOUTLINE")
			elseif not DCS_ShowDuraCheck:GetChecked(true) then
				v.itemrepair:SetPoint("CENTER",v,"CENTER",0,-2)
				v.itemrepair:SetFont("Fonts\\FRIZQT__.TTF", 12, "THINOUTLINE")
			end
		elseif DCS_ShowItemRepairCheck:GetChecked(false) then
			v.itemrepair:SetPoint("BOTTOM",v,"BOTTOM",1,3)
			v.itemrepair:SetFont("Fonts\\FRIZQT__.TTF", 11, "THINOUTLINE")
		end
	end
end

---------------------------------
-- Durability Mean Calculation --
---------------------------------
local function DCS_Mean_DurabilityCalc()
	duraMean = 0
	duraTotal = 0
	duraMaxTotal = 0
	for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)
		-- --------------------------
		-- -- Mean Durability Calc --
		-- --------------------------
		if durCur == nil then durCur = 0 end
		if durMax == nil then durMax = 0 end
		if duraTotal == nil then duraTotal = 0 end
		if duraMaxTotal == nil then duraMaxTotal = 0 end
		if duraMean == nil then duraMean = 0 end
		
		duraTotal = duraTotal + durCur
		duraMaxTotal = duraMaxTotal + durMax
		if duraMaxTotal == 0 then duraMaxTotal = 1 	end
		duraMean = ((duraTotal/duraMaxTotal)*100)
	end
end		

-----------------------------------
-- Durability Frame Mean Display --
-----------------------------------
local function DCS_Durability_Frame_Mean_Display()
	DCS_Mean_DurabilityCalc()
	duraDurabilityFrameFS:SetFormattedText("%.0f%%", duraMean)
	duraDurabilityFrameFS:Show()
--	print(duraMean)
	if duraMean == 100 then 
		duraDurabilityFrameFS:Hide()
	elseif duraMean >= 80 then
		duraDurabilityFrameFS:SetTextColor(0.753, 0.753, 0.753)
	elseif duraMean > 66 then
		duraDurabilityFrameFS:SetTextColor(0, 1, 0)
	elseif duraMean > 33 then
		duraDurabilityFrameFS:SetTextColor(1, 1, 0)
	elseif duraMean >= 0 then
		duraDurabilityFrameFS:SetTextColor(1, 0, 0)
	end
end

-----------------------------------
-- Mean Durability Shirt Display --
-----------------------------------
local function DCS_Mean_Durability()
	DCS_Mean_DurabilityCalc()
	for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
		duraMeanTexture:SetSize(4, (31*(duraMean/100)))
		if duraMean == 100 then 
			duraMeanTexture:SetColorTexture(0, 0, 0, 0)
		elseif duraMean < 10 then
			duraMeanTexture:SetColorTexture(1, 0, 0)
			duraMeanFS:SetTextColor(1, 0, 0)
		elseif duraMean < 33 then
			duraMeanTexture:SetColorTexture(1, 0, 0)
			duraMeanFS:SetTextColor(1, 0, 0)
		elseif duraMean < 66 then
			duraMeanTexture:SetColorTexture(1, 1, 0)
			duraMeanFS:SetTextColor(1, 1, 0)
		elseif duraMean < 80 then
			duraMeanTexture:SetColorTexture(0, 1, 0)
			duraMeanFS:SetTextColor(0, 1, 0)
		elseif duraMean < 100 then
			duraMeanTexture:SetColorTexture(0.753, 0.753, 0.753)
			duraMeanFS:SetTextColor(0.753, 0.753, 0.753)
		end
		if duraMean > 10 then 
			duraMeanTexture:ClearAllPoints()
			duraMeanTexture:SetPoint("BOTTOMLEFT",CharacterShirtSlot,"BOTTOMRIGHT",1,3)
		elseif duraMean <= 10 then 
			duraMeanTexture:ClearAllPoints()
			duraMeanTexture:SetAllPoints(CharacterShirtSlot)
			duraMeanTexture:SetColorTexture(1, 0, 0, 0.15)
		end
		DCS_Durability_Frame_Mean_Display()
	end
end

-------------------------
-- Item Durability Top --
-------------------------
local function DCS_Item_DurabilityTop()
	for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)
		if durCur == nil or durMax == nil then
			v.duratexture:SetColorTexture(0, 0, 0, 0)
			v.durability:SetFormattedText("")
		elseif ( durCur == durMax ) then
			v.duratexture:SetColorTexture(0, 0, 0, 0)
			v.durability:SetFormattedText("")
		elseif ( durCur ~= durMax ) then
			duraFinite = ((durCur/durMax)*100)
			--print(duraFinite)
		    v.durability:SetFormattedText("%.0f%%", duraFinite)
			if duraFinite == 100 then
				v.duratexture:SetColorTexture(0,  0, 0, 0)
				v.durability:SetTextColor(0, 0, 0, 0)
			elseif duraFinite > 66 then
				v.duratexture:SetColorTexture(0, 1, 0)
				v.durability:SetTextColor(0, 1, 0)
			elseif duraFinite > 33 then
				v.duratexture:SetColorTexture(1, 1, 0)
				v.durability:SetTextColor(1, 1, 0)
			elseif duraFinite > 10 then
				v.duratexture:SetColorTexture(1, 0, 0)
				v.durability:SetTextColor(1, 0, 0)
			elseif duraFinite <= 10 then
				v.duratexture:SetAllPoints(v)
				v.duratexture:SetColorTexture(1, 0, 0, 0.10)
				v.durability:SetTextColor(1, 0, 0)
			end
		end
		DCS_Mean_DurabilityCalc()
	end
end

local _, gdbprivate = ...
gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsShowDuraChecked = {
	ShowDuraSetChecked = false,
}	

local DCS_ShowDuraCheck = CreateFrame("CheckButton", "DCS_ShowDuraCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowDuraCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowDuraCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowDuraCheck:ClearAllPoints()
	DCS_ShowDuraCheck:SetPoint("LEFT", 25, -75)
	DCS_ShowDuraCheck:SetScale(1.25)
	DCS_ShowDuraCheck.tooltipText = L["Displays each equipped item's durability."] --Creates a tooltip on mouseover.
	_G[DCS_ShowDuraCheck:GetName() .. "Text"]:SetText(L["Item Durability"])
	
DCS_ShowDuraCheck:SetScript("OnEvent", function(self, event, ...)
	local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraChecked
	self:SetChecked(checked.ShowDuraSetChecked)
	if self:GetChecked(true) then
		DCS_Set_Dura_Item_Positions()
		DCS_Item_DurabilityTop()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraChecked.ShowDuraSetChecked = true
	else
		for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.durability:SetFormattedText("")
		end
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraChecked.ShowDuraSetChecked = false
	end
end)

DCS_ShowDuraCheck:SetScript("OnClick", function(self,event,arg1) 
	if self:GetChecked(true) then
		DCS_Set_Dura_Item_Positions()
		DCS_Item_DurabilityTop()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraChecked.ShowDuraSetChecked = true
	else
		DCS_Set_Dura_Item_Positions()
		for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.durability:SetFormattedText("")
		end
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraChecked.ShowDuraSetChecked = false
	end
end)

--------------------------------------
-- Durability Bar Textures Creation --
--------------------------------------
local function DCS_Durability_Bar_Textures()
	for k, v in ipairs(DCSITEM_SLOT_FRAMES_RIGHT) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)

		if durCur == nil or durMax == nil then
			v.duratexture:SetColorTexture(0, 0, 0, 0)
		elseif ( durCur == durMax ) then
			v.duratexture:SetColorTexture(0, 0, 0, 0)
		elseif ( durCur ~= durMax ) then
			duraFinite = ((durCur/durMax)*100)
		end
		v.duratexture:SetPoint("BOTTOMLEFT",v,"BOTTOMRIGHT",1,3)
		v.duratexture:SetSize(4, (31*(duraFinite/100)))
		v.duratexture:Show()
		duraMeanTexture:Show()
	end
	for k, v in ipairs(DCSITEM_SLOT_FRAMES_LEFT) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)

		if durCur == nil or durMax == nil then
			v.duratexture:SetColorTexture(0, 0, 0, 0)
		elseif ( durCur == durMax ) then
			v.duratexture:SetColorTexture(0, 0, 0, 0)
		elseif ( durCur ~= durMax ) then
			duraFinite = ((durCur/durMax)*100)
		end
		v.duratexture:SetPoint("BOTTOMRIGHT",v,"BOTTOMLEFT",-2,3)
		v.duratexture:SetSize(3, (31*(duraFinite/100)))
		v.duratexture:Show()
		duraMeanTexture:Show()
	end
end

local _, gdbprivate = ...
gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsShowDuraTextureChecked = {
	ShowDuraTextureSetChecked = false,
}	

local DCS_ShowDuraTextureCheck = CreateFrame("CheckButton", "DCS_ShowDuraTextureCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowDuraTextureCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowDuraTextureCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowDuraTextureCheck:ClearAllPoints()
	DCS_ShowDuraTextureCheck:SetPoint("LEFT", 25, -25)
	DCS_ShowDuraTextureCheck:SetScale(1.25)
	DCS_ShowDuraTextureCheck.tooltipText = L["Displays a durability bar next to each item."] --Creates a tooltip on mouseover.
	_G[DCS_ShowDuraTextureCheck:GetName() .. "Text"]:SetText(L["Durability Bars"])
	
DCS_ShowDuraTextureCheck:SetScript("OnEvent", function(self, event, ...)
	local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraTextureChecked
	self:SetChecked(checked.ShowDuraTextureSetChecked)
	if self:GetChecked(true) then
		DCS_Durability_Bar_Textures()
		DCS_Mean_Durability()
		DCS_Item_DurabilityTop()
		duraMeanTexture:Show()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraTextureChecked.ShowDuraTextureSetChecked = true
	else
		for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.duratexture:Hide()
		end
		duraMeanTexture:Hide()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraTextureChecked.ShowDuraTextureSetChecked = false
	end
end)

DCS_ShowDuraTextureCheck:SetScript("OnClick", function(self,event,arg1) 
	if self:GetChecked(true) then
		DCS_Durability_Bar_Textures()
		DCS_Mean_Durability()
		DCS_Item_DurabilityTop()
		duraMeanTexture:Show()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraTextureChecked.ShowDuraTextureSetChecked = true
	else
		for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.duratexture:Hide()
		end
		duraMeanTexture:Hide()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDuraTextureChecked.ShowDuraTextureSetChecked = false
	end
end)

-----------------------
-- Durability "Stat" --
-----------------------
function PaperDollFrame_SetDurability(statFrame, unit)
	DCS_Mean_DurabilityCalc()

	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local displayDura = format("%.2f%%", duraMean);

	PaperDollFrame_SetLabelAndText(statFrame, (L["Durability"]), displayDura, false, duraMean);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, format(L["Durability %s"], displayDura));
	statFrame.tooltip2 = (L["Average equipped item durability percentage."]);

	local duraFinite = 0
	statFrame:Show();
end

local _, gdbprivate = ...
gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsShowAverageRepairChecked = {
	ShowAverageRepairSetChecked = false,
}	

local DCS_ShowAverageDuraCheck = CreateFrame("CheckButton", "DCS_ShowAverageDuraCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowAverageDuraCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowAverageDuraCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowAverageDuraCheck:ClearAllPoints()
	DCS_ShowAverageDuraCheck:SetPoint("LEFT", 25, -50)
	DCS_ShowAverageDuraCheck:SetScale(1.25)
	DCS_ShowAverageDuraCheck.tooltipText = L["Displays average item durability on the character shirt slot and durability frames."] --Creates a tooltip on mouseover.
	_G[DCS_ShowAverageDuraCheck:GetName() .. "Text"]:SetText(L["Average Durability"])
	
	DCS_ShowAverageDuraCheck:SetScript("OnEvent", function(self, event, ...)
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowAverageRepairChecked
		self:SetChecked(checked.ShowAverageRepairSetChecked)
		if self:GetChecked(true) then
			DCS_Mean_Durability()
			duraMeanFS:SetFormattedText("%.0f%%", duraMean)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowAverageRepairChecked.ShowAverageRepairSetChecked = true
		else
			duraMeanFS:SetFormattedText("")
			duraDurabilityFrameFS:Hide()
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowAverageRepairChecked.ShowAverageRepairSetChecked = false
		end
		if duraMean == 100 then 
			duraMeanFS:SetFormattedText("")
		end
	end)

	DCS_ShowAverageDuraCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowAverageRepairChecked
		if self:GetChecked(true) then
			DCS_Mean_Durability()
			duraMeanFS:SetFormattedText("%.0f%%", duraMean)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowAverageRepairChecked.ShowAverageRepairSetChecked = true
		else
			duraMeanFS:SetFormattedText("")
			duraDurabilityFrameFS:Hide()
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowAverageRepairChecked.ShowAverageRepairSetChecked = false
		end
		if duraMean == 100 then 
			duraMeanFS:SetFormattedText("")
		end
	end)

	
----------------------
-- Item Repair Cost --
----------------------
local function DCS_Item_RepairCostBottom()
	for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local scanTool = CreateFrame("GameTooltip")
			scanTool:ClearLines()
		local repairitemCost = select(3, scanTool:SetInventoryItem("player", slotId))
		if (repairitemCost<=0) then
			v.itemrepair:SetFormattedText("")
		elseif (repairitemCost>9999999) then
			v.itemrepair:SetTextColor(1, 0.843, 0)
			v.itemrepair:SetFormattedText("%.0fg", (repairitemCost/10000))
		elseif (repairitemCost<10000000) then
			v.itemrepair:SetTextColor(1, 0.843, 0)
			v.itemrepair:SetFormattedText("%.2fg", (repairitemCost/10000))
		elseif (repairitemCost<10000) then
			v.itemrepair:SetTextColor(0.753, 0.753, 0.753)
			v.itemrepair:SetFormattedText("%.2fs", (repairitemCost/100))
		elseif (repairitemCost<100) then
			v.itemrepair:SetTextColor(0.722, 0.451, 0.200)
			v.itemrepair:SetFormattedText("%.0fc", repairitemCost)
		end
	end
end

-----------------------
-- Total Repair Cost --
-----------------------
local repairitemCostTotal
local function DCS_Item_RepairTotal()
	for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local scanTool = CreateFrame("GameTooltip")
			scanTool:ClearLines()
		local repairnewitemCost = select(3, scanTool:SetInventoryItem("player", slotId))
		if repairitemCostTotal == nil then
			repairitemCostTotal = 0
		end
		local repairTotal = repairitemCostTotal + repairnewitemCost
		repairitemCostTotal = repairTotal
		--print(repairitemCostTotal)
	end
end

-------------------------
-- Repair Total "Stat" --
-------------------------
function PaperDollFrame_SetRepairTotal(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	DCS_Item_RepairTotal()
	local gold = floor(abs(repairitemCostTotal / 10000))
	local silver = floor(abs(mod(repairitemCostTotal / 100, 100)))
	local copper = floor(abs(mod(repairitemCostTotal, 100)))
	--print(format("I have %d gold %d silver %d copper.", gold, silver, copper))

	local displayRepairTotal = format("%dg %ds %dc", gold, silver, copper);

	--STAT_FORMAT
	-- PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue) -- Formatting

	PaperDollFrame_SetLabelAndText(statFrame, (L["Repair Total"]), displayRepairTotal, false, repairitemCostTotal);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, format(L["Repair Total %s"], displayRepairTotal));
	statFrame.tooltip2 = (L["Total equipped item repair cost before discounts."]);

	statFrame:Show();
	repairitemCostTotal = 0
end

local _, gdbprivate = ...
gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsShowItemRepairChecked = {
	ShowItemRepairSetChecked = false,
}	

local DCS_ShowItemRepairCheck = CreateFrame("CheckButton", "DCS_ShowItemRepairCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowItemRepairCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowItemRepairCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowItemRepairCheck:ClearAllPoints()
	DCS_ShowItemRepairCheck:SetPoint("LEFT", 25, -100)
	DCS_ShowItemRepairCheck:SetScale(1.25)
	DCS_ShowItemRepairCheck.tooltipText = L["Displays each equipped item's repair cost."] --Creates a tooltip on mouseover.
	_G[DCS_ShowItemRepairCheck:GetName() .. "Text"]:SetText(L["Item Repair Cost"])
	
DCS_ShowItemRepairCheck:SetScript("OnEvent", function(self, event, ...)
	local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowItemRepairChecked
	self:SetChecked(checked.ShowItemRepairSetChecked)
	if self:GetChecked(true) then
		DCS_Set_Dura_Item_Positions()
		DCS_Item_RepairCostBottom()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowItemRepairChecked.ShowItemRepairSetChecked = true
	else
		for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.itemrepair:SetFormattedText("")
		end
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowItemRepairChecked.ShowItemRepairSetChecked = false
	end
end)

DCS_ShowItemRepairCheck:SetScript("OnClick", function(self,event,arg1) 
	local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowItemRepairChecked
	if self:GetChecked(true) then
		DCS_Set_Dura_Item_Positions()
		DCS_Item_RepairCostBottom()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowItemRepairChecked.ShowItemRepairSetChecked = true
	else
		DCS_Set_Dura_Item_Positions()
		for k, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.itemrepair:SetFormattedText("")
		end
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowItemRepairChecked.ShowItemRepairSetChecked = false
	end
end)