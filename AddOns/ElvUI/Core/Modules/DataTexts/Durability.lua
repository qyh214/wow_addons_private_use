local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local select, wipe = select, wipe
local format, pairs = format, pairs
local GetInventoryItemDurability = GetInventoryItemDurability
local ToggleCharacter = ToggleCharacter
local InCombatLockdown = InCombatLockdown
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemLink = GetInventoryItemLink
local GetMoneyString = GetMoneyString

local DURABILITY = DURABILITY
local REPAIR_COST = REPAIR_COST
local tooltipString = '%d%%'
local totalDurability = 0
local invDurability = {}
local totalRepairCost
local db

local slots = {
	[1] = _G.INVTYPE_HEAD,
	[3] = _G.INVTYPE_SHOULDER,
	[5] = _G.INVTYPE_CHEST,
	[6] = _G.INVTYPE_WAIST,
	[7] = _G.INVTYPE_LEGS,
	[8] = _G.INVTYPE_FEET,
	[9] = _G.INVTYPE_WRIST,
	[10] = _G.INVTYPE_HAND,
	[16] = _G.INVTYPE_WEAPONMAINHAND,
	[17] = _G.INVTYPE_WEAPONOFFHAND,
	[18] = _G.INVTYPE_RANGED,
}

local function OnEvent(self)
	totalDurability = 100
	totalRepairCost = 0

	wipe(invDurability)

	for index in pairs(slots) do
		local currentDura, maxDura = GetInventoryItemDurability(index)
		if currentDura and maxDura > 0 then
			local perc, repairCost = (currentDura/maxDura)*100
			invDurability[index] = perc

			if perc < totalDurability then
				totalDurability = perc
			end

			if E.Retail and E.ScanTooltip.GetTooltipData then
				E.ScanTooltip:SetInventoryItem('player', index)
				E.ScanTooltip:Show()

				local data = E.ScanTooltip:GetTooltipData()
				repairCost = data and data.repairCost
			else
				repairCost = select(3, E.ScanTooltip:SetInventoryItem('player', index))
			end

			totalRepairCost = totalRepairCost + (repairCost or 0)
		end
	end

	local r, g, b = E:ColorGradient(totalDurability * .01, 1, .1, .1, 1, 1, .1, .1, 1, .1)
	local hex = E:RGBToHex(r, g, b)

	if db.NoLabel then
		self.text:SetFormattedText('%s%d%%|r', hex, totalDurability)
	else
		self.text:SetFormattedText('%s%s%d%%|r', db.Label ~= '' and db.Label or (DURABILITY..': '), hex, totalDurability)
	end

	if totalDurability <= db.percThreshold then
		E:Flash(self, 0.53, true)
	else
		E:StopFlash(self)
	end
end

local function Click()
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
	ToggleCharacter('PaperDollFrame')
end

local function OnEnter()
	DT.tooltip:ClearLines()

	for slot, durability in pairs(invDurability) do
		DT.tooltip:AddDoubleLine(format('|T%s:14:14:0:0:64:64:4:60:4:60|t %s', GetInventoryItemTexture('player', slot), GetInventoryItemLink('player', slot)), format(tooltipString, durability), 1, 1, 1, E:ColorGradient(durability * 0.01, 1, .1, .1, 1, 1, .1, .1, 1, .1))
	end

	if totalRepairCost > 0 then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine(REPAIR_COST, GetMoneyString(totalRepairCost), .6, .8, 1, 1, 1, 1)
	end

	DT.tooltip:Show()
end

local function ApplySettings(self)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end
end

DT:RegisterDatatext('Durability', nil, {'UPDATE_INVENTORY_DURABILITY', 'MERCHANT_SHOW'}, OnEvent, nil, Click, OnEnter, nil, DURABILITY, nil, ApplySettings)
