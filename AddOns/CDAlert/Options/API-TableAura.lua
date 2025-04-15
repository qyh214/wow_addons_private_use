local addonName,ns = ...
local L = ns.L
ns.AurayOffset = -5	--用于存光环表内行数
ns.AurarowFrames = {}--用于存表的行框架,方便查询和删除后重新排序

--光环表格行
function ns.AddAuraTableButtons(frame,id,name)
	local rowFrame = CreateFrame("Frame", nil, frame)
    rowFrame:SetSize(610, 26)
    rowFrame:SetPoint("TOPLEFT", 5, ns.AurayOffset)
	ns.AurarowFrames[id] = rowFrame -- 将行 Frame 存储起来
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

	
	local icon = ns.GetSpellIcon(id)
	local nametext = ns.AddTableText(rowFrame,rowFrame,100,162)
	nametext:SetText("|T"..icon ..":18|t "..name)
	
	local get = ns.AddTableClick(rowFrame,-30,ACTION_SPELL_AURA_APPLIED_BUFF,"AuraIds",id,"get")
	
	local rem = ns.AddTableClick(rowFrame,45,ACTION_SPELL_AURA_REMOVED,"AuraIds",id,"remove")
	
	local rem = ns.AddTableClick(rowFrame,120,SOURCES,"AuraIds",id,"source")
	
	


	local closeButton = CreateFrame("Button", nil, rowFrame, "UIPanelCloseButton")
	closeButton:SetPoint("RIGHT", 0, 0)
	closeButton:SetScript("OnClick", function()
		CDAlertDB["AuraIds"][id] = nil -- 移除对应的表格内容
        rowFrame:Hide() -- 隐藏这一行
        local newOffset = -5
		for key, row in pairs(ns.AurarowFrames) do
			if key and row:IsShown() and rowFrame~= row then -- 只对显示的行重新定位
            row:SetPoint("TOPLEFT", 5, newOffset)
            newOffset = newOffset - 28
			ns.AurayOffset = newOffset
		end
		ns.AurarowFrames[id] = nil
    end
	end)
	closeButton:SetScript("OnEnter", function(self)
		rowFramebackground:SetColorTexture(0.5, 0.5, 0.5, 1)
	end)
	closeButton:SetScript("OnLeave", function(self)
		rowFramebackground:SetColorTexture(0.5, 0.5, 0.5, 0.3)
	end)
	ns.AurayOffset = ns.AurayOffset - 28
	return rowFrame
end