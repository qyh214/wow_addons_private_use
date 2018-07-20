function PLH_CreateOptionsPanel()

	--[[ Main Panel ]]--
	local configFrame = CreateFrame('Frame', 'PLHConfigFrame', InterfaceOptionsFramePanelContainer)
	configFrame:Hide()
	configFrame.name = 'Personal Loot Helper'
	InterfaceOptions_AddCategory(configFrame)

	--[[ Title ]]--
	local titleLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	titleLabel:SetPoint('TOPLEFT', configFrame, 'TOPLEFT', 16, -16)
	titleLabel:SetText('Personal Loot Helper (PLH)')

	-- [[ Version ]] --
	local versionLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	versionLabel:SetPoint('BOTTOMLEFT', titleLabel, 'BOTTOMRIGHT', 8, 0)
	versionLabel:SetText('v' .. GetAddOnMetadata('PersonalLootHelper', 'Version'))

	--[[ Author ]]--
	local authorLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	authorLabel:SetPoint('TOPRIGHT', configFrame, 'TOPRIGHT', -16, -24)
	authorLabel:SetText("Author: Madone-Zul'Jin")

	--[[ Display Options ]]--
	local displayLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	displayLabel:SetPoint('TOPLEFT', titleLabel, 'BOTTOMLEFT', 0, -20)
	displayLabel:SetText("Display options")
	
	--[[ PLH_PREFS_AUTO_HIDE ]]--
	local autoHideCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
	autoHideCheckbox:SetPoint('TOPLEFT', displayLabel, 'BOTTOMLEFT', 20, -5)
	autoHideCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_AUTO_HIDE])

	local autoHideLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	autoHideLabel:SetPoint('LEFT', autoHideCheckbox, 'RIGHT', 0, 0)
	autoHideLabel:SetText("Automatically hide PLH when there is no loot to trade")

	--[[ PLH_PREFS_SKIP_CONFIRMATION ]]--
	local skipConfirmationCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
	skipConfirmationCheckbox:SetPoint('TOPLEFT', autoHideCheckbox, 'BOTTOMLEFT', 0, -5)
	skipConfirmationCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_SKIP_CONFIRMATION])

	local skipConfirmationLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	skipConfirmationLabel:SetPoint('LEFT', skipConfirmationCheckbox, 'RIGHT', 0, 0)
	skipConfirmationLabel:SetText("Automatically skip confirmation when offering or requesting loot")

	--[[ Looter Options ]]--
	local looterLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	looterLabel:SetPoint('TOPLEFT', skipConfirmationCheckbox, 'BOTTOMLEFT', -20, -15)
	looterLabel:SetText("When I receive tradeable loot...")
	
	--[[ PLH_PREFS_ONLY_OFFER_IF_UPGRADE ]]
	local onlyOfferIfUpgradeCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
	onlyOfferIfUpgradeCheckbox:SetPoint('TOPLEFT', looterLabel, 'BOTTOMLEFT', 20, -5)
	onlyOfferIfUpgradeCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_ONLY_OFFER_IF_UPGRADE])

	local onlyOfferIfUpgradeLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	onlyOfferIfUpgradeLabel:SetPoint('LEFT', onlyOfferIfUpgradeCheckbox, 'RIGHT', 0, 0)
	onlyOfferIfUpgradeLabel:SetText("Only prompt me to trade if loot is an ilvl upgrade for other players")

	--[[ PLH_PREFS_NEVER_OFFER_BOE ]]--
	local neverOfferBOECheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
	neverOfferBOECheckbox:SetPoint('TOPLEFT', onlyOfferIfUpgradeCheckbox, 'BOTTOMLEFT', 0, -5)
	neverOfferBOECheckbox:SetChecked(PLH_PREFS[PLH_PREFS_NEVER_OFFER_BOE])

	local neverOfferBOELabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	neverOfferBOELabel:SetPoint('LEFT', neverOfferBOECheckbox, 'RIGHT', 0, 0)
	neverOfferBOELabel:SetText("Never prompt me to trade Bind on Equip loot")

	-- [[ PLH_PREFS_SHOW_TRADEABLE_ALERT ]] --
	local showTradeableAlertCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
	showTradeableAlertCheckbox:SetPoint('TOPLEFT', neverOfferBOECheckbox, 'BOTTOMLEFT', 0, -5)
	showTradeableAlertCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_SHOW_TRADEABLE_ALERT])

	local showTradeableAlertLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	showTradeableAlertLabel:SetPoint('LEFT', showTradeableAlertCheckbox, 'RIGHT', 0, 0)
	showTradeableAlertLabel:SetText("Show me a list of who can use the loot")
	
	--[[ Non-looter Options ]]--
	local nonLooterLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	nonLooterLabel:SetPoint('TOPLEFT', showTradeableAlertCheckbox, 'BOTTOMLEFT', -20, -15)
	nonLooterLabel:SetText("When others receive tradeable loot...")

	--[[ PLH_PREFS_CURRENT_SPEC_ONLY ]]--
	local currentSpecOnlyCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
	currentSpecOnlyCheckbox:SetPoint('TOPLEFT', nonLooterLabel, 'BOTTOMLEFT', 20, -5)
	currentSpecOnlyCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_CURRENT_SPEC_ONLY])

	local currentSpecOnlyLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	currentSpecOnlyLabel:SetPoint('LEFT', currentSpecOnlyCheckbox, 'RIGHT', 0, 0)
	currentSpecOnlyLabel:SetText("Only prompt me if I can equip in current spec")

	--[[ PLH_PREFS_ILVL_THRESHOLD ]]--

	local ilvlThresholdLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	ilvlThresholdLabel:SetPoint('TOPLEFT', currentSpecOnlyCheckbox, 'BOTTOMLEFT', 5, -10)
	ilvlThresholdLabel:SetText("Only prompt me if")

	local ilvlThresholdValue = {
		0,
		-1,
		-6,
		-11,
		-16,
		-21,
		-26,
		-31,
		-9999
	}

	local ilvlThresholdDescription = {
		"looted ilvl is higher than equipped ilvl",
		"looted ilvl is at least equal to equipped ilvl",
		"looted ilvl is at least equal to equipped ilvl -5",
		"looted ilvl is at least equal to equipped ilvl -10",
		"looted ilvl is at least equal to equipped ilvl -15",
		"looted ilvl is at least equal to equipped ilvl -20",
		"looted ilvl is at least equal to equipped ilvl -25",
		"looted ilvl is at least equal to equipped ilvl -30",
		"always show all items"
	}

	local ilvlThresholdMenu = CreateFrame('Button', 'ilvlThresholdMenu', configFrame, 'MSA_DropDownMenuTemplate')
	ilvlThresholdMenu:SetPoint('LEFT', ilvlThresholdLabel, 'RIGHT', -5, 0)

	local function ilvlThresholdMenu_OnClick(self, arg1, arg2, checked)
		MSA_DropDownMenu_SetText(ilvlThresholdMenu, ilvlThresholdDescription[arg1])
	end

	local function ilvlThresholdMenu_Initialize(self, level)
		local info = MSA_DropDownMenu_CreateInfo()
		info.func = ilvlThresholdMenu_OnClick
		for i = 1, #ilvlThresholdValue do
			info.arg1 = i
			info.text = ilvlThresholdDescription[i]
			MSA_DropDownMenu_AddButton(info)
		end
	end

	MSA_DropDownMenu_Initialize(ilvlThresholdMenu, ilvlThresholdMenu_Initialize)
	MSA_DropDownMenu_SetWidth(ilvlThresholdMenu, 300);
	MSA_DropDownMenu_JustifyText(ilvlThresholdMenu, 'LEFT')

	local function GetILVLThresholdDescription(ilvlThreshold)
		for i = 1, #ilvlThresholdValue do
			if ilvlThresholdValue[i] == ilvlThreshold then
				return ilvlThresholdDescription[i]
			end
		end
		return ilvlThresholdDescription[2]  -- we couldn't find a match, so return default
	end

	local function GetILVLThresholdValue(description)
		for i = 1, #ilvlThresholdDescription do
			if ilvlThresholdDescription[i] == description then
				return ilvlThresholdValue[i]
			end
		end
		return ilvlThresholdValue[2]  -- we couldn't find a match, so return default
	end

	MSA_DropDownMenu_SetText(ilvlThresholdMenu, GetILVLThresholdDescription(PLH_PREFS[PLH_PREFS_ILVL_THRESHOLD]))
	
	--[[ PLH_PREFS_INCLUDE_XMOG ]]--
	
	local includeXMOGCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
	includeXMOGCheckbox:SetPoint('TOPLEFT', neverOfferBOECheckbox, 'BOTTOMLEFT', 0, -120)
	includeXMOGCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_INCLUDE_XMOG])

	local includeXMOGLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	includeXMOGLabel:SetPoint('LEFT', includeXMOGCheckbox, 'RIGHT', 0, 0)
	includeXMOGLabel:SetText("Prompt me for transmog even if item is not an upgrade")

	-- [[ PLH_PREFS_WHISPER_MESSAGE ]]--
	
	local sampleItem = '\124cffa335ee\124Hitem:151981::::::::110::::2:1522:3610:\124h[Life-Bearing Footpads]\124h\124r'
	local whisperMessageLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	whisperMessageLabel:SetPoint('TOPLEFT', includeXMOGCheckbox, 'BOTTOMLEFT', -25, -15)
	whisperMessageLabel:SetText("Enter message to whisper when requesting loot from players who are not using PLH.\n" ..
		"You may include the looted item by using %item.  For example:\n" ..
		"      \"" .. PLH_DEFAULT_PREFS[PLH_PREFS_WHISPER_MESSAGE] .. "\" could appear as\n" ..
		"      \"" .. PLH_GetWhisperMessage(sampleItem, PLH_DEFAULT_PREFS[PLH_PREFS_WHISPER_MESSAGE]) .. "\"\n")
	whisperMessageLabel:SetWordWrap(true)
	whisperMessageLabel:SetJustifyH('LEFT')
	whisperMessageLabel:SetWidth(500)
	whisperMessageLabel:SetSpacing(3)

	local whisperMessageEditBox = CreateFrame('EditBox', nil, configFrame)
	whisperMessageEditBox:SetWidth(450)
	whisperMessageEditBox:SetHeight(30)
	whisperMessageEditBox:SetTextInsets(4, 4, 4, 4)
	whisperMessageEditBox:SetMaxLetters(100)
	whisperMessageEditBox:SetAutoFocus(false)
	whisperMessageEditBox:SetFont('Fonts\\FRIZQT__.TTF', 11)
	whisperMessageEditBox:SetPoint('TOPLEFT', whisperMessageLabel, 'BOTTOMLEFT', 20, -10)
	whisperMessageEditBox:SetText(PLH_PREFS[PLH_PREFS_WHISPER_MESSAGE])
	
	local whisperMessageEditBoxBackdrop = {
		bgFile = nil, 
		edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
		tile = false,
		tileSize = 8,
		edgeSize = 8,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}

	local whisperMessageEditBoxBorder = CreateFrame('Frame', nil, whisperMessageEditBox)
	whisperMessageEditBoxBorder:SetWidth(whisperMessageEditBox:GetWidth() + 5)
	whisperMessageEditBoxBorder:SetHeight(whisperMessageEditBox:GetHeight() + 5)
	whisperMessageEditBoxBorder:SetPoint('CENTER', whisperMessageEditBox, 'CENTER')
	whisperMessageEditBoxBorder:SetBackdrop(whisperMessageEditBoxBackdrop)

	--[[ Thank You Message ]] --
	local thankYouLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	thankYouLabel:SetPoint('BOTTOM', configFrame, 'BOTTOM', 0, 24)
	thankYouLabel:SetSpacing(5)
	thankYouLabel:SetWidth(500)
	thankYouLabel:SetWordWrap(true)
	
	local function UpdateThankYouLabel()
		local text = ''
--		if PLH_STATS[PLH_ITEMS_REQUESTED] > 0 or PLH_STATS[PLH_ITEMS_RECEIVED] > 0 then
--			text = text .. "You have requested " .. PLH_STATS[PLH_ITEMS_REQUESTED] .. " and received " .. PLH_STATS[PLH_ITEMS_RECEIVED] .. " item(s) through PLH\n"
--		end
--		if PLH_STATS[PLH_ITEMS_OFFERED] > 0 or PLH_STATS[PLH_ITEMS_GIVEN_AWAY] > 0 then
--			text = text .. "You have offered " .. PLH_STATS[PLH_ITEMS_OFFERED] .. " and given away " .. PLH_STATS[PLH_ITEMS_GIVEN_AWAY] .. " item(s) through PLH\n"
--		end
--		if PLH_GetNumberOfPLHUsers() > 0 then
--			text = text .. PLH_GetNumberOfPLHUsers() .. " of " .. GetNumGroupMembers() .. " group members are running PLH\n"
--		end
		text = text .. "\nIf you find PLH to be useful, please tell your friends and guildmates about it!"
		thankYouLabel:SetText(text)
	end
	
	--[[ OnShow Event]]
	configFrame:SetScript('OnShow', function(frame)
		autoHideCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_AUTO_HIDE])
		skipConfirmationCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_SKIP_CONFIRMATION])
		onlyOfferIfUpgradeCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_ONLY_OFFER_IF_UPGRADE])
		neverOfferBOECheckbox:SetChecked(PLH_PREFS[PLH_PREFS_NEVER_OFFER_BOE])
		showTradeableAlertCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_SHOW_TRADEABLE_ALERT])
		currentSpecOnlyCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_CURRENT_SPEC_ONLY])
		MSA_DropDownMenu_SetText(ilvlThresholdMenu, GetILVLThresholdDescription(PLH_PREFS[PLH_PREFS_ILVL_THRESHOLD]))
		includeXMOGCheckbox:SetChecked(PLH_PREFS[PLH_PREFS_INCLUDE_XMOG])
		whisperMessageEditBox:SetText(PLH_PREFS[PLH_PREFS_WHISPER_MESSAGE])
		UpdateThankYouLabel()
	end)

	--[[ Okay Action ]]--
	function configFrame.okay(arg1, arg2, arg3, ...)
		PLH_PREFS[PLH_PREFS_AUTO_HIDE] = autoHideCheckbox:GetChecked()
		PLH_PREFS[PLH_PREFS_SKIP_CONFIRMATION] = skipConfirmationCheckbox:GetChecked()
		PLH_PREFS[PLH_PREFS_ONLY_OFFER_IF_UPGRADE] = onlyOfferIfUpgradeCheckbox:GetChecked()
		PLH_PREFS[PLH_PREFS_NEVER_OFFER_BOE] = neverOfferBOECheckbox:GetChecked()
		PLH_PREFS[PLH_PREFS_SHOW_TRADEABLE_ALERT] = showTradeableAlertCheckbox:GetChecked()
		PLH_PREFS[PLH_PREFS_CURRENT_SPEC_ONLY] = currentSpecOnlyCheckbox:GetChecked()
		PLH_PREFS[PLH_PREFS_ILVL_THRESHOLD] = GetILVLThresholdValue(MSA_DropDownMenu_GetText(ilvlThresholdMenu))
		PLH_PREFS[PLH_PREFS_INCLUDE_XMOG] = includeXMOGCheckbox:GetChecked()
		if PLH_PREFS[PLH_PREFS_WHISPER_MESSAGE] ~= whisperMessageEditBox:GetText() then
			PLH_PREFS[PLH_PREFS_WHISPER_MESSAGE] = whisperMessageEditBox:GetText()
			PLH_META[PLH_SHOW_WHISPER_WARNING] = true
		end
	end

end