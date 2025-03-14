local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)

---@class Frame
ham.settingsFrame = CreateFrame("Frame")
local ICON_SIZE = 50
local PADDING_CATERGORY = 60
local PADDING = 30
local PADDING_HORIZONTAL = 200
local PADDING_PRIO_CATEGORY = 130
local classButtons = {}
local prioFrames = {}
local prioTextures = {}
local prioFramesCounter = 0
local firstIcon = nil
local positionx = 0
local currentPrioTitle = nil
local lastStaticElement = nil

function ham.settingsFrame:updateConfig(option, value)
	if ham.options[option] ~= nil then
		ham.options[option] = value -- Update in-memory
		HAMDB[option] = value       -- Persist to DB
	else
		print(L["Invalid option: "] .. tostring(option))
	end
	-- Rebuild the macro and update priority frame
	ham.checkTinker()
	ham.updateHeals()
	ham.updateMacro()
	self:updatePrio()
end

function ham.settingsFrame:OnEvent(event, addOnName)
	if addOnName == "AutoPotion" then
		if event == "ADDON_LOADED" then
			HAMDB = HAMDB or CopyTable(ham.defaults)
			if HAMDB.activatedSpells == nil then
				print(L["The Settings of AutoPotion were reset due to breaking changes."])
				HAMDB = CopyTable(ham.defaults)
			end
			self:InitializeOptions()
		end
	end
	if event == "PLAYER_LOGIN" then
		self:InitializeClassSpells(lastStaticElement)
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
	end
end

ham.settingsFrame:RegisterEvent("PLAYER_LOGIN")
ham.settingsFrame:RegisterEvent("ADDON_LOADED")
ham.settingsFrame:SetScript("OnEvent", ham.settingsFrame.OnEvent)

function ham.settingsFrame:createPrioFrame(id, iconTexture, positionx, isSpell, isTinker)
	local icon = CreateFrame("Frame", nil, self.content, UIParent)
	icon:SetFrameStrata("MEDIUM")
	icon:SetWidth(ICON_SIZE)
	icon:SetHeight(ICON_SIZE)
	icon:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(icon, "ANCHOR_TOPRIGHT")
		if isSpell == true then
			GameTooltip:SetSpellByID(id)
		elseif isTinker then
			GameTooltip:SetInventoryItem("player", id)
		else
			GameTooltip:SetItemByID(id)
		end
		GameTooltip:Show()
	end)
	icon:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	local texture = icon:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture(iconTexture)
	texture:SetAllPoints(icon)
	---@diagnostic disable-next-line: inject-field
	icon.texture = texture

	if firstIcon == nil then
		icon:SetPoint("BOTTOMLEFT", 0, PADDING_PRIO_CATEGORY - PADDING * 2)
		firstIcon = icon
	else
		icon:SetPoint("TOPLEFT", firstIcon, positionx, 0)
	end
	icon:Show()
	table.insert(prioFrames, icon)
	table.insert(prioTextures, texture)
	prioFramesCounter = prioFramesCounter + 1
	return icon
end

function ham.settingsFrame:updatePrio()
	local spellCounter = 0
	local itemCounter = 0

	for i, frame in pairs(prioFrames) do
		frame:Hide()
	end

	-- Add spells to priority frames
	if next(ham.spellIDs) ~= nil then
		for i, id in ipairs(ham.spellIDs) do
			local iconTexture, originalIconTexture
			if isRetail == true then
				iconTexture, originalIconTexture = C_Spell.GetSpellTexture(id)
			else
				iconTexture = GetSpellTexture(id)
			end
			local currentFrame = prioFrames[i]
			local currentTexture = prioTextures[i]
			if currentFrame ~= nil then
				currentFrame:SetScript("OnEnter", nil)
				currentFrame:SetScript("OnLeave", nil)
				currentFrame:HookScript("OnEnter", function(_, btn, down)
					GameTooltip:SetOwner(currentFrame, "ANCHOR_TOPRIGHT")
					GameTooltip:SetSpellByID(id)
					GameTooltip:Show()
				end)
				currentFrame:HookScript("OnLeave", function(_, btn, down)
					GameTooltip:Hide()
				end)
				currentTexture:SetTexture(iconTexture)
				currentTexture:SetAllPoints(currentFrame)
				currentFrame.texture = currentTexture
				currentFrame:Show()
			else
				self:createPrioFrame(id, iconTexture, positionx, true, false)
				positionx = positionx + (ICON_SIZE + (ICON_SIZE / 2))
			end
			spellCounter = spellCounter + 1
		end
	end

	-- Add items to priority frames
	if next(ham.itemIdList) ~= nil then
		for i, id in ipairs(ham.itemIdList) do
			local entry
			local iconTexture
			local isTinker = false

			-- if the entry is a gear slot (ie: tinker)
			if type(id) == "string" and id:match("^slot:") then
				local slot = assert(tonumber(id:sub(6)), "Invalid slot number")
				entry = GetInventoryItemID("player", slot)
				iconTexture = GetInventoryItemTexture("player", slot)
				isTinker = true
				-- otherwise its a normal item id
			else
				local _, _, _, _, _, _, _, _, _, tmpTexture = C_Item.GetItemInfo(id)
				entry = id
				iconTexture = tmpTexture
			end

			local currentFrame = prioFrames[i + spellCounter]
			local currentTexture = prioTextures[i + spellCounter]

			if currentFrame ~= nil then
				currentFrame:SetScript("OnEnter", nil)
				currentFrame:SetScript("OnLeave", nil)
				currentFrame:HookScript("OnEnter", function(_, btn, down)
					GameTooltip:SetOwner(currentFrame, "ANCHOR_TOPRIGHT")
					if isTinker then
						GameTooltip:SetInventoryItem("player", ham.tinkerSlot)
					else
						GameTooltip:SetItemByID(id)
					end
					GameTooltip:Show()
				end)
				currentFrame:HookScript("OnLeave", function(_, btn, down)
					GameTooltip:Hide()
				end)
				currentTexture:SetTexture(iconTexture)
				currentTexture:SetAllPoints(currentFrame)
				currentFrame.texture = currentTexture
				currentFrame:Show()
			else
				self:createPrioFrame(entry, iconTexture, positionx, false, isTinker)
				positionx = positionx + (ICON_SIZE + (ICON_SIZE / 2))
			end
			itemCounter = itemCounter + 1
		end
	end
end

function ham.settingsFrame:InitializeOptions()
	-- Create the main panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName, InterfaceOptionsFramePanelContainer)
	self.panel.name = addonName

	-- Register with Interface Options
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(self.panel)
	else
		local category = Settings.RegisterCanvasLayoutCategory(self.panel, addonName)
		Settings.RegisterAddOnCategory(category)
		self.panel.categoryID = category:GetID() -- for OpenToCategory use
	end

	-- inset frame to provide some padding
	self.content = CreateFrame("Frame", nil, self.panel)
	self.content:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 16, -16)
	self.content:SetPoint("BOTTOMRIGHT", self.panel, "BOTTOMRIGHT", -16, 16)

	-- title
	local title = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	title:SetPoint("TOP", 0, 0)
	title:SetText(L["Auto Potion Settings"])

	-- subtitle
	local subtitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 0, -40)
	subtitle:SetText(L["Configure the behavior of the addon. IE: if you want to include class spells"])

	-- behavior title
	local behaviourTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	behaviourTitle:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -30)
	behaviourTitle:SetText(L["Addon Behaviour"])

	-------------  Stop Casting  -------------	
	local stopCastButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	stopCastButton:SetPoint("TOPLEFT", behaviourTitle, 0, -PADDING)
	---@diagnostic disable-next-line: undefined-field
	stopCastButton.Text:SetText(L["Include /stopcasting in the macro"])
	stopCastButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("stopCast", stopCastButton:GetChecked())
	end)
	stopCastButton:HookScript("OnEnter", function(_, btn, down)
		---@diagnostic disable-next-line: param-type-mismatch
		GameTooltip:SetOwner(stopCastButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Useful for casters."])
		GameTooltip:Show()
	end)
	stopCastButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	stopCastButton:SetChecked(HAMDB.stopCast)
	lastStaticElement = stopCastButton

	-------------  Shortest Cooldown  -------------	
	local cdResetButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	cdResetButton:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING)
	---@diagnostic disable-next-line: undefined-field
	cdResetButton.Text:SetText(L["Includes the shortest Cooldown in the reset Condition of Castsequence. !!USE CAREFULLY!!"])
	cdResetButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("cdReset", cdResetButton:GetChecked())
	end)
	cdResetButton:SetChecked(HAMDB.cdReset)
	lastStaticElement = cdResetButton

	-------------  Healthstone Priority  -------------	
	local raidStoneButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	raidStoneButton:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING)
	---@diagnostic disable-next-line: undefined-field
	raidStoneButton.Text:SetText(L["Low Priority Healthstones"])
	raidStoneButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("raidStone", raidStoneButton:GetChecked())
	end)
	raidStoneButton:HookScript("OnEnter", function(_, btn, down)
		---@diagnostic disable-next-line: param-type-mismatch
		GameTooltip:SetOwner(raidStoneButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Prioritize health potions over a healthstone."])
		GameTooltip:Show()
	end)
	raidStoneButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	raidStoneButton:SetChecked(HAMDB.raidStone)
	lastStaticElement = raidStoneButton


	-------------  ITEMS  -------------
	local witheringPotionButton = nil
	local witheringDreamsPotionButton = nil
	local cavedwellerDelightButton = nil
	local heartseekingButton = nil
	if isRetail then
		local itemsTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
		itemsTitle:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING_CATERGORY)
		itemsTitle:SetText(L["Items"])

		---Withering Potion---
		witheringPotionButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
		witheringPotionButton:SetPoint("TOPLEFT", itemsTitle, 0, -PADDING)
		---@diagnostic disable-next-line: undefined-field
		witheringPotionButton.Text:SetText(L["Potion of Withering Vitality"])
		witheringPotionButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("witheringPotion", witheringPotionButton:GetChecked())
		end)
		witheringPotionButton:HookScript("OnEnter", function(_, btn, down)
			---@diagnostic disable-next-line: param-type-mismatch
			GameTooltip:SetOwner(witheringPotionButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetItemByID(ham.witheringR3.getId())
			GameTooltip:Show()
		end)
		witheringPotionButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		witheringPotionButton:SetChecked(HAMDB.witheringPotion)

		---Withering Dreams Potion---
		witheringDreamsPotionButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
		witheringDreamsPotionButton:SetPoint("TOPLEFT", itemsTitle, 220, -PADDING)
		---@diagnostic disable-next-line: undefined-field
		witheringDreamsPotionButton.Text:SetText(L["Potion of Withering Dreams"])
		witheringDreamsPotionButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("witheringDreamsPotion", witheringDreamsPotionButton:GetChecked())
		end)
		witheringDreamsPotionButton:HookScript("OnEnter", function(_, btn, down)
			---@diagnostic disable-next-line: param-type-mismatch
			GameTooltip:SetOwner(witheringDreamsPotionButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetItemByID(ham.witheringDreamsR3.getId())
			GameTooltip:Show()
		end)
		witheringDreamsPotionButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		witheringDreamsPotionButton:SetChecked(HAMDB.witheringDreamsPotion)

		---Cavedwellers Delight---
		cavedwellerDelightButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
		cavedwellerDelightButton:SetPoint("TOPLEFT", itemsTitle, 440, -PADDING)
		---@diagnostic disable-next-line: undefined-field
		cavedwellerDelightButton.Text:SetText(L["Cavedweller's Delight"])
		cavedwellerDelightButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("cavedwellerDelight", cavedwellerDelightButton:GetChecked())
		end)
		cavedwellerDelightButton:HookScript("OnEnter", function(_, btn, down)
			---@diagnostic disable-next-line: param-type-mismatch
			GameTooltip:SetOwner(cavedwellerDelightButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetItemByID(ham.cavedwellersDelightR3.getId())
			GameTooltip:Show()
		end)
		cavedwellerDelightButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		cavedwellerDelightButton:SetChecked(HAMDB.cavedwellerDelight)

		---Heartseeking Health Injector---
		heartseekingButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
		heartseekingButton:SetPoint("TOPLEFT", itemsTitle, 0, -60)
		---@diagnostic disable-next-line: undefined-field
		heartseekingButton.Text:SetText(L["Heartseeking Health Injector (tinker)"])
		heartseekingButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("heartseekingInjector", heartseekingButton:GetChecked())
		end)
		heartseekingButton:HookScript("OnEnter", function(_, btn, down)
			---@diagnostic disable-next-line: param-type-mismatch
			if ham.tinkerSlot then
				GameTooltip:SetOwner(heartseekingButton, "ANCHOR_TOPRIGHT")
				GameTooltip:SetInventoryItem("player", ham.tinkerSlot)
				GameTooltip:Show()
			end
		end)
		heartseekingButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		heartseekingButton:SetChecked(HAMDB.heartseekingInjector)

		lastStaticElement = heartseekingButton
	end


	-------------  CURRENT PRIORITY  -------------
	currentPrioTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	currentPrioTitle:SetPoint("BOTTOMLEFT", 0, PADDING_PRIO_CATEGORY)
	currentPrioTitle:SetText(L["Current Priority"])


	-------------  RESET BUTTON  -------------
	local btn = CreateFrame("Button", nil, self.content, "UIPanelButtonTemplate")
	btn:SetPoint("BOTTOMLEFT", 2, 3)
	btn:SetText(L["Reset to Default"])
	btn:SetWidth(120)
	btn:SetScript("OnClick", function()
		HAMDB = CopyTable(ham.defaults)

		for spellID, button in pairs(classButtons) do
			if ham.dbContains(spellID) then
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end
		end
		cdResetButton:SetChecked(HAMDB.cdReset)
		raidStoneButton:SetChecked(HAMDB.raidStone)
		if isRetail then
			witheringPotionButton:SetChecked(HAMDB.witheringPotion)
			witheringDreamsPotionButton:SetChecked(HAMDB.witheringDreamsPotion)
			cavedwellerDelightButton:SetChecked(HAMDB.cavedwellerDelight)
		end
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
		print(L["Reset successful!"])
	end)
end

function ham.settingsFrame:InitializeClassSpells(relativeTo)
	-------------  CLASS / RACIALS  -------------
	local myClassTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	myClassTitle:SetPoint("TOPLEFT", relativeTo, 0, -PADDING_CATERGORY)
	myClassTitle:SetText(L["Class/Racial Spells"])

	local lastbutton = nil
	local posy = -PADDING
	if next(ham.supportedSpells) ~= nil then
		local count = 0
		for i, spell in ipairs(ham.supportedSpells) do
			if IsSpellKnown(spell) or IsSpellKnown(spell, true) then
				local name = C_Spell.GetSpellName(spell)
				local button = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")

				if count == 3 then
					lastbutton = nil
					count = 0
					posy = posy - PADDING
				end
				if lastbutton ~= nil then
					button:SetPoint("TOPLEFT", lastbutton, PADDING_HORIZONTAL, 0)
				else
					button:SetPoint("TOPLEFT", myClassTitle, 0, posy)
				end
				---@diagnostic disable-next-line: undefined-field
				button.Text:SetText(name)
				button:HookScript("OnClick", function(_, btn, down)
					if button:GetChecked() then
						ham.insertIntoDB(spell)
					else
						ham.removeFromDB(spell)
					end
					ham.updateHeals()
					ham.updateMacro()
					self:updatePrio()
				end)
				button:HookScript("OnEnter", function(_, btn, down)
					---@diagnostic disable-next-line: param-type-mismatch
					GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT")
					GameTooltip:SetSpellByID(spell);
					GameTooltip:Show()
				end)
				button:HookScript("OnLeave", function(_, btn, down)
					GameTooltip:Hide()
				end)
				button:SetChecked(ham.dbContains(spell))
				table.insert(classButtons, spell, button)
				lastbutton = button
				count = count + 1
			end
		end
	end
end

SLASH_HAM1 = "/ham"
SLASH_HAM2 = "/healtsthoneautomacro"
SLASH_HAM3 = "/ap"
SLASH_HAM4 = "/autopotion"

SlashCmdList.HAM = function(msg, editBox)
	-- Check if the message contains "debug"
	if msg and msg:trim():lower() == "debug" then
		ham.debug = not ham.debug
		ham.checkTinker()
		print("|cffb48ef9AutoPotion:|r Debug mode is now " .. (ham.debug and "enabled" or "disabled"))
		return
	end

	-- Open settings if no "debug" keyword was passed
	if InterfaceOptions_AddCategory then
		InterfaceOptionsFrame_OpenToCategory(addonName)
	else
		local settingsCategoryID = _G[addonName].categoryID
		Settings.OpenToCategory(settingsCategoryID)
	end
end
