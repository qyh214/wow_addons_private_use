local addonName,ns = ...
local L = ns.L
ns.SpellyOffset = -5	--用于存光环表内行数
ns.SpellrowFrames = {}--用于存表的行框架,方便查询和删除后重新排序

--光环表格行
function ns.AddSpellTableButtons(frame,id,name)
	local rowFrame = CreateFrame("Frame", nil, frame)
    rowFrame:SetSize(610, 26)
    rowFrame:SetPoint("TOPLEFT", 5, ns.SpellyOffset)
	ns.SpellrowFrames[id] = rowFrame -- 将行 Frame 存储起来
	local rowFramebackground = rowFrame:CreateTexture(nil, "BACKGROUND")
	rowFramebackground:SetTexture(130937)
	rowFramebackground:SetAllPoints(rowFrame) -- 使背景纹理与字体字符串大小相同
	rowFramebackground:SetColorTexture(0.5, 0.5, 0.5, 0.3) -- 设置背景颜色为黑色，透明度为0.5
	rowFramebackground:SetScript("OnEnter", function(self)
		self:SetColorTexture(0.5, 0.5, 0.5, 1)
	end)
	rowFramebackground:SetScript("OnLeave", function(self)
		self:SetColorTexture(0.5, 0.5, 0.5, 0.3)
	end)

	local idtext = ns.AddTableText(rowFrame,rowFrame,3,62)
	idtext:SetText(id)
	
	local start = ns.AddTableNotes(rowFrame,100,0,100,"SpellIds",id,"start") --创建备注
	start:HookScript("OnEnter", function ()
		rowFramebackground:SetColorTexture(0.5, 0.5, 0.5, 1)
	end)
	start:SetScript("OnLeave", function()
		rowFramebackground:SetColorTexture(0.5, 0.5, 0.5, 0.3)
	end)
	
	local icon = ns.GetSpellIcon(id)
	local nametext = ns.AddTableText(rowFrame,rowFrame,222,162)
	nametext:SetText("|T"..icon ..":18|t "..name)
	
	
	local font3 = ns.AddTableNotes(rowFrame,390,0,100,"SpellIds",id,"end") --创建备注
	font3:HookScript("OnEnter", function ()
		rowFramebackground:SetColorTexture(0.5, 0.5, 0.5, 1)
	end)
	font3:SetScript("OnLeave", function()
		rowFramebackground:SetColorTexture(0.5, 0.5, 0.5, 0.3)
	end)

	local closeButton = CreateFrame("Button", nil, rowFrame, "UIPanelCloseButton")
	closeButton:SetPoint("RIGHT", 0, 0)
	closeButton:SetScript("OnClick", function()
		CDAlertDB["SpellIds"][id] = nil -- 移除对应的表格内容
        rowFrame:Hide() -- 隐藏这一行
        local newOffset = -5
		for key, row in pairs(ns.SpellrowFrames) do
			if key and row:IsShown() and rowFrame~= row then -- 只对显示的行重新定位
            row:SetPoint("TOPLEFT", 5, newOffset)
            newOffset = newOffset - 28
			ns.SpellyOffset = newOffset
		end
		ns.SpellrowFrames[id] = nil
    end
	end)
	closeButton:SetScript("OnEnter", function(self)
		rowFramebackground:SetColorTexture(0.5, 0.5, 0.5, 1)
	end)
	closeButton:SetScript("OnLeave", function(self)
		rowFramebackground:SetColorTexture(0.5, 0.5, 0.5, 0.3)
	end)
	ns.SpellyOffset = ns.SpellyOffset - 28
	return rowFrame
end