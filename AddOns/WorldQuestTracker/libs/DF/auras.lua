
---@type detailsframework
local DF = _G ["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return
end

local detailsFramework = DF

local _
local tinsert = table.insert
local GetSpellInfo = GetSpellInfo
local lower = string.lower
local GetSpellBookItemInfo = GetSpellBookItemInfo
local unpack = unpack
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local tremove = tremove

local CONST_MAX_SPELLS = 500000

function DF:GetAuraByName(unit, spellName, isDebuff)
	isDebuff = isDebuff and "HARMFUL|PLAYER"

	for i = 1, 40 do
		local name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitAura(unit, i, isDebuff)
		if (not name) then
			return
		end

		if (name == spellName) then
			return name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll
		end
	end
end

local defaultTextForAuraFrame = {
	AUTOMATIC = "Automatic",
	MANUAL = "Manual",
	METHOD = "Aura Tracking Method:",
	BUFFS_IGNORED = "Buffs Ignored",
	DEBUFFS_IGNORED = "Debuffs Ignored",
	BUFFS_TRACKED = "Buffs Tracked",
	DEBUFFS_TRACKED = "Debuffs Tracked",

	AUTOMATIC_DESC = "Auras are being tracked automatically, the addon controls what to show.\nYou may add auras to the blacklist or add extra auras to track.",
	MANUAL_DESC = "Auras are being tracked manually, the addon only check for auras you entered below.",

	MANUAL_ADD_BLACKLIST_BUFF = "Add Buff to Blacklist",
	MANUAL_ADD_BLACKLIST_DEBUFF =  "Add Debuff to Blacklist",
	MANUAL_ADD_TRACKLIST_BUFF = "Add Buff to Tracklist",
	MANUAL_ADD_TRACKLIST_DEBUFF = "Add Debuff to Tracklist",
}

--store spell caches, they load empty and are filled when an addon require a cache with all spells
local spellsHashMap
local spellsIndexTable
local spellsWithSameName

function DF:GetSpellCaches()
	return spellsHashMap, spellsIndexTable, spellsWithSameName
end

local lazyLoadAllSpells = function(payload, iterationCount, maxIterations)
	local startPoint = payload.nextIndex
	--the goal is iterate over 500000 spell ids over 200 frames
	local endPoint = startPoint + 2500
	payload.nextIndex = endPoint
	local i = startPoint + 1

	--make upvalues be closer
	local toLowerCase = string.lower
	local GetSpellInfo = GetSpellInfo

	local hashMap = payload.hashMap
	local indexTable = payload.indexTable
	local allSpellsSameName = payload.allSpellsSameName

	while (i < endPoint) do
		local spellName = GetSpellInfo(i)

		if (spellName) then
			spellName = toLowerCase(spellName)
			hashMap[spellName] = i --[spellname] = spellId
			indexTable[#indexTable+1] = spellName --array with all spellnames

			local spellNameTable = allSpellsSameName[spellName]
			if (not spellNameTable) then
				spellNameTable = {}
				allSpellsSameName[spellName] = spellNameTable
			end
			spellNameTable[#spellNameTable+1] = i
		end

		i = i + 1
	end
end

function DF:UnloadSpellCache()
	if (spellsHashMap) then
		table.wipe(spellsHashMap)
		table.wipe(spellsIndexTable)
		table.wipe(spellsWithSameName)
	end
end

function DF:LoadSpellCache(hashMap, indexTable, allSpellsSameName)
	if (spellsHashMap and next(spellsHashMap)) then
		--return the already loaded cache
		return spellsHashMap, spellsIndexTable, spellsWithSameName
	end

	assert(type(hashMap) == "table", "DetailsFramework:LoadSpellCache(): require a table on #1 parameter.")
	assert(type(indexTable) == "table", "DetailsFramework:LoadSpellCache(): require a table on #2 parameter.")
	assert(type(allSpellsSameName) == "table", "DetailsFramework:LoadSpellCache(): require a table on #3 parameter.")

	spellsHashMap = hashMap
	spellsIndexTable = indexTable
	spellsWithSameName = allSpellsSameName

	local iterations = 200
	local payload = {
		nextIndex = 0,
		hashMap = hashMap,
		indexTable = indexTable,
		allSpellsSameName = allSpellsSameName,
	}
	detailsFramework.Schedules.LazyExecute(lazyLoadAllSpells, payload, iterations)

	return spellsHashMap, spellsIndexTable, spellsWithSameName
end

do
	local metaPrototype = {
		WidgetType = "aura_tracker",
		dversion = DF.dversion,
	}

	--check if there's a metaPrototype already existing
	if (_G[DF.GlobalWidgetControlNames["aura_tracker"]]) then
		--get the already existing metaPrototype
		local oldMetaPrototype = _G[DF.GlobalWidgetControlNames["aura_tracker"]]
		--check if is older
		if ((not oldMetaPrototype.dversion) or(oldMetaPrototype.dversion < DF.dversion) ) then
			--the version is older them the currently loading one
			--copy the new values into the old metatable
			for funcName, _ in pairs(metaPrototype) do
				oldMetaPrototype[funcName] = metaPrototype[funcName]
			end
		end
	else
		--first time loading the framework
		_G[DF.GlobalWidgetControlNames["aura_tracker"]] = metaPrototype
	end
end

local AuraTrackerMetaFunctions = _G[DF.GlobalWidgetControlNames["aura_tracker"]]
DF:Mixin(AuraTrackerMetaFunctions, DF.ScriptHookMixin)

--create panels
local onProfileChangedCallback = function(self, newdb)
	self.db = newdb

	--automatic
	self.buff_ignored:SetData(newdb.aura_tracker.buff_banned)
	self.debuff_ignored:SetData(newdb.aura_tracker.debuff_banned)
	self.buff_tracked:SetData(newdb.aura_tracker.buff_tracked)
	self.debuff_tracked:SetData(newdb.aura_tracker.debuff_tracked)

	self.buff_ignored:Refresh()
	self.debuff_ignored:Refresh()
	self.buff_tracked:Refresh()
	self.debuff_tracked:Refresh()

	--manual
	self.buffs_added:SetData(newdb.aura_tracker.buff)
	self.debuffs_added:SetData(newdb.aura_tracker.debuff)
	self.buffs_added:Refresh()
	self.debuffs_added:Refresh()

	--method
	if (newdb.aura_tracker.track_method == 0x1) then
		self.f_auto:Show()
		self.f_manual:Hide()

		self.AutomaticTrackingCheckbox:SetValue(true)
		self.ManualTrackingCheckbox:SetValue(false)
		self.desc_label.text = self.LocTexts.AUTOMATIC_DESC

	elseif (newdb.aura_tracker.track_method == 0x2) then
		self.f_auto:Hide()
		self.f_manual:Show()

		self.AutomaticTrackingCheckbox:SetValue(false)
		self.ManualTrackingCheckbox:SetValue(true)
		self.desc_label.text = self.LocTexts.MANUAL_DESC
	end
end

local aura_panel_defaultoptions = {
	height = 400,
	row_height = 18,
	width = 230,
	button_text_template = "OPTIONS_FONT_TEMPLATE"
}

function DF:CreateAuraConfigPanel(parent, name, db, changeCallback, options, texts)
	local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
	local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

	local newAuraPanel = CreateFrame("frame", name, parent, "BackdropTemplate")
	newAuraPanel.db = db
	newAuraPanel.OnProfileChanged = onProfileChangedCallback
	newAuraPanel.LocTexts = texts
	options = options or {}
	self.table.deploy(options, aura_panel_defaultoptions)

	local auraPanel_Auto = CreateFrame("frame", "$parent_Automatic", newAuraPanel, "BackdropTemplate")
	local auraPanel_Manual = CreateFrame("frame", "$parent_Manual", newAuraPanel, "BackdropTemplate")
	auraPanel_Auto:SetPoint("topleft", newAuraPanel, "topleft", 0, -24)
	auraPanel_Manual:SetPoint("topleft", newAuraPanel, "topleft", 0, -24)
	auraPanel_Auto:SetSize(600, 600)
	auraPanel_Manual:SetSize(600, 600)
	newAuraPanel.f_auto = auraPanel_Auto
	newAuraPanel.f_manual = auraPanel_Manual

	--check if the texts table is valid and also deploy default values into the table in case some value is nil
	texts = (type(texts == "table") and texts) or defaultTextForAuraFrame
	DF.table.deploy(texts, defaultTextForAuraFrame)

	local onSwitchTrackingMethod = function(self)
		local method = self.Method

		newAuraPanel.db.aura_tracker.track_method = method
		if (changeCallback) then
			DF:QuickDispatch(changeCallback)
		end

		if (method == 0x1) then
			auraPanel_Auto:Show()
			auraPanel_Manual:Hide()
			newAuraPanel.AutomaticTrackingCheckbox:SetValue(true)
			newAuraPanel.ManualTrackingCheckbox:SetValue(false)
			newAuraPanel.desc_label.text = texts.AUTOMATIC_DESC

		elseif (method == 0x2) then
			auraPanel_Auto:Hide()
			auraPanel_Manual:Show()
			newAuraPanel.AutomaticTrackingCheckbox:SetValue(false)
			newAuraPanel.ManualTrackingCheckbox:SetValue(true)
			newAuraPanel.desc_label.text = texts.MANUAL_DESC
		end
	end

	local methodSelectionBackground = CreateFrame("frame", nil, newAuraPanel, "BackdropTemplate")
	methodSelectionBackground:SetHeight(82)
	methodSelectionBackground:SetPoint("topleft", newAuraPanel, "topleft", 0, 0)
	methodSelectionBackground:SetPoint("topright", newAuraPanel, "topright", 0, 0)
	DF:ApplyStandardBackdrop(methodSelectionBackground)

	local trackingMethodLabel = self:CreateLabel(methodSelectionBackground, texts.METHOD, 12, "orange")
	trackingMethodLabel:SetPoint("topleft", methodSelectionBackground, "topleft", 6, -4)

	newAuraPanel.desc_label = self:CreateLabel(methodSelectionBackground, "", 10, "silver")
	newAuraPanel.desc_label:SetPoint("left", methodSelectionBackground, "left", 130, 0)
	newAuraPanel.desc_label:SetJustifyV("top")

	local automaticTrackingCheckbox = DF:CreateSwitch(methodSelectionBackground, onSwitchTrackingMethod, newAuraPanel.db.aura_tracker.track_method == 0x1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
	automaticTrackingCheckbox.Method = 0x1
	automaticTrackingCheckbox:SetAsCheckBox()
	automaticTrackingCheckbox:SetSize(24, 24)
	newAuraPanel.AutomaticTrackingCheckbox = automaticTrackingCheckbox

	local automaticTrackingLabel = DF:CreateLabel(methodSelectionBackground, "Automatic")
	automaticTrackingLabel:SetPoint("left", automaticTrackingCheckbox, "right", 2, 0)

	local manualTrackingCheckbox = DF:CreateSwitch(methodSelectionBackground, onSwitchTrackingMethod, newAuraPanel.db.aura_tracker.track_method == 0x2, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
	manualTrackingCheckbox.Method = 0x2
	manualTrackingCheckbox:SetAsCheckBox()
	manualTrackingCheckbox:SetSize(24, 24)
	newAuraPanel.ManualTrackingCheckbox = manualTrackingCheckbox

	local manualTrackingLabel = DF:CreateLabel(methodSelectionBackground, "Manual")
	manualTrackingLabel:SetPoint("left", manualTrackingCheckbox, "right", 2, 0)

	automaticTrackingCheckbox:SetPoint("topleft", trackingMethodLabel, "bottomleft", 0, -6)
	manualTrackingCheckbox:SetPoint("topleft", automaticTrackingCheckbox, "bottomleft", 0, -6)


-------- anchors points

	local y = -110

-------- automatic

	local setAutoCompleteWordList = function(self, capsule)
		if (next(spellsHashMap)) then --this will error if the spell cache isn't loaded with DF:LoadSpellCache(hashMap, indexTable, allSpellsSameName)
			auraPanel_Auto.AddBuffBlacklistTextBox.SpellAutoCompleteList = spellsIndexTable
			auraPanel_Auto.AddDebuffBlacklistTextBox.SpellAutoCompleteList = spellsIndexTable
			auraPanel_Auto.AddBuffTracklistTextBox.SpellAutoCompleteList = spellsIndexTable
			auraPanel_Auto.AddDebuffTracklistTextBox.SpellAutoCompleteList = spellsIndexTable

			auraPanel_Manual.NewBuffTextBox.SpellAutoCompleteList = spellsIndexTable
			auraPanel_Manual.NewDebuffTextBox.SpellAutoCompleteList = spellsIndexTable

			auraPanel_Auto.AddBuffBlacklistTextBox:SetAsAutoComplete("SpellAutoCompleteList")
			auraPanel_Auto.AddDebuffBlacklistTextBox:SetAsAutoComplete("SpellAutoCompleteList")
			auraPanel_Auto.AddBuffTracklistTextBox:SetAsAutoComplete("SpellAutoCompleteList")
			auraPanel_Auto.AddDebuffTracklistTextBox:SetAsAutoComplete("SpellAutoCompleteList")

			auraPanel_Manual.NewBuffTextBox:SetAsAutoComplete("SpellAutoCompleteList")
			auraPanel_Manual.NewDebuffTextBox:SetAsAutoComplete("SpellAutoCompleteList")

			auraPanel_Auto.AddBuffBlacklistTextBox.ShouldOptimizeAutoComplete = true
			auraPanel_Auto.AddDebuffBlacklistTextBox.ShouldOptimizeAutoComplete = true
			auraPanel_Auto.AddBuffTracklistTextBox.ShouldOptimizeAutoComplete = true
			auraPanel_Auto.AddDebuffTracklistTextBox.ShouldOptimizeAutoComplete = true

			auraPanel_Manual.NewBuffTextBox.ShouldOptimizeAutoComplete = true
			auraPanel_Manual.NewDebuffTextBox.ShouldOptimizeAutoComplete = true
		end
	end

	--this set the width of the background box, text entry and button
	local textEntryWidth = 120

	--create the background
		local blacklistAddBackground = CreateFrame("frame", nil, auraPanel_Auto, "BackdropTemplate")
		blacklistAddBackground:SetSize(textEntryWidth + 10, 135)
		DF:ApplyStandardBackdrop(blacklistAddBackground)
		blacklistAddBackground.__background:SetVertexColor(0.47, 0.27, 0.27)

		local tracklistAddBackground = CreateFrame("frame", nil, auraPanel_Auto, "BackdropTemplate")
		tracklistAddBackground:SetSize(textEntryWidth + 10, 135)
		DF:ApplyStandardBackdrop(tracklistAddBackground)
		tracklistAddBackground.__background:SetVertexColor(0.27, 0.27, 0.47)

	--black list
		--create labels
		local buffBlacklistLabel = self:CreateLabel(blacklistAddBackground, texts.MANUAL_ADD_BLACKLIST_BUFF, DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
		local debuffBlacklistLabel = self:CreateLabel(blacklistAddBackground, texts.MANUAL_ADD_BLACKLIST_DEBUFF, DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))

		local buffNameBlacklistEntry = self:CreateTextEntry(blacklistAddBackground, function()end, textEntryWidth, 20, "AddBuffBlacklistTextBox", _, _, options_dropdown_template)
		buffNameBlacklistEntry:SetHook("OnEditFocusGained", setAutoCompleteWordList)
		buffNameBlacklistEntry:SetJustifyH("left")
		buffNameBlacklistEntry.tooltip = "Enter the buff name using lower case letters."
		auraPanel_Auto.AddBuffBlacklistTextBox = buffNameBlacklistEntry

		local debuffNameBlacklistEntry = self:CreateTextEntry(blacklistAddBackground, function()end, textEntryWidth, 20, "AddDebuffBlacklistTextBox", _, _, options_dropdown_template)
		debuffNameBlacklistEntry:SetHook("OnEditFocusGained", setAutoCompleteWordList)
		debuffNameBlacklistEntry:SetJustifyH("left")
		debuffNameBlacklistEntry.tooltip = "Enter the debuff name using lower case letters."
		auraPanel_Auto.AddDebuffBlacklistTextBox = debuffNameBlacklistEntry

		local getSpellIDFromSpellName = function(spellName)
			--check if the user entered a spell ID
			local bIsSpellId = tonumber(spellName)
			if (bIsSpellId) then
				local spellId = tonumber(spellName)
				if (spellId and spellId > 1 and spellId < 10000000) then
					local isValidSpellID = GetSpellInfo(spellId)
					if (isValidSpellID) then
						return spellId
					else
						return
					end
				end
			end

			--get the spell ID from the spell name
			spellName = lower(spellName)
			return spellsHashMap[spellName]
		end

		local addBuffNameToBacklistButton = self:CreateButton(blacklistAddBackground, function()
			local text = buffNameBlacklistEntry.text
			buffNameBlacklistEntry:SetText("")
			buffNameBlacklistEntry:ClearFocus()

			if (text ~= "") then
				--get the spellId
				local spellId = getSpellIDFromSpellName(text)
				if (not spellId) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Spell not found!")
					return
				end

				--add the spellName to the blacklist
				newAuraPanel.db.aura_tracker.buff_banned [spellId] = true

				--refresh the buff blacklist frame
				newAuraPanel.buff_ignored:Refresh()

				DF:QuickDispatch(changeCallback)
			end

		end, textEntryWidth/2 -3, 20, "By Name", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", options.button_text_template))

		local addBuffIDToBacklistButton = self:CreateButton(blacklistAddBackground, function()
			local text = buffNameBlacklistEntry.text
			buffNameBlacklistEntry:SetText("")
			buffNameBlacklistEntry:ClearFocus()

			if (text ~= "") then
				if (not tonumber(text)) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Invalid Spell-ID.")
				end

				--get the spellId
				local spellId = getSpellIDFromSpellName(text)
				if (not spellId) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Spell not found!")
					return
				end

				--add the spellId to the blacklist
				newAuraPanel.db.aura_tracker.buff_banned [spellId] = false

				--refresh the buff blacklist frame
				newAuraPanel.buff_ignored:Refresh()

				DF:QuickDispatch(changeCallback)
			end

		end, textEntryWidth/2 -3, 20, "By ID", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", options.button_text_template))

		local addDebuffNameToBacklistButton = self:CreateButton(blacklistAddBackground, function()
			local text = debuffNameBlacklistEntry.text
			debuffNameBlacklistEntry:SetText("")
			debuffNameBlacklistEntry:ClearFocus()

			if (text ~= "") then
				--get the spellId
				local spellId = getSpellIDFromSpellName(text)
				if (not spellId) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Spell not found!")
					return
				end

				--add the spellName to the blacklist
				newAuraPanel.db.aura_tracker.debuff_banned [spellId] = true

				--refresh the buff blacklist frame
				newAuraPanel.debuff_ignored:Refresh()

				DF:QuickDispatch(changeCallback)
			end
		end, textEntryWidth/2 -3, 20, "By Name", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", options.button_text_template))

		local addDebuffIDToBacklistButton = self:CreateButton(blacklistAddBackground, function()
			local text = debuffNameBlacklistEntry.text
			debuffNameBlacklistEntry:SetText("")
			debuffNameBlacklistEntry:ClearFocus()

			if (text ~= "") then
				if (not tonumber(text)) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Invalid Spell-ID.")
				end

				--get the spellId
				local spellId = getSpellIDFromSpellName(text)
				if (not spellId) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Spell not found!")
					return
				end

				--add the spellId to the blacklist
				newAuraPanel.db.aura_tracker.debuff_banned [spellId] = false

				--refresh the buff blacklist frame
				newAuraPanel.debuff_ignored:Refresh()

				DF:QuickDispatch(changeCallback)
			end
		end, textEntryWidth/2 -3, 20, "By ID", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", options.button_text_template))


	--track list
		local buffTracklistLabel = self:CreateLabel(tracklistAddBackground, texts.MANUAL_ADD_TRACKLIST_BUFF, DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
		local debuffTracklistLabel = self:CreateLabel(tracklistAddBackground, texts.MANUAL_ADD_TRACKLIST_DEBUFF, DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))

		local buffNameTracklistEntry = self:CreateTextEntry(tracklistAddBackground, function()end, textEntryWidth, 20, "AddBuffTracklistTextBox", _, _, options_dropdown_template)
		buffNameTracklistEntry:SetHook("OnEditFocusGained", setAutoCompleteWordList)
		buffNameTracklistEntry:SetJustifyH("left")
		buffNameTracklistEntry.tooltip = "Enter the buff name using lower case letters."
		auraPanel_Auto.AddBuffTracklistTextBox = buffNameTracklistEntry

		local debuffNameTracklistEntry = self:CreateTextEntry(tracklistAddBackground, function()end, textEntryWidth, 20, "AddDebuffTracklistTextBox", _, _, options_dropdown_template)
		debuffNameTracklistEntry:SetHook("OnEditFocusGained", setAutoCompleteWordList)
		debuffNameTracklistEntry:SetJustifyH("left")
		debuffNameTracklistEntry.tooltip = "Enter the debuff name using lower case letters."
		auraPanel_Auto.AddDebuffTracklistTextBox = debuffNameTracklistEntry

		local addDebuffNameToTracklistButton = self:CreateButton(tracklistAddBackground, function()
			local text = debuffNameTracklistEntry.text
			debuffNameTracklistEntry:SetText("")
			debuffNameTracklistEntry:ClearFocus()

			if (text ~= "") then
				--get the spellId
				local spellId = getSpellIDFromSpellName(text)
				if (not spellId) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Spell not found!")
					return
				end

				--add the spellName to the tracklist
				newAuraPanel.db.aura_tracker.debuff_tracked [spellId] = true

				--refresh the buff blacklist frame
				newAuraPanel.debuff_tracked:Refresh()

				DF:QuickDispatch(changeCallback)
			end
		end, textEntryWidth/2 -3, 20, "By Name", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", options.button_text_template))

		local addDebuffIDToTracklistButton = self:CreateButton(tracklistAddBackground, function()
			local text = debuffNameTracklistEntry.text
			debuffNameTracklistEntry:SetText("")
			debuffNameTracklistEntry:ClearFocus()

			if (text ~= "") then
				if (not tonumber(text)) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Invalid Spell-ID.")
				end

				--get the spellId
				local spellId = getSpellIDFromSpellName(text)
				if (not spellId) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Spell not found!")
					return
				end

				newAuraPanel.db.aura_tracker.debuff_tracked [spellId] = false

				--refresh the buff blacklist frame
				newAuraPanel.debuff_tracked:Refresh()

				DF:QuickDispatch(changeCallback)
			end
		end, textEntryWidth/2 -3, 20, "By ID", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", options.button_text_template))

		local addBuffNameToTracklistButton = self:CreateButton(tracklistAddBackground, function()
			local text = buffNameTracklistEntry.text
			buffNameTracklistEntry:SetText("")
			buffNameTracklistEntry:ClearFocus()

			if (text ~= "") then
				--get the spellId
				local spellId = getSpellIDFromSpellName(text)
				if (not spellId) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Spell not found!")
					return
				end

				--add the spellName to the tracklist
				newAuraPanel.db.aura_tracker.buff_tracked [spellId] = true

				--refresh the buff tracklist frame
				newAuraPanel.buff_tracked:Refresh()

				--callback the addon
				DF:QuickDispatch(changeCallback)
			end

		end, textEntryWidth/2 -3, 20, "By Name", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", options.button_text_template))

		local addBuffIDToTracklistButton = self:CreateButton(tracklistAddBackground, function()
			local text = buffNameTracklistEntry.text
			buffNameTracklistEntry:SetText("")
			buffNameTracklistEntry:ClearFocus()

			if (text ~= "") then
				if (not tonumber(text)) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Invalid Spell-ID.")
				end

				--get the spellId
				local spellId = getSpellIDFromSpellName(text)
				if (not spellId) then
					DetailsFramework.Msg({__name = "DetailsFramework"}, "Spell not found!")
					return
				end

				--add the spellId to the tracklist
				newAuraPanel.db.aura_tracker.buff_tracked [spellId] = false

				--refresh the buff tracklist frame
				newAuraPanel.buff_tracked:Refresh()

				--callback the addon
				DF:QuickDispatch(changeCallback)
			end
		end, textEntryWidth/2 -3, 20, "By ID", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", options.button_text_template))

	--anchors:
		blacklistAddBackground:SetPoint("topleft", auraPanel_Auto, "topleft", 0, y)
		tracklistAddBackground:SetPoint("topleft", blacklistAddBackground, "bottomleft", 0, -10)

		--debuff blacklist
		debuffNameBlacklistEntry:SetPoint("topleft", blacklistAddBackground, "topleft", 5, -20)
		debuffBlacklistLabel:SetPoint("bottomleft", debuffNameBlacklistEntry, "topleft", 0, 2)
		addDebuffNameToBacklistButton:SetPoint("topleft", debuffNameBlacklistEntry, "bottomleft", 0, -2)
		addDebuffIDToBacklistButton:SetPoint("left", addDebuffNameToBacklistButton, "right", 1, 0)

		--buff blacklist
		buffBlacklistLabel:SetPoint("topleft", addDebuffNameToBacklistButton.widget, "bottomleft", 0, -10)
		buffNameBlacklistEntry:SetPoint("topleft", buffBlacklistLabel, "bottomleft", 0, -2)
		addBuffNameToBacklistButton:SetPoint("topleft", buffNameBlacklistEntry, "bottomleft", 0, -2)
		addBuffIDToBacklistButton:SetPoint("left", addBuffNameToBacklistButton, "right", 1, 0)

		--debuff tracklist
		debuffNameTracklistEntry:SetPoint("topleft", tracklistAddBackground, "topleft", 5, -20)
		debuffTracklistLabel:SetPoint("bottomleft", debuffNameTracklistEntry, "topleft", 0, 2)
		addDebuffNameToTracklistButton:SetPoint("topleft", debuffNameTracklistEntry, "bottomleft", 0, -2)
		addDebuffIDToTracklistButton:SetPoint("left", addDebuffNameToTracklistButton, "right", 1, 0)

		--buff tracklist
		buffTracklistLabel:SetPoint("topleft", addDebuffNameToTracklistButton.widget, "bottomleft", 0, -10)
		buffNameTracklistEntry:SetPoint("topleft", buffTracklistLabel, "bottomleft", 0, -2)
		addBuffNameToTracklistButton:SetPoint("topleft", buffNameTracklistEntry, "bottomleft", 0, -2)
		addBuffIDToTracklistButton:SetPoint("left", addBuffNameToTracklistButton, "right", 1, 0)

	--options passed to the create aura panel
	local width, height, row_height = options.width, options.height, options.row_height

	local scrollWidth = 208

do --deprecated, using a scrollbox tempate from scrollbox.lua
	local scrollHeight = 343
	local lineAmount = 18
	local lineHeight = 18
	local backdropColor = {.8, .8, .8, 0.2}
	local backdropColor_OnEnter = {.8, .8, .8, 0.4}

	--aura scroll box default settings
	local auraScrollDefaultSettings = {
		show_spell_tooltip = false,
		line_height = 18,
		line_amount = 18,
	}

	local autoTrackList_LineOnEnter = function(self, capsule, value)
		local flag = self.Flag
		value = value or self.SpellID

		if not flag then
			GameCooltip2:Preset(2)
			GameCooltip2:SetOwner(self, "left", "right", 2, 0)
			GameCooltip2:SetOption("TextSize", 10)

			local spellName, _, spellIcon = GetSpellInfo(value)
			if (spellName) then
				GameCooltip2:AddLine(spellName .. "(" .. value .. ")")
				GameCooltip2:AddIcon(spellIcon, 1, 1, 14, 14, .1, .9, .1, .9)
			end
			GameCooltip2:Show()

		else
			local spellName, _, spellIcon = GetSpellInfo(value)
			if (spellName and spellsWithSameName) then
				local spellNameLower = spellName:lower()
				local sameNameSpells = spellsWithSameName[spellNameLower]

				if (sameNameSpells) then
					GameCooltip2:Preset(2)
					GameCooltip2:SetOwner(self, "left", "right", 2, 0)
					GameCooltip2:SetOption("TextSize", 10)

					for i, spellId in ipairs(sameNameSpells) do
						GameCooltip2:AddLine(spellName .. " (" .. spellId .. ")")
						GameCooltip2:AddIcon(spellIcon, 1, 1, 14, 14, .1, .9, .1, .9)
					end

					GameCooltip2:Show()
				end
			end
		end
	end

	local autoTrackList_LineOnLeave = function()
		GameCooltip2:Hide()
	end


	local createAuraScrollBox = function(scrollBoxParent, scrollBoxName, scrollBoxParentKey, scrollBoxTitle, databaseTable, removeAuraFunc, options)
		local scrollOptions = {}
		detailsFramework.OptionsFunctions.BuildOptionsTable(scrollOptions, auraScrollDefaultSettings, options)

		local updateFunc = function(self, data, offset, totalLines)
			for i = 1, totalLines do
				local index = i + offset
				local auraTable = data[index]
				if (auraTable) then
					local line = self:GetLine(i)
					local spellId, spellName, spellIcon, lowerSpellName, flag = unpack(auraTable)

					line.SpellID = spellId
					line.SpellName = spellName
					line.SpellNameLower = lowerSpellName
					line.SpellIcon = spellIcon
					line.Flag = flag

					if (flag) then
						line.name:SetText(spellName)
					else
						line.name:SetText(spellName .. "(" .. spellId .. ")")
					end

					line.icon:SetTexture(spellIcon)
					line.icon:SetTexCoord(.1, .9, .1, .9)
				end
			end
		end

		local auraLineOnEnter = function(line)
			if (scrollOptions.options.show_spell_tooltip and line.SpellID and GetSpellInfo(line.SpellID)) then
				GameTooltip:SetOwner(line, "ANCHOR_CURSOR")
				GameTooltip:SetSpellByID(line.SpellID)
				GameTooltip:AddLine(" ")
				GameTooltip:Show()
			end

			line:SetBackdropColor(unpack(backdropColor_OnEnter))
		end

		local auraLineOnLeave = function(self)
			self:SetBackdropColor(unpack(backdropColor))
			GameTooltip:Hide()
		end

		local onAuraRemoveButtonClick = function(self)
			local spellId = self:GetParent().SpellID
			databaseTable[spellId] = nil
			databaseTable["" .. (spellId or "")] = nil -- cleanup...
			scrollBoxParent[scrollBoxParentKey]:Refresh()
			if (removeAuraFunc) then --upvalue
				detailsFramework:QuickDispatch(removeAuraFunc)
			end
		end

		local createLineFunc = function(self, index)
			local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
			local lineHeight = scrollOptions.options.line_height

			line:SetPoint("topleft", self, "topleft", 1, -((index - 1) * (lineHeight + 1)) - 1)
			line:SetSize(scrollWidth - 2, lineHeight)
			line:SetScript("OnEnter", autoTrackList_LineOnEnter)
			line:HookScript("OnEnter", auraLineOnEnter)
			line:SetScript("OnLeave", autoTrackList_LineOnLeave)
			line:HookScript("OnLeave", auraLineOnLeave)

			line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			line:SetBackdropColor(unpack(backdropColor))

			local icon = line:CreateTexture("$parentIcon", "overlay")
			icon:SetSize(lineHeight - 2, lineHeight - 2)

			local name = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
			DF:SetFontSize(name, 10)

			local removeButton = CreateFrame("button", "$parentRemoveButton", line, "UIPanelCloseButton")
			removeButton:SetSize(16, 16)
			removeButton:SetScript("OnClick", onAuraRemoveButtonClick)
			removeButton:SetPoint("topright", line, "topright")
			removeButton:GetNormalTexture():SetDesaturated(true)

			icon:SetPoint("left", line, "left", 2, 0)
			name:SetPoint("left", icon, "right", 3, 0)

			line.icon = icon
			line.name = name
			line.removebutton = removeButton

			return line
		end

		local auraScrollBox = DF:CreateScrollBox(scrollBoxParent, scrollBoxName, updateFunc, databaseTable, scrollWidth, scrollHeight, scrollOptions.options.line_amount, scrollOptions.options.line_height)
		DF:ReskinSlider(auraScrollBox)
		scrollBoxParent[scrollBoxParentKey] = auraScrollBox
		auraScrollBox.OriginalData = databaseTable

		function auraScrollBox:Refresh()
			local t = {}
			local added = {}
			for spellID, flag in pairs(auraScrollBox.OriginalData) do
				local spellName, _, spellIcon = GetSpellInfo(spellID)
				if (spellName and not added[tonumber(spellID) or 0]) then
					local lowerSpellName = spellName:lower()
					tinsert(t, {spellID, spellName, spellIcon, lowerSpellName, flag})
					added[tonumber(spellID) or 0] = true
				end
			end

			table.sort(t, function(t1, t2) return t1[4] < t2[4] end)

			self:SetData(t)
			self:Refresh()
		end

		function auraScrollBox:DoSetData(newDB)
			self:SetData(newDB)
			self.OriginalData = newDB
			if (self.Refresh) then
				self:Refresh()
			else
				self:Refresh()
			end
		end

		local titleLabel = DF:CreateLabel(scrollBoxParent, scrollBoxTitle)
		titleLabel.textcolor = "silver"
		titleLabel.textsize = 10
		titleLabel:SetPoint("bottomleft", auraScrollBox, "topleft", 0, 2)

		for i = 1, lineAmount do
			auraScrollBox:CreateLine(createLineFunc)
		end

		auraScrollBox:Refresh()
		return auraScrollBox
	end
end

	local onAuraRemoveCallback = function()
		if (changeCallback) then
			DF:QuickDispatch(changeCallback)
		end
	end

	options.title_text = texts.DEBUFFS_TRACKED or defaultTextForAuraFrame.DEBUFFS_TRACKED
	local debuffTrackedAuraScrollBox = detailsFramework:CreateAuraScrollBox(auraPanel_Auto, "$parentDebuffTracked", newAuraPanel.db.aura_tracker.debuff_tracked, onAuraRemoveCallback, options)
	auraPanel_Auto.DebuffTrackerScroll = debuffTrackedAuraScrollBox

	options.title_text = texts.BUFFS_IGNORED or defaultTextForAuraFrame.BUFFS_IGNORED
	local buffIgnoredAuraScrollBox = detailsFramework:CreateAuraScrollBox(auraPanel_Auto, "$parentBuffIgnored", newAuraPanel.db.aura_tracker.buff_banned, onAuraRemoveCallback, options)
	auraPanel_Auto.BuffIgnoredScroll = buffIgnoredAuraScrollBox

	options.title_text = texts.DEBUFFS_IGNORED or defaultTextForAuraFrame.DEBUFFS_IGNORED
	local debuffIgnoredAuraScrollBox = detailsFramework:CreateAuraScrollBox(auraPanel_Auto, "$parentDebuffIgnored", newAuraPanel.db.aura_tracker.debuff_banned, onAuraRemoveCallback, options)
	auraPanel_Auto.DebuffIgnoredScroll = debuffIgnoredAuraScrollBox

	options.title_text = texts.BUFFS_TRACKED or defaultTextForAuraFrame.BUFFS_TRACKED
	local buffTrackedAuraScrollBox = detailsFramework:CreateAuraScrollBox(auraPanel_Auto, "$parentBuffTracked", newAuraPanel.db.aura_tracker.buff_tracked, onAuraRemoveCallback, options)
	auraPanel_Auto.BuffTrackerScroll = buffTrackedAuraScrollBox

	local xLocation = 140
	scrollWidth = scrollWidth + 20

	debuffIgnoredAuraScrollBox:SetPoint("topleft", auraPanel_Auto, "topleft", 0 + xLocation, y)
	buffIgnoredAuraScrollBox:SetPoint("topleft", auraPanel_Auto, "topleft", 8 + scrollWidth + xLocation, y)
	debuffTrackedAuraScrollBox:SetPoint("topleft", auraPanel_Auto, "topleft", 16 +(scrollWidth * 2) + xLocation, y)
	buffTrackedAuraScrollBox:SetPoint("topleft", auraPanel_Auto, "topleft", 24 +(scrollWidth * 3) + xLocation, y)

	newAuraPanel.buff_ignored = buffIgnoredAuraScrollBox
	newAuraPanel.debuff_ignored = debuffIgnoredAuraScrollBox
	newAuraPanel.buff_tracked = buffTrackedAuraScrollBox
	newAuraPanel.debuff_tracked = debuffTrackedAuraScrollBox

	auraPanel_Auto:SetScript("OnShow", function()
		buffTrackedAuraScrollBox:Refresh()
		debuffTrackedAuraScrollBox:Refresh()
		buffIgnoredAuraScrollBox:Refresh()
		debuffIgnoredAuraScrollBox:Refresh()
	end)
	auraPanel_Auto:SetScript("OnHide", function()
		--
	end)

	--show the frame selecton on the f.db

	if (newAuraPanel.db.aura_tracker.track_method == 0x1) then
		onSwitchTrackingMethod(automaticTrackingCheckbox)
	elseif (newAuraPanel.db.aura_tracker.track_method == 0x2) then
		onSwitchTrackingMethod(manualTrackingCheckbox)
	end

-------manual

	--build the two aura scrolls for buff and debuff

	local scroll_width = width
	local scroll_height = height
	local scroll_lines = 15
	local scroll_line_height = 20

	local backdrop_color = {.8, .8, .8, 0.2}
	local backdrop_color_on_enter = {.8, .8, .8, 0.4}

	local line_onenter = function(self)
		self:SetBackdropColor(unpack(backdrop_color_on_enter))
		local spellid = select(7, GetSpellInfo(self.value))
		if (spellid) then
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:SetSpellByID(spellid)
			GameTooltip:AddLine(" ")
			GameTooltip:Show()
		end
	end

	local line_onleave = function(self)
		self:SetBackdropColor(unpack(backdrop_color))
		GameTooltip:Hide()
	end

	local onclick_remove_button = function(self)
		local spell = self:GetParent().value
		local data = self:GetParent():GetParent():GetData()

		for i = 1, #data do
			if (data[i] == spell) then
				tremove(data, i)
				break
			end
		end

		self:GetParent():GetParent():Refresh()
	end

	local scroll_createline = function(self, index)
		local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
		line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
		line:SetSize(scroll_width - 2, scroll_line_height)
		line:SetScript("OnEnter", line_onenter)
		line:SetScript("OnLeave", line_onleave)

		line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		line:SetBackdropColor(unpack(backdrop_color))

		local icon = line:CreateTexture("$parentIcon", "overlay")
		icon:SetSize(scroll_line_height - 2, scroll_line_height - 2)

		local name = line:CreateFontString("$parentName", "overlay", "GameFontNormal")

		local remove_button = CreateFrame("button", "$parentRemoveButton", line, "UIPanelCloseButton")
		remove_button:SetSize(16, 16)
		remove_button:SetScript("OnClick", onclick_remove_button)
		remove_button:SetPoint("topright", line, "topright")
		remove_button:GetNormalTexture():SetDesaturated(true)

		icon:SetPoint("left", line, "left", 2, 0)
		name:SetPoint("left", icon, "right", 2, 0)

		line.icon = icon
		line.name = name
		line.removebutton = remove_button

		return line
	end

	local scroll_refresh = function(self, data, offset, total_lines)
		for i = 1, total_lines do
			local index = i + offset
			local aura = data [index]
			if (aura) then
				local line = self:GetLine(i)
				local name, _, icon = GetSpellInfo(aura)
				line.value = aura
				if (name) then
					line.name:SetText(name)
					line.icon:SetTexture(icon)
					line.icon:SetTexCoord(.1, .9, .1, .9)
				else
					line.name:SetText(aura)
					line.icon:SetTexture([[Interface\InventoryItems\WoWUnknownItem01]])
				end
			end
		end
	end

	local buffs_added = self:CreateScrollBox(auraPanel_Manual, "$parentBuffsAdded", scroll_refresh, newAuraPanel.db.aura_tracker.buff, scroll_width, scroll_height, scroll_lines, scroll_line_height)
	buffs_added:SetPoint("topleft", auraPanel_Manual, "topleft", 0, y)
	DF:ReskinSlider(buffs_added)

	for i = 1, scroll_lines do
		buffs_added:CreateLine(scroll_createline)
	end

	local debuffs_added = self:CreateScrollBox(auraPanel_Manual, "$parentDebuffsAdded", scroll_refresh, newAuraPanel.db.aura_tracker.debuff, scroll_width, scroll_height, scroll_lines, scroll_line_height)
	debuffs_added:SetPoint("topleft", auraPanel_Manual, "topleft", width+30, y)
	DF:ReskinSlider(debuffs_added)

	for i = 1, scroll_lines do
		debuffs_added:CreateLine(scroll_createline)
	end

	newAuraPanel.buffs_added = buffs_added
	newAuraPanel.debuffs_added = debuffs_added

	local buffs_added_name = DF:CreateLabel(buffs_added, "Buffs", 12, "silver")
	buffs_added_name:SetTemplate(DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
	buffs_added_name:SetPoint("bottomleft", buffs_added, "topleft", 0, 2)
	buffs_added.Title = buffs_added_name

	local debuffs_added_name = DF:CreateLabel(debuffs_added, "Debuffs", 12, "silver")
	debuffs_added_name:SetTemplate(DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
	debuffs_added_name:SetPoint("bottomleft", debuffs_added, "topleft", 0, 2)
	debuffs_added.Title = debuffs_added_name

	-- build the text entry to type the spellname
	local new_buff_string = self:CreateLabel(auraPanel_Manual, "Add Buff")
	local new_debuff_string = self:CreateLabel(auraPanel_Manual, "Add Debuff")
	local new_buff_entry = self:CreateTextEntry(auraPanel_Manual, function()end, 200, 20, "NewBuffTextBox", _, _, options_dropdown_template)
	local new_debuff_entry = self:CreateTextEntry(auraPanel_Manual, function()end, 200, 20, "NewDebuffTextBox", _, _, options_dropdown_template)

	new_buff_entry:SetHook("OnEditFocusGained", setAutoCompleteWordList)
	new_debuff_entry:SetHook("OnEditFocusGained", setAutoCompleteWordList)
	new_buff_entry.tooltip = "Enter the buff name using lower case letters.\n\nYou can add several spells at once using |cFFFFFF00;|r to separate each spell name."
	new_debuff_entry.tooltip = "Enter the debuff name using lower case letters.\n\nYou can add several spells at once using |cFFFFFF00;|r to separate each spell name."

	new_buff_entry:SetJustifyH("left")
	new_debuff_entry:SetJustifyH("left")

	local add_buff_button = self:CreateButton(auraPanel_Manual, function()

		local text = new_buff_entry.text
		new_buff_entry:SetText("")
		new_buff_entry:ClearFocus()

		if (text ~= "") then
			--check for more than one spellname
			if (text:find(";")) then
				for _, spellName in ipairs({strsplit(";", text)}) do
					spellName = self:trim(spellName)
					local spellID = getSpellIDFromSpellName(spellName)

					if (spellID) then
						tinsert(newAuraPanel.db.aura_tracker.buff, spellID)
						--[[
						if not tonumber(spellName) then
							tinsert(f.db.aura_tracker.buff, spellName)
						else
							tinsert(f.db.aura_tracker.buff, spellID)
						end
						]]--
					else
						print("spellId not found for spell:", spellName)
					end
				end
			else
				--get the spellId
				local spellID = getSpellIDFromSpellName(text)
				if (not spellID) then
					print("spellIs for spell ", text, "not found")
					return
				end

				tinsert(newAuraPanel.db.aura_tracker.buff, spellID)
				--[[
				if not tonumber(text) then
					tinsert(f.db.aura_tracker.buff, text)
				else
					tinsert(f.db.aura_tracker.buff, spellID)
				end
				]]--
			end

			buffs_added:Refresh()
		end

	end, 100, 20, "Add Buff", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

	local add_debuff_button = self:CreateButton(auraPanel_Manual, function()
		local text = new_debuff_entry.text
		new_debuff_entry:SetText("")
		new_debuff_entry:ClearFocus()
		if (text ~= "") then
			--check for more than one spellname
			if (text:find(";")) then
				for _, spellName in ipairs({strsplit(";", text)}) do
					spellName = self:trim(spellName)
					local spellID = getSpellIDFromSpellName(spellName)

					if (spellID) then
						tinsert(newAuraPanel.db.aura_tracker.debuff, spellID)
						--[[
						if not tonumber(spellName) then
							tinsert(f.db.aura_tracker.debuff, spellName)
						else
							tinsert(f.db.aura_tracker.debuff, spellID)
						end
						]]--
					else
						print("spellId not found for spell:", spellName)
					end
				end
			else
				--get the spellId
				local spellID = getSpellIDFromSpellName(text)
				if (not spellID) then
					print("spellIs for spell ", text, "not found")
					return
				end

				tinsert(newAuraPanel.db.aura_tracker.debuff, spellID)
				--[[
				if not tonumber(text) then
					print(text)
					tinsert(f.db.aura_tracker.debuff, text)
				else
					print(spellID)
					tinsert(f.db.aura_tracker.debuff, spellID)
				end
				]]--
			end

			debuffs_added:Refresh()
		end
	end, 100, 20, "Add Debuff", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

	local multiple_spells_label = DF:CreateLabel(buffs_added, "You can add multiple auras at once by separating them with ';'.\nExample: Fireball; Frostbolt; Flamestrike", 10, "gray")
	multiple_spells_label:SetSize(350, 24)
	multiple_spells_label:SetJustifyV("top")

	local export_box = self:CreateTextEntry(auraPanel_Manual, function()end, 242, 20, "ExportAuraTextBox", _, _, options_dropdown_template)

	local export_buff_button = self:CreateButton(auraPanel_Manual, function()
		local str = ""
		for _, spellId in ipairs(newAuraPanel.db.aura_tracker.buff) do
			local spellName = GetSpellInfo(spellId)
			if (spellName) then
				str = str .. spellName .. "; "
			end
		end
		export_box.text = str
		export_box:SetFocus(true)
		export_box:HighlightText()

	end, 120, 20, "Export Buffs", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

	local export_debuff_button = self:CreateButton(auraPanel_Manual, function()
		local str = ""
		for _, spellId in ipairs(newAuraPanel.db.aura_tracker.debuff) do
			local spellName = GetSpellInfo(spellId)
			if (spellName) then
				str = str .. spellName .. "; "
			end
		end

		export_box.text = str
		export_box:SetFocus(true)
		export_box:HighlightText()

	end, 120, 20, "Export Debuffs", nil, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

	new_buff_entry:SetPoint("topleft", auraPanel_Manual, "topleft", 480, y)
	new_buff_string:SetPoint("bottomleft", new_buff_entry, "topleft", 0, 2)
	add_buff_button:SetPoint("left", new_buff_entry, "right", 2, 0)
	add_buff_button.tooltip = "Add the aura to be tracked.\n\nClick an aura on the list to remove it."

	new_debuff_string:SetPoint("topleft", new_buff_entry, "bottomleft", 0, -6)
	new_debuff_entry:SetPoint("topleft", new_debuff_string, "bottomleft", 0, -2)
	add_debuff_button:SetPoint("left", new_debuff_entry, "right", 2, 0)
	add_debuff_button.tooltip = "Add the aura to be tracked.\n\nClick an aura on the list to remove it."

	multiple_spells_label:SetPoint("topleft", new_debuff_entry, "bottomleft", 0, -6)

	export_buff_button:SetPoint("topleft", multiple_spells_label, "bottomleft", 0, -12)
	export_debuff_button:SetPoint("left",export_buff_button, "right", 2, 0)
	export_box:SetPoint("topleft", export_buff_button, "bottomleft", 0, -6)

	buffs_added:Refresh()
	debuffs_added:Refresh()

	newAuraPanel:SetScript("OnShow", function()
		buffs_added:Refresh()
		debuffs_added:Refresh()
	end)

	return newAuraPanel
end


function DF:GetAllPlayerSpells(include_lower_case)
	local playerSpells = {}
	local tab, tabTex, offset, numSpells = GetSpellTabInfo(2)
	for i = 1, numSpells do
		local index = offset + i
		local spellType, spellId = GetSpellBookItemInfo(index, "player")
		if (spellType == "SPELL") then
			local spellName = GetSpellInfo(spellId)
			tinsert(playerSpells, spellName)
			if (include_lower_case) then
				tinsert(playerSpells, lower(spellName))
			end
		end
	end
	return playerSpells
end

function DF:SetAutoCompleteWithSpells(textentry)
	textentry:SetHook("OnEditFocusGained", function()
		local playerSpells = DF:GetAllPlayerSpells(true)
		textentry.WordList = playerSpells
	end)
	textentry:SetAsAutoComplete("WordList")
end



