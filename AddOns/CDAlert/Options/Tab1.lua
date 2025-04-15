local addonName,ns = ...
local L = ns.L
local DB = ns.CDAlertDefaultDB

ns.event("PLAYER_LOGIN", function()
--分页4滚动内容不需要滚动框架就直接锚定在ns.tabframe
local ConFrame1 = CreateFrame("Frame", nil, ns.tabframe1)
ConFrame1:SetSize(670,480)
ConFrame1:SetAllPoints(ns.tabframe1)

local SpellDesc1 = ConFrame1:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
SpellDesc1:SetPoint("TOPLEFT",ConFrame1,"TOPLEFT", 15, -45)
SpellDesc1:SetFont("fonts\\ARHei.ttf", 15, "OUTLINE")
SpellDesc1:SetTextColor(1,1,1)
--SpellDesc1:SetText(L["光环说明一"])
local SpellDesc2 = ConFrame1:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
SpellDesc2:SetPoint("TOPLEFT",SpellDesc1,"BOTTOMLEFT", 0, -10)
SpellDesc2:SetFont("fonts\\ARHei.ttf", 15, "OUTLINE")
SpellDesc2:SetTextColor(1,1,1)
--SpellDesc2:SetText(L["光环说明二"])


--创建光环表格背景
local SpellTableFrame = CreateFrame("Frame", "MyTableFrame", ConFrame1, "BackdropTemplate")
SpellTableFrame:SetSize(650, 400)
SpellTableFrame:SetPoint("TOPLEFT",15,-90)
SpellTableFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
SpellTableFrame:SetBackdropColor(0, 0, 0, 0.5)
SpellTableFrame:SetBackdropBorderColor(0.7, 0.7, 0.7)

-- 创建光环表格滚动框架
local SpellscrollFrame = CreateFrame("ScrollFrame", "MyScrollFrame", SpellTableFrame, "UIPanelScrollFrameTemplate")
SpellscrollFrame:SetPoint("TOPLEFT", SpellTableFrame, "TOPLEFT", 4, -5)
SpellscrollFrame:SetPoint("BOTTOMRIGHT", SpellTableFrame, "BOTTOMRIGHT", -30, 5)

-- 创建光环内容框架
local SpellcontentFrame = CreateFrame("Frame", nil, SpellscrollFrame)
SpellcontentFrame:SetSize(620, 180)
SpellscrollFrame:SetScrollChild(SpellcontentFrame)	--设置滚动框内容为内容框架


--初始化光环图表内容
for key, datacon in pairs(CDAlertDB["SpellIds"]) do
	local idname = ns.GetSpellName(key)
	if not CDAlertDB["SpellIds"][key]["end"] then CDAlertDB["SpellIds"][key]["end"] = L["好了"] end
	ns.AddSpellTableButtons(SpellcontentFrame,key,idname)
end

--是否过滤默认
local function SpellTableHide()
	ns.SpellyOffset = -5
	for key, row in pairs(ns.SpellrowFrames) do
		if CDAlertDB["SpellIds"][key] then
			ns.SpellrowFrames[key]:Show()
		end
		if ns.SpellrowFrames[key]:IsShown() then -- 只对显示的行重新定位
			ns.SpellrowFrames[key]:SetPoint("TOPLEFT", 5, ns.SpellyOffset)
			ns.SpellyOffset = ns.SpellyOffset - 28
		end
	end
end

-- 创建光环表格查询添加输入框
local SpellQueryBox = ns.AddEditBox(ConFrame1,25,-8,80,true)
SpellQueryBox:HookScript("OnEnterPressed", function(self)
	self:ClearFocus() -- 清除编辑框的焦点
    local id = tonumber(self:GetText()) -- 获取编辑框中的文本
	if not id or id == "" then return end
	local idname = ns.GetSpellName(id)
	--DB插入
	if CDAlertDB["SpellIds"][id] then print(id.."--"..idname.."--"..L["法术已存在"]) return end
	local newtable = {name=idname, ["end"] = L["好了"]}
	CDAlertDB["SpellIds"][id] = newtable
	--表内插入
	ns.AddSpellTableButtons(SpellcontentFrame,id,idname)
	C_Timer.After(0.1,function()	--延迟设置滚动条到最底部,不延迟不会获取到最大值
		SpellscrollFrame:SetVerticalScroll(SpellscrollFrame:GetVerticalScrollRange())
	end)
end)
SpellQueryBox:HookScript("OnTextChanged", function(self, userInput)
    local text = self:GetText() -- 获取输入框中的文本
	ns.SpellyOffset = -5
	if text == "" or text == nil then
		SpellTableHide()
	else
		for key, row in pairs(ns.SpellrowFrames) do
			if string.find(key,text) then
				ns.SpellrowFrames[key]:Show()
			else
				ns.SpellrowFrames[key]:Hide()
			end
			
			if ns.SpellrowFrames[key]:IsShown() then -- 只对显示的行重新定位
            ns.SpellrowFrames[key]:SetPoint("TOPLEFT", 5, ns.SpellyOffset)
            ns.SpellyOffset = ns.SpellyOffset - 28
			end
			
		end
	end
end)

--光环添加按钮
local SpellAddButton = ns.AddButtons(ConFrame1,ADD,110,-11,60,23)
SpellAddButton:HookScript("OnClick", function(self, button, down)
	SpellQueryBox:ClearFocus() -- 清除编辑框的焦点
    local id = tonumber(SpellQueryBox:GetText()) -- 获取编辑框中的文本
	if not id or id == "" then return end
	local idname = ns.GetSpellName(id)
	--DB插入
	if CDAlertDB["SpellIds"][id] then print(id.."--"..idname.."--"..L["法术已存在"]) return end
	local newtable = {name=idname, ["end"] = L["好了"]}
	CDAlertDB["SpellIds"][id] = newtable
	--表内插入
	ns.AddSpellTableButtons(SpellcontentFrame,id,idname)
	C_Timer.After(0.1,function()	--延迟设置滚动条到最底部,不延迟不会获取到最大值
		SpellscrollFrame:SetVerticalScroll(SpellscrollFrame:GetVerticalScrollRange())
	end)
end)

--恢复光环列表
local auraltextRe = ns.AddfuncButton(ConFrame1,ConFrame1,L["恢复默认列表"],-15, -10, 125)
auraltextRe:HookScript("OnClick", function()
	ns.SpellyOffset = -5
	for key, datacon in pairs(CDAlertDB["SpellIds"]) do
		if key then
			if ns.SpellrowFrames[key] then
				ns.SpellrowFrames[key]:Hide()
			end
			ns.SpellrowFrames[key] = nil
		end
	end
	CDAlertDB["SpellIds"] = DB["SpellIds"]
	for key, datacon in pairs(CDAlertDB["SpellIds"]) do
		local idname = ns.GetSpellName(key)
		if not CDAlertDB["SpellIds"][key]["end"] then CDAlertDB["SpellIds"][key]["end"] = L["好了"] end
		ns.AddSpellTableButtons(SpellcontentFrame,key,idname)
	end
end)

--清空光环列表
local auraltextDe = ns.AddfuncButton(ConFrame1,ConFrame1,L["清空列表"],-15,-50,125)
auraltextDe:HookScript("OnClick", function()
	CDAlertDB["SpellIds"] = {}
	ns.SpellyOffset = -5
	for key, row in pairs(ns.SpellrowFrames) do
		row:Hide()
		ns.SpellrowFrames[key] = nil
	end
end)

end)