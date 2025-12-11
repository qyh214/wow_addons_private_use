local T, C, L, G = unpack(select(2, ...))

G.dragFrameList = {}

local Mover
local SelectedMover

local anchors = {
	{"CENTER", L["中间"]},
	{"LEFT", L["左"]},
	{"RIGHT", L["右"]},
	{"TOP", L["上"]},
	{"BOTTOM", L["下"]},
	{"TOPLEFT", L["左上"]},
	{"TOPRIGHT", L["右上"]},
	{"BOTTOMLEFT", L["左下"]},
	{"BOTTOMRIGHT", L["右下"]},
}

--====================================================--
--[[                   -- API --                    ]]--
--====================================================--
local GetSelected = function()
	for i = 1, #G.dragFrameList do
		local frame = G.dragFrameList[i]
		if frame.df.isSelected then
			return frame, frame:GetName()
		end
	end
end

local RemoveSelected = function()
	for i = 1, #G.dragFrameList do
		local df = G.dragFrameList[i].df
		df.isSelected = false
		df.mask:SetBackdropBorderColor(0, 0, 0)
	end
	SelectedMover:Hide()
end

local GetDefaultPositions = function(frame, name)
	if C.DB["FramePoints"][name] == nil then
		C.DB["FramePoints"][name] = {}
	end
	for key, v in pairs(frame.point) do
		if C.DB["FramePoints"][name][key] == nil then
			C.DB["FramePoints"][name][key] = v
		end
	end	
end

local DisplayFramePoint = function(name)
	local point = T.ValueFromDB({"FramePoints", name})
	T.UIDropDownMenu_SetSelectedValueText(SelectedMover.a1dd.dd, anchors, point.a1)	
	T.UIDropDownMenu_SetSelectedValueText(SelectedMover.a2dd.dd, anchors, point.a2)
	SelectedMover.xbox.box:SetText(point.x)
	SelectedMover.ybox.box:SetText(point.y)
end

local Display_boss = function()
	local Encounter = T.GetEncounterName(C.DB["GeneralOption"]["moving_boss"])
	UIDropDownMenu_SetSelectedValue(SelectedMover.boss_btn.dd, C.DB["GeneralOption"]["moving_boss"])
	UIDropDownMenu_SetText(SelectedMover.boss_btn.dd, Encounter)
end

local ToggleFrameName = function()
	for i = 1, #G.dragFrameList do
		local frame = G.dragFrameList[i]
		if C.DB["GeneralOption"]["moving_name"] then
			frame.df.text:SetAlpha(1)
		else
			frame.df.text:SetAlpha(0)
		end
	end
end

local UnlockCurrentBoss = function()
	Mover:Show()
	Display_boss()
	for i = 1, #G.dragFrameList do
		local frame = G.dragFrameList[i]	
		if not frame.movingtag or frame.movingtag == C.DB["GeneralOption"]["moving_boss"] then
			if frame.df.enable then
				frame.df:Show()
			end
		else
			frame.df:Hide()
		end
	end
	ToggleFrameName()
end
T.UnlockCurrentBoss = UnlockCurrentBoss

local LockAll = function()
	Mover:Hide()
	RemoveSelected()
	for i = 1, #G.dragFrameList do
		local frame = G.dragFrameList[i]	
		frame.df:Hide()
	end
end
T.LockAll = LockAll

local PlaceFrame = function(frame)
	local name = frame:GetName()
	GetDefaultPositions(frame, name)
	local point = C.DB["FramePoints"][name]
	if point then
		frame:ClearAllPoints()
		frame:SetPoint(point.a1, UIParent, point.a2, point.x, point.y)
	end
end
T.PlaceFrame = PlaceFrame

local PlaceAllFrames = function()
	for i = 1, #G.dragFrameList do
		local frame = G.dragFrameList[i]
		PlaceFrame(frame)
	end
end
T.PlaceAllFrames = PlaceAllFrames

local ResetFramePoint = function(frame)
	local name = frame:GetName()	
	C.DB["FramePoints"][name] = nil
	PlaceFrame(frame)
end

local ResetAllFramesPoint = function()
	RemoveSelected()
	for i = 1, #G.dragFrameList do
		local frame = G.dragFrameList[i]
		ResetFramePoint(frame)
	end
end

-- 创建移动框
T.CreateDragFrame = function(frame)
	local name = frame:GetName()
	
	if tContains(G.dragFrameList, name) then
		T.msg(name, "首领模块名字重复")
	end
	
	table.insert(G.dragFrameList, frame) --add frame object to the list
	
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	
	frame.df = CreateFrame("Frame", name.."DragFrame", UIParent)
	frame.df:SetAllPoints(frame)
	frame.df:SetFrameStrata("HIGH")
	frame.df:EnableMouse(true)
	frame.df:RegisterForDrag("LeftButton")
	frame.df:SetClampedToScreen(true)
	frame.df:Hide()
	
	-- texture
	frame.df.mask = T.createbdframe(frame.df)
	frame.df.mask:SetBackdropColor(.3, .3, .3, .2)
	
	-- name
	frame.df.text = T.createtext(frame.df, "OVERLAY", 12, "OUTLINE", "CENTER")
	frame.df.text:SetWidth(300)
	frame.df.text:SetPoint("CENTER", frame.df, "CENTER")
	frame.df.text:SetText(frame.movingname)

	frame.df.enable = true
	frame.df.isSelected = false
	
	frame.df:SetScript("OnMouseDown", function(self)
		if not self.isSelected then
			RemoveSelected()
			self.isSelected = true
			
			self.mask:SetBackdropBorderColor(unpack(G.addon_color))
			
			SelectedMover.Title:SetText(frame.movingname)
			SelectedMover:Show()
			
			DisplayFramePoint(name)
		end
	end)
	
	frame.df:SetScript("OnDragStart", function(self)
		frame:StartMoving()
		self.x, self.y = frame:GetCenter() -- 开始的位置
	end)
	
	frame.df:SetScript("OnDragStop", function(self) 
		frame:StopMovingOrSizing()
		local x, y = frame:GetCenter() -- 结束的位置
		local x1, y1 = ("%d"):format(x - self.x), ("%d"):format(y -self.y)
		C.DB["FramePoints"][name].x = C.DB["FramePoints"][name].x + x1
		C.DB["FramePoints"][name].y = C.DB["FramePoints"][name].y + y1
		
		PlaceFrame(frame) -- 重新连接到锚点
		DisplayFramePoint(name)
	end)
	
	-- 显示预览
	frame.df:SetScript("OnShow", function()
		if frame.PreviewShow then
			frame:PreviewShow()
		end
		if frame.config_id then -- 首领模块
			frame:Show()
		end
	end)
	
	-- 隐藏预览
	frame.df:SetScript("OnHide", function()
		if frame.PreviewHide then
			frame:PreviewHide()
		end
		if frame.config_id then -- 首领模块
			if frame.npcID then
				if IsEncounterInProgress() and T.CheckEncounter(frame.npcID, frame.ficon) then
					frame:Show()
				else
					frame:Hide()
				end
			elseif frame.mapID then
				if T.CheckDungeon(frame.mapID) then
					frame:Show()
				else
					frame:Hide()
				end
			end
		end
	end)
	
	--frame.df.ResizeButton = CreateFrame("Button", fname.."DragFrameResizeButton", frame.df)
	--frame.df.ResizeButton:SetSize(16, 16)
	--frame.df.ResizeButton:SetPoint("BOTTOMRIGHT", frame.df, "BOTTOMRIGHT", 0, 0)
	--frame.df.ResizeButton.tex = frame.df.ResizeButton:CreateTexture(nil, "OVERLAY")
	--frame.df.ResizeButton.tex:SetAllPoints()
	--frame.df.ResizeButton.tex:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
end

-- 禁用移动框
T.ReleaseDragFrame = function(frame)
	if frame.df then
		frame.df.enable = false
		frame.df:Hide()
		if frame.df.isSelected then
			SelectedMover:Hide()
		end
	end
end

-- 恢复移动框
T.RestoreDragFrame = function(frame, parent)
	if frame.df then
		frame.df.enable = true
		if Mover:IsShown() and (not parent or parent.enable) then
			if not frame.movingtag or frame.movingtag == C.DB["GeneralOption"]["moving_boss"] then
				frame.df:Show()
			end
		end
	end
end

-- 开关子框体移动功能
T.Toggle_Subframe_moving = function(parent, subframe, value)
	if value then
		subframe.enable = true
		T.RestoreDragFrame(subframe, parent)
	else
		subframe.enable = false
		subframe:Hide()
		T.ReleaseDragFrame(subframe)
	end
end

-- 解锁界面
T.IsInPreview = function()
	return Mover:IsShown()
end
--====================================================--
--[[                -- 移动控制面板 --              ]]--
--====================================================--
local Mover_width = 360
local function CreateInputBox(name, key, numeric, points)
	local anchor = T.EditFrame(SelectedMover, 170, name, points)

	anchor.box:SetScript("OnEscapePressed", function(self)
		local frame, name = GetSelected()
		self:SetText(T.ValueFromDB({"FramePoints", name, key}))
		self:ClearFocus()
	end)
	
	if numeric then
		anchor.box:SetNumericFullRange(true)
	end
	
	anchor.box:SetScript("OnEnterPressed", function(self)
		local frame, name = GetSelected()
		local text = self:GetText()
		T.ValueToDB({"FramePoints", name, key}, numeric and tonumber(text) or text)
		PlaceFrame(frame)
		
		self.button:Hide()
		self:ClearFocus()
	end)
	
	return anchor
end

local function CreateDropDown(name, key, option_table, points)
	local anchor = T.UIDropDownMenuFrame(SelectedMover, name, points)
	anchor.dd:SetPoint("LEFT", anchor, "LEFT", 80, 0)
	
	local function DD_UpdateChecked(self, value)
		local frame, name = GetSelected()
		return (T.ValueFromDB({"FramePoints", name, key}) == value)
	end
	
	local function DD_SetChecked(self, value)
		local frame, name = GetSelected()
		T.ValueToDB({"FramePoints", name, key}, value)
		T.UIDropDownMenu_SetSelectedValueText(anchor.dd, option_table, value)
		PlaceFrame(frame)
	end
		
	UIDropDownMenu_Initialize(anchor.dd, function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			info.value = option_table[i][1]
			info.arg1 = option_table[i][1]
			info.text = option_table[i][2]
			info.checked = DD_UpdateChecked
			info.func = DD_SetChecked
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	return anchor
end

Mover = CreateFrame("Frame")
Mover:Hide()

SelectedMover = CreateFrame("Frame", G.addon_name.."SelectedMover", UIParent, "BackdropTemplate")
SelectedMover:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -250, 220)
SelectedMover:SetSize(Mover_width, 400)
SelectedMover:SetFrameStrata("HIGH")
SelectedMover:SetFrameLevel(30)
SelectedMover:Hide()

T.createborder(SelectedMover)

SelectedMover:RegisterForDrag("LeftButton")
SelectedMover:SetScript("OnDragStart", function(self) self:StartMoving() end)
SelectedMover:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
SelectedMover:SetClampedToScreen(true)
SelectedMover:SetMovable(true)
SelectedMover:EnableMouse(true)
SelectedMover:EnableKeyboard(true)

SelectedMover.close = CreateFrame("Button", nil, SelectedMover, "UIPanelCloseButton")
SelectedMover.close:SetPoint("TOPRIGHT", -5, -5)
SelectedMover.close:SetScript("OnClick", RemoveSelected)

-- 标题
SelectedMover.Title = T.createtext(SelectedMover, "OVERLAY", 16, "OUTLINE", "LEFT")
SelectedMover.Title:SetPoint("TOP", SelectedMover, "TOP", 0, -15)

-- 显示/隐藏框体名字
SelectedMover.NameToggleButton = T.ClickButton(SelectedMover, Mover_width-30, {"BOTTOM", SelectedMover, "BOTTOM", 0, 120}, "")
SelectedMover.NameToggleButton:SetScript("OnShow", function(self)
	if C.DB["GeneralOption"]["moving_name"] then
		self.Text:SetText(L["隐藏框体名字"])
	else
		self.Text:SetText(L["显示框体名字"])
	end
end)
SelectedMover.NameToggleButton:SetScript("OnClick", function(self)
	C.DB["GeneralOption"]["moving_name"] = not C.DB["GeneralOption"]["moving_name"] 
	if C.DB["GeneralOption"]["moving_name"] then
		self.Text:SetText(L["隐藏框体名字"])
	else
		self.Text:SetText(L["显示框体名字"])
	end
	ToggleFrameName()
end)

-- 重置
SelectedMover.ResetButton = T.ClickButton(SelectedMover, Mover_width-30, {"TOP", SelectedMover.NameToggleButton, "BOTTOM", 0, -5}, HUD_EDIT_MODE_RESET_POSITION)
SelectedMover.ResetButton:SetScript("OnClick", function()
	local frame, name = GetSelected()
	ResetFramePoint(frame)
	DisplayFramePoint(name)
end)

-- 重置所有
SelectedMover.ResetAllButton = T.ClickButton(SelectedMover, Mover_width-30, {"TOP", SelectedMover.ResetButton, "BOTTOM", 0, -5}, L["重置所有位置"])
SelectedMover.ResetAllButton:SetScript("OnClick", function()
	StaticPopupDialogs[G.addon_name.."Reset Positions Confirm"].text = L["重置位置确认"]
	StaticPopupDialogs[G.addon_name.."Reset Positions Confirm"].OnAccept = function()
		ResetAllFramesPoint()
	end
	StaticPopup_Show(G.addon_name.."Reset Positions Confirm")
end)

-- 锁定
SelectedMover.LockButton = T.ClickButton(SelectedMover, Mover_width-30, {"TOP", SelectedMover.ResetAllButton, "BOTTOM", 0, -20}, L["锁定框体"])
SelectedMover.LockButton:SetScript("OnClick", LockAll)

-- 按键移动
local function ProcessMovementKey(key)
	local deltaAmount = IsModifierKeyDown() and 10 or 1;
	local xDelta, yDelta = 0, 0
	
	if key == "UP" then
		yDelta = deltaAmount
	elseif key == "DOWN" then
		yDelta = -deltaAmount
	elseif key == "LEFT" then
		xDelta = -deltaAmount
	elseif key == "RIGHT" then
		xDelta = deltaAmount
	end
	
	local frame, name = GetSelected()

	frame:StopMovingOrSizing()
	C.DB["FramePoints"][name].x = C.DB["FramePoints"][name].x + xDelta
	C.DB["FramePoints"][name].y = C.DB["FramePoints"][name].y + yDelta
	
	PlaceFrame(frame) -- 重新连接到锚点	
	DisplayFramePoint(name)
end

local movementKeys = {
	UP = true,
	DOWN = true,
	LEFT = true,
	RIGHT = true,
}

Mover:SetScript("OnKeyDown", function(self, key)
	if key == "ESCAPE" then
		if not InCombatLockdown() then
			self:SetPropagateKeyboardInput(false)
		end
		LockAll()
	elseif movementKeys[key] then
		if not InCombatLockdown() then
			self:SetPropagateKeyboardInput(false)
		end
		ProcessMovementKey(key)
	else
		if not InCombatLockdown() then
			self:SetPropagateKeyboardInput(true)
		end
	end
end)

local function Init()
	SelectedMover.boss_btn = T.UIDropDownMenuFrame(SelectedMover, L["首领"], {"TOPLEFT", SelectedMover, "TOPLEFT", 30, -60}) -- 首领
	SelectedMover.boss_btn.dd:SetPoint("LEFT", SelectedMover.boss_btn, "LEFT", 80, 0)
	
	SelectedMover.a1dd = CreateDropDown(L["框体的"], "a1", anchors, {"TOPLEFT", SelectedMover.boss_btn, "BOTTOMLEFT", 0, -10})
	SelectedMover.a2dd = CreateDropDown(L["对齐到屏幕的"], "a2", anchors, {"TOPLEFT", SelectedMover.a1dd, "BOTTOMLEFT", 0, -10})
	SelectedMover.xbox = CreateInputBox("X", "x", true, {"TOPLEFT", SelectedMover.a2dd, "BOTTOMLEFT", 0, -10})
	SelectedMover.ybox = CreateInputBox("Y", "y", true, {"TOPLEFT", SelectedMover.xbox, "BOTTOMLEFT", 0, -10})
	
	C_AddOns.LoadAddOn("Blizzard_EncounterJournal")
	C_AddOns.LoadAddOn("Blizzard_PlayerSpells")
	
	local ins = {}
	
	for InstanceID in pairs(G.Encounter_Order) do
		table.insert(ins, {"Raid", InstanceID})
	end
	
	for ChallengeMapID in pairs(G.ChallengeMap_Order) do
		table.insert(ins, {"MythicPlus", ChallengeMapID})
	end
	
	table.sort(ins, function(a, b)
		if a[1] ~= b[1] then
			return a[1] == "Raid"
		else
			return a[2] < b[2]
		end
	end)
	
	local function EncounterData_Initialize(self, level, menuList)
		if level == 1 then
			for i, t in pairs(ins) do
				if t[1] == "Raid" then
					local InstanceID = t[2]
					local info = UIDropDownMenu_CreateInfo()
					info.text = EJ_GetInstanceInfo(InstanceID)
					info.value = t[1]..InstanceID
					info.hasArrow = true
					info.menuList = t[1]..InstanceID
					UIDropDownMenu_AddButton(info)
				else
					local ChallengeMapID = t[2]
					local info = UIDropDownMenu_CreateInfo()
					info.text = C_ChallengeMode.GetMapUIInfo(ChallengeMapID)
					info.value = t[1]..ChallengeMapID
					info.hasArrow = true
					info.menuList = t[1]..ChallengeMapID
					UIDropDownMenu_AddButton(info)
				end
			end
		elseif menuList then
			local tag1, tag2
			if string.find(menuList, "Raid") then
				tag1 = "Encounter_Order"
				tag2 = tonumber(string.match(menuList, "Raid(%d+)"))
			else
				tag1 = "ChallengeMap_Order"
				tag2 = tonumber(string.match(menuList, "MythicPlus(%d+)"))
			end
			
			if G[tag1][tag2] then
				for i, ENCID in pairs(G[tag1][tag2]) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = T.GetEncounterName(ENCID)
					info.value = ENCID
					info.notCheckable = true
					info.func = function()
						if C.DB["GeneralOption"]["moving_boss"] ~= ENCID then
							C.DB["GeneralOption"]["moving_boss"] = ENCID				
							UnlockCurrentBoss()
						end
						HideDropDownMenu(1)
					end
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end
	end
	
	UIDropDownMenu_Initialize(SelectedMover.boss_btn.dd, EncounterData_Initialize)
	
	local first = ins[1]
	if first then
		local tag1 = first[1] == "Raid" and "Encounter_Order" or "ChallengeMap_Order"
		local tag2 = first[2]
		C.DB["GeneralOption"]["moving_boss"] = G[tag1][tag2][1]
	end
	
	PlaceAllFrames()
end

T.RegisterEnteringWorldCallback(Init)