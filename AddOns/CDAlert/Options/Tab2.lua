local addonName,ns = ...
local L = ns.L
local DB = ns.CDAlertDefaultDB

ns.event("PLAYER_LOGIN", function()
--分页4滚动内容不需要滚动框架就直接锚定在ns.tabframe
local ConFrame2 = CreateFrame("Frame", nil, ns.tabframe2)
ConFrame2:SetSize(670,480)
ConFrame2:SetAllPoints(ns.tabframe2)

local ItemDesc1 = ConFrame2:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
ItemDesc1:SetPoint("TOPLEFT",ConFrame2,"TOPLEFT", 15, -45)
ItemDesc1:SetFont("fonts\\ARHei.ttf", 15, "OUTLINE")
ItemDesc1:SetTextColor(1,1,1)
--ItemDesc1:SetText(L["光环说明一"])
local ItemDesc2 = ConFrame2:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
ItemDesc2:SetPoint("TOPLEFT",ItemDesc1,"BOTTOMLEFT", 0, -10)
ItemDesc2:SetFont("fonts\\ARHei.ttf", 15, "OUTLINE")
ItemDesc2:SetTextColor(1,1,1)
--ItemDesc2:SetText(L["光环说明二"])


--创建光环表格背景
local ItemTableFrame = CreateFrame("Frame", "MyTableFrame", ConFrame2, "BackdropTemplate")
ItemTableFrame:SetSize(650, 400)
ItemTableFrame:SetPoint("TOPLEFT",15,-90)
ItemTableFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
ItemTableFrame:SetBackdropColor(0, 0, 0, 0.5)
ItemTableFrame:SetBackdropBorderColor(0.7, 0.7, 0.7)

-- 创建光环表格滚动框架
local ItemscrollFrame = CreateFrame("ScrollFrame", "MyScrollFrame", ItemTableFrame, "UIPanelScrollFrameTemplate")
ItemscrollFrame:SetPoint("TOPLEFT", ItemTableFrame, "TOPLEFT", 4, -5)
ItemscrollFrame:SetPoint("BOTTOMRIGHT", ItemTableFrame, "BOTTOMRIGHT", -30, 5)

-- 创建光环内容框架
local ItemcontentFrame = CreateFrame("Frame", nil, ItemscrollFrame)
ItemcontentFrame:SetSize(620, 180)
ItemscrollFrame:SetScrollChild(ItemcontentFrame)	--设置滚动框内容为内容框架


--初始化光环图表内容
for key, datacon in pairs(CDAlertDB["ItemIds"]) do
	local idname = ns.GetItemName(key)
	if not CDAlertDB["ItemIds"][key]["end"] then CDAlertDB["ItemIds"][key]["end"] = L["好了"] end
	ns.AddItemTableButtons(ItemcontentFrame,key,idname)
end

--是否过滤默认
local function ItemTableHide()
	ns.ItemyOffset = -5
	for key, row in pairs(ns.ItemrowFrames) do
		if CDAlertDB["ItemIds"][key] then
			ns.ItemrowFrames[key]:Show()
		end
		if ns.ItemrowFrames[key]:IsShown() then -- 只对显示的行重新定位
			ns.ItemrowFrames[key]:SetPoint("TOPLEFT", 5, ns.ItemyOffset)
			ns.ItemyOffset = ns.ItemyOffset - 28
		end
	end
end

-- 创建光环表格查询添加输入框
local ItemQueryBox = ns.AddEditBox(ConFrame2,25,-8,80,true)
ItemQueryBox:HookScript("OnEnterPressed", function(self)
	self:ClearFocus() -- 清除编辑框的焦点
    local id = tonumber(self:GetText()) -- 获取编辑框中的文本
	if not id or id == "" then return end
	local idname = ns.GetItemName(id)
	--DB插入
	if CDAlertDB["ItemIds"][id] then print(id.."--"..idname.."--"..L["法术已存在"]) return end
	local newtable = {name=idname, ["end"] = L["好了"]}
	CDAlertDB["ItemIds"][id] = newtable
	--表内插入
	ns.AddItemTableButtons(ItemcontentFrame,id,idname)
	C_Timer.After(0.1,function()	--延迟设置滚动条到最底部,不延迟不会获取到最大值
		ItemscrollFrame:SetVerticalScroll(ItemscrollFrame:GetVerticalScrollRange())
	end)
end)
ItemQueryBox:HookScript("OnTextChanged", function(self, userInput)
    local text = self:GetText() -- 获取输入框中的文本
	ns.ItemyOffset = -5
	if text == "" or text == nil then
		ItemTableHide()
	else
		for key, row in pairs(ns.ItemrowFrames) do
			if string.find(key,text) then
				ns.ItemrowFrames[key]:Show()
			else
				ns.ItemrowFrames[key]:Hide()
			end
			
			if ns.ItemrowFrames[key]:IsShown() then -- 只对显示的行重新定位
            ns.ItemrowFrames[key]:SetPoint("TOPLEFT", 5, ns.ItemyOffset)
            ns.ItemyOffset = ns.ItemyOffset - 28
			end
			
		end
	end
end)

--光环添加按钮
local ItemAddButton = ns.AddButtons(ConFrame2,ADD,110,-11,60,23)
ItemAddButton:HookScript("OnClick", function(self, button, down)
	ItemQueryBox:ClearFocus() -- 清除编辑框的焦点
    local id = tonumber(ItemQueryBox:GetText()) -- 获取编辑框中的文本
	if not id or id == "" then return end
	local idname = ns.GetItemName(id)
	--DB插入
	if CDAlertDB["ItemIds"][id] then print(id.."--"..idname.."--"..L["法术已存在"]) return end
	local newtable = {name=idname, ["end"] = L["好了"]}
	CDAlertDB["ItemIds"][id] = newtable
	--表内插入
	ns.AddItemTableButtons(ItemcontentFrame,id,idname)
	C_Timer.After(0.1,function()	--延迟设置滚动条到最底部,不延迟不会获取到最大值
		ItemscrollFrame:SetVerticalScroll(ItemscrollFrame:GetVerticalScrollRange())
	end)
end)

--恢复光环列表
local auraltextRe = ns.AddfuncButton(ConFrame2,ConFrame2,L["恢复默认列表"],-15, -10, 125)
auraltextRe:HookScript("OnClick", function()
	ns.ItemyOffset = -5
	for key, datacon in pairs(CDAlertDB["ItemIds"]) do
		if key then
			if ns.ItemrowFrames[key] then
				ns.ItemrowFrames[key]:Hide()
			end
			ns.ItemrowFrames[key] = nil
		end
	end
	CDAlertDB["ItemIds"] = DB["ItemIds"]
	for key, datacon in pairs(CDAlertDB["ItemIds"]) do
		local idname = ns.GetItemName(key)
		if not CDAlertDB["ItemIds"][key]["end"] then CDAlertDB["ItemIds"][key]["end"] = L["好了"] end
		ns.AddItemTableButtons(ItemcontentFrame,key,idname)
	end
end)

--清空光环列表
local auraltextDe = ns.AddfuncButton(ConFrame2,ConFrame2,L["清空列表"],-15,-50,125)
auraltextDe:HookScript("OnClick", function()
	CDAlertDB["ItemIds"] = {}
	ns.ItemyOffset = -5
	for key, row in pairs(ns.ItemrowFrames) do
		row:Hide()
		ns.ItemrowFrames[key] = nil
	end
end)

end)