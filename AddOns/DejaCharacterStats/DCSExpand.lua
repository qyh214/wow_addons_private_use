local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

-- ------------------------------------------------
-- -- DCS Character Frame Expand/Collapse Button --
-- ------------------------------------------------
local DCS_tooltipText

local function DCS_ExpandCheck_OnEnter(self)
	GameTooltip:SetOwner(DCS_ExpandCheck, "ANCHOR_RIGHT");
	GameTooltip:SetText(DCS_tooltipText, 1, 1, 1, 1, true)
	GameTooltip:Show()
end

local function DCS_ExpandCheck_OnLeave(self)
	GameTooltip_Hide()
 end
 
local _, gdbprivate = ...
	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsExpandChecked = {
		ExpandSetChecked = true,
}
local DCS_ExpandCheck = CreateFrame("Button", "DCS_ExpandCheck", PaperDollFrame)
	DCS_ExpandCheck:RegisterForClicks("AnyDown")
	DCS_ExpandCheck:ClearAllPoints()
	DCS_ExpandCheck:SetPoint("TOPRIGHT", CharacterTrinket1Slot, "BOTTOMRIGHT", 2, -3)
	DCS_ExpandCheck:SetSize(32, 32)
	DCS_ExpandCheck:SetHighlightTexture("Interface\\BUTTONS\\UI-Common-MouseHilight")
	
DCS_ExpandCheck:SetScript("OnEnter", DCS_ExpandCheck_OnEnter)
DCS_ExpandCheck:SetScript("OnLeave", DCS_ExpandCheck_OnLeave)
		 
DCS_ExpandCheck:SetScript("OnMouseDown", function (self, button, up)
	local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandChecked.ExpandSetChecked
	if checked == true then
		DCS_ExpandCheck:SetPushedTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Down")
		DCS_ExpandCheck:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Down")
	else
		DCS_ExpandCheck:SetPushedTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Down")
		DCS_ExpandCheck:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Down")
	end
end)

DCS_ExpandCheck:SetScript("OnMouseUp", function (self, button, up)
	local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandChecked.ExpandSetChecked
	if checked == true then
	--	print(checked)
		CharacterFrame_Collapse()
		DCS_ExpandCheck:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up")
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandChecked.ExpandSetChecked = false
		DCS_tooltipText = L['Show Character Stats'] --Creates a tooltip on mouseover.
	else
	--	print(checked)
		CharacterFrame_Expand()
		DCS_Scrollbar:SetMinMaxValues(0, 0)
		DCS_ExpandCheck:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up")
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandChecked.ExpandSetChecked = true
		DCS_tooltipText = L['Hide Character Stats'] --Creates a tooltip on mouseover.
	end
	DCS_ExpandCheck_OnEnter()
end)

-- -----------------------------
-- -- PaperDoll OnShow/OnHide --
-- -----------------------------
PaperDollFrame:SetScript("OnShow", function(self, event, arg1)
	CharacterStatsPane.initialOffsetY = 0
	CharacterFrameTitleText:SetText(UnitPVPName("player"))
	PaperDollFrame_SetLevel()
	PaperDollFrame_UpdateStats()

	SetPaperDollBackground(CharacterModelFrame, "player")
	PaperDollBgDesaturate(true)
	PaperDollSidebarTabs:Show()
	PaperDollFrame_UpdateInventoryFixupComplete(self)

	local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandChecked.ExpandSetChecked
	if checked == true then
	--	print(checked)
		CharacterFrame_Expand()
		DCS_Scrollbar:SetMinMaxValues(0, 0)
		DCS_tooltipText = L['Hide Character Stats'] --Creates a tooltip on mouseover.
		DCS_ExpandCheck:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up")
	else
	--	print(checked)
		CharacterFrame_Collapse()
		DCS_tooltipText = L['Show Character Stats'] --Creates a tooltip on mouseover.
		DCS_ExpandCheck:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up")
	end
end)

local _, gdbprivate = ...
	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsExpandButtonChecked = {
		ExpandButtonSetChecked = true,
}
local DCS_ExpandButtonCheck = CreateFrame("CheckButton", "DCS_ExpandButtonCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ExpandButtonCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ExpandButtonCheck:ClearAllPoints()
	DCS_ExpandButtonCheck:SetPoint("LEFT", 25, -150)
	DCS_ExpandButtonCheck:SetScale(1.25)
	DCS_ExpandButtonCheck.tooltipText = L['Displays the Expand button for the character stats frame.'] --Creates a tooltip on mouseover.
	_G[DCS_ExpandButtonCheck:GetName() .. "Text"]:SetText(L["Expand"])
	
	DCS_ExpandButtonCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandButtonChecked
			self:SetChecked(checked.ExpandButtonSetChecked)
			if self:GetChecked(true) then
				DCS_ExpandCheck:Show()
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandButtonChecked.ExpandButtonSetChecked = true
			else
				DCS_ExpandCheck:Hide()
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandButtonChecked.ExpandButtonSetChecked = false
			end
		end
	end)

	DCS_ExpandButtonCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandButtonChecked
		if self:GetChecked(true) then
			DCS_ExpandCheck:Show()
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandButtonChecked.ExpandButtonSetChecked = true
		else
			DCS_ExpandCheck:Hide()
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsExpandButtonChecked.ExpandButtonSetChecked = false
		end
	end)