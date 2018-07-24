local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local DT = E:GetModule('DataTexts')
local PD = E:GetModule('PaperDoll')

local displayString = ''
local lastPanel
local floor = math.floor

local slots = {
	[1] = { "HeadSlot", HEADSLOT },
	[2] = { "NeckSlot", NECKSLOT },
	[3] = { "ShoulderSlot", SHOULDERSLOT },
	[4] = { "BackSlot", BACKSLOT },
	[5] = { "ChestSlot", CHESTSLOT },
	[6] = { "WristSlot", WRISTSLOT },
	[7] = { "HandsSlot", HANDSSLOT },
	[8] = { "WaistSlot", WAISTSLOT },
	[9] = { "LegsSlot", LEGSSLOT },
	[10] = { "FeetSlot", FEETSLOT },
	[11] = { "Finger0Slot", FINGER0SLOT_UNIQUE },
	[12] = { "Finger1Slot", FINGER1SLOT_UNIQUE },
	[13] = { "Trinket0Slot", TRINKET0SLOT_UNIQUE },
	[14] = { "Trinket1Slot", TRINKET1SLOT_UNIQUE },
	[15] = { "MainHandSlot", MAINHANDSLOT },
	[16] = { "SecondaryHandSlot", SECONDARYHANDSLOT },
}

local levelColors = {
	[0] = { 1, 0, 0 },
	[1] = { 0, 1, 0 },
	[2] = { 1, 1, .5 },
}

local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		PD:ScheduleTimer("UpdateDataTextItemLevel", 5, self)
		return
	end
	PD:UpdateDataTextItemLevel(self)
end

function PD:UpdateDataTextItemLevel(self)
	local	avgItemLevel, avgEquipItemLevel = GetAverageItemLevel()
	self.text:SetFormattedText(displayString, L["Item Level"], floor(avgItemLevel), floor(avgEquipItemLevel))
end

local function OnEnter(self)
	local	avgItemLevel, avgEquipItemLevel = GetAverageItemLevel()
	local color, itemLink, itemLevel
	
	DT:SetupTooltip(self)
	DT.tooltip:AddDoubleLine(TOTAL, floor(avgItemLevel), 1, 1, 1, 0, 1, 0)
	DT.tooltip:AddDoubleLine(GMSURVEYRATING3, floor(avgEquipItemLevel), 1, 1, 1, 0, 1, 0)
	DT.tooltip:AddLine(" ")
	for i = 1, 16 do
		itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slots[i][1]))
		if itemLink then
  		itemLevel = PD:GetItemLevel("player", itemLink)
      if itemLevel and avgEquipItemLevel then
      	color = levelColors[(itemLevel < avgEquipItemLevel - 10 and 0 or (itemLevel > avgEquipItemLevel + 10 and 1 or (2)))]
      	DT.tooltip:AddDoubleLine(slots[i][2], itemLevel, 1, 1, 1, color[1], color[2], color[3])
      end
		end
	end
	DT.tooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = string.join("", "|cffffffff%s:|r", " ", hex, "%d / %d|r")
	if lastPanel ~= nil then OnEvent(lastPanel) end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext(L["Item Level"], {"PLAYER_ENTERING_WORLD", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, OnEvent, nil, nil, OnEnter)
