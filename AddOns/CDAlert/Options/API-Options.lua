local addonName,ns = ...
local L = ns.L
ns.Y = {}	--用于分页行数自动拓展

--创建主页面点击放大分类按钮
local tabbutton = {}
function ns.AddClickBC(parent,frame, id, width, text, xOffset, yOffset)
	local xOffset = xOffset or 6
    local yOffset = yOffset or -2
    local prevButton = tabbutton[id - 1] -- 获取前一个按钮

    local button = CreateFrame("Button", nil, parent, "ColumnDisplayButtonTemplate")
    button:SetSize(width, 24) -- 如果不是24，右边框体会出问题
    if prevButton then
		frame:Hide()
        button:SetPoint("BOTTOMLEFT", prevButton["A"], "BOTTOMRIGHT", 10 ,0)
		button:SetScale(.9)
		button:GetFontString():SetTextColor(1, 1, 1)
    else
        button:SetPoint("BOTTOM", parent, "TOPLEFT", xOffset, yOffset)
		button:SetScale(1.1)
		button:GetFontString():SetTextColor(1, 1, 0)
    end
    button:SetText(text)
    button:GetFontString():SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    button:GetFontString():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	
    tabbutton[id] = {}
	tabbutton[id]["A"] = button
	tabbutton[id]["B"] = frame
    button:SetScript("OnClick", function(self)
        for aa, row in pairs(tabbutton) do
            if self == row["A"] then -- 只对当前按钮重新定位
                row["A"]:SetScale(1.1)
				row["A"]:GetFontString():SetTextColor(1, 1, 0)
				row["B"]:Show()
            else
                row["A"]:SetScale(.9)
				row["A"]:GetFontString():SetTextColor(1, 1, 1)
				row["B"]:Hide()
            end
        end
    end)

    return button
end

--点击功能按钮
function ns.AddfuncButton(parent,point,name,x,y,width,height)
	local width = width or 110
	local height = height or 25
	local x = x or 500
	local y = y or 1
	local funcButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	funcButton:SetText(name)
	funcButton:SetSize(width,height)
	funcButton:SetPoint("TOPRIGHT",point,"TOPRIGHT", x, y)
	funcButton:SetScript("OnClick", function()end)
	return funcButton
end

--创建主页面编辑框
function ns.AddEditBox(parent,x,y,size,Numeric,scale)
	local Box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	Box:SetSize(size, 30)
	Box:SetScale(scale or 1)
	Box:SetPoint("TOPLEFT", x,y)
	Box:SetAutoFocus(false)
	Box:SetNumeric(Numeric)
	local ClearBox = CreateFrame("Button", nil, Box)
	ClearBox:SetPoint("RIGHT", -5, 0)
	ClearBox:SetSize(13, 13)
	ClearBox:SetNormalTexture("common-search-clearbutton")
	ClearBox:SetHighlightTexture("common-search-clearbutton")
	Box:SetScript("OnEnterPressed", function() end)
	--Box:SetScript("OnTextChanged", function() end)
	Box:SetScript("OnTextChanged", function(self)
		ClearBox:SetShown(self:GetText() ~= "")
	end)
	ClearBox:SetScript("OnClick", function() Box:SetText("") Box:GetScript("OnTextChanged")(Box)  end)
	return Box
end

--创建主页面点击按钮
function ns.AddButtons(parent,name,x,y,width,height,Numeric,scale)
	local Button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	Button:SetPoint("TOPLEFT", x,y)
	Button:SetSize(width,height)
	Button:SetText(name)
	Button:SetScript("OnClick", function() end)
	return Button
end