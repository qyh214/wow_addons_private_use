local addonName,ns = ...
local L = ns.L
local DB = ns.CDAlertDefaultDB

ns.event("PLAYER_LOGIN", function()
--分页4滚动内容不需要滚动框架就直接锚定在ns.tabframe
local ConFrame3 = CreateFrame("Frame", nil, ns.tabframe3)
ConFrame3:SetSize(670,480)
ConFrame3:SetAllPoints(ns.tabframe3)

local AuraDesc1 = ConFrame3:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
AuraDesc1:SetPoint("TOPLEFT",ConFrame3,"TOPLEFT", 15, -45)
AuraDesc1:SetFont("fonts\\ARHei.ttf", 15, "OUTLINE")
AuraDesc1:SetTextColor(1,1,1)
--AuraDesc1:SetText(L["光环说明一"])
local AuraDesc2 = ConFrame3:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
AuraDesc2:SetPoint("TOPLEFT",AuraDesc1,"BOTTOMLEFT", 0, -10)
AuraDesc2:SetFont("fonts\\ARHei.ttf", 15, "OUTLINE")
AuraDesc2:SetTextColor(1,1,1)
--AuraDesc2:SetText(L["光环说明二"])


--创建光环表格背景
local AuraTableFrame = CreateFrame("Frame", "MyTableFrame", ConFrame3, "BackdropTemplate")
AuraTableFrame:SetSize(650, 400)
AuraTableFrame:SetPoint("TOPLEFT",15,-90)
AuraTableFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
AuraTableFrame:SetBackdropColor(0, 0, 0, 0.5)
AuraTableFrame:SetBackdropBorderColor(0.7, 0.7, 0.7)

-- 创建光环表格滚动框架
local AurascrollFrame = CreateFrame("ScrollFrame", "MyScrollFrame", AuraTableFrame, "UIPanelScrollFrameTemplate")
AurascrollFrame:SetPoint("TOPLEFT", AuraTableFrame, "TOPLEFT", 4, -5)
AurascrollFrame:SetPoint("BOTTOMRIGHT", AuraTableFrame, "BOTTOMRIGHT", -30, 5)

-- 创建光环内容框架
local AuracontentFrame = CreateFrame("Frame", nil, AurascrollFrame)
AuracontentFrame:SetSize(620, 180)
AurascrollFrame:SetScrollChild(AuracontentFrame)	--设置滚动框内容为内容框架


--初始化光环图表内容
for key, datacon in pairs(CDAlertDB["AuraIds"]) do
	local idname = ns.GetSpellName(key)
	ns.AddAuraTableButtons(AuracontentFrame,key,idname)
end

--是否过滤默认
local function AuraTableHide()
	ns.AurayOffset = -5
	for key, row in pairs(ns.AurarowFrames) do
		if CDAlertDB["AuraIds"][key] then
			ns.AurarowFrames[key]:Show()
		end
		if ns.AurarowFrames[key]:IsShown() then -- 只对显示的行重新定位
			ns.AurarowFrames[key]:SetPoint("TOPLEFT", 5, ns.AurayOffset)
			ns.AurayOffset = ns.AurayOffset - 28
		end
	end
end

-- 创建光环表格查询添加输入框
local AuraQueryBox = ns.AddEditBox(ConFrame3,25,-8,80,true)
AuraQueryBox:HookScript("OnEnterPressed", function(self)
	self:ClearFocus() -- 清除编辑框的焦点
    local id = tonumber(self:GetText()) -- 获取编辑框中的文本
	if not id or id == "" then return end
	local idname = ns.GetSpellName(id)
	--DB插入
	if CDAlertDB["AuraIds"][id] then print(id.."--"..idname.."--"..L["法术已存在"]) return end
	local newtable = {["get"]=true,["remove"]=true,["source"] = true}
	CDAlertDB["AuraIds"][id] = newtable
	--表内插入
	ns.AddAuraTableButtons(AuracontentFrame,id,idname)
	C_Timer.After(0.1,function()	--延迟设置滚动条到最底部,不延迟不会获取到最大值
		AurascrollFrame:SetVerticalScroll(AurascrollFrame:GetVerticalScrollRange())
	end)
end)
AuraQueryBox:HookScript("OnTextChanged", function(self, userInput)
    local text = self:GetText() -- 获取输入框中的文本
	ns.AurayOffset = -5
	if text == "" or text == nil then
		AuraTableHide()
	else
		for key, row in pairs(ns.AurarowFrames) do
			if string.find(key,text) then
				ns.AurarowFrames[key]:Show()
			else
				ns.AurarowFrames[key]:Hide()
			end
			
			if ns.AurarowFrames[key]:IsShown() then -- 只对显示的行重新定位
            ns.AurarowFrames[key]:SetPoint("TOPLEFT", 5, ns.AurayOffset)
            ns.AurayOffset = ns.AurayOffset - 28
			end
			
		end
	end
end)

--光环添加按钮
local AuraAddButton = ns.AddButtons(ConFrame3,ADD,110,-11,60,23)
AuraAddButton:HookScript("OnClick", function(self, button, down)
	AuraQueryBox:ClearFocus() -- 清除编辑框的焦点
    local id = tonumber(AuraQueryBox:GetText()) -- 获取编辑框中的文本
	if not id or id == "" then return end
	local idname = ns.GetSpellName(id)
	--DB插入
	if CDAlertDB["AuraIds"][id] then print(id.."--"..idname.."--"..L["法术已存在"]) return end
	local newtable = {["get"]=true,["remove"]=true,["source"] = true}
	CDAlertDB["AuraIds"][id] = newtable
	--表内插入
	ns.AddAuraTableButtons(AuracontentFrame,id,idname)
	C_Timer.After(0.1,function()	--延迟设置滚动条到最底部,不延迟不会获取到最大值
		AurascrollFrame:SetVerticalScroll(AurascrollFrame:GetVerticalScrollRange())
	end)
end)

--恢复光环列表
local auraltextRe = ns.AddfuncButton(ConFrame3,ConFrame3,L["恢复默认列表"],-15, -10, 125)
auraltextRe:HookScript("OnClick", function()
	ns.AurayOffset = -5
	for key, datacon in pairs(CDAlertDB["AuraIds"]) do
		if key then
			if ns.AurarowFrames[key] then
				ns.AurarowFrames[key]:Hide()
			end
			ns.AurarowFrames[key] = nil
		end
	end
	CDAlertDB["AuraIds"] = DB["AuraIds"]
	for key, datacon in pairs(CDAlertDB["AuraIds"]) do
		local idname = ns.GetSpellName(key)
		if not CDAlertDB["AuraIds"][key]["end"] then CDAlertDB["AuraIds"][key]["end"] = L["好了"] end
		ns.AddAuraTableButtons(AuracontentFrame,key,idname)
	end
end)

--清空光环列表
local auraltextDe = ns.AddfuncButton(ConFrame3,ConFrame3,L["清空列表"],-15,-50,125)
auraltextDe:HookScript("OnClick", function()
	CDAlertDB["AuraIds"] = {}
	ns.AurayOffset = -5
	for key, row in pairs(ns.AurarowFrames) do
		row:Hide()
		ns.AurarowFrames[key] = nil
	end
end)

end)