local addonName,ns = ...
local L = ns.L

--表格行文本
function ns.AddTableText(parent,pointframe,x,width)
	local background = parent:CreateTexture(nil, "ARTWORK")
	background:SetTexture(130937)
	background:SetPoint("LEFT",pointframe, x, 0)
	background:SetSize(width,23)
	background:SetColorTexture(0, 0, 0, .5) -- 设置背景颜色为黑色，透明度为0.5
	local font = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	font:SetPoint("LEFT",background,"LEFT", 5, 0)
	font:SetFont("fonts\\ARHei.ttf", 15, "OUTLINE")
	return font
end

--表格行备注输入框
function ns.AddTableNotes(parent,x,y,width,DB,DB2,DB3)
	local text = ""
	if DB3 then
		text = CDAlertDB[DB][DB2][DB3]
	elseif DB2 then
		text = CDAlertDB[DB][DB2]
	elseif DB then
		text = CDAlertDB[DB]
	end
	if not text then text = "" end
	
	local background = parent:CreateTexture(nil, "ARTWORK")
	background:SetTexture(130937)
	background:SetPoint("LEFT", x, y) 
	background:SetSize(width*1.1+8,23)
	background:SetColorTexture(0, 0, 0, 0.5) -- 设置背景颜色为黑色，透明度为0.5
	
	local NotesBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	NotesBox:SetSize(width, 20)
	NotesBox:SetPoint("LEFT",background, 6, 0)
	NotesBox:SetScale(1.1)
	NotesBox:SetAutoFocus(false) -- 不自动获取焦点
	NotesBox:SetJustifyH("CENTER")
	NotesBox:SetMultiLine(true)
	NotesBox:SetMaxLetters(20)
	NotesBox:SetText(text)
	NotesBox:SetTextInsets(-4,0,0,0) --文字可用位置
	NotesBox:SetTextColor(0.9, 0.9, 0.9,0.9) 
	local defaultText = NotesBox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	defaultText:SetPoint("CENTER", -3, 0)
	defaultText:SetText("")
	defaultText:SetTextColor(0.5, 0.5, 0.5, .5)
	NotesBox:SetScript("OnTextChanged", function(self, userInput)
		if DB3 then
			CDAlertDB[DB][DB2][DB3] = self:GetText()
		elseif DB2 then
			CDAlertDB[DB][DB2] = self:GetText()
		elseif DB then
			CDAlertDB[DB] = self:GetText()
		end
		if self:GetText() == "" then
			defaultText:Show()
		else
			defaultText:Hide()
		end
	end)
	NotesBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus() -- 清除编辑框的焦点
	end)
	NotesBox:SetScript("OnEditFocusGained", function(self)
		defaultText:Hide()-- 当编辑框获得焦点时隐藏提示文本
	end)
	NotesBox:SetScript("OnEditFocusLost", function(self)
		if self:GetText() == "" then
			defaultText:Show() -- 当编辑框失去焦点且为空时显示提示文本
		end
	end)
	return NotesBox
end

--表格内勾选按钮和文字
function ns.AddTableClick(parent,y,name,DB,DB2,DB3)
	local click = false
	if DB3 then
		click = CDAlertDB[DB][DB2][DB3]
	elseif DB2 then
		click = CDAlertDB[DB][DB2]
	elseif DB then
		click = CDAlertDB[DB]
	end
	local background = parent:CreateTexture(nil, "ARTWORK")
	background:SetTexture(130937)
	background:SetPoint("LEFT",parent,"LEFT", 300+y, 0)
	background:SetSize(65,23)
	background:SetColorTexture(0, 0, 0, .5) -- 设置背景颜色为黑色，透明度为0.5
	local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	check:SetPoint("LEFT",background,"LEFT", 0, 0)
	check:SetChecked(click)
	check:SetScript("OnClick", function (self)
		if DB3 then
			CDAlertDB[DB][DB2][DB3] = self:GetChecked()
		elseif DB2 then
			CDAlertDB[DB][DB2] = self:GetChecked()
		elseif DB then
			CDAlertDB[DB] = self:GetChecked()
		end
	end)
	local text = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetPoint("LEFT", check, "RIGHT", 0, 1)
	text:SetText(name)
	text:SetFont("fonts\\ARHei.ttf", 14, "OUTLINE")
	text:SetTextColor(1,1,1,.83)
	local cleckandtext = {}
	cleckandtext.text = text
	cleckandtext.check = check
	return cleckandtext
end