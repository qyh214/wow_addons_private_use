-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local LibStub = _G.LibStub
local ADDON_NAME, private = ...

-- Locales
local AL = LibStub("AceLocale-3.0"):GetLocale("RareScanner");

-- RareScanner database libraries
local RSNpcDB = private.ImportLib("RareScannerNpcDB")
local RSGeneralDB = private.ImportLib("RareScannerGeneralDB")
local RSConfigDB = private.ImportLib("RareScannerConfigDB")

-- RareScanner general libraries
local RSConstants = private.ImportLib("RareScannerConstants")
local RSLogger = private.ImportLib("RareScannerLogger")
local RSUtils = private.ImportLib("RareScannerUtils")

-- RareScanner services
local RSLoot = private.ImportLib("RareScannerLoot")
local RSLootTooltip = private.ImportLib("RareScannerLootTooltip")


RSLootMixin = { };

function RSLootMixin:OnLoad()
	self:SetScript("OnEvent", function(self, event, key, down)
		if (event ~= "MODIFIER_STATE_CHANGED") then
			return
		end
	
		if (down == 1) then
			local toolTip = self:GetParent().LootBarToolTip
			if (IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown() and toolTip:IsShown()) then
				GameTooltip_ShowCompareItem(toolTip)
			end
		elseif (down == 0) then
			local toolTip = self:GetParent().LootBarToolTip
			GameTooltip_HideShoppingTooltips(toolTip)
		end
	end)
end

function RSLootMixin:OnEnter()
	if (self:GetParent() and self:GetParent():GetParent()) then
		local itemLink, _, _, _, itemClassID, itemSubClassID = RSGeneralDB.GetItemInfo(self.itemID)

		local toolTip = self:GetParent().LootBarToolTip
		toolTip:SetOwner(self:GetParent():GetParent(), RSConfigDB:GetLootTooltipPosition())
		toolTip:SetHyperlink(self.itemLink)
		toolTip:SetParent(self)
	
		-- Adds extra information
		RSLootTooltip.AddRareScannerInformation(toolTip, itemLink, self.itemID, itemClassID, itemSubClassID)
		
		toolTip:Show()
		self:RegisterEvent("MODIFIER_STATE_CHANGED")

		self.Icon.Anim:Play();
	end
end

function RSLootMixin:OnLeave()
	self:GetParent().LootBarToolTip:Hide()
	self.Icon.Anim:Stop();
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
end

function RSLootMixin:OnMouseDown(button)
	RSLootTooltip.HandleInputEvents(button, self.itemLink, self.itemClassID, self.itemSubClassID, self.itemID)
end

function RSLootMixin:AddItem(itemID, numActive)
	local itemLink, _, _, iconFileDataID, itemClassID, itemSubClassID = RSGeneralDB.GetItemInfo(itemID)

	-- Set item icon
	self.Icon:SetTexture(iconFileDataID)
	self.itemID = itemID
	self.itemLink = itemLink
	self.itemClassID = itemClassID
	self.itemSubClassID = itemSubClassID
	self:Show()

	-- Add frame and position icons
	local colNum = numActive
	local rowNum = floor(numActive/RSConfigDB.GetNumItemsPerRow())
	if (floor(numActive%RSConfigDB.GetNumItemsPerRow()) == 0) then
		rowNum = floor(numActive/RSConfigDB.GetNumItemsPerRow()) - 1
	else
		rowNum = floor(numActive/RSConfigDB.GetNumItemsPerRow())
	end
	if (rowNum > 0) then
		colNum = numActive - (RSConfigDB.GetNumItemsPerRow() * rowNum)
	end
	self:SetPoint("TOPLEFT", (self:GetWidth() * (colNum - 1)), -(self:GetHeight() * rowNum))

	-- Recenter parent
	local maxWidth
	if (numActive < RSConfigDB.GetNumItemsPerRow()) then
		maxWidth = numActive
	else
		maxWidth = RSConfigDB.GetNumItemsPerRow()
	end

	self:GetParent():SetSize(self:GetWidth() * maxWidth, 20 * (floor(numActive/RSConfigDB.GetNumItemsPerRow()) + 1))
	self:GetParent():SetPoint("TOP", self:GetParent():GetParent(), "BOTTOM", 0, -3)
end
