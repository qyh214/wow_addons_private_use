local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local slots = {}
local iconSize = 32
local fontSize = math.floor(select(2, GameFontWhite:GetFont()) + .5)

local GOLD_SYMBOL = format("|cffFFD700%s|r", GOLD_AMOUNT_SYMBOL)
local SILVER_SYMBOL = format("|cffD0D0D0%s|r", SILVER_AMOUNT_SYMBOL)
local COPPER_SYMBOL = format("|cffC77050%s|r", COPPER_AMOUNT_SYMBOL)

local LightLoot = CreateFrame("Button", "LightLoot", UIParent, "BackdropTemplate")
LightLoot:RegisterForClicks("AnyUp")
LightLoot:SetFrameStrata("HIGH")
LightLoot:SetClampedToScreen(true)
LightLoot:SetParent(UIParent)
LightLoot:SetToplevel(true)
LightLoot:SetMovable(true)

LightLoot:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

LightLoot:SetScript("OnHide", function(self)
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
	CloseLoot()
end)

local Title = B.CreateFS(LightLoot, 18, "", false, "TOP", 0, 20)
LightLoot.Title = Title

local function OnEnter(self)
	local slot = self:GetID()
	if GetLootSlotType(slot) == LOOT_SLOT_ITEM then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end
	self.glow:Show()
end

local function OnLeave(self)
	self.glow:Hide()
	GameTooltip:Hide()
	ResetCursor()
end

local function OnClick(self)
	LootFrame.selectedLootButton = self
	LootFrame.selectedSlot = self:GetID()
	LootFrame.selectedQuality = self.lootQuality
	LootFrame.selectedItemName = self.name:GetText()

	if IsModifiedClick() then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSlot(self:GetID())
	end
end

local function OnUpdate(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

local function CreateSlot(id)
	local button = CreateFrame("Button", "LightLootSlot"..id, LightLoot, "BackdropTemplate")
	button:SetHeight(math.max(fontSize, iconSize))
	button:SetPoint("LEFT", LightLoot, "LEFT", DB.margin, 0)
	button:SetPoint("RIGHT", LightLoot, "RIGHT", -DB.margin, 0)
	button:SetID(id)

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)
	button:SetScript("OnClick", OnClick)
	button:SetScript("OnUpdate", OnUpdate)

	local icBD = CreateFrame("Frame", nil, button, "BackdropTemplate")
	icBD:SetSize(iconSize, iconSize)
	icBD:SetPoint("LEFT", button, "LEFT")
	B.CreateBD(icBD, .25)
	button.icBD = icBD

	local icon = icBD:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon:SetInside(icBD)
	button.icon = icon

	local glow = button:CreateTexture(nil, "HIGHLIGHT")
	glow:SetAlpha(.5)
	glow:SetPoint("TOPLEFT", icBD, "TOPRIGHT", DB.margin, 0)
	glow:SetPoint("BOTTOMLEFT", icBD, "BOTTOMRIGHT", DB.margin, 0)
	glow:SetPoint("RIGHT", button, "RIGHT")
	glow:SetTexture(DB.bdTex)
	glow:SetVertexColor(cr, cg, cb)
	glow:Hide()
	button.glow = glow

	local name = B.CreateFS(icBD, 14, "")
	name:SetJustifyH("LEFT")
	name:SetNonSpaceWrap(true)
	B.UpdatePoint(name, "LEFT", icon, "RIGHT", DB.margin, 0)
	button.name = name

	local count = B.CreateFS(icBD, 14, "", false, "BOTTOMRIGHT", -1, 1)
	button.count = count

	local quest = B.CreateFS(icBD, 14, "!", false, "LEFT", 3, 0)
	button.quest = quest

	slots[id] = button
	return button
end

function LightLoot:UpdateWidth()
	local maxWidth = 0
	for _, slot in pairs(slots) do
		if slot:IsShown() then
			local width = slot.name:GetStringWidth()
			if width > maxWidth then
				maxWidth = width
			end
		end
	end

	self:SetWidth(math.max(maxWidth + iconSize + DB.margin*3, self.Title:GetStringWidth()))
end

function LightLoot:UpdateHeight()
	local shownSlots = 0

	for _, slot in pairs(slots) do
		if slot:IsShown() then
			shownSlots = shownSlots + 1
			slot:SetPoint("TOP", LightLoot, "TOP", 0, (-DB.margin + iconSize) - (shownSlots * iconSize) - (shownSlots - 1) * DB.margin)
		end
	end

	self:SetHeight(math.max(shownSlots * iconSize + DB.margin*2 + (shownSlots - 1) * DB.margin , iconSize))
end

function LightLoot:LOOT_OPENED(event, autoloot)
	self:Show()

	if not self:IsShown() then
		CloseLoot(not autoLoot)
	end

	if IsFishingLoot() then
		self.Title:SetText(PROFESSIONS_FISHING)
	elseif UnitIsDead("target") then
		self.Title:SetText(UnitName("target"))
	else
		self.Title:SetText(LOOT)
	end

	if GetCVar("lootUnderMouse") == "1" then
		local x, y = GetCursorPosition()
		x = x / self:GetEffectiveScale()
		y = y / self:GetEffectiveScale()

		self:Raise()
		self:GetCenter()
		B.UpdatePoint(self, "TOPLEFT", UIParent, "BOTTOMLEFT", x - 40, y + 20)
	else
		self:SetUserPlaced(false)
		B.UpdatePoint(self, "CENTER", UIParent, "CENTER", 300, 0)
	end

	local maxQuality = 0
	local items = GetNumLootItems()
	if items > 0 then
		for i = 1, items do
			local slot = slots[i] or CreateSlot(i)
			local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i)
			if lootIcon then
				local r, g, b = C_Item.GetItemQualityColor(lootQuality)
				local slotType = GetLootSlotType(i)

				if slotType == Enum.LootSlotType.Money then
					lootName = lootName:gsub("\n", "，")
				end

				if lootQuantity and lootQuantity > 1 then
					slot.count:SetText(B.Numb(lootQuantity))
					slot.count:Show()
				else
					slot.count:Hide()
				end

				if questId and not isActive then
					slot.quest:Show()
				else
					slot.quest:Hide()
				end

				if (lootQuality and lootQuality >= 0) or questId or isQuestItem then
					if questId or isQuestItem then
						r, g, b = 1, .8, 0
					end
					slot.name:SetTextColor(r, g, b)
					slot.icBD:SetBackdropBorderColor(r, g, b)
				else
					slot.name:SetTextColor(.5, .5, .5)
					slot.icBD:SetBackdropBorderColor(.5, .5, .5)
				end

				slot.lootQuality = lootQuality
				slot.isQuestItem = isQuestItem

				slot.name:SetText(lootName)
				slot.icon:SetTexture(lootIcon)

				maxQuality = math.max(maxQuality, lootQuality)

				slot:Enable()
				slot:Show()
			end
		end
	else
		local slot = slots[1] or CreateSlot(1)

		slot.name:SetText(NONE)
		slot.name:SetTextColor(.5, .5, .5)
		slot.icon:SetTexture(nil)

		slot.count:Hide()
		slot.quest:Hide()
		slot.glow:Hide()
		slot:Disable()
		slot:Show()
	end

	local r, g, b = C_Item.GetItemQualityColor(maxQuality)
	self.bd:SetBackdropBorderColor(r, g, b)
	self.Title:SetTextColor(r, g, b)

	if self.bd.__shadow then
		self.bd.__shadow:SetBackdropBorderColor(r, g, b)
	end

	self:UpdateHeight()
	self:UpdateWidth()
end
LightLoot:RegisterEvent("LOOT_OPENED")

function LightLoot:LOOT_SLOT_CLEARED(event, slot)
	if not self:IsShown() then return end

	slots[slot]:Hide()
	self:UpdateHeight()
end
LightLoot:RegisterEvent("LOOT_SLOT_CLEARED")

function LightLoot:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	self:Hide()

	for _, slot in pairs(slots) do
		slot:Hide()
	end
end
LightLoot:RegisterEvent("LOOT_CLOSED")

function LightLoot:OPEN_MASTER_LOOT_LIST()
	MasterLooterFrame_Show(LootFrame.selectedLootButton)
end
LightLoot:RegisterEvent("OPEN_MASTER_LOOT_LIST")

function LightLoot:UPDATE_MASTER_LOOT_LIST()
	if LootFrame.selectedLootButton then
		MasterLooterFrame_UpdatePlayers()
	end
end
LightLoot:RegisterEvent("UPDATE_MASTER_LOOT_LIST")

function LightLoot:PLAYER_LOGIN()
	LightLoot.bd = B.SetBD(LightLoot)
end
LightLoot:RegisterEvent("PLAYER_LOGIN")

LootFrame:UnregisterAllEvents()
table.insert(UISpecialFrames, "LightLoot")

-- fix blizzard setpoint connection bs
hooksecurefunc(MasterLooterFrame, 'Hide', MasterLooterFrame.ClearAllPoints)
