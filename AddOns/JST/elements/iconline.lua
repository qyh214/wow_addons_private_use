local T, C, L, G = unpack(select(2, ...))
local addon_name = G.addon_name
local FrameHolder = G.FrameHolder

T.CreateSpellLineFrame = function(name, text, size, anchor1, anchor2, x, y)
	local frame = CreateFrame("Frame", addon_name..name, FrameHolder)
	frame:Hide()
	
	local width = size*5 + 5*4
	local height = size
	frame:SetSize(width, height)
	
	frame.movingname = text
	frame.point = { a1 = anchor1, a2 = anchor2, x = x, y = y}
	T.CreateDragFrame(frame)
	
	frame.active_byindex = {}
	
	return frame
end

T.CreateSpellIconBase = function(parent, tag)
	local icon = CreateFrame("Frame", nil, parent)
	icon:SetSize(40, 40)
	icon:Hide()
	
	T.createborder(icon)
	
	-- 图标材质
	icon.texture = icon:CreateTexture(nil, "BORDER", nil, 1)
	icon.texture:SetTexCoord( .1, .9, .1, .9)
	icon.texture:SetAllPoints()
	
	-- 冷却转圈
	icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	icon.cooldown:SetAllPoints()
	icon.cooldown:SetDrawEdge(false)
	icon.cooldown:SetFrameLevel(icon:GetFrameLevel())
	icon.cooldown:SetReverse(true)
	
	-- 右下：层数
	icon.charge_text = T.createtext(icon, "OVERLAY", 20, "OUTLINE", "RIGHT") -- 层数
	icon.charge_text:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 2)
	icon.charge_text:SetHeight(12)
	icon.charge_text:SetTextColor(0, 1, 1)

	-- 上：来源名称
	icon.source_text = T.createtext(icon, "OVERLAY", 12, "OUTLINE", "CENTER") -- 玩家名字
	icon.source_text:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, -2)
	icon.source_text:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 2, -2)
	icon.source_text:SetHeight(12)
	
	icon:HookScript("OnShow", function(self)
		parent:lineup()
	end)
	
	icon:HookScript("OnHide", function(self)
		parent:lineup()
	end)
	
	table.insert(parent.active_byindex, icon)
	
	icon.tag = tag
	
	return icon
end

T.CreateAnimSpellIcon = function(parent, tag)
	local icon = CreateFrame("Frame", nil, parent)
	icon:SetSize(40, 40)
	icon:Hide()
	
	T.createborder(icon)
	
	-- 图标材质
	icon.texture = icon:CreateTexture(nil, "BORDER", nil, 1)
	icon.texture:SetTexCoord( .1, .9, .1, .9)
	icon.texture:SetAllPoints()
	
	-- 冷却转圈
	icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	icon.cooldown:SetAllPoints()
	icon.cooldown:SetDrawEdge(false)
	icon.cooldown:SetFrameLevel(icon:GetFrameLevel())
	icon.cooldown:SetHideCountdownNumbers(true)
	icon.cooldown:SetReverse(true)
	
	-- 粗边框
	T.SetHighLightBorderColor(icon, icon, {1, 1, 1}, 4)
	
	-- 粗边框闪烁动画
	icon.anim = icon:CreateAnimationGroup()
	icon.anim:SetLooping("BOUNCE")
	
	icon.anim:SetScript("OnStop", function()
		icon.innerBD:SetAlpha(1)
	end)
	
	icon.timer = icon.anim:CreateAnimation("Alpha")
	icon.timer:SetChildKey("innerBD")
	icon.timer:SetDuration(.3)
	icon.timer:SetFromAlpha(1)
	icon.timer:SetToAlpha(.2)
	
	-- 表层框架
	icon.cover = CreateFrame("Frame", nil, icon)
	icon.cover:SetFrameLevel(icon:GetFrameLevel()+5)
	icon.cover:SetAllPoints(icon)
	
	-- 上：技能名字
	icon.toptext = T.createtext(icon.cover, "OVERLAY", 12, "OUTLINE", "CENTER")
	icon.toptext:SetPoint("TOPLEFT", icon.cover, "TOPLEFT", -7, -7)
	icon.toptext:SetPoint("TOPRIGHT", icon.cover, "TOPRIGHT", 7, -7)
	icon.toptext:SetHeight(12)	
	icon.toptext:SetTextColor(1, 1, 0)
	
	-- 下：层数
	icon.brtext = T.createtext(icon.cover, "OVERLAY", 20, "OUTLINE", "RIGHT")
	icon.brtext:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", -4, 2)
	icon.brtext:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 2)
	icon.brtext:SetHeight(18)
	icon.brtext:SetTextColor(0, 1, 1)
	
	-- 中：时间
	icon.text = T.createtext(icon.cover, "OVERLAY", 20, "OUTLINE", "LEFT")
	icon.text:SetTextColor(1, 1, 1)
	icon.text:SetPoint("CENTER", icon, "CENTER", 0, 0)
	
	-- 外下：描述
	icon.bottomtext = T.createtext(icon.cover, "OVERLAY", 12, "OUTLINE", "CENTER")
	icon.bottomtext:SetTextColor(0, 1, .5)
	icon.bottomtext:SetPoint("TOP", icon, "BOTTOM", 0, -2)
	
	-- 右上：标记
	icon.ficontext = T.createtext(icon.cover, "OVERLAY", 18, "OUTLINE", "RIGHT")
	icon.ficontext:SetPoint("TOPRIGHT", icon.cover, "TOPRIGHT", 4, 2)
	
	icon:HookScript("OnShow", function(self)
		parent:lineup()
	end)
	
	icon:HookScript("OnHide", function(self)
		parent:lineup()
	end)
	
	table.insert(parent.active_byindex, icon)
	
	icon.tag = tag
	
	return icon
end