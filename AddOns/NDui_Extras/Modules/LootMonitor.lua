local _, ns = ...
local B, C, L, DB = unpack(ns)

local Button_Height = 16
local LMFrame_Width = 200

local LMFrame_Report = {}
local LMFrame_CFG = {
	maxLines = 20,
	minQuality = 3,
	inGroup = false,
}

local LM_Message_Info = {
	L["LM Message 1"],
	L["LM Message 2"],
	L["LM Message 3"],
	L["LM Message 4"],
}

local function UnitClassColor(unit)
	local r, g, b = B.UnitColor(unit)
	return B.HexRGB(r, g, b)..unit.."|r"
end

local function isCollection(itemID, itemClassID, itemSubClassID)
	return (itemID and C_ToyBox.GetToyInfo(itemID)) or (DB.MiscellaneousIDs[itemClassID] and DB.CollectionIDs[itemSubClassID])
end

local function isEquipment(itemID, itemQuality, itemClassID)
	return ((itemID and (C_ArtifactUI.GetRelicInfoByItemID(itemID) or C_Soulbinds.IsItemConduitByItemInfo(itemID))) or (itemClassID and DB.EquipmentIDs[itemClassID])) and (itemQuality and itemQuality >= LMFrame_CFG["minQuality"])
end

local LMFrame = CreateFrame("Frame", "LootMonitor", UIParent)
LMFrame:SetFrameStrata("HIGH")
LMFrame:SetClampedToScreen(true)
LMFrame:SetPoint("LEFT", 4, 0)

local LMFrame_Title = B.CreateFS(LMFrame, Button_Height-2, L["LootMonitor Title"], true, "TOPLEFT", 10, -10)
local LMFrame_Info = B.CreateFS(LMFrame, Button_Height-2, L["LootMonitor Info"], true, "BOTTOMRIGHT", -10, 10)

local function CloseLMFrame()
	table.wipe(LMFrame_Report)
	for index = 1, LMFrame_CFG["maxLines"] do
		LMFrame[index]:Hide()
	end
	LMFrame:SetSize(LMFrame_Width, Button_Height*4)
	LMFrame:Hide()
end

local function CreateLMFrame()
	B.SetBD(LMFrame)
	B.CreateMF(LMFrame)

	local LMFrame_Close = B.CreateButton(LMFrame, 18, 18, true, DB.closeTex)
	LMFrame_Close:SetPoint("TOPRIGHT", -7, -7)
	LMFrame_Close:SetScript("OnClick", function(self) CloseLMFrame() end)
end

local function Button_OnClick(self, button)
	if button == "RightButton" then
		SendChatMessage(string.format(LM_Message_Info[random(4)], LMFrame_Report[self.index]["link"]), "WHISPER", nil, LMFrame_Report[self.index]["name"])
	else
		local editBox = ChatEdit_ChooseBoxForSend()
		ChatEdit_ActivateChat(editBox)
		editBox:SetText(editBox:GetText()..LMFrame_Report[self.index]["link"])
	end
end

local function Button_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 10, 0)
	GameTooltip:SetHyperlink(LMFrame_Report[self.index]["link"])
end

local function Button_OnLeave(self)
	GameTooltip:Hide()
end

local function CreateLMButton(index)
	local button = CreateFrame("Button", "LMFrame_Report"..index, LMFrame)
	button:SetHighlightTexture(DB.bdTex)
	button:SetHeight(Button_Height)
	button:SetPoint("RIGHT", -10, 0)

	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(1, 1, 1, .25)
	button.hl = hl

	local text = B.CreateFS(button, Button_Height-2)
	text:SetJustifyH("LEFT")
	text:SetNonSpaceWrap(true)
	text:SetPoint("LEFT", 0, 0)
	button.text = text

	button:RegisterForClicks("AnyDown")
	button:SetScript("OnClick", Button_OnClick)
	button:SetScript("OnEnter", Button_OnEnter)
	button:SetScript("OnLeave", Button_OnLeave)
	button.index = index

	if index == 1 then
		button:SetPoint("TOPLEFT", LMFrame_Title, "BOTTOMLEFT", 0, -5)
	else
		button:SetPoint("TOPLEFT", LMFrame[index - 1], "BOTTOMLEFT", 0, -1)
	end

	LMFrame[index] = button
	return button
end

local function UpdateLMFrame(self, event, ...)
	if event == "PLAYER_LOGIN" then
		CreateLMFrame()
		for index = 1, LMFrame_CFG["maxLines"] do
			CreateLMButton(index)
		end
		CloseLMFrame()
		LMFrame:UnregisterEvent(event)
	elseif event == "CHAT_MSG_LOOT" then
		if LMFrame_CFG["inGroup"] and not IsInGroup() then return end

		local lootText, lootPlayer = ...
		local itemLink
		for link in string.gmatch(lootText, "|c%x+|Hitem:.-|h.-|h|r") do
			if link then itemLink = link end
		end

		if not itemLink or string.len(lootPlayer) < 1 then return end

		local itemQuality = C_Item.GetItemQualityByID(itemLink)
		local itemID, _, _, _, _, itemClassID, itemSubClassID = C_Item.GetItemInfoInstant(itemLink)

		if isEquipment(itemID, itemQuality, itemClassID) or isCollection(itemID, itemClassID, itemSubClassID) then
			local textWidth, maxWidth = 0, 0
			local lootTime = DB.InfoColor..GameTime_GetGameTime(true).."|r"
			local playerName = UnitClassColor(string.split("-", lootPlayer))

			local itemExtra, hasStat, hasMisc = B.GetItemExtra(itemLink)
			if hasStat then itemExtra = "|cff00FF00"..itemExtra.."|r" end
			if hasMisc then itemExtra = "|cff00FFFF"..itemExtra.."|r" end

			if #LMFrame_Report >= LMFrame_CFG["maxLines"] then table.remove(LMFrame_Report, 1) end

			table.insert(LMFrame_Report, {time = lootTime, player = playerName, link = itemLink, info = itemExtra, name = lootPlayer})

			local numButtons = #LMFrame_Report
			for index = 1, numButtons do
				LMFrame[index].text:SetFormattedText("%s %s %s %s", LMFrame_Report[index]["time"], LMFrame_Report[index]["player"], LMFrame_Report[index]["link"], LMFrame_Report[index]["info"])
				LMFrame[index]:Show()
				textWidth = math.floor(LMFrame[index].text:GetStringWidth() + 20.5)
				maxWidth = math.max(textWidth, maxWidth)
			end

			LMFrame:SetWidth(maxWidth)
			LMFrame:SetHeight((Button_Height+1)*(numButtons+3)+6)

			if not LMFrame:IsShown() then
				LMFrame:Show()
			end
		end
	end
end

LMFrame:RegisterEvent("CHAT_MSG_LOOT")
LMFrame:RegisterEvent("PLAYER_LOGIN")
LMFrame:SetScript("OnEvent", UpdateLMFrame)

SLASH_NDLM1 = "/ndlm"
SlashCmdList["NDLM"] = function()
	if not LMFrame:IsShown() then
		LMFrame:Show()
	else
		LMFrame:Hide()
	end
end