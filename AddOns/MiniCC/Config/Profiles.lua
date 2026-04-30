---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local profileManager = addon.Core.ProfileManager

---@class ProfilesConfig
local M = {}
addon.Config.Profiles = M

local noneLabel = "(none)"
local rowHeight = 28
local specColW = 160

local profilePrefix    = "!MiniCC:2!"
local legacyPrefix     = "!MiniCC!"
local profileIOWindow

local function ExportCurrentProfile()
	profileManager:SaveCurrentProfile()
	local db = mini:GetSavedVars()
	local profileData = db.Profiles and db.Profiles[db.ActiveProfile]
	if not profileData then return "" end
	local serialized = C_EncodingUtil.SerializeCBOR(profileData)
	local encoded = C_EncodingUtil.EncodeBase64(serialized)
	return profilePrefix .. encoded
end

local function ImportAsProfile(str, name)
	local encoded
	local isLegacy = false
	if str:sub(1, #profilePrefix) == profilePrefix then
		encoded = str:sub(#profilePrefix + 1)
	elseif str:sub(1, #legacyPrefix) == legacyPrefix then
		encoded = str:sub(#legacyPrefix + 1)
		isLegacy = true
	else
		return false, L["Invalid profile string."]
	end

	local decoded = C_EncodingUtil.DecodeBase64(encoded)
	if not decoded or decoded == "" then
		return false, L["Failed to decode profile string."]
	end
	local ok, data = pcall(C_EncodingUtil.DeserializeCBOR, decoded)
	if not ok or type(data) ~= "table" then
		return false, L["Profile string is corrupted."]
	end

	-- Legacy strings contain the full saved-vars table; extract the profile payload.
	local profileData
	if isLegacy then
		profileData = {}
		for _, k in ipairs(addon.Core.ProfileManager.PayloadKeys) do
			if data[k] ~= nil then profileData[k] = data[k] end
		end
	else
		profileData = data
	end

	local db = mini:GetSavedVars()
	db.Profiles = db.Profiles or {}
	if db.Profiles[name] then
		return false, string.format(L['A profile named "%s" already exists.'], name)
	end
	db.Profiles[name] = profileData
	return true
end

local function GetOrCreateProfileIOWindow()
	if profileIOWindow then
		return profileIOWindow
	end

	local win = CreateFrame("Frame", "MiniCCProfileIOWindow", UIParent, "BackdropTemplate")
	win:SetSize(500, 310)
	win:SetFrameStrata("DIALOG")
	win:SetClampedToScreen(true)
	win:SetMovable(true)
	win:EnableMouse(true)
	win:RegisterForDrag("LeftButton")
	win:SetScript("OnDragStart", win.StartMoving)
	win:SetScript("OnDragStop", win.StopMovingOrSizing)
	win:Hide()
	win:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	win:SetBackdropColor(0, 0, 0, 0.9)

	local innerWidth = 500 - 32

	local title = win:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOP", win, "TOP", 0, -10)
	title:SetText(L["Import/Export Profile"])
	title:SetTextColor(1, 0.82, 0)

	local divider1 = win:CreateTexture(nil, "ARTWORK")
	divider1:SetHeight(1)
	divider1:SetPoint("TOPLEFT", win, "TOPLEFT", 8, -28)
	divider1:SetPoint("TOPRIGHT", win, "TOPRIGHT", -8, -28)
	divider1:SetColorTexture(1, 1, 1, 0.15)

	local exportLabel = win:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	exportLabel:SetPoint("TOPLEFT", win, "TOPLEFT", 16, -42)
	exportLabel:SetText(L["Export Profile"])

	local exportBox = CreateFrame("EditBox", nil, win, "InputBoxTemplate")
	exportBox:SetHeight(28)
	exportBox:SetWidth(innerWidth)
	exportBox:SetPoint("TOPLEFT", exportLabel, "BOTTOMLEFT", 0, -6)
	exportBox:SetAutoFocus(false)
	exportBox:SetMaxLetters(0)
	exportBox:SetScript("OnEscapePressed", function() win:Hide() end)
	exportBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)

	local divider2 = win:CreateTexture(nil, "ARTWORK")
	divider2:SetHeight(1)
	divider2:SetPoint("TOPLEFT", exportBox, "BOTTOMLEFT", 0, -12)
	divider2:SetPoint("TOPRIGHT", exportBox, "BOTTOMRIGHT", 0, -12)
	divider2:SetColorTexture(1, 1, 1, 0.15)

	local importSectionLabel = win:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	importSectionLabel:SetPoint("TOPLEFT", divider2, "BOTTOMLEFT", 0, -12)
	importSectionLabel:SetText(L["Import Profile"])

	local nameLabel = win:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	nameLabel:SetPoint("TOPLEFT", importSectionLabel, "BOTTOMLEFT", 0, -10)
	nameLabel:SetText(L["Profile Name"])

	local nameBox = CreateFrame("EditBox", nil, win, "InputBoxTemplate")
	nameBox:SetHeight(28)
	nameBox:SetWidth(innerWidth)
	nameBox:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -4)
	nameBox:SetAutoFocus(false)
	nameBox:SetMaxLetters(64)
	nameBox:SetScript("OnEscapePressed", function() win:Hide() end)

	local stringLabel = win:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	stringLabel:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", 0, -10)
	stringLabel:SetText(L["Profile String"])

	local importBox = CreateFrame("EditBox", nil, win, "InputBoxTemplate")
	importBox:SetHeight(28)
	importBox:SetWidth(innerWidth)
	importBox:SetPoint("TOPLEFT", stringLabel, "BOTTOMLEFT", 0, -4)
	importBox:SetAutoFocus(false)
	importBox:SetMaxLetters(0)
	importBox:SetScript("OnEscapePressed", function() win:Hide() end)

	local importBtn = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
	importBtn:SetSize(100, 22)
	importBtn:SetPoint("TOPRIGHT", importBox, "BOTTOMRIGHT", 0, -12)
	importBtn:SetText(L["Import"])
	importBtn:SetScript("OnClick", function()
		local str = importBox:GetText():gsub("%s+", "")
		local name = nameBox:GetText():match("^%s*(.-)%s*$")
		if str == "" then
			mini:Notify(L["Please paste a profile string to import."])
			return
		end
		if name == "" then
			mini:Notify(L["Please enter a profile name."])
			return
		end
		local ok, err = ImportAsProfile(str, name)
		if not ok then
			mini:Notify(err)
			return
		end
		profileManager:SwitchProfile(name)
		mini:Notify(L["Profile imported successfully."])
		win:Hide()
	end)

	local closeBtn = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
	closeBtn:SetSize(80, 22)
	closeBtn:SetPoint("TOPRIGHT", importBtn, "TOPLEFT", -8, 0)
	closeBtn:SetText(CLOSE)
	closeBtn:SetScript("OnClick", function() win:Hide() end)

	win.ExportBox = exportBox
	win.ImportBox = importBox
	win.NameBox = nameBox
	profileIOWindow = win
	return win
end

local function ShowProfileIOWindow()
	local win = GetOrCreateProfileIOWindow()
	win.ExportBox:SetText(ExportCurrentProfile())
	win.ImportBox:SetText("")
	win.NameBox:SetText(profileManager:GetActiveProfile() .. " (2)")
	win:ClearAllPoints()
	win:SetPoint("CENTER", UIParent, "CENTER")
	win:Show()
end

StaticPopupDialogs["MINICC_PROFILE_NAME"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	hasEditBox = true,
	editBoxWidth = 220,
	OnShow = function(self, data)
		self.EditBox:SetText(data and data.Default or "")
		self.EditBox:HighlightText()
		self.EditBox:SetFocus()
	end,
	OnAccept = function(self, data)
		local text = self.EditBox:GetText():match("^%s*(.-)%s*$")
		if text ~= "" and data and data.OnAccept then
			data.OnAccept(text)
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		local data = parent.data
		local text = self:GetText():match("^%s*(.-)%s*$")
		if text ~= "" and data and data.OnAccept then
			data.OnAccept(text)
		end
		parent:Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

local function MakeButton(parent, text, width)
	local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	btn:SetSize(width or 80, 22)
	btn:SetText(text)
	return btn
end

function M:Build(panel)
	local db = mini:GetSavedVars()

	-- ── Active profile ─────────────────────────────────────────────────
	local activeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	activeLabel:SetText(L["Active Profile"])
	activeLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local profileItems = {}
	for _, name in ipairs(profileManager:GetProfileNames()) do
		profileItems[#profileItems + 1] = name
	end

	local activeDd, isModern = mini:Dropdown({
		Parent = panel,
		Items = profileItems,
		Width = 160,
		GetValue = function()
			return profileManager:GetActiveProfile()
		end,
		SetValue = function(value)
			profileManager:SwitchProfile(value)
		end,
	})
	activeDd:SetWidth(160)
	activeDd:SetPoint("TOPLEFT", activeLabel, "BOTTOMLEFT", isModern and 0 or -16, -4)

	local newBtn = MakeButton(panel, L["New"], 70)
	newBtn:SetPoint("TOPLEFT", activeLabel, "BOTTOMLEFT", 170, -3)

	local renameBtn = MakeButton(panel, L["Rename"], 70)
	renameBtn:SetPoint("LEFT", newBtn, "RIGHT", 4, 0)
	renameBtn:SetPoint("TOP", newBtn, "TOP")

	local cloneBtn = MakeButton(panel, L["Clone"], 70)
	cloneBtn:SetPoint("LEFT", renameBtn, "RIGHT", 4, 0)
	cloneBtn:SetPoint("TOP", renameBtn, "TOP")

	local deleteBtn = MakeButton(panel, L["Delete"], 70)
	deleteBtn:SetPoint("LEFT", cloneBtn, "RIGHT", 4, 0)
	deleteBtn:SetPoint("TOP", cloneBtn, "TOP")

	newBtn:SetScript("OnClick", function()
		StaticPopup_Show("MINICC_PROFILE_NAME", L["New Profile"], nil, {
			Default = "",
			OnAccept = function(name)
				if db.Profiles and db.Profiles[name] then
					mini:Notify(L['A profile named "%s" already exists.'], name)
					return
				end
				profileManager:SaveCurrentProfile()
				profileManager:CreateProfile(name, profileManager:GetActiveProfile())
				profileManager:SwitchProfile(name)
			end,
		})
	end)

	cloneBtn:SetScript("OnClick", function()
		local current = profileManager:GetActiveProfile()
		StaticPopup_Show("MINICC_PROFILE_NAME", L["Clone Profile"], nil, {
			Default = current .. " (2)",
			OnAccept = function(name)
				if db.Profiles and db.Profiles[name] then
					mini:Notify(L['A profile named "%s" already exists.'], name)
					return
				end
				profileManager:SaveCurrentProfile()
				profileManager:CreateProfile(name, current)
				profileManager:SwitchProfile(name)
			end,
		})
	end)

	renameBtn:SetScript("OnClick", function()
		local current = profileManager:GetActiveProfile()
		StaticPopup_Show("MINICC_PROFILE_NAME", L["Rename Profile"], nil, {
			Default = current,
			OnAccept = function(newName)
				if newName == current then return end
				if db.Profiles and db.Profiles[newName] then
					mini:Notify(L['A profile named "%s" already exists.'], newName)
					return
				end
				profileManager:RenameProfile(current, newName)
			end,
		})
	end)

	deleteBtn:SetScript("OnClick", function()
		if #profileManager:GetProfileNames() <= 1 then
			mini:Notify(L["Cannot delete the last profile."])
			return
		end
		local current = profileManager:GetActiveProfile()
		StaticPopup_Show("MINICC_CONFIRM",
			string.format(L['Delete profile "%s"?'], current), nil, {
				OnYes = function()
					profileManager:DeleteProfile(current)
				end,
			})
	end)

	local resetBtn = MakeButton(panel, L["Reset"], 90)
	resetBtn:SetPoint("TOPLEFT", newBtn, "BOTTOMLEFT", 0, -4)
	resetBtn:SetScript("OnClick", function()
		if InCombatLockdown() then
			mini:NotifyCombatLockdown()
			return
		end
		local current = profileManager:GetActiveProfile()
		StaticPopup_Show("MINICC_CONFIRM",
			string.format(L['Reset profile "%s" to defaults?'], current), nil, {
				OnYes = function()
					profileManager:ResetCurrentProfileToDefaults()
					local tabController = addon.Config.TabController
					if tabController then
						for i = 1, #tabController.Tabs do
							local content = tabController:GetContent(tabController.Tabs[i].Key)
							if content and content.MiniRefresh then content:MiniRefresh() end
						end
					end
					addon:Refresh()
					mini:Notify(L["Profile reset to defaults."])
				end,
			})
	end)

	local importExportBtn = MakeButton(panel, L["Import/Export"], 110)
	importExportBtn:SetPoint("LEFT", resetBtn, "RIGHT", 4, 0)
	importExportBtn:SetPoint("TOP", resetBtn, "TOP")
	importExportBtn:SetScript("OnClick", function()
		if InCombatLockdown() then
			mini:NotifyCombatLockdown()
			return
		end
		ShowProfileIOWindow()
	end)

	-- ── Auto-switch section ────────────────────────────────────────────
	-- Spacer anchored below the second button row so the divider always
	-- has a clean anchor regardless of dropdown height differences.
	local spacer = CreateFrame("Frame", nil, panel)
	spacer:SetHeight(16)
	spacer:SetPoint("TOPLEFT", resetBtn, "BOTTOMLEFT", 0, 0)
	spacer:SetPoint("RIGHT", panel, "RIGHT")

	local autoDiv = mini:Divider({
		Parent = panel,
		Text = L["Auto-Switch"],
	})
	autoDiv:SetPoint("LEFT", panel, "LEFT")
	autoDiv:SetPoint("RIGHT", panel, "RIGHT")
	autoDiv:SetPoint("TOP", spacer, "BOTTOM", 0, 0)

	local noteText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	noteText:SetText(L["Automatically switch profiles based on your specialization."])
	noteText:SetPoint("TOPLEFT", autoDiv, "BOTTOMLEFT", 0, -4)
	noteText:SetWidth(mini.ContentWidth or 600)
	noteText:SetJustifyH("LEFT")

	-- Spec rows - built lazily on first panel show because spec data is unavailable
	-- at ADDON_LOADED time (only ready after PLAYER_LOGIN).
	local specRows = {}
	local specRowsBuilt = false
	local prevRow = noteText

	local function BuildSpecRows()
		if specRowsBuilt then return end
		specRowsBuilt = true

		local numSpecs = GetNumSpecializations and GetNumSpecializations() or 0
		for specIdx = 1, numSpecs do
			local specId, specName, _, specIcon = GetSpecializationInfo(specIdx)
			if specId then
				local capturedSpecId = specId
				local thisItems = { noneLabel }

				local row = CreateFrame("Frame", nil, panel)
				row:SetHeight(rowHeight)
				row:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT", 0, -8)
				row:SetPoint("RIGHT", panel, "RIGHT")

				local icon = row:CreateTexture(nil, "ARTWORK")
				icon:SetSize(20, 20)
				icon:SetTexture(specIcon)
				icon:SetPoint("LEFT", row, "LEFT", 0, 0)
				icon:SetPoint("TOP", row, "TOP", 0, -4)

				local lbl = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				lbl:SetText(specName)
				lbl:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, 0)
				lbl:SetWidth(specColW - 28)

				local dd, ddIsModern = mini:Dropdown({
					Parent = panel,
					Items = thisItems,
					Width = 160,
					GetValue = function()
						return profileManager:GetAutoSwitchRule(capturedSpecId) or noneLabel
					end,
					SetValue = function(value)
						profileManager:SetAutoSwitchRule(
							capturedSpecId,
							value == noneLabel and nil or value)
					end,
				})
				dd:SetWidth(160)
				dd:SetPoint("TOPLEFT", row, "TOPLEFT",
					specColW + (ddIsModern and 0 or -16),
					ddIsModern and 0 or 4)

				specRows[specIdx] = { dd = dd, items = thisItems }
				prevRow = row
			end
		end
	end

	-- The panel's parent scroll container fires OnShow each time the tab is selected.
	panel:SetScript("OnShow", function()
		BuildSpecRows()
		if panel.OnMiniRefresh then panel:OnMiniRefresh() end
	end)

	-- MiniRefresh
	panel.OnMiniRefresh = function()
		for i = #profileItems, 1, -1 do profileItems[i] = nil end
		for _, name in ipairs(profileManager:GetProfileNames()) do
			profileItems[#profileItems + 1] = name
		end

		local allItems = { noneLabel }
		for _, name in ipairs(profileManager:GetProfileNames()) do
			allItems[#allItems + 1] = name
		end
		for _, rowData in pairs(specRows) do
			local items = rowData.items
			for i = #items, 1, -1 do items[i] = nil end
			for _, v in ipairs(allItems) do items[#items + 1] = v end
			rowData.dd:MiniRefresh()
		end

		if #profileManager:GetProfileNames() > 1 then
			deleteBtn:Enable()
		else
			deleteBtn:Disable()
		end

		activeDd:MiniRefresh()
	end

	panel.OnMiniRefresh()

	-- Refresh all panels whenever the active profile changes.
	profileManager:RegisterOnProfileChanged("ConfigUI", function()
		local tabController = addon.Config.TabController
		if not tabController then return end
		for i = 1, #tabController.Tabs do
			local content = tabController:GetContent(tabController.Tabs[i].Key)
			if content and content.MiniRefresh then
				content:MiniRefresh()
			end
		end
	end)
end
