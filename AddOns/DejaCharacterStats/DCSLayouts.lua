local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

DCS_ClassSpecDB = {}

local _, DCS_TableData = ...

local _, gdbprivate = ...
	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsScrollbarChecked = {
		ScrollbarSetChecked = false,
	}

local StatScrollFrame = CreateFrame("ScrollFrame", nil, CharacterFrameInsetRight, "UIPanelScrollFrameTemplate")
	StatScrollFrame:ClearAllPoints()
	StatScrollFrame:SetPoint("TOPLEFT", CharacterFrameInsetRight, "TOPLEFT", 5, -6)
	StatScrollFrame:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "BOTTOMRIGHT", 0, 3)
	StatScrollFrame.ScrollBar:ClearAllPoints()
	StatScrollFrame.ScrollBar:SetPoint("TOPLEFT", StatScrollFrame, "TOPRIGHT", -16, -16)
	StatScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", StatScrollFrame, "BOTTOMRIGHT", -16, 16)
	StatScrollFrame.ScrollBar:Hide()
	
	StatScrollFrame:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked
		if checked.ScrollbarSetChecked == true then
			self.ScrollBar:SetShown(floor(yrange) ~= 0)
		elseif not checked.ScrollbarSetChecked == true then
			self.ScrollBar:Hide()
		end
	end)
	
	StatFrame = CreateFrame("Frame", nil, StatScrollFrame)
	StatFrame:SetWidth(191)
	StatFrame:SetPoint("TOPLEFT")
	StatFrame.AnchorFrame = CreateFrame("Frame", nil, StatFrame)
	StatFrame.AnchorFrame:SetSize(StatFrame:GetWidth(), 2)
	StatFrame.AnchorFrame:SetPoint("TOPLEFT")
	StatScrollFrame:SetScrollChild(StatFrame)

	CharacterStatsPane.ItemLevelFrame:SetParent(StatFrame)
	CharacterStatsPane.ItemLevelFrame.Value:SetFont(CharacterStatsPane.ItemLevelFrame.Value:GetFont(), 22, "THINOUTLINE")
	CharacterStatsPane.ItemLevelFrame.Value:SetPoint("CENTER",CharacterStatsPane.ItemLevelFrame.Background, "CENTER", 0, 1)

	CharacterStatsPane.AttributesCategory:SetParent(StatFrame)
	CharacterStatsPane.AttributesCategory:SetHeight(28)
	CharacterStatsPane.AttributesCategory.Background:SetHeight(28)

	CharacterStatsPane.ClassBackground:SetParent(StatFrame)

	CharacterStatsPane.EnhancementsCategory:SetParent(StatFrame)
	CharacterStatsPane.EnhancementsCategory:SetHeight(28)
	CharacterStatsPane.EnhancementsCategory.Background:SetHeight(28)

	
	for k, v in pairs(DCS_TableData.StatData) do
		if (not v.frame) then
			if (v.category) then
				v.frame = CreateFrame("FRAME", nil, StatFrame, "CharacterStatFrameCategoryTemplate")
			else
				v.frame = CreateFrame("FRAME", nil, StatFrame, "CharacterStatFrameTemplate")
			end
		end
		v.frame.statKey = k
	end

local DefaultData = DCS_TableData:MergeTable({
    { statKey = "ItemLevelFrame" },
    { statKey = "AttributesCategory" },
        { statKey = "HEALTH" },
        { statKey = "POWER" },
        { statKey = "ALTERNATEMANA" },
        { statKey = "ARMOR" },
        { statKey = "STRENGTH" },
        { statKey = "AGILITY" },
        { statKey = "INTELLECT" },
        { statKey = "STAMINA" },
        { statKey = "ATTACK_DAMAGE" },
        { statKey = "ATTACK_AP" },
        { statKey = "ATTACK_ATTACKSPEED" },
        { statKey = "SPELLPOWER" },
        { statKey = "MANAREGEN" },
        { statKey = "ENERGY_REGEN" },
        { statKey = "RUNE_REGEN" },
        { statKey = "FOCUS_REGEN" },		
        { statKey = "MOVESPEED" },
        { statKey = "GCD" },
        { statKey = "REPAIR_COST" },
    { statKey = "EnhancementsCategory" },
        { statKey = "CRITCHANCE" },
        { statKey = "HASTE" },
        { statKey = "VERSATILITY" },
        { statKey = "MASTERY" },
        { statKey = "LIFESTEAL" },
        { statKey = "AVOIDANCE" },
        { statKey = "DODGE" },
        { statKey = "PARRY" },
        { statKey = "BLOCK" },
        { statKey = "ITEMLEVEL", hidden = true },
})

local ShownData = DefaultData

local function UpdateStatFrameWidth(width)
	local stat
	for _, v in ipairs(ShownData) do
		stat = DCS_TableData.StatData[v.statKey]
		if (stat) then
			stat.frame:SetWidth(width)
			if (stat.frame.Background) then
				stat.frame.Background:SetWidth(width)
			end
		end
	end
end


-----------------------
-- Config Mode Setup --
-----------------------

local configMode = false

local function ShowCharacterStats(unit)
    local stat
    local count, height = 0, 4
    for _, v in ipairs(ShownData) do
        stat = DCS_TableData.StatData[v.statKey]
        stat.updateFunc(stat.frame, unit)
        if (configMode) then
            stat.frame:Show()
            stat.frame.checkButton:Show()
            stat.frame.checkButton:SetChecked(not v.hidden)
            if (v.hidden) then
                stat.frame:SetAlpha(0.32)
			end
        elseif (v.hidden) then
            stat.frame:Hide()
        elseif (stat.frame.checkButton) then
            stat.frame.checkButton:Hide()
		end
        if (stat.frame:IsShown()) then
            stat.frame:ClearAllPoints()
            stat.frame:SetPoint("TOPLEFT", StatFrame.AnchorFrame, "TOPLEFT", 0, -height)
			if (stat.category) then
                count = 0
            else
                stat.frame.Background:SetShown((count%2) ~= 0)
                count = count + 1
            end
			if not (configMode) then
				stat.frame:SetAlpha(1.00)
			end
            height = height + stat.frame:GetHeight()
        end
    end
    height = floor(height)
    StatFrame:SetHeight(height)
	local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked
	if checked.ScrollbarSetChecked == true then
		UpdateStatFrameWidth(height > 353 and 180 or 191)
	else
		UpdateStatFrameWidth(191)
	end
end

local DCS_TALENT_UPDATE_Frame = CreateFrame("Frame", nil, UIParent)
	DCS_TALENT_UPDATE_Frame:RegisterEvent("PLAYER_TALENT_UPDATE")
	DCS_TALENT_UPDATE_Frame:SetScript("OnEvent", function(self, event, ...)
		local uniqueKey = UnitName("player") .. ":" .. GetRealmName() .. ":" .. GetSpecialization()
		--print(uniqueKey)
		if (DCS_ClassSpecDB[uniqueKey]) then
			if (ShownData.uniqueKey ~= uniqueKey) then
			ShownData = DCS_TableData:MergeTable(DCS_ClassSpecDB[uniqueKey])
			--print("Set saved variables.")
			end
		else
			--print("Set default initialization")
			ShownData = DCS_TableData:CopyTable(DefaultData)
			ShownData.uniqueKey = uniqueKey
			DCS_ClassSpecDB[uniqueKey] = ShownData
		end
		ShowCharacterStats("player")
	end)
	
local function DCS_Table_Reset()
	local uniqueKey = UnitName("player") .. ":" .. GetRealmName() .. ":" .. GetSpecialization()
	--print(uniqueKey)
	--print("Set default initialization")
	ShownData = DCS_TableData:CopyTable(DefaultData)
	ShownData.uniqueKey = uniqueKey
	DCS_ClassSpecDB[uniqueKey] = ShownData
	ShowCharacterStats("player")
end


-------------------------
-- Drag 'n' Drop Stats --
-------------------------

local DragSourceFrame, DragTargetFrame

local function OnDragStart(self)
	if (not configMode) then return end
	DragSourceFrame = self
	local cursorX, cursorY = GetCursorPosition()
	local uiScale = UIParent:GetScale()
	local adjust = select(5, UIParent:GetPoint(2)) or 0
	self:StartMoving()
	self:ClearAllPoints()
	self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, (cursorY-adjust) / uiScale)
end

local function OnDragStop(self)
	if (not configMode) then return end
	DragSourceFrame = false
	self:StopMovingOrSizing()
	local stat, dst
	for i, v in ipairs(ShownData) do
		stat = DCS_TableData.StatData[v.statKey]
		if (stat.frame.statKey ~= self.statKey and stat.frame:IsMouseOver()) then
			DCS_TableData:SwapStat(ShownData, self.statKey, v)
			break
		end
	end
	if (DragTargetFrame) then
		DragTargetFrame.anchorBar:Hide()
	end
	ShowCharacterStats("player")
end

local function onCheckClick(self)
	local checked = self:GetChecked()
	local statKey = self:GetParent().statKey
	if (checked) then
		self:GetParent():SetAlpha(1)
	else
		self:GetParent():SetAlpha(0.32)
	end
	for _, v in ipairs(ShownData) do
		if (v.statKey == statKey) then
			v.hidden = not checked
			break
		end
	end
end

for k, v in pairs(DCS_TableData.StatData) do
	v.frame:SetMovable(true)
	v.frame:RegisterForDrag("LeftButton")
	v.frame:HookScript("OnDragStart", OnDragStart)
	v.frame:HookScript("OnDragStop", OnDragStop)
	v.frame.checkButton = CreateFrame("CheckButton", nil, v.frame, "UICheckButtonTemplate")
	v.frame.checkButton:SetSize(14, 14)
	v.frame.checkButton:SetPoint("LEFT", -1, 0)
	v.frame.checkButton:SetScript("OnClick", onCheckClick)
	v.frame.checkButton:Hide()
	v.frame.anchorBar = v.frame:CreateTexture(nil, "OVERLAY")
	v.frame.anchorBar:SetPoint("TOPLEFT", 0, 2)
	v.frame.anchorBar:SetPoint("TOPRIGHT", 0, -2)
	v.frame.anchorBar:SetColorTexture(1, 0.8, 0)
	v.frame.anchorBar:Hide()
end

StatScrollFrame:HookScript("OnUpdate", function(self, elasped)
	if (DragSourceFrame) then
		self.timer = (self.timer or 0) + elasped
		if (self.timer > 0.2) then
			local stat
			for i, v in ipairs(ShownData) do
				stat = DCS_TableData.StatData[v.statKey]
				if (stat.frame.statKey ~= DragSourceFrame.statKey and stat.frame:IsMouseOver()) then
					DragTargetFrame = stat.frame
					stat.frame.anchorBar:Show()
				else
					stat.frame.anchorBar:Hide()
				end
			end
			self.timer = 0
		end
	end
end)


---------------------
-- Show/Hide Logic --
---------------------

CharacterStatsPane:HookScript("OnShow", function(self)
	self:Hide()
	StatScrollFrame:Show()
end)

hooksecurefunc("PaperDollFrame_UpdateStats", function()
	ShowCharacterStats("player")
end)

hooksecurefunc("PaperDollFrame_SetSidebar", function(self, index)
	if (PaperDollFrame.currentSideBar and PaperDollFrame.currentSideBar:GetName() == "CharacterStatsPane") then
		StatScrollFrame:Show()
	else
		StatScrollFrame:Hide()
	end
end)


------------------------
-- Reset Stats Button --
------------------------

local DCS_TableResetCheck = CreateFrame("Button", "DCS_TableResetButton", CharacterFrameInsetRight, "UIPanelButtonTemplate")
	DCS_TableResetCheck:ClearAllPoints()
	DCS_TableResetCheck:SetPoint("BOTTOMRIGHT", 5, -36)
	DCS_TableResetCheck:SetScale(0.80)
	DCS_TableResetCheck:Hide()

local LOCALE = GetLocale()
--print (LOCALE)
	if (LOCALE == "ptBR" or LOCALE == "frFR" or LOCALE == "deDE") then
	--print ("ptBR, frFR, deDE = 175")
	LOCALE = 175
	else
	--print ("enUS = 125")
	LOCALE = 125
	end

	DCS_TableResetCheck:SetWidth(LOCALE)
	DCS_TableResetCheck:SetHeight(30)
	_G[DCS_TableResetCheck:GetName() .. "Text"]:SetText(L["Reset Stats"])
	DCS_TableResetCheck:SetScript("OnClick", function(self, button, down)
	DCS_Table_Reset()
end)


------------------------
-- Config Mode Toggle --
------------------------
local DCS_ConfigtooltipText = 'Unlock DCS'

local DCS_configButton = CreateFrame("Button", nil, PaperDollSidebarTab1)
	DCS_configButton:SetSize(22, 22)
	DCS_configButton:SetPoint("BOTTOMLEFT", PaperDollSidebarTab1, "BOTTOMLEFT", -1, -4)
	DCS_configButton:SetNormalTexture("Interface\\Buttons\\LockButton-Locked-Up")
	DCS_configButton:SetPushedTexture("Interface\\Buttons\\LockButton-Unlocked-Down")
	DCS_configButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

local function DCS_configButton_OnEnter(self)
	GameTooltip:SetOwner(DCS_configButton, "ANCHOR_RIGHT");
	GameTooltip:SetText(DCS_ConfigtooltipText, 1, 1, 1, 1, true)
	GameTooltip:Show()
end

local function DCS_configButton_OnLeave(self)
	GameTooltip_Hide()
 end
 
	DCS_configButton:SetScript("OnEnter", DCS_configButton_OnEnter)
	DCS_configButton:SetScript("OnLeave", DCS_configButton_OnLeave)

	DCS_configButton:SetScript("OnMouseUp", function(self, button, up)
		configMode = not configMode
		if (configMode) then
			self:SetNormalTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
			DCS_ConfigtooltipText = 'Lock DCS' --Creates a tooltip on mouseover.
			DCS_TableResetCheck:Show()
		else
			self:SetNormalTexture("Interface\\Buttons\\LockButton-Locked-Up")
			DCS_ConfigtooltipText = 'Unlock DCS' --Creates a tooltip on mouseover.
			DCS_TableResetCheck:Hide()
		end
		ShowCharacterStats("player")
		DCS_configButton_OnEnter()
	end)

PaperDollFrame:HookScript("OnHide", function(self)
	configMode = false
	DCS_ConfigtooltipText = 'Unlock DCS'
end)


---------------------
-- Scrollbar Check --
---------------------

local DCS_ScrollbarCheck = CreateFrame("CheckButton", "DCS_ScrollbarCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ScrollbarCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ScrollbarCheck:ClearAllPoints()
	DCS_ScrollbarCheck:SetPoint("LEFT", 25, -175)
	DCS_ScrollbarCheck:SetScale(1.25)
	DCS_ScrollbarCheck.tooltipText = 'Displays the DCS scrollbar.' --Creates a tooltip on mouseover.
	_G[DCS_ScrollbarCheck:GetName() .. "Text"]:SetText("Scrollbar")
	
	DCS_ScrollbarCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked
			self:SetChecked(checked.ScrollbarSetChecked)
			if self:GetChecked(true) then
				StatScrollFrame.ScrollBar:Show() 
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked = true
			else
				StatScrollFrame.ScrollBar:Hide() 
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked = false
			end
		end
		DCS_ScrollbarCheck:UnregisterAllEvents();
	end)

	DCS_ScrollbarCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked
		if self:GetChecked(true) then
			StatScrollFrame.ScrollBar:Show() 
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked = true
		else
			StatScrollFrame.ScrollBar:Hide() 
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked = false
		end		
        ShowCharacterStats("player")
	end)

function PaperDollFrame_SetAttackSpeed(statFrame, unit)
	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed(unit);

	local displaySpeed = format("%.2f", speed);
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2f", offhandSpeed);
	end
	if ( offhandSpeed ) then
		displaySpeed =  BreakUpLargeNumbers(displaySpeed).." / ".. offhandSpeed;
	else
		displaySpeed =  BreakUpLargeNumbers(displaySpeed);
	end
	PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));

	statFrame:Show();
end
