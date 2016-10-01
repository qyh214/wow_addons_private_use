--- Kaliel's Tracker
--- Copyright (c) 2012-2016, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, addon = ...
local KT = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "LibSink-2.0")
KT:SetDefaultModuleState(false)
KT.title = GetAddOnMetadata(addonName, "Title")
KT.version = GetAddOnMetadata(addonName, "Version")
KT.locale = GetLocale()

local LSM = LibStub("LibSharedMedia-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local abs = math.abs
local floor = math.floor
local fmod = math.fmod
local format = string.format
local gsub = string.gsub
local hooksecurefunc = hooksecurefunc
local ipairs = ipairs
local pairs = pairs
local strfind = string.find
local tinsert = table.insert
local tremove = table.remove
local unpack = unpack
local round = function(n) return floor(n + 0.5) end

-- WoW API
local _G = _G
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local InCombatLockdown = InCombatLockdown
local UIParent = UIParent

local trackerWidth = 280
local paddingBottom = 15
local mediaPath = "Interface\\AddOns\\"..addonName.."\\Media\\"
local questState = {}
local freeTags = {}
local freeButtons = {}
local msgPatterns = {}
local stopUpdate = false
local db

-- Main frame
local KTF = CreateFrame("Frame", addonName.."Frame", UIParent)
KT.frame = KTF

-- Blizzard frame
local OTF = ObjectiveTrackerFrame
local OTFHeader = OTF.HeaderMenu

-- Blizzard Constants
OBJECTIVE_TRACKER_LINE_WIDTH = 240
QUEST_DASH = "- "
DEFAULT_OBJECTIVE_TRACKER_MODULE.freeLines[1].Dash:SetText(QUEST_DASH)
OBJECTIVE_TRACKER_DASH_WIDTH = DEFAULT_OBJECTIVE_TRACKER_MODULE.freeLines[1].Dash:GetWidth()
OBJECTIVE_TRACKER_TEXT_WIDTH = OBJECTIVE_TRACKER_LINE_WIDTH - OBJECTIVE_TRACKER_DASH_WIDTH - 12
DEFAULT_OBJECTIVE_TRACKER_MODULE.lineWidth = OBJECTIVE_TRACKER_TEXT_WIDTH
DEFAULT_OBJECTIVE_TRACKER_MODULE.freeLines[1].Text:SetWidth(OBJECTIVE_TRACKER_TEXT_WIDTH)

AUTO_QUEST_POPUP_TRACKER_MODULE.blockOffsetX = -26
SCENARIO_CONTENT_TRACKER_MODULE.blockOffsetX = -16

OBJECTIVE_TRACKER_COLOR["Header"] = { r = 1, g = 0.5, b = 0 }			-- orange
OBJECTIVE_TRACKER_COLOR["Complete"] = { r = 0.1, g = 0.85, b = 0.1 }	-- green
OBJECTIVE_TRACKER_COLOR["CompleteHighlight"] = { r = 0, g = 1, b = 0 }	-- green

--------------
-- Internal --
--------------

local function SetHeaders(type)
	local bgrColor = db.hdrBgrColorShare and KT.borderColor or db.hdrBgrColor
	local txtColor = db.hdrTxtColorShare and KT.borderColor or db.hdrTxtColor

	for _, header in ipairs(KT.headers) do
		if not type or type == "background" then
			if db.hdrBgr == 1 then
				header.Background:Hide()
			elseif db.hdrBgr == 2 then
				header.Background:SetAtlas("Objective-Header")
				header.Background:SetVertexColor(1, 1, 1)
				header.Background:ClearAllPoints()
				header.Background:SetPoint("TOPLEFT", -29, 14)
				header.Background:Show()
			elseif db.hdrBgr >= 3 then
				header.Background:SetTexture(mediaPath.."UI-KT-HeaderBackground-"..(db.hdrBgr - 2))
				header.Background:SetVertexColor(bgrColor.r, bgrColor.g, bgrColor.b)
				header.Background:SetPoint("TOPLEFT", -20, 0)
				header.Background:SetPoint("BOTTOMRIGHT", 17, -7)
				header.Background:Show()
			end
		end
		if not type or type == "text" then
			header.Text:SetFont(KT.font, db.fontSize+1, db.fontFlag)
			if db.hdrBgr == 2 then
				header.Text:SetTextColor(1, 0.82, 0)
			else
				header.Text:SetTextColor(txtColor.r, txtColor.g, txtColor.b)
			end
			header.Text:SetShadowColor(0, 0, 0, db.fontShadow)
			header.Text:SetPoint("LEFT", 4, 0)
			header.animateReason = 0
		end
	end
end

local function SetMsgPatterns()
	local patterns = {
		-- enUS/frFR/etc. ... "%s: %d/%d"
		-- deDE (only) ...... "%1$s: %2$d/%3$d"
		ERR_QUEST_ADD_FOUND_SII,
		ERR_QUEST_ADD_ITEM_SII,
		ERR_QUEST_ADD_KILL_SII,
	}
	for _, patt in ipairs(patterns) do
		patt = "^"..patt:gsub("%d+%$", ""):gsub("%%s", ".*"):gsub("%%d", "%%d+").."$"
		tinsert(msgPatterns, patt)
	end
end

local function SetMessage(text, pattern, r, g, b, icon, x, y)
	if pattern then
		text = format(pattern, text.." ...")
	end
	if icon then
		x = x or 0
		y = y or 0
		if db.sink20OutputSink == "Blizzard" then
			x = floor(x * 2 * COMBAT_TEXT_X_SCALE)
			y = y - 6
		end
		text = format("|T%s:0:0:%d:%d|t%s", icon, x, y, text)
	end
	KT:Pour(text, r, g, b)
end

local function SlashHandler(msg, editbox)
	local cmd, value = msg:match("^(%S*)%s*(.-)$")
	if cmd == "config" then
		KT:OpenOptions()
	else
		ObjectiveTracker_MinimizeButton_OnClick()
	end
end

local function SetScrollbarPosition()
	KTF.Bar:SetPoint("TOPRIGHT", -5, -round(5+(KTF.Scroll.value*(((db.maxHeight-60)/((OTF.height-db.maxHeight)/KTF.Scroll.step))/KTF.Scroll.step))))
end

-- Setup ---------------------------------------------------------------------------------------------------------------

local function Init()
	db = KT.db.profile

	if db.keyBindMinimize ~= "" then
		SetOverrideBindingClick(KTF, false, db.keyBindMinimize, KTF.MinimizeButton:GetName())
	end

	for _, module in ipairs(OTF.MODULES) do
		KT:SaveHeader(module)
	end

	KT:MoveTracker()
	KT:SetBackground()
	KT:SetText()

	KT:SetQuestsHeaderText()
	KT:SetAchievsHeaderText()

	if db.collapsed then
		ObjectiveTracker_MinimizeButton_OnClick()
	end
end

local function SetFrames()
	-- Main frame
	KTF:SetWidth(trackerWidth)
	KTF:SetFrameStrata(db.frameStrata)
	KTF:SetFrameLevel(KTF:GetFrameLevel() + 25)

	KTF:SetScript("OnEvent", function(_, event, ...)
		_DBG("Event - "..event)
		if event == "PLAYER_ENTERING_WORLD" then
			KT.inWorld = true
			KT.inInstance = IsInInstance()
			if db.collapseInInstance and KT.inInstance and not db.collapsed then
				ObjectiveTracker_MinimizeButton_OnClick()
			end
		elseif event == "PLAYER_LEAVING_WORLD" then
			KT.inWorld = false
		elseif event == "QUEST_WATCH_LIST_CHANGED" or event == "TRACKED_ACHIEVEMENT_LIST_CHANGED" then
			local id, added = ...
			if id and not added then
				questState[id] = nil
			end
			KT:ToggleEmptyTracker(added)
		elseif event == "QUEST_AUTOCOMPLETE" then
			KTF.Scroll.value = 0
		elseif event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED" then
			KT:SetQuestsHeaderText()
		elseif event == "ACHIEVEMENT_EARNED" then
			KT:SetAchievsHeaderText()
		elseif event == "PLAYER_REGEN_ENABLED" and stopUpdate then
			stopUpdate = false
			KT:RemoveFixedButton()
			if not db.collapsed then
				ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST)
			end
		elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
			if KTF.Buttons.num > 0 then
				KTF.Buttons.reanchor = not InCombatLockdown()
			end
		elseif event == "UPDATE_BINDINGS" then
			KT:UpdateHotkey()
		end
	end)
	KTF:RegisterEvent("PLAYER_LEAVING_WORLD")
	KTF:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
	KTF:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED")
	KTF:RegisterEvent("QUEST_AUTOCOMPLETE")
	KTF:RegisterEvent("QUEST_ACCEPTED")
	KTF:RegisterEvent("QUEST_REMOVED")
	KTF:RegisterEvent("ACHIEVEMENT_EARNED")
	KTF:RegisterEvent("PLAYER_REGEN_ENABLED")
	KTF:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	KTF:RegisterEvent("ZONE_CHANGED")
	KTF:RegisterEvent("UPDATE_BINDINGS")

	-- Minimize button
	OTFHeader.MinimizeButton:Hide()
	local button = CreateFrame("Button", addonName.."MinimizeButton", KTF)
	button:SetSize(16, 16)
	button:SetPoint("TOPRIGHT", -10, -8)
	button:SetFrameLevel(KTF:GetFrameLevel() + 10)
	button:SetNormalTexture(mediaPath.."UI-KT-HeaderButtons")
	button:GetNormalTexture():SetTexCoord(0, 0.5, 0.25, 0.5)

	button:RegisterForClicks("AnyDown")
	button:SetScript("OnClick", function(self, btn)
		if IsAltKeyDown() then
			KT:OpenOptions()
		elseif not KT:IsTrackerEmpty() then
			ObjectiveTracker_MinimizeButton_OnClick()
		end
	end)
	button:SetScript("OnEnter", function(self)
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local title = (db.keyBindMinimize ~= "") and KT.title.." "..NORMAL_FONT_COLOR_CODE.."("..db.keyBindMinimize..")|r" or KT.title
		GameTooltip:AddLine(title, 1, 1, 1)
		GameTooltip:AddLine("Alt+Click - addon Options", 0.5, 0.5, 0.5)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		self:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
		GameTooltip:Hide()
	end)
	KTF.MinimizeButton = button

	KT:ToggleOtherButtons()

	-- Scroll frame
	local Scroll = CreateFrame("ScrollFrame", addonName.."Scroll", KTF)
	Scroll:SetPoint("TOPLEFT", 4, -4)
	Scroll:SetPoint("BOTTOMRIGHT", -4, 4)
	Scroll:EnableMouseWheel(true)
	Scroll.step = 20
	Scroll.value = 0
	Scroll:SetScript("OnMouseWheel", function(self, delta)
		if not db.collapsed and OTF.height > db.maxHeight then	-- floats ??? +11
			if delta < 0 then
				self.value = (self.value+self.step < OTF.height-db.maxHeight) and self.value + self.step or OTF.height - db.maxHeight
			else
				self.value = (self.value-self.step > 0) and self.value - self.step or 0
			end
			self:SetVerticalScroll(self.value)
			if db.frameScrollbar then
				SetScrollbarPosition()
			end
			if self.value > 0 and self.value < OTF.height-db.maxHeight then
				CloseDropDownMenus()
			end
			_DBG("SCROLL ... "..self.value.." ... "..OTF.height.." - "..db.maxHeight)
		end
	end)
	Scroll:SetScript("OnScrollRangeChanged", function(self, x, y)
		KT:MoveButtons()
	end)
	KTF.Scroll = Scroll

	-- Scroll child frame
	local Child = CreateFrame("Frame", addonName.."ScrollChild", KTF.Scroll)
	Child:SetSize(trackerWidth-8, 4000)
	KTF.Scroll:SetScrollChild(Child)

	-- Scroll indicator
	local Bar = CreateFrame("Frame", addonName.."ScrollBar", KTF)
	Bar:SetSize(2, 50)
	Bar:SetPoint("TOPRIGHT", -5, -5)
	Bar:SetFrameLevel(KTF:GetFrameLevel() + 10)
	Bar.texture = Bar:CreateTexture()
	Bar.texture:SetAllPoints()
	Bar:Hide()
	KTF.Bar = Bar

	-- Blizzard frame
	OTF:KTSetParent(Child)
	OTF:KTSetPoint("TOPLEFT", 30, -1)
	OTF:KTSetPoint("BOTTOMRIGHT")

	OTFHeader:Show()
	OTFHeader.Hide = function() end
	OTFHeader.SetShown = function() end
	OTFHeader:SetSize(10, 21)
	OTFHeader:ClearAllPoints()
	OTFHeader:SetPoint("TOPLEFT", -20, -1)
	OTFHeader.Title:ClearAllPoints()
	OTFHeader.Title:SetPoint("LEFT")
	OTFHeader.Title:SetWidth(trackerWidth - 90)
	OTFHeader.Title:SetJustifyH("LEFT")
	OTFHeader.Title:SetWordWrap(false)

	ScenarioBlocksFrame:SetWidth(243)

	-- Buttons frame
	local Buttons = CreateFrame("Frame", addonName.."Buttons", UIParent)
	Buttons:SetSize(40, 40)
	Buttons:SetPoint("TOPLEFT", 0, 0)
	Buttons:SetFrameStrata(db.frameStrata)
	Buttons:SetFrameLevel(KTF:GetFrameLevel() - 1)
	Buttons:SetAlpha(0)
	Buttons.num = 0
	Buttons.reanchor = false
	KTF.Buttons = Buttons

	-- Frame locks
	if FRAMELOCK_STATES and FRAMELOCK_STATES.PETBATTLES then
		FRAMELOCK_STATES.PETBATTLES[addonName.."Frame"] = "hidden"
		FRAMELOCK_STATES.PETBATTLES[addonName.."Buttons"] = "hidden"
	end
end

-- Hooks ---------------------------------------------------------------------------------------------------------------

local function SetHooks()
	local bck_ObjectiveTracker_Update = ObjectiveTracker_Update
	ObjectiveTracker_Update = function(reason, id)
		if reason ~= OBJECTIVE_TRACKER_UPDATE_STATIC then
			_DBG("|cffffff00Update ... "..(reason and reason or ""))
		end
		if reason == OBJECTIVE_TRACKER_UPDATE_QUEST and not KT.inWorld then
			return
		end
		bck_ObjectiveTracker_Update(reason, id)
		OTF.isUpdating = true
		if db.collapsed then
			local _, numQuests = GetNumQuestLogEntries()
			local title = ""
			if db.hdrCollapsedTxt == 2 then
				title = ("%d/%d (%d)"):format(numQuests, MAX_QUESTS, GetDailyQuestsCompleted())
			elseif db.hdrCollapsedTxt == 3 then
				title = ("%d/%d Quests  -  %d Dailies"):format(numQuests, MAX_QUESTS, GetDailyQuestsCompleted())
			end
			OTFHeader.Title:SetText(title)
		end
		if reason == OBJECTIVE_TRACKER_UPDATE_STATIC then
			return
		elseif reason == OBJECTIVE_TRACKER_UPDATE_TASK_ADDED then
			KT.activeTask = id
			if db.collapsed and KT.AddonPetTracker:IsShown() then
				return
			end
			KT:ToggleEmptyTracker(true)
		elseif KT.activeTask then
			local isInArea, _ = GetTaskInfo(KT.activeTask)
			if not isInArea then
				KT.activeTask = 0
				KT:ToggleEmptyTracker()
			end
		end
		KT:SetSize()
		OTF.isUpdating = false
	end

	local bck_DEFAULT_OBJECTIVE_TRACKER_MODULE_AddObjective = DEFAULT_OBJECTIVE_TRACKER_MODULE.AddObjective
	function DEFAULT_OBJECTIVE_TRACKER_MODULE:AddObjective(block, objectiveKey, textOrTextFunc, lineType, useFullHeight, dashStyle, colorStyle)
		local text = (type(textOrTextFunc) == "function") and textOrTextFunc() or textOrTextFunc
		local _, _, leftText, colon, progress, numHave, numNeed, rightText = strfind(text, "(.-)(%s?:?%s?)((%d+)%s?/%s?(%d+))(.*)")
		if progress then
			if tonumber(numHave) > 0 and tonumber(numHave) < tonumber(numNeed) then
				progress = "|cffc8c800" .. progress .. "|r"
			end
			if not db.objNumSwitch then
				text = leftText .. colon .. progress .. rightText
			else
				text = progress
				if rightText ~= " " then
					text = text .. rightText
				end
				if leftText ~= "" then
					text = text .. " " .. leftText
				end
			end
		end
		local line = bck_DEFAULT_OBJECTIVE_TRACKER_MODULE_AddObjective(self, block, objectiveKey, text, lineType, useFullHeight, dashStyle, colorStyle)
		if line.Dash then
			line.Dash:SetFont(KT.font, db.fontSize, db.fontFlag)
			line.Dash:SetShadowColor(0, 0, 0, db.fontShadow)
		end
		if line.Check then
			line.Check:SetSize(db.fontSize-2.5, db.fontSize-2.5)
			line.Check:ClearAllPoints()
			line.Check:SetPoint("LEFT", -db.fontSize*0.2+(db.fontFlag == "" and 0 or 1), 0)
		end
		-- completion state
		if type(objectiveKey) == "string" then
			if strfind(objectiveKey, "Complete") then
				if not questState[block.id] or questState[block.id] ~= "complete" then
					SetMessage(block.title, ERR_QUEST_COMPLETE_S, 0, 1, 0, "Interface\\GossipFrame\\ActiveQuestIcon", -2, 0)
					questState[block.id] = "complete"
				end
			elseif strfind(objectiveKey, "Failed") then
				if not questState[block.id] or questState[block.id] ~= "failed" then
					SetMessage(block.title, ERR_QUEST_FAILED_S, 1, 0, 0, "Interface\\GossipFrame\\AvailableQuestIcon", -2, 0)
					questState[block.id] = "failed"
				end
			end
		end
		return line
	end

	local bck_DEFAULT_OBJECTIVE_TRACKER_MODULE_SetStringText = DEFAULT_OBJECTIVE_TRACKER_MODULE.SetStringText
	function DEFAULT_OBJECTIVE_TRACKER_MODULE:SetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)
		fontString:SetFont(KT.font, db.fontSize, db.fontFlag)
		fontString:SetShadowColor(0, 0, 0, db.fontShadow)
		fontString:SetWordWrap(db.textWordWrap)
		return bck_DEFAULT_OBJECTIVE_TRACKER_MODULE_SetStringText(self, fontString, text, useFullHeight, colorStyle, useHighlight)
	end

	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "OnBlockHeaderEnter", function(self, block)
		local colorStyle
		if self == QUEST_TRACKER_MODULE then
			if block.questCompleted then
				colorStyle = OBJECTIVE_TRACKER_COLOR["CompleteHighlight"]
			elseif db.colorDifficulty then
				_, colorStyle = GetQuestDifficultyColor(block.level)
			end
		end
		if colorStyle then
			block.HeaderText:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
			block.HeaderText.colorStyle = colorStyle
		end

		if db.tooltipShow and (self == QUEST_TRACKER_MODULE or self == ACHIEVEMENT_TRACKER_MODULE) then
			GameTooltip:SetOwner(block, "ANCHOR_NONE")
			GameTooltip:ClearAllPoints()
			if KTF.anchorLeft then
				GameTooltip:SetPoint("TOPLEFT", block, "TOPRIGHT", 12, 0)
			else
				GameTooltip:SetPoint("TOPRIGHT", block, "TOPLEFT", -32, 0)
			end
			if self == QUEST_TRACKER_MODULE then
				GameTooltip:SetHyperlink(GetQuestLink(GetQuestLogIndexByID(block.id)))
			else
				GameTooltip:SetHyperlink(GetAchievementLink(block.id))
			end
			if db.tooltipShowID then
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..block.id)
			end
			GameTooltip:Show()
		end

		if block.fixedTag then
			colorStyle = OBJECTIVE_TRACKER_COLOR["NormalHighlight"]
			block.fixedTag:SetBackdropColor(colorStyle.r, colorStyle.g, colorStyle.b)
			block.fixedTag.text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		end
	end)

	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "OnBlockHeaderLeave", function(self, block)
		local colorStyle
		if self == QUEST_TRACKER_MODULE then
			if block.questCompleted then
				colorStyle = OBJECTIVE_TRACKER_COLOR["Complete"]
			elseif db.colorDifficulty then
				colorStyle = GetQuestDifficultyColor(block.level)
			end
		end
		if colorStyle then
			block.HeaderText:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
			block.HeaderText.colorStyle = colorStyle
		end

		if db.tooltipShow then
			GameTooltip:Hide()
		end

		if block.fixedTag then
			colorStyle = OBJECTIVE_TRACKER_COLOR["Normal"]
			block.fixedTag:SetBackdropColor(colorStyle.r, colorStyle.g, colorStyle.b)
			block.fixedTag.text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		end
	end)

	hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderClick", function(self, block, mouseButton)
		GameTooltip:Hide()
	end)
	hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "OnBlockHeaderClick", function(self, block, mouseButton)
		GameTooltip:Hide()
	end)

	local bck_ObjectiveTracker_AddBlock = ObjectiveTracker_AddBlock
	ObjectiveTracker_AddBlock = function(block, forceAdd)
		local blockAdded = bck_ObjectiveTracker_AddBlock(block, forceAdd)
		if blockAdded then
			if block.module == QUEST_TRACKER_MODULE or block.module == ACHIEVEMENT_TRACKER_MODULE then
				local button = block.button
				if not button then
					button = CreateFrame("Button", nil, block)
					button:SetAllPoints()
					button:SetScript("OnEnter", function() block.module:OnBlockHeaderEnter(block) end)
					button:SetScript("OnLeave", function() block.module:OnBlockHeaderLeave(block) end)
					button:SetScript("OnClick", function(self, btn) block.module:OnBlockHeaderClick(block, btn) end)
					button:RegisterForClicks("AnyUp")
					block.button = button
				end
				button:Show()
			elseif block.module == BONUS_OBJECTIVE_TRACKER_MODULE then
				block:SetWidth(240 + 15)
			end
		end
		return blockAdded
	end

	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "FreeBlock", function(self, block)
		if block.button then
			block.button:Hide()
		end
	end)

	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "FreeUnusedLines", function(self, block)
		local colorStyle
		if block.questCompleted then
			colorStyle = OBJECTIVE_TRACKER_COLOR["Complete"]
		elseif db.colorDifficulty and self == QUEST_TRACKER_MODULE then
			colorStyle = GetQuestDifficultyColor(block.level)
		end
		if colorStyle then
			block.HeaderText:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
			block.HeaderText.colorStyle = colorStyle
		end
	end)

	local function CreateFixedTag(block)
		block.itemButton:Hide()

		local tag = block.fixedTag
		if not tag then
			local numFreeButtons = #freeTags
			if numFreeButtons > 0 then
				tag = freeTags[numFreeButtons]
				tremove(freeTags, numFreeButtons)
				tag:SetParent(OTF.BlocksFrame)
			else
				tag = CreateFrame("Frame", nil, OTF.BlocksFrame)
				tag:SetSize(32, 32)
				tag:SetBackdrop({ bgFile = mediaPath.."UI-KT-QuestItemTag" })
				tag.text = tag:CreateFontString(nil, "ARTWORK", "GameFontNormalMed1")
				tag.text:SetFont(LSM:Fetch("font", "Arial Narrow"), 14, "None")
				tag.text:SetPoint("CENTER", -0.5, 0)
			end
			tag:SetPoint("TOPRIGHT", block, 3, 3)
			tag:Show()
			block.fixedTag = tag
		end

		local colorStyle = OBJECTIVE_TRACKER_COLOR["Normal"]
		tag:SetBackdropColor(colorStyle.r, colorStyle.g, colorStyle.b)
		tag.text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		tag.text:SetText(KTF.Buttons.num)
	end

	local function CreateFixedButton(block)
		local questID = block.id
		local button = KT:GetFixedButton(questID)
		if not button then
			if InCombatLockdown() then
				_DBG(" - STOP Create button")
				stopUpdate = true
				return nil
			end

			local numFreeButtons = #freeButtons
			if numFreeButtons > 0 then
				_DBG(" - USE button "..questID)
				button = freeButtons[numFreeButtons]
				tremove(freeButtons, numFreeButtons)
			else
				_DBG(" - CREATE button "..questID)
				local name = addonName.."Button"..time()..questID
				button = CreateFrame("Button", name, KTF.Buttons, "SecureActionButtonTemplate")		--"KTQuestObjectiveItemButtonTemplate"
				button:SetSize(26, 26)

				button.icon = button:CreateTexture(name.."Icon", "BORDER")
				button.icon:SetAllPoints()

				button.Count = button:CreateFontString(name.."Count", "BORDER", "NumberFontNormal")
				button.Count:SetJustifyH("RIGHT")
				button.Count:SetPoint("BOTTOMRIGHT", button.icon, -3, 2)

				button.Cooldown = CreateFrame("Cooldown", name.."Cooldown", button, "CooldownFrameTemplate")
				button.Cooldown:SetAllPoints()

				button.HotKey = button:CreateFontString(name.."HotKey", "ARTWORK", "NumberFontNormalSmallGray")
				button.HotKey:SetSize(29, 10)
				button.HotKey:SetJustifyH("RIGHT")
				button.HotKey:SetText(RANGE_INDICATOR)
				button.HotKey:SetPoint("TOPRIGHT", button.icon, 2, -2)

				button.text = button:CreateFontString(name.."Text", "ARTWORK", "NumberFontNormalSmall")
				button.text:SetSize(29, 10)
				button.text:SetJustifyH("LEFT")
				button.text:SetPoint("TOPLEFT", button.icon, 1, -3)

				button:SetScript("OnEvent", QuestObjectiveItem_OnEvent)
				button:SetScript("OnUpdate", QuestObjectiveItem_OnUpdate)
				button:SetScript("OnShow", QuestObjectiveItem_OnShow)
				button:SetScript("OnHide", QuestObjectiveItem_OnHide)
				button:SetScript("OnEnter", QuestObjectiveItem_OnEnter)
				button:SetScript("OnLeave", QuestObjectiveItem_OnLeave)
				button:RegisterForClicks("AnyUp")

				button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
				do local tex = button:GetNormalTexture()
					tex:ClearAllPoints()
					tex:SetPoint("CENTER")
					tex:SetSize(44, 44)
				end
				button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
				button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
				button:SetFrameLevel(KTF:GetFrameLevel() + 1)
				button:SetAttribute("type","item")
				button:Hide()	-- Cooldown init

				KT:Masque_AddButton(button)
			end
			button:Show()
			KT.fixedButtons[questID] = button
			KTF.Buttons.reanchor = true
		end
		button.block = block
		button.num = KTF.Buttons.num
		button.text:SetText(KTF.Buttons.num)
		button:SetAlpha(1)
		if db.qiActiveButton and KTF.ActiveButton.questID == questID then
			KT.ActiveButton:Update(questID)
		end
		return button
	end

	local bck_QUEST_TRACKER_MODULE_SetBlockHeader = QUEST_TRACKER_MODULE.SetBlockHeader
	function QUEST_TRACKER_MODULE:SetBlockHeader(block, text, questLogIndex, isQuestComplete)
		local _, level, _, _, _, _, frequency, questID = GetQuestLogTitle(questLogIndex)
		local tagID, _ = GetQuestTagInfo(questID)
		text = KT:CreateQuestTag(level, tagID, frequency)..text
		bck_QUEST_TRACKER_MODULE_SetBlockHeader(self, block, text, questLogIndex, isQuestComplete)
		block.level = level
		block.title = text

		local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
		if item and (not isQuestComplete or showItemWhenComplete) then
			KTF.Buttons.num = KTF.Buttons.num + 1
			CreateFixedTag(block)
			local button = CreateFixedButton(block)
			if not InCombatLockdown() then
				button:SetID(questLogIndex)
				button.charges = charges
				button.rangeTimer = -1
				button.item = item
				button.link = link
				SetItemButtonTexture(button, item)
				SetItemButtonCount(button, charges)
				QuestObjectiveItem_UpdateCooldown(button)
				button:SetAttribute("item", link)
			end
		else
			KT:RemoveFixedButton(block)
		end
	end

	local bck_QUEST_TRACKER_MODULE_OnFreeBlock = QUEST_TRACKER_MODULE.OnFreeBlock
	function QUEST_TRACKER_MODULE:OnFreeBlock(block)
		KT:RemoveFixedButton(block)
		bck_QUEST_TRACKER_MODULE_OnFreeBlock(self, block)
	end

	local bck_QUEST_TRACKER_MODULE_Update = QUEST_TRACKER_MODULE.Update
	function QUEST_TRACKER_MODULE:Update()
		KTF.Buttons.num = 0
		bck_QUEST_TRACKER_MODULE_Update()
	end

	hooksecurefunc(QUEST_TRACKER_MODULE, "EndLayout", function(self, isStaticReanchor)
		if InCombatLockdown() then
			if KTF.Buttons.num > 0 then
				stopUpdate = true
			end
		else
			if KTF.Buttons.reanchor then
				_DBG(" - REANCHOR buttons")
				local questID, block, yOfs
				local contentsHeight = 0
				for i=1, GetNumQuestWatches() do
					questID, _ = GetQuestWatchInfo(i)
					block = self.usedBlocks[questID]
					if block and block.itemButton then
						yOfs = -(contentsHeight + 7)
						contentsHeight = contentsHeight + 26 + 3
						KT.fixedButtons[questID]:SetPoint("TOP", 0, yOfs)
					end
				end
				KTF.Buttons:SetHeight(contentsHeight + 7 + 4)
				KTF.Buttons.reanchor = false
			end
			if db.collapsed or KTF.Buttons.num == 0 then
				KTF.Buttons:Hide()
			else
				KTF.Buttons:Show()
			end
			KT.ActiveButton:Update()
		end
		if db.collapsed or KTF.Buttons.num == 0 then
			KTF.Buttons:SetAlpha(0)
		else
			KTF.Buttons:SetAlpha(1)
		end
	end)

	local function SetProgressBarStyle(block, anchor, progressBar)
		progressBar.Bar.Label:SetPoint("CENTER")
		progressBar.Bar.Label:SetFont(LSM:Fetch("font", "Arial Narrow"), 14, "None")
		if anchor then
			progressBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 15, -block.module.lineSpacing)
		else
			progressBar:SetPoint("TOPLEFT", 15, -block.module.lineSpacing)
		end
	end

	local bck_BONUS_OBJECTIVE_TRACKER_MODULE_AddProgressBar = BONUS_OBJECTIVE_TRACKER_MODULE.AddProgressBar
	function BONUS_OBJECTIVE_TRACKER_MODULE:AddProgressBar(block, line, questID, finished)
		local anchor = block.currentLine or block.HeaderText
		local progressBar = bck_BONUS_OBJECTIVE_TRACKER_MODULE_AddProgressBar(self, block, line, questID, finished)
		SetProgressBarStyle(block, anchor, progressBar)
		return progressBar
	end

	hooksecurefunc("BonusObjectiveTracker_ShowRewardsTooltip", function(block)
		GameTooltip:ClearAllPoints()
		if KTF.anchorLeft then
			GameTooltip:SetPoint("TOPLEFT", block, "TOPRIGHT", 24, -2)
		else
			GameTooltip:SetPoint("TOPRIGHT", block, "TOPLEFT", -12, -2)
		end
	end)

	local bck_SCENARIO_TRACKER_MODULE_AddProgressBar = SCENARIO_TRACKER_MODULE.AddProgressBar
	function SCENARIO_TRACKER_MODULE:AddProgressBar(block, line, criteriaIndex)
		local anchor = block.currentLine or block.HeaderText
		local progressBar = bck_SCENARIO_TRACKER_MODULE_AddProgressBar(self, block, line, criteriaIndex)
		SetProgressBarStyle(block, anchor, progressBar)
		return progressBar
	end

	ScenarioStageBlock:HookScript("OnEnter", function(self)
		GameTooltip:ClearAllPoints()
		if KTF.anchorLeft then
			GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 59, -1)
		else
			GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT",  -16, -1)
		end
	end)

	function ObjectiveTracker_Collapse()
		_DBG("--------------------------------")
		_DBG("COLLAPSE")
		OTF.collapsed = true
		KT.db.profile.collapsed = OTF.collapsed
		OTF.BlocksFrame:Hide()
		KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.25)
		OTFHeader.Title:Show()
		CloseDropDownMenus()
		KT.animTask = false
	end

	function ObjectiveTracker_Expand()
		_DBG("--------------------------------")
		_DBG("EXPAND")
		OTF.collapsed = nil
		KT.db.profile.collapsed = OTF.collapsed
		OTF.BlocksFrame:Show()
		KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.25, 0.5)
		OTFHeader.Title:Hide()
		CloseDropDownMenus()
	end

	hooksecurefunc("BonusObjectiveTracker_OnBlockAnimOutFinished", function(self)
		KT.animTask = false
		if KT.AddonPetTracker:IsShown() then
			local yOfs = PetTracker.Objectives:GetUsedHeight()
			PetTracker.Objectives:SetPoint("TOPLEFT", OTF, -10, -yOfs)
		end
	end)

	hooksecurefunc("BonusObjectiveTracker_SetBlockState", function(block, state, force)
		if state == "PRESENT" then
			_DBG(" - "..state)
			KT.activeTask = block.id
		elseif state == "LEAVING" and KT.activeTask > 0 then
			_DBG(" - "..state)
			KT.animTask = true
			KT.activeTask = 0
			if KT:IsTrackerEmpty(true) then
				OTF.BlocksFrame.contentsHeight = OTF.BlocksFrame.contentsHeight + paddingBottom
			end
		end
	end)

	local bck_QuestPOI_GetButton = QuestPOI_GetButton
	QuestPOI_GetButton = function(parent, questID, style, index, storyQuest)
		local poiButton = bck_QuestPOI_GetButton(parent, questID, style, index, storyQuest)
		poiButton.Glow.Show = function() end
		return poiButton
	end

	local bck_UIErrorsFrame_OnEvent = UIErrorsFrame:GetScript("OnEvent")
	UIErrorsFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "UI_INFO_MESSAGE" then
			local text, _ = ...
			for _, patt in ipairs(msgPatterns) do
				if strfind(text, patt) then
					SetMessage(text, nil, 1, 1, 0, "Interface\\GossipFrame\\AvailableQuestIcon", -2, 0)
					return
				end
			end
		end
		bck_UIErrorsFrame_OnEvent(self, event, ...)
	end)

	-- Legion World Map fix - TODO: test collisions in Legion
	local bck_WorldMapFrame_UIElementsFrame_ActionButton_Refresh = WorldMapFrame.UIElementsFrame.ActionButton.Refresh
	function WorldMapFrame.UIElementsFrame.ActionButton:Refresh()
		if InCombatLockdown() then return end
		bck_WorldMapFrame_UIElementsFrame_ActionButton_Refresh(self)
	end

	local bck_WorldMapFrame_UIElementsFrame_BountyBoard_Refresh = WorldMapFrame.UIElementsFrame.BountyBoard.Refresh
	function WorldMapFrame.UIElementsFrame.BountyBoard:Refresh()
		if InCombatLockdown() then return end
		bck_WorldMapFrame_UIElementsFrame_BountyBoard_Refresh(self)
	end

	local bck_WorldMapFrame_UpdateOverlayLocations = WorldMapFrame_UpdateOverlayLocations
	WorldMapFrame_UpdateOverlayLocations = function()
		if InCombatLockdown() then return end
		bck_WorldMapFrame_UpdateOverlayLocations()
	end

	local bck_WorldMapScrollFrame_ResetZoom = WorldMapScrollFrame_ResetZoom
	WorldMapScrollFrame_ResetZoom = function()
		if InCombatLockdown() then return end
		bck_WorldMapScrollFrame_ResetZoom()
	end
end

function QuestObjectiveItem_OnEnter(self)	-- replacement
	QUEST_TRACKER_MODULE:OnBlockHeaderEnter(self.block)
	if KTF.anchorLeft then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 3)
	else
		GameTooltip:SetOwner(self, "ANCHOR_LEFT", -3)
	end
	GameTooltip:SetQuestLogSpecialItem(self:GetID())
end

function QuestObjectiveItem_OnLeave(self)	-- replacement
	QUEST_TRACKER_MODULE:OnBlockHeaderLeave(self.block)
	GameTooltip:Hide()
end

function QuestObjectiveItem_OnUpdate(self, elapsed)		-- replacement
	local rangeTimer = self.rangeTimer
	if rangeTimer then
		rangeTimer = rangeTimer - elapsed
		if rangeTimer <= 0 then
			local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(self:GetID())
			if not charges or charges ~= self.charges then
				ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST)
				return
			end
			local hotkey = self.HotKey
			local valid = IsQuestLogSpecialItemInRange(self:GetID())
			if hotkey:GetText() == RANGE_INDICATOR then
				if valid == 0 then
					hotkey:Show()
					hotkey:SetVertexColor(1.0, 0.1, 0.1)
				elseif valid == 1 then
					hotkey:Show()
					hotkey:SetVertexColor(0.6, 0.6, 0.6)
				else
					hotkey:Hide()
				end
			else
				if valid == 0 then
					hotkey:SetVertexColor(1.0, 0.1, 0.1)
				else
					hotkey:SetVertexColor(0.6, 0.6, 0.6)
				end
			end
			rangeTimer = TOOLTIP_UPDATE_TIME
		end
		self.rangeTimer = rangeTimer
	end

	if db.qiActiveButton and not InCombatLockdown() and self.block then
		if KT.ActiveButton.timerID then
			if KT.ActiveButton.timerID ~= self.block.id then
				return
			end
		else
			KT.ActiveButton.timerID = self.block.id
		end
		if KT.ActiveButton.timer > 50 then
			KT.ActiveButton:Update()
		else
			--_DBG("... "..KT.ActiveButton.timer.." ... "..self.block.id)
			KT.ActiveButton.timer = KT.ActiveButton.timer + TOOLTIP_UPDATE_TIME
		end
	end
end

--------------
-- External --
--------------

function KT:SetSize()
	local height = 33
	local mod = 0
	local PTheight = 0

	if OTF.BlocksFrame.contentsHeight then
		OTF.BlocksFrame.contentsHeight = round(OTF.BlocksFrame.contentsHeight)
	else
		return
	end

	_DBG(" - height = "..OTF.BlocksFrame.contentsHeight)
	if not db.collapsed and not self:IsTrackerEmpty() then
		if ACHIEVEMENT_TRACKER_MODULE.hasSkippedBlocks then
			OTF.BlocksFrame:Hide()
			OTF.BlocksFrame:Show()
		end

		if BONUS_OBJECTIVE_TRACKER_MODULE.firstBlock then
			mod = mod + BONUS_OBJECTIVE_TRACKER_MODULE.blockPadding
		end
		if self.AddonPetTracker:IsShown() then
			PTheight = round(PetTracker.Objectives:GetHeight()) + 7 - (self:IsTrackerEmpty(true) and paddingBottom or 0)
			mod = mod + PTheight
		end
		height = OTF.BlocksFrame.contentsHeight + mod + 10 + paddingBottom
		_DBG(" - "..OTF.BlocksFrame.contentsHeight.." + "..mod.." + 10 + "..paddingBottom.." = "..height, true)
		OTF.height = height

		if height > db.maxHeight then
			_DBG("MOVE ... "..KTF.Scroll.value.." > "..OTF.height.." - "..db.maxHeight)
			if KTF.Scroll.value > OTF.height-db.maxHeight then
				KTF.Scroll.value = OTF.height - db.maxHeight
			end
			KTF.Scroll:SetVerticalScroll(KTF.Scroll.value)
			if db.frameScrollbar then
				SetScrollbarPosition()
				KTF.Bar:Show()
			end
			height = db.maxHeight
		elseif height <= db.maxHeight then
			if KTF.Scroll.value > 0 then
				KTF.Scroll.value = 0
				KTF.Scroll:SetVerticalScroll(0)
			end
			KTF.Scroll:UpdateScrollChildRect()
			if db.frameScrollbar then
				KTF.Bar:Hide()
			end
		end
		self:MoveButtons()
		height = height - fmod(height, 2)
	else
		OTF.height = height - 10
		OTF:SetHeight(OTF.height)
		KTF.Scroll:SetVerticalScroll(0)
		if db.frameScrollbar then
			KTF.Bar:Hide()
		end
	end

	KTF:SetHeight(height)
	KTF.height = height
end

function KT:MoveTracker()
	KTF:ClearAllPoints()
	KTF:SetPoint(db.anchorPoint, UIParent, db.anchorPoint, db.xOffset, db.yOffset)
	KTF.directionUp = (db.anchorPoint == "BOTTOMLEFT" or db.anchorPoint == "BOTTOMRIGHT")
	KTF.anchorLeft = (db.anchorPoint == "TOPLEFT" or db.anchorPoint == "BOTTOMLEFT")

	local options = self.options.args.general.args.sec1.args
	if KTF.anchorLeft then
		options.xOffset.min = 0
		options.xOffset.max = self.screenWidth - trackerWidth
	else
		options.xOffset.min = -(self.screenWidth - trackerWidth)
		options.xOffset.max = 0
	end

	if KTF.directionUp then
		options.yOffset.min = 0
		options.yOffset.max = self.screenHeight - options.maxHeight.min
	else
		options.yOffset.min = -(self.screenHeight - options.maxHeight.min)
		options.yOffset.max = 0
	end

	options.maxHeight.max = self.screenHeight - abs(db.yOffset)
	db.maxHeight = (abs(db.yOffset)+db.maxHeight > self.screenHeight) and options.maxHeight.max or db.maxHeight

	self:MoveButtons()
end

function KT:SetBackground()
	local backdrop = {
		bgFile = LSM:Fetch("background", db.bgr),
		edgeFile = LSM:Fetch("border", db.border),
		edgeSize = db.borderThickness,
		insets = { left=db.bgrInset, right=db.bgrInset, top=db.bgrInset, bottom=db.bgrInset }
	}
	self.borderColor = db.classBorder and self.classColor or db.borderColor

	KTF:SetBackdrop(backdrop)
	KTF:SetBackdropColor(db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a)
	KTF:SetBackdropBorderColor(self.borderColor.r, self.borderColor.g, self.borderColor.b, db.borderAlpha)

	SetHeaders("background")

	self.hdrBtnColor = db.hdrBtnColorShare and self.borderColor or db.hdrBtnColor
	KTF.MinimizeButton:GetNormalTexture():SetVertexColor(self.hdrBtnColor.r, self.hdrBtnColor.g, self.hdrBtnColor.b)
	if self.Filters:IsEnabled() then
		if db.filterAuto[1] or db.filterAuto[2] then
			KTF.FilterButton:GetNormalTexture():SetVertexColor(0, 1, 0)
		else
			KTF.FilterButton:GetNormalTexture():SetVertexColor(self.hdrBtnColor.r, self.hdrBtnColor.g, self.hdrBtnColor.b)
		end
	end
	if db.hdrOtherButtons then
		KTF.QuestLogButton:GetNormalTexture():SetVertexColor(self.hdrBtnColor.r, self.hdrBtnColor.g, self.hdrBtnColor.b)
		KTF.AchievementsButton:GetNormalTexture():SetVertexColor(self.hdrBtnColor.r, self.hdrBtnColor.g, self.hdrBtnColor.b)
	end

	if db.qiBgrBorder then
		KTF.Buttons:SetBackdrop(backdrop)
		KTF.Buttons:SetBackdropColor(db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a)
		KTF.Buttons:SetBackdropBorderColor(self.borderColor.r, self.borderColor.g, self.borderColor.b, db.borderAlpha)
	else
		KTF.Buttons:SetBackdrop(nil)
	end

	KTF.Bar.texture:SetColorTexture(self.borderColor.r, self.borderColor.g, self.borderColor.b, db.borderAlpha)

	if db.bgr == "None" and db.border == "None" then
		KTF.Scroll:SetHitRectInsets(-150, 0, 0, 0.1)
	else
		KTF.Scroll:SetHitRectInsets(0.1, 0, 0, 0.1)
	end
end

function KT:SetText()
	self.font = LSM:Fetch("font", db.font)

	OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT = (2 * db.fontSize) + 1

	-- Collapsed
	OTFHeader.Title:SetFont(self.font, db.fontSize, db.fontFlag)
	OTFHeader.Title:SetTextColor(0, 0.7, 1)	-- blue
	OTFHeader.Title:SetShadowColor(0, 0, 0, db.fontShadow)
	-- Headers
	SetHeaders("text")
	-- Others
	ScenarioStageBlock.Stage:SetFont(self.font, db.fontSize+5, db.fontFlag)
end

function KT:SaveHeader(module)
	tinsert(KT.headers, module.Header)
	module.title = module.Header.Text:GetText()
	module.Header.Text:SetWidth(165)
end

function KT:SetHeaderText(module, append)
	local text = module.title
	if append then
		text = format("%s (%s)", text, append)
	end
	module.Header.Text:SetText(text)
end

function KT:SetQuestsHeaderText(reset)
	if db.hdrQuestsTitleAppend then
		local _, numQuests = GetNumQuestLogEntries()
		self:SetHeaderText(QUEST_TRACKER_MODULE, numQuests.."/"..MAX_QUESTS)
	elseif reset then
		self:SetHeaderText(QUEST_TRACKER_MODULE)
	end
end

function KT:SetAchievsHeaderText(reset)
	if db.hdrAchievsTitleAppend then
		self:SetHeaderText(ACHIEVEMENT_TRACKER_MODULE, GetTotalAchievementPoints())
	elseif reset then
		self:SetHeaderText(ACHIEVEMENT_TRACKER_MODULE)
	end
end

function KT:ToggleOtherButtons()
	if not db.hdrOtherButtons then
		if KTF.QuestLogButton then
			KTF.QuestLogButton:Hide()
			KTF.AchievementsButton:Hide()
		end
		return
	end
	if KTF.QuestLogButton then
		KTF.QuestLogButton:Show()
		KTF.AchievementsButton:Show()
	else
		local button
		-- Quest Log button
		button = CreateFrame("Button", addonName.."QuestLogButton", KTF)
		button:SetSize(16, 16)
		button:SetPoint("TOPRIGHT", -(self.Filters:IsEnabled() and 70 or 50), -8)
		button:SetFrameLevel(KTF:GetFrameLevel() + 10)
		button:SetNormalTexture(mediaPath.."UI-KT-HeaderButtons")
		button:GetNormalTexture():SetTexCoord(0.5, 1, 0, 0.25)

		button:RegisterForClicks("AnyDown")
		button:SetScript("OnClick", function(self, btn)
			ToggleQuestLog()
		end)
		button:SetScript("OnEnter", function(self)
			self:GetNormalTexture():SetVertexColor(1, 1, 1)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(QuestLogMicroButton.tooltipText, 1, 1, 1)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function(self)
			self:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
			GameTooltip:Hide()
		end)
		KTF.QuestLogButton = button

		-- Achievements button
		button = CreateFrame("Button", addonName.."AchievementsButton", KTF)
		button:SetSize(16, 16)
		button:SetPoint("TOPRIGHT", -(self.Filters:IsEnabled() and 50 or 30), -8)
		button:SetFrameLevel(KTF:GetFrameLevel() + 10)
		button:SetNormalTexture(mediaPath.."UI-KT-HeaderButtons")
		button:GetNormalTexture():SetTexCoord(0.5, 1, 0.25, 0.5)

		button:RegisterForClicks("AnyDown")
		button:SetScript("OnClick", function(self, btn)
			ToggleAchievementFrame()
		end)
		button:SetScript("OnEnter", function(self)
			self:GetNormalTexture():SetVertexColor(1, 1, 1)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(AchievementMicroButton.tooltipText, 1, 1, 1)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function(self)
			self:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
			GameTooltip:Hide()
		end)
		KTF.AchievementsButton = button
	end
end

function KT:MoveButtons()
	if not InCombatLockdown() then
		local point, xOfs, yOfs
		if KTF.anchorLeft then
			point = "LEFT"
			xOfs = KTF:GetRight() and KTF:GetRight() + db.qiXOffset
		else
			point = "RIGHT"
			xOfs = KTF:GetLeft() and KTF:GetLeft() - db.qiXOffset
		end
		local hMod = 2 * (4 - db.bgrInset)
		local yMod = 0
		if not db.qiBgrBorder then
			hMod = hMod + 4
			yMod = 2 + (4 - db.bgrInset)
		end
		if KTF.directionUp and (db.maxHeight+hMod) < KTF.Buttons:GetHeight() then
			point = "BOTTOM"..point
			yOfs = KTF:GetBottom() and KTF:GetBottom() - yMod
		else
			point = "TOP"..point
			yOfs = KTF:GetTop() and KTF:GetTop() + yMod
		end
		if xOfs and yOfs then
			KTF.Buttons:ClearAllPoints()
			KTF.Buttons:SetPoint(point, UIParent, "BOTTOMLEFT", xOfs, yOfs)
		end
	end
end

function KT:RemoveFixedButton(block)
	if block then
		local tag = block.fixedTag
		if tag then
			tinsert(freeTags, tag)
			block.fixedTag = nil
			tag:Hide()
		end
		local questID = block.id
		local button = self:GetFixedButton(questID)
		if button then
			button:SetAlpha(0)
			if InCombatLockdown() then
				_DBG(" - STOP Remove button")
				stopUpdate = true
			else
				_DBG(" - REMOVE button "..questID)
				tinsert(freeButtons, button)
				self.fixedButtons[questID] = nil
				button:Hide()
				KTF.Buttons.reanchor = true
			end
			if db.qiActiveButton then
				KTF.ActiveButton.text:SetText("")
			end
		end
		if self.ActiveButton.timerID == questID then
			self.ActiveButton.timerID = nil
		end
	else
		for questID, button in pairs(self.fixedButtons) do
			_DBG(" - REMOVE button "..questID)
			tinsert(freeButtons, button)
			self.fixedButtons[questID] = nil
			button:Hide()
		end
		KTF.Buttons.reanchor = true
	end
end

function KT:GetFixedButton(questID)
	if self.fixedButtons[questID] then
		return self.fixedButtons[questID]
	else
		return nil
	end
end

function KT:CreateQuestTag(level, questTag, frequency)
	local tag = ""

	if level == -1 then
		level = "*"
	else
		level = tostring(level)
	end

	if questTag == ELITE then
		tag = "+"
	elseif questTag == QUEST_TAG_GROUP then
		tag = "g"
	elseif questTag == QUEST_TAG_PVP then
		tag = "pvp"
	elseif questTag == QUEST_TAG_DUNGEON then
		tag = "d"
	elseif questTag == QUEST_TAG_HEROIC then
		tag = "hc"
	elseif questTag == QUEST_TAG_RAID then
		tag = "r"
	elseif questTag == QUEST_TAG_RAID10 then
		tag = "r10"
	elseif questTag == QUEST_TAG_RAID25 then
		tag = "r25"
	elseif questTag == QUEST_TAG_SCENARIO then
		tag = "s"
	elseif questTag == QUEST_TAG_ACCOUNT then
		tag = "a"
	elseif questTag == QUEST_TAG_LEGENDARY then
		tag = "leg"
	end

	if frequency == 2 then
		tag = tag.."!"	-- daily quest
	elseif frequency == 3 then
		tag = tag.."!!"	-- weekly quest
	end

	if tag ~= "" then
		tag = ("|cff00b3ff%s|r"):format(tag)
	end

	tag = ("[%s%s] "):format(level, tag)
	return tag
end

function KT:IsTrackerEmpty(noaddon)
	local result = (GetNumQuestWatches() == 0 and
		GetNumAutoQuestPopUps() == 0 and
		GetNumTrackedAchievements() == 0 and
		self.activeTask == 0 and
		not C_Scenario.IsInScenario() and
		not self.LegionInvasion.used)
	if not noaddon then
		result = (result and not self.AddonPetTracker:IsShown())
	end
	return result
end

function KT:ToggleEmptyTracker(added)
	local alpha, mouse = 1, true
	if self:IsTrackerEmpty() then
		if not db.collapsed then
			ObjectiveTracker_MinimizeButton_OnClick()
		end
		KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 0.75)
		if db.hideEmptyTracker then
			alpha = 0
			mouse = false
		end
	else
		if db.collapsed then
			if added then
				ObjectiveTracker_MinimizeButton_OnClick()
			else
				KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.25)
			end
		else
			KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.25, 0.5)
		end
	end
	KTF:SetAlpha(alpha)
	KTF.MinimizeButton:EnableMouse(mouse)
	if self.Filters:IsEnabled() then
		KTF.FilterButton:EnableMouse(mouse)
	end
	if db.hdrOtherButtons then
		KTF.QuestLogButton:EnableMouse(mouse)
		KTF.AchievementsButton:EnableMouse(mouse)
	end
end

function KT:UpdateHotkey()
	local key = GetBindingKey("EXTRAACTIONBUTTON1")
	if db.keyBindMinimize == key then
		SetOverrideBinding(KTF, false, db.keyBindMinimize, nil)
		db.keyBindMinimize = ""
	end
end

function KT:MergeTables(source, target)
	if type(target) ~= "table" then target = {} end
	for k, v in pairs(source) do
		if type(v) == "table" then
			target[k] = self:MergeTables(v, target[k])
		elseif target[k] == nil then
			target[k] = v
		end
	end
	return target
end

-- Load ----------------------------------------------------------------------------------------------------------------

function KT:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)

	SLASH_KALIELSTRACKER1, SLASH_KALIELSTRACKER2 = "/kt", "/kalielstracker"
	SlashCmdList["KALIELSTRACKER"] = SlashHandler

	SetMsgPatterns()

	-- Get character data
	local _, class = UnitClass("player")
	self.classColor = RAID_CLASS_COLORS[class]

	self.headers = {}
	self.borderColor = {}
	self.hdrBtnColor = {}
	self.fixedButtons = {}
	self.activeTask = 0
	self.animTask = false
	self.inWorld = true
	self.inInstance = IsInInstance()
	self.initialized = false

	-- Setup Options
	self:SetupOptions()
	db = self.db.profile

	-- Blizzard frame resets
	OTF.KTSetParent = OTF.SetParent
	OTF.SetParent = function() end
	OTF.SetFrameStrata = function() end
	OTF.SetFrameLevel = function() end
	OTF:SetClampedToScreen(false)
	OTF.SetClampedToScreen = function() end
	OTF:EnableMouse(false)
	OTF.EnableMouse = function() end
	OTF:SetMovable(false)
	OTF.SetMovable = function() end
	OTF:ClearAllPoints()
	OTF.ClearAllPoints = function() end
	OTF.SetAllPoints = function() end
	OTF.KTSetPoint = OTF.SetPoint
	OTF.SetPoint = function() end
	OTF:Show()
	OTF.Show = function() end
	OTF.Hide = function() end
	OTF.SetShown = function() end
end

function KT:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	-- Modules
	self.Filters:Enable()
	self.QuestLog:Enable()
	if db.qiActiveButton then self.ActiveButton:Enable() end
	if db.specialLegionInvasion then self.LegionInvasion:Enable() end
	if self.AddonPetTracker.isLoaded then self.AddonPetTracker:Enable() end
	if self.AddonTomTom.isLoaded then self.AddonTomTom:Enable() end
	self.AddonOthers:Enable()
	self.Help:Enable()

	self.screenWidth = round(GetScreenWidth())
	self.screenHeight = round(GetScreenHeight())

	KTF:SetScript("OnEvent", function()
		SetHooks()
		SetFrames()
		Init()
		KT.initialized = true
	end)
	KTF:RegisterEvent("PLAYER_ENTERING_WORLD")
end