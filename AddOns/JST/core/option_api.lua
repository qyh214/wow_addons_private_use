local T, C, L, G = unpack(select(2, ...))
local addon_name = G.addon_name

local enable_tags = {
	rl		 = { tag = L["RL加载"], 		tip = L["RL加载tip"]},
	spell 	 = { tag = L["技能分配加载"], 	tip = L["技能分配加载tip"]},
}

local sound_suffix = {
	["SPELL_AURA_APPLIED"] = {"aura", L["获得光环音效"]},
	["SPELL_AURA_REMOVED"] = {"auralose", L["移除光环音效"]},
	["SPELL_AURA_APPLIED_DOSE"] = {"stack", L["层数增加音效"]},
	["SPELL_CAST_START"] = {"cast", L["开始施法音效"]},
	["SPELL_CAST_SUCCESS"] = {"succeed", L["施法成功音效"]},
	["SPELL_SUMMON"] = {"summon", L["召唤小怪音效"]},
	["SPELL_DAMAGE"] = {"dmg", L["伤害音效"]},
}
G.sound_suffix = sound_suffix

local PhaseTriggerEvents  = {
	["SPELL_AURA_APPLIED"] = L["获得光环"],
	["SPELL_AURA_REMOVED"] = L["移除光环"],
	["SPELL_AURA_APPLIED_DOSE"] = L["光环堆叠"],	
	["SPELL_CAST_START"] = L["开始施法"],
	["SPELL_CAST_SUCCESS"] = L["施法成功"],
	["SPELL_INTERRUPT"] = L["施法打断"],
}

--====================================================--
--[[                   -- API --                    ]]--
--====================================================--
-- 声音预览按钮
local CreateSoundPreviewButton = function(button, sound, points)
	local sound_description = ""
	local file = string.match(sound, "%[(.+)%]") or sound
	local cd = string.match(sound, "cd(%d+)")
	local stack = string.find(sound, "stack")
	local cap, stacksfx 
	
	if cd then
		sound_description = sound_description.." "..string.format(L["倒数"], cd)
	elseif stack then	
		local more = string.match(sound, "stackmore(%d+)")
		local less = string.match(sound, "stackless(%d+)")
		local stacksfx = string.find(sound, "stacksfx")
		if more then
			sound_description = sound_description.." "..string.format(L["层数大于"], more)
			cap = tonumber(more)
		elseif less then
			sound_description = sound_description.." "..string.format(L["层数小于"], less)
			cap = tonumber(less)
		elseif stacksfx then 
			sound_description = sound_description.." "..L["层数变化"]
		end
	end
	
	local bu = CreateFrame("Button", nil, button)	
	bu:SetSize(20, 20)
	bu:SetPoint(unpack(points))
	
	bu.text = T.createtext(bu, "OVERLAY", 14, "OUTLINE", "LEFT")
	bu.text:SetPoint("LEFT", bu, "RIGHT", 0, 0)
	bu.text:SetText(sound_description)
	
	bu:SetNormalTexture("chatframe-button-icon-voicechat")
	bu:GetNormalTexture():SetDesaturated(true)
	bu:GetNormalTexture():SetVertexColor(1, 1, 1)
	bu:SetHighlightTexture("chatframe-button-icon-voicechat")
	bu:GetHighlightTexture():SetDesaturated(true)
	bu:GetHighlightTexture():SetVertexColor(1, .82, 0)
	
	bu:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
		GameTooltip:AddLine(PREVIEW)
		GameTooltip:Show()
	end)
	
	bu:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	bu:SetScript("OnClick", function(self)
		if file then
			T.PlaySound(file)
			if cd then
				C_Timer.After(1.5, function()
					local countdown = tonumber(cd)
					T.StartCountDown(nil, GetTime()+countdown, countdown)
				end)
			elseif stack then
				if cap then
					C_Timer.After(1.5, function()
						if cap <= 10 then
							T.PlaySound("count\\"..cap)
						else
							T.SpeakText(tostring(cap))
						end
					end)
				elseif stacksfx then
					C_Timer.After(1.5, function()
						T.PlaySound(stacksfx)
					end)
				end
			end
		elseif cd then
			local countdown = tonumber(cd)
			T.StartCountDown(nil, GetTime()+countdown, countdown)
		elseif stack then
			if cap then
				if cap <= 10 then
					T.PlaySound("count\\"..cap)
				else
					T.SpeakText(tostring(cap))
				end
			elseif stacksfx then
				T.PlaySound(stacksfx)
			end
		end
	end)
end

-- 隐藏滑动条
local function HideScorllBar(scrollframe)
	local scrollBar = scrollframe.ScrollBar
	scrollBar:SetAlpha(0)
	scrollBar:EnableMouse(false)
	
	scrollBar.ScrollDownButton:SetAlpha(0)
	scrollBar.ScrollDownButton:EnableMouse(false)
	
	scrollBar.ScrollUpButton:SetAlpha(0)
	scrollBar.ScrollUpButton:EnableMouse(false)
	
	scrollBar.ThumbTexture:SetAlpha(0)
	scrollBar.ThumbTexture:EnableMouse(false)
end
T.HideScorllBar = HideScorllBar

--====================================================--
--[[                -- 推荐设置 --                  ]]--
--====================================================--
local function AddRecommondTooltip(frame)
	frame:HookScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
		GameTooltip:AddLine(L["发送该配置给队友"])
		GameTooltip:Show()
	end)
	
	frame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
end

local link = "|cnIQ4:|HJSTR:%1$s:%2$s:%3$s:%4$s:%5$s|h[%4$s>%5$s]|h|r"

local function FormatPath(path)
	local str, matched, only_character
	str = T.PathToString(path)
	str, matched = gsub(str, "-<only_character>", "")
	only_character = matched > 0 and 1 or 0
	
	return str, only_character
end

local function RemoveStrFormat(text)
	text = text:gsub("|T[^|]+|t", "")	
	text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
	text = text:gsub("|r", "")
	text = text:gsub("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_[.]+:0|t", "")
	text = text:gsub(string.format(L["使用标记%s"], ""), "")
	text = text:gsub(" >", ">")
	text = text:gsub("[\(](.+)[\)]", "")
	
	return text
end

-- 推荐设置
local function RecommondOptions(path, value, text, value_text)
	if not UnitInAnyGroup("player") then
		T.msg(L["不在队伍中"])
		return
	end
	
	local path_str, only_character = FormatPath(path)
	local value_str = T.ValueToString(value)
	local description = RemoveStrFormat(text)	
	local value_msg = value_text and gsub(value_text, "[\(](.+)[\)]", "") or T.ValueToMsg(value)
	local str = string.format(link, path_str, only_character, value_str, description, value_msg)
	
	T.addon_msg(string.format("Rec,%s", str), "GROUP")
end

local function FilterRecommond(event, ...)
	local channel, sender, GUID, message, str = ...
	if message == "Rec" and str then
		local name = T.GetNameByGUID(GUID)
		T.msg(name .."-".. str)
	end
end

T.RegisterCallback("ADDON_MSG", FilterRecommond)

hooksecurefunc("SetItemRef", function(link)
	if link:find("JSTR") then
		local _, path_str, only_character, value_str, description, value_msg = string.split(":", link)	
		StaticPopupDialogs[addon_name.."Accept Settings Confirm"].text = string.format(L["确认载入推荐设置"], description, value_msg)
		StaticPopupDialogs[addon_name.."Accept Settings Confirm"].OnAccept = function()
			local path = T.StringToPath(path_str)
			local value = T.StringToValue(value_str)
			
			if tonumber(only_character) == 1 then
				T.ValueToPath(JST_CDB, path, value)
			else
				T.ValueToDB(path, value)
			end
			
			T.msg(string.format(L["配置已载入"], description, value_msg))
			
			local GUI = G.GUI
			local detailFrame = G.detailFrame -- 刷新
			
			local show_GUI = GUI:IsShown()
			local show_detail = detailFrame:IsShown()
			
			if show_GUI then
				GUI:Hide()
				GUI:Show()
			end
			
			if show_detail then
				detailFrame:Hide()
				detailFrame:Show()
			end			
		end
		StaticPopup_Show(addon_name.."Accept Settings Confirm")
	end
end)

--====================================================--
--[[                -- 依赖关系 --                  ]]--
--====================================================--
-- 启用依赖关系
local createDR = function(parent, ...)
	for i=1, select("#", ...) do
		local object = select(i, ...)
		parent:HookScript("OnShow", function(self)
			if self:GetChecked() and self:IsEnabled() then
				if object.Enable then
					object:Enable()
				end
			else
				if object.Disable then
					object:Disable()
				end
			end
		end)
		parent:HookScript("OnClick", function(self)
			if self:GetChecked() and self:IsEnabled() then
				if object.Enable then
					object:Enable()
				end
			else
				if object.Disable then
					object:Disable()
				end
			end
		end)		
		parent:HookScript("OnEnable", function(self)
			if self:GetChecked() and self:IsEnabled() then
				if object.Enable then
					object:Enable()
				end
			else
				if object.Disable then
					object:Disable()
				end
			end
		end)
		parent:HookScript("OnDisable", function()
			if object.Disable then
				object:Disable()
			end
		end)
	end
end

-- 显示依赖关系
local createVisibleDR = function(func, parent, ...)
	local children = {...}
	
	parent:HookScript("OnShow", function(self)
		if func() then
			for _, object in pairs(children) do
				object:Show()
			end
		else
			for _, object in pairs(children) do
				object:Hide()
			end
		end
	end)
	
	local oldfunc = parent.visible_apply	
	parent.visible_apply = function()
		if oldfunc then
			oldfunc()
		end
		if func() then
			for _, object in pairs(children) do
				object:Show()
			end
		else
			for _, object in pairs(children) do
				object:Hide()
			end
		end
	end
end

--====================================================--
--[[              -- GUI 选项排列 --                ]]--
--====================================================--
local SetGUIPoint = function(parent, width_perc, obj, before_gap, after_gap, x, y)
	local width = parent:GetWidth()
	local line_height = 30
	
	parent.option_x = parent.option_x or 0
	parent.option_y = parent.option_y or 0
	
	if before_gap then -- 与上一项之间的行间距
		parent.option_y = parent.option_y + before_gap
	end
	
	if obj.istitle then
		local line = parent:CreateTexture(nil, "BACKGROUND")
		line:SetTexture(G.media.blank)
		line:SetGradient("HORIZONTAL", CreateColor(1, .82, 0, .8), CreateColor(0, 0, 0, 0))
		line:SetSize(parent:GetWidth(), 1)
		line:SetPoint("TOPLEFT", obj, "BOTTOMLEFT", -40, -5)
		
		local bgtex = parent:CreateTexture(nil, "BACKGROUND")
		bgtex:SetTexture(G.media.blank)
		bgtex:SetColorTexture(0, 0, 0, .5)
		bgtex:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, 0)
		
		parent.bgtex = bgtex
	end
	
	local obj_type = obj:GetObjectType()
	local x_off, y_off = 0, 0
	
	if obj_type == "Slider" then
		x_off = 196
		y_off = 5
	elseif obj.dd then
		y_off = -8
	end
	
	if parent.option_x + width_perc*width > width then -- 需要换行
		obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 10 + x_off + (x or 0), - parent.option_y - line_height + y_off + (y or 0))
		
		-- 下一项的锚点
		parent.option_x = width_perc*width
		parent.option_y = parent.option_y + math.ceil(width_perc)*line_height
		
		if not obj.istitle and parent.bgtex then
			parent.bgtex:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, - parent.option_y - line_height - 10)
		end
				
		if after_gap then -- 与下一项之间的行间距
			parent.option_y = parent.option_y + after_gap
		end
	else
		obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 10 + x_off + (x or 0) + parent.option_x, - parent.option_y + y_off + (y or 0))
		
		-- 下一项的锚点
		parent.option_x = parent.option_x + width_perc*width
	end
end

local iconnum_per_line = 10
local SetIconButtonPoint = function(parent, category, bu)
	local x = 10 + mod(parent[category.."IconNum"], iconnum_per_line)*75
	local y = - parent[category.."option_y"]
	
	bu:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)		
	
	parent[category.."IconNum"] = parent[category.."IconNum"] + 1
end

--====================================================--
--[[             -- 标题/描述/分割线 --             ]]--
--====================================================--
local function CreateGUITitle(parent, text)
	local fs = T.createtext(parent, "OVERLAY", 14, "OUTLINE", "LEFT")
	fs:SetText(text or " ")	
	fs:SetTextColor(1, .82, 0)
	fs.istitle = true
	return fs
end

local function CreateGUIDesciption(parent, text, ficon)
	local str = ficon and T.GetFlagIconStr(ficon, false) or ""
	local fs = T.createtext(parent, "OVERLAY", 14, "OUTLINE", "LEFT")
	fs:SetWidth(parent:GetWidth()-40)
	fs:SetText(str..(text or " "))
	return fs
end

--====================================================--
--[[                -- 普通按钮 --                ]]--
--====================================================--
local ClickButton = function(parent, width, points, text, tip)
	local bu = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	
	if points then
		bu:SetPoint(unpack(points))
	end
	
	bu.Text:SetFont(G.Font, 14, "OUTLINE")
	bu:SetText(text or "")
	
	if width == 0 then
		bu:SetSize(bu.Text:GetWidth() + 5, 25)
	else
		bu:SetSize(width, 25)
	end

	if tip then
		bu:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT",  -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		bu:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	return bu
end
T.ClickButton = ClickButton

local ClickButton_DB = function(parent, path)
	local info = T.GetOptionInfo(path)
	local frame = ClickButton(parent, info.bu_width or 150, nil, info.text, info.tip)
		
	frame:SetScript("OnClick", function(self)
		if info.apply then info.apply(self) end
	end)
	
	return frame
end

local CreateAddtionalMarkDropdownforMrtCopy = function(parent)
	local option_table = {
		{"", L["忽略标记"]},
	}
	for i = 1, 8 do
		table.insert(option_table, {"{rt"..i.."}", T.FormatRaidMark(i)})
	end
	
	local frame = T.UIDropDownMenuFrame(parent, "", {"LEFT", parent, "RIGHT", -5, 0})
	frame.dd:SetPoint("LEFT", frame, "LEFT", -5, -2)
	UIDropDownMenu_SetWidth(frame.dd, 90)
	
	local function DD_UpdateChecked(self, arg1)
		return (UIDropDownMenu_GetSelectedValue(frame.dd) == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)

	T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, "")
	
	parent.rt_dd = frame.dd
end

local CreateAddtionalNumDropdownforMrtCopy = function(parent)
	local option_table = {}
	for i = 2, 5 do
		table.insert(option_table, {i, string.format(L["MRT循环次数%d"], i)})
	end
	
	local frame = T.UIDropDownMenuFrame(parent, "", {"LEFT", parent.rt_dd, "RIGHT", -5, 0})
	frame.dd:SetPoint("LEFT", frame, "LEFT", -20, 0)
	UIDropDownMenu_SetWidth(frame.dd, 90)
	
	local function DD_UpdateChecked(self, arg1)
		return (UIDropDownMenu_GetSelectedValue(frame.dd) == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, 3)

	parent.num_dd = frame.dd
end

local CreateAddtionalBackupCheckforMrtCopy = function(parent)
	local bu = T.Checkbutton(parent, L["替补"])
	bu:SetPoint("LEFT", parent.num_dd, "RIGHT", -15, 2)
	
	parent.backup_check = bu
end

local ClickButton_Detail_DB = function(info, key_path, button, alert)
	local detailFrame = G.detailFrame
	local frame = ClickButton(detailFrame, 150, nil, info.text)
	
	if info.key == "copy_interrupt_btn" then
		CreateAddtionalMarkDropdownforMrtCopy(frame)
		CreateAddtionalNumDropdownforMrtCopy(frame)
		CreateAddtionalBackupCheckforMrtCopy(frame)
		
		info.onclick = function()
			local rt = UIDropDownMenu_GetSelectedValue(frame.rt_dd)
			local num = UIDropDownMenu_GetSelectedValue(frame.num_dd)
			local backup = frame.backup_check:GetChecked()
			local str = T.GetInterruptStr(info.mobID, info.spellID, rt, num, backup)
			T.DisplayCopyString(frame, str)
		end
	end
	
	frame:SetScript("OnClick", function(self)
		if info.onclick then 
			info.onclick(alert, button, self)
		end
	end)
	
	table.insert(detailFrame.options, frame)
	
	return frame
end

--====================================================--
--[[                 -- 勾选按钮 --                 ]]--
--====================================================--
local Checkbutton = function(parent, text)
	local bu = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	bu:SetHitRectInsets(0, -50, 0, 0)
	
	bu.Text:SetFont(G.Font, 14, "OUTLINE")
	bu.Text:SetText(text)
	bu.Text:SetTextColor(1, 1, 1)
	bu.Text:SetJustifyH("LEFT")
	
	bu:SetScript("OnDisable", function(self)
		bu.Text:SetTextColor(.5, .5, .5)
	end)
	
	bu:SetScript("OnEnable", function(self)
		bu.Text:SetTextColor(1, 1, 1)
	end)
	
	return bu
end
T.Checkbutton = Checkbutton

local Checkbutton_DB = function(parent, path, category_text)
	local info = T.GetOptionInfo(path)
	local bu = Checkbutton(parent, info.text)	
	
	AddRecommondTooltip(bu)
	
	bu:SetScript("OnShow", function(self)
		self:SetChecked(T.ValueFromDB(path))
	end)
	
	bu:SetScript("OnClick", function(self)
		if not IsLeftShiftKeyDown() and not IsRightShiftKeyDown() then
			local value = self:GetChecked()
			if ( value ) then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			else
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			end
			T.ValueToDB(path, value)
			if info.apply then info.apply() end
		else
			local value = T.ValueFromDB(path)
			self:SetChecked(value)
			
			local arg1 = category_text
			local arg2 = info.text
			RecommondOptions(path, value, string.format("%s>%s", arg1, arg2))
		end
	end)

	return bu
end
T.Checkbutton_DB = Checkbutton_DB

local Checkbutton_Detail_DB = function(info, key_path, button, alert)
	local detailFrame = G.detailFrame
	local bu = Checkbutton(detailFrame, info.text)
	
	AddRecommondTooltip(bu)
	
	bu:SetScript("OnShow", function(self)
		self:SetChecked(T.ValueFromDB(key_path))
	end)
	
	bu:SetScript("OnClick", function(self)
		if not IsLeftShiftKeyDown() and not IsRightShiftKeyDown() then
			local value = self:GetChecked()
			if ( value ) then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			else
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			end
			T.ValueToDB(key_path, value)
			if info.apply then
				info.apply(value, alert, button)
			end
		else
			local value = T.ValueFromDB(key_path)
			self:SetChecked(value)
			
			local arg1 = button.Text:GetText()
			local arg2 = info.text
			RecommondOptions(key_path, value, string.format("%s>%s", arg1, arg2))
		end
	end)
	
	table.insert(detailFrame.options, bu)
	
	if info.sound then
		CreateSoundPreviewButton(bu, info.sound, {"LEFT", bu.Text, "RIGHT", 10, 0})
	end
	
	return bu
end

local CreateTagFrame = function(bu, enable_tag, ficon)
	local tag = enable_tag and enable_tags[enable_tag] and enable_tags[enable_tag].tag or ""
	local tip = enable_tag and enable_tags[enable_tag] and enable_tags[enable_tag].tip
	local ficon = ficon and T.GetFlagIconStr(ficon) or ""
	
	local frame = CreateFrame("Frame", nil, bu)
	frame:SetPoint("RIGHT", bu, "LEFT", 0, 0)	
	frame:SetSize(80,30)
	
	frame.text = T.createtext(bu, "OVERLAY", 14, "OUTLINE", "RIGHT")
	frame.text:SetPoint("RIGHT", frame, "RIGHT", 0, 0)	
	frame.text:SetText(tag..ficon)
	
	if tip then
		frame:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT",  -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		frame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
end

local Checkbutton_Encounter_DB = function(parent, path, text, enable_tag, ficon)
	local bu = Checkbutton(parent, text)
	bu.Text:SetWidth(600)
	
	CreateTagFrame(bu, enable_tag, ficon)	
	SetGUIPoint(parent, 1, bu, nil, nil, 80)
	AddRecommondTooltip(bu)
	
	bu:SetScript("OnShow", function(self)
		self:SetChecked(T.ValueFromDB(path))
	end)
	
	bu:SetScript("OnClick", function(self)
		if not IsLeftShiftKeyDown() and not IsRightShiftKeyDown() then
			local value = self:GetChecked()
			if ( value ) then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			else
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			end
			T.ValueToDB(path, value)
			if self.apply then self.apply() end
		else
			local value = T.ValueFromDB(path)
			self:SetChecked(value)
			
			local arg1 = parent.title:GetText()
			local arg2 = text
			RecommondOptions(path, value, string.format("%s>%s", arg1, arg2))
		end
	end)
	
	return bu
end

--====================================================--
--[[                 -- 输入框 --                   ]]--
--====================================================--
local EditboxWithButton = function(parent, width, points, tip)	
	local box = CreateFrame("EditBox", nil, parent)
	if points then
		box:SetPoint(unpack(points))
	end
	
	box:SetSize(width or 200, 20)	
	T.createborder(box)

	box:SetFont(G.Font, 14, "OUTLINE")
	box:SetAutoFocus(false)
	box:SetTextInsets(3, 0, 0, 0)

	box.button = ClickButton(box, 0, {"RIGHT", box, "RIGHT", -2, 0}, OKAY)
	box.button:Hide()
	box.button:SetScript("OnClick", function()
		if box:GetScript("OnEnterPressed") then
			box:GetScript("OnEnterPressed")(box)
		end
	end)
	
	box:SetScript("OnChar", function(self)
		self.button:Show()
		self.sd:SetBackdropBorderColor(1, 1, 0)
	end)
	
	box:SetScript("OnEditFocusGained", function(self)
		self.sd:SetBackdropBorderColor(1, 1, 1)
	end)
	
	box:SetScript("OnEditFocusLost", function(self)
		self.sd:SetBackdropBorderColor(0, 0, 0)
	end)
	
	box:SetScript("OnHide", function(self) 
		self.button:Hide()
	end)

	if tip then
		box:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		box:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	box:SetScript("OnEnable", function(self)
		self:SetTextColor(1, 1, 1, 1)
	end)
	
	box:SetScript("OnDisable", function(self)
		self:SetTextColor(0.7, 0.7, 0.7, 0.5)
	end)

	return box
end

-- 带标题的输入框组合
local EditFrame = function(parent, width, text, points, tip)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(20, 20)
	if points then
		frame:SetPoint(unpack(points))
	end
	
	local name = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	name:SetPoint("LEFT", frame, "LEFT", 0, 0)
	name:SetText(text or "")	
	frame.name = name
	
	local box = EditboxWithButton(frame, width, {"LEFT", frame, "LEFT", 100, 0}, tip)
	frame.box = box
	
	return frame
end
T.EditFrame = EditFrame

--====================================================--
--[[                 -- 滑动条 --                   ]]--
--====================================================--
local SliderWithValueText = function(parent, name, points, min, max, step, tip, button)
	local slider = CreateFrame("Slider", name and (addon_name..name.."MiniSlider"), parent, "MinimalSliderTemplate")
	slider:SetSize(120, 12)
	if points then
		slider:SetPoint(unpack(points))
	end
	
	slider.Text = T.createtext(slider, "OVERLAY", 10, "OUTLINE")
	slider.Text:SetPoint("LEFT", slider, "RIGHT", -5, 0)

	slider:SetMinMaxValues(min, max)
	slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(true)
	
	if button then
		slider.button = ClickButton(slider, 50, {"LEFT", slider, "RIGHT", 30, 0}, APPLY)
		slider.button:Hide()
		
		slider:SetScript("OnHide", function(self)
			self.button:Hide()
		end)
	end
	
	slider.Enable = function()		
		slider:SetEnabled(true)
		slider.Text:SetTextColor(1, 1, 1, 1)
		slider.Thumb:Show()
	end
	
	slider.Disable = function()
		slider:SetEnabled(false)
		slider.Text:SetTextColor(0.7, 0.7, 0.7, 0.5)
		slider.Thumb:Hide()
		if slider.button then
			slider.button:Hide()
		end
	end
	
	if tip then
		slider:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		slider:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	return slider
end
T.SliderWithValueText = SliderWithValueText

local SliderWithSteppers = function(parent, text, points, min, max, step, tip, button)
	local frame = CreateFrame("Slider", nil, parent, "MinimalSliderWithSteppersTemplate")
	frame:SetWidth(180)
	if points then
		frame:SetPoint(unpack(points))
	end
	
	frame.LeftText:SetFont(G.Font, 14, "OUTLINE")
	frame.LeftText:ClearAllPoints()
	frame.LeftText:SetPoint("LEFT", frame.Slider, "LEFT", -215, 0)
	frame.LeftText:SetJustifyH("LEFT")
	frame.LeftText:SetText(text)
	frame.LeftText:SetTextColor(1, 1, 1, 1)
	frame.LeftText:Show()
	
	frame.RightText:SetFont(G.Font, 14, "OUTLINE")
	frame.RightText:ClearAllPoints()
	frame.RightText:SetPoint("LEFT", frame.Slider, "RIGHT", 15, 0)
	frame.RightText:SetTextColor(1, 1, 1, 1)
	frame.RightText:Show()

	frame.Slider:SetMinMaxValues(min, max)
	frame.Slider:SetValueStep(step)
	frame.Slider:SetObeyStepOnDrag(true)
	
	frame.Enable = function()
		frame.Slider:SetEnabled(true)
		frame.Slider.Thumb:Show()
		frame.Back:Enable()
		frame.Forward:Enable()
		frame.LeftText:SetTextColor(1, 1, 1, 1)
		frame.RightText:SetTextColor(1, 1, 1, 1)
	end
	
	frame.Disable = function()
		frame.Slider:SetEnabled(false)
		frame.Slider.Thumb:Hide()
		frame.Back:Disable()
		frame.Forward:Disable()
		frame.LeftText:SetTextColor(0.7, 0.7, 0.7, 0.5)
		frame.RightText:SetTextColor(0.7, 0.7, 0.7, 0.5)
		if button then
			frame.button:Hide()
		end
	end
	
	if tip then
		frame:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, 10)
			GameTooltip:AddLine(tip)
			GameTooltip:Show() 
		end)
		frame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	if button then
		frame.button = ClickButton(frame, 50, {"LEFT", frame, "RIGHT", 30, 0}, APPLY)
		frame:SetScript("OnHide", function(self)
			self.button:Hide()
		end)
	end
	
	return frame
end

local Slider_DB = function(parent, path, category_text)
	local info = T.GetOptionInfo(path)
	local multipler = (info.min < 1 and info.min > 0 and 100) or 1

	local frame = SliderWithSteppers(parent, info.text, nil, info.min*multipler, info.max*multipler, info.step*multipler, info.tip)
	
	AddRecommondTooltip(frame.Slider)
	
	frame.Slider:SetScript("OnShow", function(self)		
		local value = T.ValueFromDB(path)
		self:SetValue(value*multipler)
		frame.RightText:SetText(floor(value*multipler)..((multipler == 100 and "%") or ""))
	end)
	
	frame.Slider:HookScript("OnMouseDown", function(self)
		if IsLeftShiftKeyDown() or IsRightShiftKeyDown() then
			local value = T.ValueFromDB(path)
			local arg1 = category_text
			local arg2 = info.text
			RecommondOptions(path, value, string.format("%s>%s", arg1, arg2))
		end
	end)
	
	frame.Slider:SetScript("OnValueChanged", function(self, getvalue)
		if getvalue ~= self.old_value then
			T.ValueToDB(path, getvalue/multipler)
			frame.RightText:SetText(getvalue..((multipler == 100 and "%") or ""))
			if info.apply then
				info.apply()
			end
			self.old_value = getvalue
		end
	end)
	
	return frame
end

local Slider_Detail_DB = function(info, key_path, button, alert)
	local detailFrame = G.detailFrame
	local frame = SliderWithSteppers(detailFrame, info.text, nil, info.min, info.max, 1)
	
	AddRecommondTooltip(frame.Slider)
	
	frame.Slider:SetScript("OnShow", function(self)
		local value = T.ValueFromDB(key_path)
		self:SetValue(value)
		if info.div then
			frame.RightText:SetText(value/info.div)
		else
			frame.RightText:SetText(value)
		end
	end)
	
	frame.Slider:HookScript("OnMouseDown", function(self)
		if IsLeftShiftKeyDown() or IsRightShiftKeyDown() then
			local value = T.ValueFromDB(key_path)
			local arg1 = button.Text:GetText()
			local arg2 = info.text
			RecommondOptions(key_path, value, string.format("%s>%s", arg1, arg2))
		end
	end)
	
	frame.Slider:SetScript("OnValueChanged", function(self, getvalue, userInput)
		if getvalue ~= self.old_value then
			T.ValueToDB(key_path, getvalue)
			if info.div then
				frame.RightText:SetText(getvalue/info.div)
			else
				frame.RightText:SetText(getvalue)
			end
			if info.apply then
				info.apply(getvalue, alert, button)
			end
			self.old_value = getvalue
		end
	end)
	
	table.insert(detailFrame.options, frame)
	
	return frame
end

--====================================================--
--[[                 -- 下拉菜单 --                 ]]--
--====================================================--
local UIDropDownMenu_SetSelectedValueText = function(dd, t, value)
	UIDropDownMenu_SetSelectedValue(dd, value)
	for i, info in pairs(t) do
		if info[1] == value then
			UIDropDownMenu_SetText(dd, info[2])
			break
		end
	end
end
T.UIDropDownMenu_SetSelectedValueText = UIDropDownMenu_SetSelectedValueText

local UIDropDownMenuFrame = function(parent, text, points)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(20, 20)
	
	if points then
		frame:SetPoint(unpack(points))
	end
	
	local name = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT")
	name:SetPoint("LEFT", frame, "LEFT", 0, 0)
	name:SetTextColor(1, 1, 1)
	name:SetText(text or "")
	frame.name = name
	
	local dd = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
	dd:SetPoint("LEFT", frame, "LEFT", 185, 0)
	UIDropDownMenu_SetWidth(dd, 180)
	
	dd.Text:SetFont(G.Font, 14, "OUTLINE")
	dd.Text:SetPoint("RIGHT", dd.Right, "RIGHT", -40, 0)	
	
	frame.dd = dd

	frame.Enable = function()
		frame.name:SetTextColor(1, 1, 1)
		UIDropDownMenu_EnableDropDown(frame.dd)
	end
	
	frame.Disable = function()
		frame.name:SetTextColor(.5, .5, .5)
		UIDropDownMenu_DisableDropDown(frame.dd)
	end
	
	return frame
end
T.UIDropDownMenuFrame = UIDropDownMenuFrame

local UIDropDownMenuFrame_DB = function(parent, path, category_text)
	local info = T.GetOptionInfo(path)
	local option_table = info.option_table
	local frame = UIDropDownMenuFrame(parent, info.text)
	
	AddRecommondTooltip(frame.dd)
	
	local function DD_UpdateChecked(self, arg1)
		local value = T.ValueFromDB(path)
		return value == arg1
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.ValueToDB(path, arg1)
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
		if info.apply then info.apply() end
		if frame.visible_apply then frame.visible_apply() end
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	frame:SetScript("OnShow", function()
		local value = T.ValueFromDB(path)
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, value)
	end)
	
	frame.dd:HookScript("OnMouseDown", function(self)
		if IsLeftShiftKeyDown() or IsRightShiftKeyDown() then
			local value = T.ValueFromDB(path)
			local value_str = self.Text:GetText()
			local arg1 = category_text
			local arg2 = info.text
			RecommondOptions(path, value, string.format("%s>%s", arg1, arg2), value_str)
		end
	end)
	
	return frame
end

local UIDropDownMenuFrame_SettingOption = function(parent, path, category_text)
	local info = T.GetOptionInfo(path)
	local option_table = info.option_table
	local frame = UIDropDownMenuFrame(parent, info.text)
	
	AddRecommondTooltip(frame.dd)
	
	local function DD_UpdateChecked(self, arg1)
		local value = T.ValueFromPath(JST_CDB, path)
		return (value == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.ValueToPath(JST_CDB, path, arg1)
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
		if info.apply then info.apply() end
		if frame.visible_apply then frame.visible_apply() end
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	frame:SetScript("OnShow", function()
		local value = T.ValueFromPath(JST_CDB, path)
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, value)
	end)
	
	frame.dd:HookScript("OnMouseDown", function(self)
		if IsLeftShiftKeyDown() or IsRightShiftKeyDown() then
			local value = T.ValueFromPath(JST_CDB, path)
			local value_str = self.Text:GetText()
			
			local new_path = CopyTable(path)
			table.insert(new_path, "<only_character>")
			
			local arg1 = category_text
			local arg2 = info.text
			RecommondOptions(new_path, value, string.format("%s>%s", arg1, arg2), value_str)
		end
	end)
	
	return frame
end

local UIDropDownMenuFrame_Detail_DB = function(info, key_path, button, alert)
	local detailFrame = G.detailFrame
	local option_table = info.key_table
	local frame = UIDropDownMenuFrame(detailFrame, info.text)
	
	AddRecommondTooltip(frame.dd)
	
	local function DD_UpdateChecked(self, arg1)
		return (T.ValueFromDB(key_path) == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.ValueToDB(key_path, arg1)
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
		if info.apply then
			info.apply(arg1, alert, button)
		end
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	frame:SetScript("OnShow", function()
		UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, T.ValueFromDB(key_path))		
	end)
	
	frame.dd:HookScript("OnMouseDown", function(self)
		if IsLeftShiftKeyDown() or IsRightShiftKeyDown() then
			local value = T.ValueFromDB(key_path)
			local value_str = self.Text:GetText()
			
			local arg1 = button.Text:GetText()
			local arg2 = info.text
			RecommondOptions(key_path, value, string.format("%s>%s", arg1, arg2), value_str)
		end
	end)
	
	table.insert(detailFrame.options, frame)
	
	return frame
end

--====================================================--
--[[                 -- 取色按钮 --                 ]]--
--====================================================--
local ColorPicker_OnClick = function(color_old, apply, points)
	ColorPickerFrame:ClearAllPoints()
	if points then
		ColorPickerFrame:SetPoint(unpack(points))
	else
		ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER")
	end
	
	ColorPickerFrame.previousValues = {r = color_old.r, g = color_old.g, b = color_old.b, opacity = color_old.a}
	
	ColorPickerFrame.swatchFunc = function()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		apply(r, g, b)
	end
	
	ColorPickerFrame.cancelFunc = function()
		apply(color_old.r, color_old.g, color_old.b)
	end
	
	ColorPickerFrame.Content.ColorPicker:SetColorRGB(color_old.r, color_old.g, color_old.b)
	ColorPickerFrame:Hide()
	ColorPickerFrame:Show()
end

local ColorpickerButton = function(parent, text, points)
	local cpb = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	cpb:SetSize(20, 20)
	
	if points then
		cpb:SetPoint(unpack(points))
	end

	cpb.ctex = cpb:CreateTexture(nil, "OVERLAY")
	cpb.ctex:SetTexture(G.media.blank)
	cpb.ctex:SetPoint"CENTER"
	cpb.ctex:SetSize(15, 15)

	cpb.name = T.createtext(cpb, "OVERLAY", 14, "OUTLINE", "LEFT")
	cpb.name:SetPoint("LEFT", cpb, "RIGHT", 10, 1)
	cpb.name:SetText(text or "")

	return cpb
end

local ColorpickerButton_DB = function(parent, path)
	local info = T.GetOptionInfo(path)
	local cpb = ColorpickerButton(parent, info.text)
	
	cpb:SetScript("OnShow", function(self)
		local color = T.ValueFromDB(path)
		self.ctex:SetVertexColor(color.r, color.g, color.b)	
	end)
	
	cpb:SetScript("OnClick", function(self)
		local color = T.ValueFromDB(path)
		ColorPicker_OnClick(color, function(r, g, b)
			self.ctex:SetVertexColor(r, g, b)
			T.ValueToDB(path, {r = r, g = g, b = b})
			if info.apply then
				info.apply()
			end
		end)
	end)
	
	return cpb
end

--====================================================--
--[[                 -- 空白占位 --                 ]]--
--====================================================--
local ClickButton_Detail_Blank = function()
	local detailFrame = G.detailFrame
	
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(20, 20)

	table.insert(detailFrame.options, frame)
	
	return frame
end

--====================================================--
--[[                  -- 设置页面 --                ]]--
--====================================================--
local GUITabs = {}

local CreateTabBase = function(index, title)
	local parent = GUITabs[index]
	
	local tab = CreateFrame("Button", nil, parent.sfa, "SelectableButtonTemplate")
	tab:SetSize(190, 30)
	
	tab.bg = tab:CreateTexture(nil, "BORDER")
	tab.bg:SetAllPoints()
	tab.bg:SetAtlas("ShipMission_FollowerListButton")
	tab.bg:SetAlpha(.8)
	
	tab.text = T.createtext(tab, "OVERLAY", 14, "OUTLINE", "LEFT")
	tab.text:SetText(title)
	tab.text:SetJustifyH("LEFT")
	tab.text:SetPoint("LEFT", tab, "LEFT", 5, 0)
	tab.text:SetSize(140, 14)
	
	return tab
end

-- 选项标签
local CreateFrameTab = function(index, collect_id, title)
	local parent = GUITabs[index]
	
	local tab = CreateTabBase(index, title)
	
	tab.selected_tex = tab:CreateTexture(nil, "OVERLAY")
	tab.selected_tex:SetAllPoints()
	tab.selected_tex:SetAtlas("ShipMission_FollowerListButton-Highlight") 
	tab.selected_tex:SetDesaturated(true)
	tab.selected_tex:SetVertexColor(1, .82, 0)
	tab.selected_tex:SetBlendMode("ADD")
	
	function tab:SetSelected(Selected)
		if Selected then
			self.text:SetTextColor(1, .82, 0)
			self.selected_tex:Show()
			self.bg:SetAlpha(.2)
			self.setting_page:Show()
			self.selected = true
			
			parent.selected_tab = self
		else
			self.text:SetTextColor(1, 1, 1)
			self.selected_tex:Hide()
			self.bg:SetAlpha(.8)
			self.setting_page:Hide()
			self.selected = false
		end
	end
	
	function tab:IsSelected()
		return self.selected
	end
	
	tab:SetScript("OnClick", function(self, button, down, slience)
		if not self:IsSelected() then
			for i, t in pairs(parent.tabs) do
				if t.children_tabs then
					for i, t in pairs(t.children_tabs) do
						t:SetSelected(false)
					end
				else
					t:SetSelected(false)
				end
			end
			self:SetSelected(true)
			if not slience then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			end
		end
	end)
	
	if collect_id then
		local collect_tab = parent.collect_tabs[collect_id]
		if collect_tab then
			table.insert(collect_tab.children_tabs, tab)
		end
	else
		table.insert(parent.tabs, tab)
		tab.sort_id = #parent.tabs
	end
	
	return tab
end

-- 标题标签
local CreateCollectTab = function(index, collect_id, title, texture)	
	local parent = GUITabs[index]
	
	local tab = CreateTabBase(index, title)
	tab.text:SetWidth(130)
	
	local img_tex = tab:CreateTexture(nil, "BACKGROUND")
	img_tex:SetPoint("TOPLEFT", 1, -1)
	img_tex:SetPoint("BOTTOMRIGHT", -1, 1)
	img_tex:SetTexture(texture)
	img_tex:SetTexCoord(0, 1, .4, .6)

	tab.collapsetex = tab:CreateTexture(nil, "OVERLAY")
	tab.collapsetex:SetSize(20, 20)
	tab.collapsetex:SetPoint("RIGHT", tab, "RIGHT", -2, 0)
	tab.collapsetex:SetDesaturated(true)
	
	function tab:Collepse()
		self.collapsetex:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand")
		self.text:SetTextColor(1, 1, 1)
		self.collapse = true
	end
	
	function tab:Expand()
		self.collapsetex:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse")
		self.text:SetTextColor(1, .82, 0)
		self.collapse = false
	end
	
	function tab:IsCollapse()
		return self.collapse
	end
	
	tab:Collepse()
	tab.children_tabs = {}
	
	tab:SetScript("OnClick", function(self, button, down, slience)
		if self:IsCollapse() then
			self:Expand()
		else
			self:Collepse()
		end
		parent:LineUpTabs()
		if not slience then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)
	
	tab.collect_id = collect_id
	parent.collect_tabs[collect_id] = tab
	
	table.insert(parent.tabs, tab)
end
T.CreateCollectTab = CreateCollectTab

-- GUI标签
local function CreateGUITab(index, text)
	local tab = CreateFrame("Button", nil, G.GUI_TabFrame, "SelectableButtonTemplate")
	tab:SetSize(150, 25)
	
	tab.Middle = tab:CreateTexture(nil, "BORDER")
	tab.Middle:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	tab.Middle:SetSize(120, 30)
	tab.Middle:SetPoint("BOTTOM", tab, "BOTTOM", 0, 2)
	tab.Middle:SetTexCoord(0.15625, 0.84375, 0, 1.0)
	
	tab.Left = tab:CreateTexture(nil, "BORDER")
	tab.Left:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	tab.Left:SetSize(20, 30)
	tab.Left:SetPoint("RIGHT", tab.Middle, "LEFT")
	tab.Left:SetTexCoord(0, 0.15625, 0, 1.0)

	tab.Right = tab:CreateTexture(nil, "BORDER")
	tab.Right:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	tab.Right:SetSize(20, 30)
	tab.Right:SetPoint("LEFT", tab.Middle, "RIGHT")
	tab.Right:SetTexCoord(0.84375, 1.0, 0, 1.0)
		
	tab.text = T.createtext(tab, "OVERLAY", 14, "OUTLINE", "CENTER")
	tab.text:SetPoint("CENTER")
	tab.text:SetText(text)
	
	tab.tabs = {}
	tab.collect_tabs = {}
	
	if index == 1 then
		tab:SetPoint("BOTTOMLEFT", G.GUI_TabFrame, "TOPLEFT", 10, 0)
	else
		tab:SetPoint("LEFT", GUITabs[index-1], "RIGHT", 0, 0)
	end
	
	function tab:LineUpTabs()
		local lastbutton
		
		table.sort(self.tabs, function(a, b)
			if a.collect_id and b.collect_id then
				return a.collect_id > b.collect_id
			elseif a.sort_id and b.sort_id then
				return a.sort_id < b.sort_id
			end
		end)
		
		for i, t in pairs(self.tabs) do
			if not lastbutton then
				t:SetPoint("TOP", self.sfa, "TOP", 0, -5)
			else
				t:SetPoint("TOP", lastbutton, "BOTTOM", 0, -5)
			end
			t:Show()
			lastbutton = t
			
			if t.children_tabs then
				if t:IsCollapse() then
					for i, sub_tab in pairs(t.children_tabs) do	
						sub_tab:Hide()
					end
				else
					for i, sub_tab in pairs(t.children_tabs) do
						sub_tab:SetPoint("TOP", lastbutton, "BOTTOM", 0, -5)
						sub_tab:Show()
						lastbutton = sub_tab
					end
				end		
			end
		end
	end
	
	tab:SetScript("PreClick", function()
		for _, t in pairs(GUITabs) do
			t:SetSelected(false)
			t.text:SetTextColor(1, 1, 1)
			t.sf:Hide()
			t.page:Hide()
		end
	end)
	
	tab:SetScript("OnClick", function(self, button, down, slience)
		if not self.selected_tab then		
			table.sort(self.tabs, function(a, b)
				if a.collect_id and b.collect_id then
					return a.collect_id > b.collect_id
				elseif a.sort_id and b.sort_id then
					return a.sort_id < b.sort_id
				end
			end)
			
			if self.tabs[1] then
				self.tabs[1]:GetScript("OnClick")(self.tabs[1], "LeftButton", false, true)
				if self.tabs[1]["children_tabs"] then
					self.tabs[1]["children_tabs"][1]:GetScript("OnClick")(self.tabs[1]["children_tabs"][1], "LeftButton", false, true)
				end
			end
		end
		if not slience then
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		end
		self:SetSelected(true)
		self.text:SetTextColor(1, .82, 0)
		self.sf:Show()
		self.page:Show()
		self:LineUpTabs()
	end)
	
	tab.sf = CreateFrame("ScrollFrame", addon_name.."tab"..index.."ScrollFrame", tab, "UIPanelScrollFrameTemplate")
	tab.sf:SetAllPoints(G.GUI_TabFrame)
	HideScorllBar(tab.sf)
	
	tab.sfa = CreateFrame("Frame", addon_name.."tab"..index.."ScrollAnchor", tab.sf)
	tab.sfa:SetPoint("TOPLEFT", tab.sf, "TOPLEFT", 0, 0)
	tab.sfa:SetWidth(tab.sf:GetWidth())
	tab.sfa:SetHeight(tab.sf:GetHeight())

	tab.sf:SetScrollChild(tab.sfa)

	tab.page = CreateFrame("Frame", nil, tab)
	tab.page:SetAllPoints(G.GUI_PageFrame)
	
	G.GUI:HookScript("OnShow", function()
		local selected
		for _, tab in pairs(GUITabs) do
			if tab:IsSelected() then
				selected = true
				return
			end
		end
		if not selected then
			GUITabs[1]:GetScript("OnClick")(GUITabs[1], "LeftButton", false, true)
		end
	end)
	
	GUITabs[index] = tab
end
T.CreateGUITab = CreateGUITab

-- 选项页面
local function CreateOptionPage(tab_type, collect_id, name, title)
	local frame = CreateFrame("Frame", addon_name..name.."OptionPage", GUITabs[tab_type].page)
	frame:SetAllPoints()
	
	local tab = CreateFrameTab(tab_type, collect_id, title)
	tab.setting_page = frame
	tab:SetSelected(false)
	
	frame.sf = CreateFrame("ScrollFrame", addon_name..name.."ScrollFrame", frame, "UIPanelScrollFrameTemplate")
	frame.sf:SetAllPoints()
	frame.sf:SetFrameLevel(frame:GetFrameLevel()+1)
	HideScorllBar(frame.sf)
	
	frame.sfa = CreateFrame("Frame", addon_name..name.."ScrollAnchor", frame.sf)
	frame.sfa:SetPoint("TOPLEFT", frame.sf, "TOPLEFT", 0, 0)
	frame.sfa:SetWidth(frame.sf:GetWidth())
	frame.sfa:SetHeight(frame.sf:GetHeight())
	frame.sfa:SetFrameLevel(frame.sf:GetFrameLevel()+1)
	
	frame.sf:SetScrollChild(frame.sfa)

	return frame
end
T.CreateOptionPage = CreateOptionPage

--====================================================--
--[[                -- 细节选项 --                  ]]--
--====================================================--
-- 刷新细节选项
local UpdateDetailFrame = function(button, path, description, detail_options, alert)
	local detailFrame = G.detailFrame
	
	if not button.detail_options then
		button.detail_options = {}
	end
	
	for i, info in pairs(detail_options) do
		local key_path = T.CopyTableInsertElement(path, info.key)
		if not button.detail_options[info.key] then
			local obj
			if string.find(info.key, "_sl") then	
				obj = Slider_Detail_DB(info, key_path, button, alert)
			elseif string.find(info.key, "_dd") then
				obj = UIDropDownMenuFrame_Detail_DB(info, key_path, button, alert)
			elseif string.find(info.key, "_bool") then				
				obj = Checkbutton_Detail_DB(info, key_path, button, alert)
			elseif string.find(info.key, "_btn") then
				obj = ClickButton_Detail_DB(info, key_path, button, alert)
			elseif string.find(info.key, "_blank") then
				obj = ClickButton_Detail_Blank()
			end
			button.detail_options[info.key] = obj
		end
	end
	
	for i, obj in pairs(detailFrame.options) do
		obj:Hide()
	end
	
	for key, obj in pairs(button.detail_options) do
		obj:Show()
	end
	
	detailFrame.sfa.option_y = 0
	detailFrame.sfa.option_x = 0
	
	for i, obj in pairs(detailFrame.options) do
		if obj:IsShown() then
			obj:ClearAllPoints()
			SetGUIPoint(detailFrame.sfa, .5, obj)
		end
	end
	
	detailFrame:SetHeight(detailFrame.sfa.option_y + 80)
	
	detailFrame.title:SetText(description)
	
	detailFrame.reset:SetScript("OnClick", function()
		for i, info in pairs(detail_options) do
			if not string.find(info.key, "_blank") then
				local key_path = T.CopyTableInsertElement(path, info.key)
				T.ValueToDB(key_path, info.default)
				if info.apply then
					info.apply(info.default, alert, button)
				end
			end
		end	
		detailFrame:Hide()
		detailFrame:Show()
	end)
	
	detailFrame:Show()
end

-- 细节选项按钮
local CreateDetailOptionButton = function(button, path, description, detail_options, alert)
	local detailFrame = G.detailFrame
	local bu = CreateFrame("Button", nil, button.cover or button)
	bu:SetSize(25, 25)
	if button.cover then
		bu:SetPoint("TOPRIGHT", button, "TOPRIGHT", 5, 5)
	else
		bu:SetPoint("LEFT", button, "LEFT", 780, 0)
	end
	
	bu:SetNormalTexture("GM-icon-settings")
	bu:GetNormalTexture():SetDesaturated(true)
	bu:GetNormalTexture():SetTexCoord( .2, .8, .2, .8)
	bu:GetNormalTexture():SetVertexColor(1, 1, 1)
	bu:SetHighlightTexture("GM-icon-settings")
	bu:GetHighlightTexture():SetDesaturated(true)
	bu:GetHighlightTexture():SetTexCoord( .2, .8, .2, .8)
	bu:GetHighlightTexture():SetVertexColor(1, .82, 0)

	bu:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
		GameTooltip:AddLine(SETTINGS)
		GameTooltip:Show()
	end)
	
	bu:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	bu:SetScript("OnClick", function(self)	
		if detailFrame.lastbutton == self then
			detailFrame:Hide()
		else
			detailFrame.lastbutton = self
			UpdateDetailFrame(button, path, description, detail_options, alert)
			self:SetScript("OnHide", function(self)
				if self == detailFrame.lastbutton then
					detailFrame:Hide()
				end
			end)
		end
	end)
	
	button.detail_bu = bu
end

--====================================================--
--[[              -- 给技能设置列表 --              ]]--
--====================================================--
-- 技能列表
local Support_spell_class = {
	PRIEST = {
		33206, -- 痛苦压制
		47788, -- 守护之魂
		73325, -- 信仰飞跃
	},
	DRUID = {
	    102342, -- 铁木树皮
	},
	SHAMAN = { 
		
	},
	PALADIN = {
		633, -- 圣疗术
		1022, -- 保护祝福
		6940, -- 牺牲祝福
		1044, -- 自由祝福	
	},
	WARRIOR = { 
		3411, -- 援护
	},
	MAGE = { 

	},
	WARLOCK = { 
		20707, -- 灵魂石
	},
	HUNTER = { 
		34477, -- 误导
	},
	ROGUE = { 
		57934, -- 嫁祸诀窍
	},
	DEATHKNIGHT = {
		
	},
	MONK = {
		116849, -- 作茧缚命
	},
	DEMONHUNTER = {
		
	},
	EVOKER = {
		370665, -- 营救
		357170, -- 时间膨胀
	},
}

local Support_spell_common = {

}

local My_Support_spells = {}

for i, spellID in pairs(Support_spell_class[G.myClass]) do
	table.insert(My_Support_spells, {spellID, T.GetIconLink(spellID)})
end
for i, spellID in pairs(Support_spell_common) do
	table.insert(My_Support_spells, {spellID, T.GetIconLink(spellID)})
end

local function FormatClassName(class, className)
	return string.format("|c%s%s|r", G.Ccolors[class]["colorStr"], className)
end

local function FormatSpecName(name, icon)
	return "|T"..icon..":12:12:0:0:64:64:4:60:4:60|t "..name
end

-- 专精列表
local SpecTable = {}

for classID = 1, GetNumClasses() do
	local className, class = GetClassInfo(classID)
	table.insert(SpecTable, {class, FormatClassName(class, className), spec = {}})
	
	for j = 1, GetNumSpecializationsForClassID(classID) do
		local id, name, _, icon  = GetSpecializationInfoForClassID(classID, j)
		table.insert(SpecTable[classID].spec, {id, FormatSpecName(name, icon)})
	end
end

local CreateSupportSpellDDFrame = function(parent, i)
	local frame = T.UIDropDownMenuFrame(parent, "")
	frame:SetWidth(95)
	
	frame.dd:SetPoint("LEFT", frame, "LEFT", 0, 0)
	UIDropDownMenu_SetWidth(frame.dd, 75)
	frame.dd.Text:SetWidth(65)
	
	if i == 1 then
		frame:SetPoint("TOPLEFT", parent, "TOPLEFT", -10, -10)
	else
		frame:SetPoint("LEFT", parent["dd_frame"..(i-1)], "RIGHT", 0, 0)
	end
	
	parent["dd_frame"..i] = frame
end
T.CreateSupportSpellDDFrame = CreateSupportSpellDDFrame

-- 轮次
local function UpdateSpellCountDD(self, max_count)
	UIDropDownMenu_Initialize(self.dd_frame1.dd, function(dd)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, max_count do
			dd_info.value = i
			dd_info.arg1 = i
			dd_info.text = string.format(L["第%d轮"], i)
			dd_info.checked = function(_, arg1)
				return (UIDropDownMenu_GetSelectedValue(dd) == arg1)
			end
			dd_info.func = function(_, arg1)
				UIDropDownMenu_SetSelectedValue(dd, i)
				UIDropDownMenu_SetText(dd, string.format(L["第%d轮"], i))
			end
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	UIDropDownMenu_SetSelectedValue(self.dd_frame1.dd, 1)
	UIDropDownMenu_SetText(self.dd_frame1.dd, string.format(L["第%d轮"], 1))
end
T.UpdateSpellCountDD = UpdateSpellCountDD

-- 序号
local function UpdateSpellIndexDD(self, max_count)
	UIDropDownMenu_Initialize(self.dd_frame2.dd, function(dd)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, max_count do
			dd_info.value = i
			dd_info.arg1 = i
			dd_info.text = string.format(L["%d号位"], i)
			dd_info.checked = function(_, arg1)
				return (UIDropDownMenu_GetSelectedValue(dd) == arg1)
			end
			dd_info.func = function(_, arg1)
				UIDropDownMenu_SetSelectedValue(dd, i)
				UIDropDownMenu_SetText(dd, string.format(L["%d号位"], i))
			end
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	UIDropDownMenu_SetSelectedValue(self.dd_frame2.dd, 1)
	UIDropDownMenu_SetText(self.dd_frame2.dd, string.format(L["%d号位"], 1))
end
T.UpdateSpellIndexDD = UpdateSpellIndexDD

-- 技能
local function UpdateSupportSpellDD(self)
	UIDropDownMenu_Initialize(self.dd_frame3.dd, function(dd)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i, spellInfo in pairs(My_Support_spells) do
			dd_info.value = spellInfo[1]
			dd_info.arg1 = spellInfo[1]
			dd_info.text = spellInfo[2]
			dd_info.checked = function(_, arg1)
				return (UIDropDownMenu_GetSelectedValue(dd) == arg1)
			end
			dd_info.func = function(_, arg1)
				UIDropDownMenu_SetSelectedValue(dd, spellInfo[1])
				UIDropDownMenu_SetText(dd, spellInfo[2])
			end
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	if My_Support_spells[1] then
		UIDropDownMenu_SetSelectedValue(self.dd_frame3.dd, My_Support_spells[1][1])
		UIDropDownMenu_SetText(self.dd_frame3.dd, My_Support_spells[1][2])
	end
end
T.UpdateSupportSpellDD = UpdateSupportSpellDD

-- 专精
local function InitSupportSpecDD(dd)
	dd.active_specs = {}
	
	function dd:SelectSpec(specID)
		self.active_specs[specID] = true	
	end
	
	function dd:CancelSpec(specID)
		self.active_specs[specID] = nil	
	end
	
	function dd:SelectAll()
		for classID, data in pairs(SpecTable) do
			for i, specInfo in pairs(data.spec) do
				self:SelectSpec(specInfo[1])
			end
		end
	end
	
	function dd:CancelAll()
		self.active_specs = table.wipe(self.active_specs)
	end
	
	function dd:IsSpecSelected(specID)
		return self.active_specs[specID]
	end
	
	function dd:IsAllSelectedForClass(classID)
		for i, specInfo in pairs(SpecTable[classID].spec) do
			if not self.active_specs[specInfo[1]] then
				return false
			end
		end
		return true
	end
	
	function dd:IsAllSelected()
		for classID, data in pairs(SpecTable) do
			for i, specInfo in pairs(data.spec) do
				if not self.active_specs[specInfo[1]] then
					return false
				end
			end
		end
		return true
	end
	
	function dd:IsNoneSelected()
		for k, v in pairs(self.active_specs) do
			return false
		end
		return true
	end
	
	function dd:UpdateCheckForAll()
		if self:IsAllSelected() then
			_G["DropDownList1Button1Check"]:Show()
			_G["DropDownList1Button1UnCheck"]:Hide()
		else
			_G["DropDownList1Button1Check"]:Hide()
			_G["DropDownList1Button1UnCheck"]:Show()
		end
		
		if self:IsNoneSelected() then
			_G["DropDownList1Button2Check"]:Show()
			_G["DropDownList1Button2UnCheck"]:Hide()
		else
			_G["DropDownList1Button2Check"]:Hide()
			_G["DropDownList1Button2UnCheck"]:Show()
		end
	end
	function dd:UpdateCheckForClass(classID)
		local checkImage = _G["DropDownList1Button"..(classID+2).."Check"]
		local uncheckImage = _G["DropDownList1Button"..(classID+2).."UnCheck"]
		if checkImage and uncheckImage then
			if dd:IsAllSelectedForClass(classID) then
				checkImage:Show()
				uncheckImage:Hide()
			else
				checkImage:Hide()
				uncheckImage:Show()
			end
		end
	end
end
T.InitSupportSpecDD = InitSupportSpecDD	

function UpdateSupportSpecDD(self)
	UIDropDownMenu_Initialize(self.dd_frame4.dd, function(dd, level, menuList)
		local dd_info = UIDropDownMenu_CreateInfo()
		dd_info.keepShownOnClick = true	
		if level == 1 then		
			dd_info.text = L["全部勾选"]
			dd_info.checked = function()
				return dd:IsAllSelected()
			end
			dd_info.func = function()
				dd:SelectAll()
				dd:UpdateCheckForAll()
				for classID in pairs(SpecTable) do
					dd:UpdateCheckForClass(classID)
				end
			end
			UIDropDownMenu_AddButton(dd_info)
			
			dd_info.text = L["全部取消"]
			dd_info.checked = function()
				return dd:IsNoneSelected()
			end
			dd_info.func = function()
				dd:CancelAll()
				dd:UpdateCheckForAll()
				for classID in pairs(SpecTable) do
					dd:UpdateCheckForClass(classID)
				end
			end
			UIDropDownMenu_AddButton(dd_info)
			
			for classID, classInfo in pairs(SpecTable) do
				dd_info.value = classInfo[1]
				dd_info.text = classInfo[2]
				dd_info.hasArrow = true
				dd_info.checked = function()
					return dd:IsAllSelectedForClass(classID)
				end				
				dd_info.func = function(btn)
					dd:UpdateCheckForClass(classID)
				end		
				dd_info.menuList = "class"..classID
				UIDropDownMenu_AddButton(dd_info)
			end
		elseif menuList then
			local classID = string.match(menuList, "class(%d+)")
			if classID then
				classID = tonumber(classID)
				for i, specInfo in pairs(SpecTable[classID].spec) do
					dd_info.value = specInfo[1]
					dd_info.arg1 = specInfo[1]
					dd_info.text = specInfo[2]
					dd_info.hasArrow = false				
					dd_info.checked = function()
						return dd:IsSpecSelected(specInfo[1])
					end
					dd_info.func = function(_, arg1)
						if dd:IsSpecSelected(specInfo[1]) then
							dd:CancelSpec(arg1)
						else
							dd:SelectSpec(arg1)
						end
						dd:UpdateCheckForClass(classID)
						dd:UpdateCheckForAll()
					end
					UIDropDownMenu_AddButton(dd_info, level)
				end
			end
		end
	end)
	
	self.dd_frame4.dd:SelectAll()
	UIDropDownMenu_SetText(self.dd_frame4.dd, SPECIALIZATION)
end
T.UpdateSupportSpecDD = UpdateSupportSpecDD

--====================================================--
--[[                -- 首领功能 --                  ]]--
--====================================================--
local CreateTitleAnchor = function(option_page)
	local anchor = CreateFrame("Frame", nil, option_page)
	anchor:SetSize(25, 25)
	anchor.istitle = true
	
	return anchor
end

local CreateTitleIcon = function(anchor, i, portrait, tex, text, spellID)
	local icon = CreateFrame("Frame", nil, anchor)
	icon:SetSize(30, 30)			
	T.createborder(icon)
	
	icon.tex = icon:CreateTexture(nil, "ARTWORK")
	icon.tex:SetAllPoints(icon)
	
	if portrait then
		SetPortraitTextureFromCreatureDisplayID(icon.tex, tex)
		icon.tex:SetTexCoord( .15, .85, .15, .85)
	else
		icon.tex:SetTexture(tex)
		icon.tex:SetTexCoord( .1, .9, .1, .9)
	end
	
	icon.text = T.createtext(icon, "ARTWORK", 25, "OUTLINE", "LEFT")
	icon.text:SetTextColor(1, .82, 0)
	icon.text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
	icon.text:SetText(text)
	
	if spellID then
		icon:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, 10)
			GameTooltip:SetSpellByID(spellID)
			GameTooltip:Show() 
		end)
		
		icon:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	if i == 1 then
		icon:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, 0)
	else
		icon:SetPoint("LEFT", anchor["icon"..(i-1)].text, "RIGHT", 10, 0)
	end
	
	anchor["icon"..i] = icon
end

-- 技能标题
local CreateEncounterSectionTitle = function(option_page, data)
	if data.title then
		local title = CreateGUITitle(option_page, data.title)
		SetGUIPoint(option_page, 1, title, 30)
	else
		local anchor = CreateTitleAnchor(option_page)
		SetGUIPoint(option_page, 1, anchor, 40)
		
		local i = 0
		if data.npcs then
			for _, info in pairs(data.npcs) do
				i = i + 1
				local sectionInfo = C_EncounterJournal.GetSectionInfo(info[1])
				if sectionInfo then
					CreateTitleIcon(anchor, i, true, sectionInfo.creatureDisplayID, T.GetFlagIconStr(info[2])..sectionInfo.title)
				else
					T.test_msg(info[1], "sectionInfo error")
				end
			end
		end
		if data.spells then
			for _, info in pairs(data.spells) do
				i = i + 1
				local spellName = C_Spell.GetSpellName(info[1])
				local spellIcon = C_Spell.GetSpellTexture(info[1])
				if spellName and spellIcon then
					CreateTitleIcon(anchor, i, false, spellIcon, T.GetFlagIconStr(info[2])..spellName, info[1])
				else
					T.msg("Spell ID removed "..info[1])
				end
			end					
		end
	end
end

local function GetIconSpellText(args)
	local spell_text, extra_text = "", ""
	
	if args.options_spellIDs then
		for _, spellID in pairs(args.options_spellIDs) do
			spell_text = spell_text..T.GetIconLink(spellID)
		end
	else
		local spellName = C_Spell.GetSpellName(args.spellID)
		local icon = args.icon_tex or C_Spell.GetSpellTexture(args.spellID)
		spell_text = string.format("|T%s:12:12:0:0:64:64:4:60:4:60|t|cff71d5ff[%s]|r", icon, spellName)
	end
	
	if args.tip then
		extra_text = string.format(" [%s]", args.tip:gsub("%%s", ""))
	elseif args.type == "com" then
		extra_text = string.format(" [%s]", L["对我施法"])
	end
	
	return spell_text..extra_text
end

-- 图标提示
T.Create_AlertIcon_Options = function(option_page, category, path, args, detail_options)	
	local edit_key = args.type.."_"..args.spellID
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local option_text = GetIconSpellText(args)
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, string.format(L["图标%s"], option_text), args.enable_tag, args.ficon)
	
	bu.apply = function()
		for _, holders in pairs(G.IconAlertGroupFrames) do
			for _, icon in pairs(holders.active_byindex) do
				if icon.edit_key == edit_key then
					icon:update_onedit("enable")
				end
			end
		end
	end
	
	if detail_options and #detail_options > 0 then	
		CreateDetailOptionButton(bu, path, option_text, detail_options)
	end
end

local function GetBarSpellText(args)
	local spell_text, extra_text = "", ""
	
	if args.options_spellIDs then
		for _, spellID in pairs(args.options_spellIDs) do
			spell_text = spell_text..T.GetIconLink(spellID)
		end
	else
		local spellName = C_Spell.GetSpellName(args.spellID)
		local icon = args.icon_tex or C_Spell.GetSpellTexture(args.spellID)
		spell_text = string.format("|T%s:12:12:0:0:64:64:4:60:4:60|t|cff71d5ff[%s]|r", icon, spellName)
	end
	
	if args.text then
		extra_text = string.format(" [%s]", args.text)
	end
	
	if args.group == 3 then
		return string.format(L["NAME换坦技能提示"], spell_text..extra_text)
	else
		return string.format(L["计时条%s"], spell_text..extra_text)
	end
end

-- 计时条提示
T.Create_Timerbar_Options = function(option_page, category, path, args, detail_options)
	local edit_key = args.type.."_"..args.spellID
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local option_text = GetBarSpellText(args)
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, option_text, args.enable_tag, args.ficon)

	bu.apply = function()
		for _, holders in pairs(G.BarAlertGroupFrames) do
			for _, bar in pairs(holders.active_byindex) do
				if bar.edit_key == edit_key then
					bar:update_onedit("enable")
				end
			end
		end
	end
	
	if detail_options and #detail_options > 0 then		
		CreateDetailOptionButton(bu, path, option_text, detail_options)
	end	
end

-- 姓名板提示
T.Create_PlateAlert_Options = function(option_page, category, path, args, detail_options)
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local frame_key, str
	
	if args.type == "PlatePower" then
		frame_key = args.mobID
		str = string.format(L["显示姓名板能量图标"], T.GetNameFromNpcID(args.mobID) or "??")
	elseif args.type == "PlateNpcID" then
		frame_key = args.mobID
		str = string.format(L["显示姓名板动画边框"], T.GetNameFromNpcID(args.mobID) or "??")
	elseif args.type == "PlateInterrupt" then
		frame_key = args.spellID
		str = string.format(L["显示姓名板图标打断"], T.GetIconLink(args.spellID))
	elseif args.type == "PlateStackAuras" then
		frame_key = args.spellID
		str = string.format(L["显示姓名板图标光环层数"], T.GetIconLink(args.spellID))
	elseif args.type == "PlateSpells" then
		frame_key = args.spellID
		str = string.format(L["姓名板法术图标"], T.GetIconLink(args.spellID))
	elseif args.type == "PlateAuras" then
		frame_key = args.spellID
		str = string.format(L["姓名板法术图标"], T.GetIconLink(args.spellID))
	elseif args.type == "PlayerAuraSource" then
		frame_key = args.spellID
		str = string.format(L["姓名板法术图标"], T.GetIconLink(args.spellID))
	end
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	
	bu.apply = function()
		if args.type == "PlateInterrupt" then
			local enable = T.ValueFromDB(path)["enable"]
			local interrupt_sl = T.ValueFromDB(path)["interrupt_sl"]
			local npcIDs = {string.split(",", args.mobID)}
			for i, npcID in pairs(npcIDs) do			
				if not G.Npc[npcID] then
					G.Npc[npcID] = {}
				end
				if enable then
					G.Npc[npcID][args.spellID] = interrupt_sl
				else
					G.Npc[npcID][args.spellID] = nil
				end
				
				local num = 0
				for spellID, interrupt_num in pairs(G.Npc[npcID]) do
					num = num + interrupt_num
				end
				if num > 0 then
					G.Npc_InterruptNum[npcID] = num
				else
					G.Npc_InterruptNum[npcID] = nil
				end
			end
		end
	end
	
	if detail_options and #detail_options > 0 then		
		CreateDetailOptionButton(bu, path, str, detail_options)
	end
end

local LCG = LibStub("LibCustomGlow-1.0")
local function HideRFAuraGlowbySpellID(spellID)
	local glow_type = C.DB["RFIconOption"]["glow_type"]
	if glow_type == "proc" then
		local current = LCG.ProcGlowPool:GetNextActive()
		while current do
			if current.name and string.find(current.name, "RFAura") and string.find(current.name, ":"..spellID) then
				LCG.ProcGlowPool:Release(current)
			end
			current = LCG.ProcGlowPool:GetNextActive(current)
		end
	else
		local current = LCG.GlowFramePool:GetNextActive()
		local spellID = tostring(spellID)
		while current do
			if current.name and string.find(current.name, "RFAura") and string.find(current.name, ":"..spellID) then
				LCG.GlowFramePool:Release(current)
			end
			current = LCG.GlowFramePool:GetNextActive(current)
		end
	end
end

-- 团队框架提示
T.Create_RFIcon_Options = function(option_page, category, path, args)
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local spellName = T.GetIconLink(args.spellID)
	local str

	if args.type == "Cast" then
		str = string.format(L["团队框架图标%s"], spellName)
	elseif args.type == "Msg" then
		str = string.format(L["团队框架图标%s"], spellName)
	elseif args.type == "Aura" then
		local extra_str = args.amount and string.format(L["层数大于"], args.amount) or ""
		str = string.format(L["团队框架高亮%s"], spellName..extra_str)
	end
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	
	if args.type == "Aura" then
		bu.apply = function()
			if not T.ValueFromDB({"RFIcon", args.type, args.spellID, "enable"}) then
				HideRFAuraGlowbySpellID(args.spellID)
			end
		end
	end
end

-- 首领模块
T.Create_BossMod_Options = function(option_page, category, path, args, detail_options)
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local str = args.name or string.format("%s %s", T.GetIconLink(args.spellID), L["首领模块"])
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	bu.apply = function() 
		G.BossModFrames[args.spellID]:update_onedit("enable")
	end

	if detail_options and #detail_options > 0 then
		CreateDetailOptionButton(bu, path, str, detail_options, G.BossModFrames[args.spellID])
	end
end

-- 音效提示
T.Create_Sound_Options = function(option_page, category, path, args)
	local enable_path = T.CopyTableInsertElement(path, "enable")	
	local str
	
	if args.ficon and (args.file == "[dispel]" or args.file == "[prepare_dispel]" or args.file == "[dispel_now]")  then
		local extra_str = args.amount and string.format(L["层数大于"], args.amount) or ""
		str = string.format(L["驱散声音提示"], T.GetIconLink(args.spellID)..extra_str)
	else
		str = string.format(sound_suffix[args.sub_event][2], T.GetIconLink(args.spellID))..(args.private_aura and "(Private Aura)" or "")
	end
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	bu.apply = function()
		local frame = G.PASoundTiggerFrames[args.spellID]
		if frame then
			frame:update_onedit()
		end
	end
	
	CreateSoundPreviewButton(bu, args.file, {"LEFT", bu, "LEFT", 780, 0})
end

-- 文字提示
T.Create_TextAlert_Options = function(option_page, category, path, args, detail_options)
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local str, edit_key
	
	if args.type == "hp" then
		str = L["血量提示"].." "..T.hex_str(string.format(args.data.ranges[1]["tip"], (args.data.ranges[1]["ul"]+args.data.ranges[1]["ll"])/2), args.color or {1, 0, 0})
		edit_key = args.type.."_"..args.data.npc_id
	elseif args.type == "pp" then
		str = L["能量提示"].." "..T.hex_str(string.format(args.data.ranges[1]["tip"], (args.data.ranges[1]["ul"]+args.data.ranges[1]["ll"])/2), args.color or {0, 1, 1})
		edit_key = args.type.."_"..args.data.npc_id
	elseif args.type == "spell" then
		str = L["技能提示"].." "..T.hex_str(args.preview, args.color or {1, 1, 1})
		edit_key = args.type.."_"..args.data.spellID
	end
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	bu.apply = function()
		if args.type == "spell" then
			T.FireEvent("DB_UPDATE", option_page.ENCID, category, args.type, args.data.spellID)
		end
		
		for _, holders in pairs(G.TextAlertGroupFrames) do
			for _, text_f in pairs(holders.active_byindex) do
				if text_f.edit_key == edit_key then
					text_f:update_onedit("enable")
				end
			end
		end
	end
	
	if detail_options and #detail_options > 0 then		
		CreateDetailOptionButton(bu, path, str, detail_options)
	end
end

-- 自保提示
T.Create_HPWatch_Options = function(option_page, category, path, args, detail_options)
	local enable_path = T.CopyTableInsertElement(path, "enable")
	local str = T.GetIconLink(args.spellID)..L["玩家自保技能提示"]
	
	local bu = Checkbutton_Encounter_DB(option_page, enable_path, str, args.enable_tag, args.ficon)
	
	if args.type == "Aura" then
		bu.apply = function()
			G.HPWatchTrigger:GetScript("OnEvent")(G.HPWatchTrigger, "OPTION_EDIT")
		end
	end
	
	if detail_options and #detail_options > 0 then		
		CreateDetailOptionButton(bu, path, str, detail_options)
	end
end

-- 转阶段
T.Create_Phase_Options = function(option_page, category, args)
	local str

	if args.type == "CLEU" then
		str = string.format(L["转阶段技能"], args.phase, string.format(PhaseTriggerEvents[args.sub_event], T.GetIconLink(args.spellID or args.extraSpellID)))..(args.count and string.format("(%d)", args.count) or "")..(args.source and string.format("(%d)", args.source) or "")
	elseif args.type == "UNIT" then
		str = string.format(L["转阶段技能"], args.phase, string.format(L["加入战斗"], T.GetNameFromNpcID(args.npcID)))
	end
	
	local text = CreateGUIDesciption(option_page, str, args.ficon)
	SetGUIPoint(option_page, 1, text, nil, nil, 20, -5)
end

--====================================================--
--[[                -- 控制台选项 --                ]]--
--====================================================--
-- GUI功能
local CreateGUIOpitons = function(parent, OptionCategroy, start_ind, end_ind)
	local start_ = start_ind or 1
	local end_ = end_ind or #G.Options[OptionCategroy]
	local category_text = ""
	
	if not parent.option_y then
		parent.option_y = -10
	end
	
	for i = start_, end_ do
		local info = G.Options[OptionCategroy][i]
		local path = {OptionCategroy, info.key}
		local obj

		if (not info.class or info.class[G.myClass]) then
			if info.option_type == "title" then
				obj = CreateGUITitle(parent, info.text)
				category_text = info.text
			elseif info.option_type == "string" then
				obj = CreateGUIDesciption(parent, info.text)				
			elseif info.option_type == "ddmenu" then
				if OptionCategroy == "SettingOption" then
					obj = UIDropDownMenuFrame_SettingOption(parent, path, category_text)
				else
					obj = UIDropDownMenuFrame_DB(parent, path, category_text)
				end
			elseif info.option_type == "check" then
				obj = Checkbutton_DB(parent, path, category_text)
			elseif info.option_type == "slider" then
				obj = Slider_DB(parent, path, category_text)
			elseif info.option_type == "button" then
				obj = ClickButton_DB(parent, path)
			elseif info.option_type == "color" then
				obj = ColorpickerButton_DB(parent, path)
			end
			
			if info.rely then
				createDR(parent[info.rely], obj)
			end
			
			local offset
			if info.option_type == "title" then
				offset = 20
			elseif info.option_type == "string" then
				offset = 5
			end
			
			SetGUIPoint(parent, info.width or 1, obj, offset)
			
			if info.key then
				parent[info.key] = obj
			end
		end
	end
end
T.CreateGUIOpitons = CreateGUIOpitons

local function AddDataTable(tag, category, alert_type)
	if not tag or not category or not alert_type then return end
	if not G.Encounter_Data[tag] then
		G.Encounter_Data[tag] = {}
	end
	if not G.Encounter_Data[tag][category] then
		G.Encounter_Data[tag][category] = {}
	end
	if not G.Encounter_Data[tag][category][alert_type] then
		G.Encounter_Data[tag][category][alert_type] = {}
	end
end

local function AddCurrentDataTable(category, alert_type)
	if not G.Current_Data[category] then
		G.Current_Data[category] = {}
	end
	if not G.Current_Data[category][alert_type] then
		G.Current_Data[category][alert_type] = {}
	end
end

local function GetTimelineData(ENCID, tag)
	if G.Timeline_Data[ENCID] then
		local str = G.Timeline_Data[ENCID][tag] or G.Timeline_Data[ENCID]["all"]
		if str then
			str = str:gsub("\n\n", "\n")
			str = str:gsub("{JSTID:(%d+)}", C_Spell.GetSpellName)
			str = str:gsub("|", "||")
			
			return str
		else
			return "\n\n\n"
		end
	else
		return "\n\n\n"
	end
end

-- BOSS设置面板

G.npcIDtoengageID = {}
G.npcIDtoENCID = {}
G.mapIDtoENCIDs = {}

T.CreateEncounterOptions = function(instance_type, option_page, ENCID, InstanceID, mapID, ChallengeMapID)
	local data = G.Encounters[ENCID]
	
	if not data then return end
		
	local encounterName = data.engage_id and EJ_GetEncounterInfo(ENCID)
	local engageTag = data.engage_id and "engage"..data.engage_id
	local mapTag = "map"..mapID
	
	option_page.ENCID = ENCID
	option_page.engageTag = engageTag
	option_page.mapTag = mapTag
	option_page.option_y = 50
	
	if engageTag then
		option_page.movingTag = encounterName
	elseif ChallengeMapID then
		local map_name = C_ChallengeMode.GetMapUIInfo(ChallengeMapID)
		option_page.movingTag = map_name..L["杂兵"]
	else
		local map_name = EJ_GetInstanceInfo(InstanceID)
		option_page.movingTag = map_name..L["杂兵"]
	end
	
	if engageTag then -- 首领战斗
		for i, npcID in pairs(data.npc_id) do
			G.npcIDtoENCID[npcID] = ENCID
			G.npcIDtoengageID[npcID] = data.engage_id
		end
	else -- 杂兵
		if not G.mapIDtoENCIDs[data.map_id] then
			G.mapIDtoENCIDs[data.map_id] = {}
		end
		G.mapIDtoENCIDs[data.map_id][ENCID] = true
	end
			
	if engageTag then -- 首领战斗
		local tex = select(5, EJ_GetCreatureInfo(1, ENCID)) or [[Interface\EncounterJournal\UI-EJ-BOSS-Default]]
		option_page.img = option_page:CreateTexture(nil, "OVERLAY")
		option_page.img:SetPoint("TOPLEFT", 5, -5)
		option_page.img:SetTexCoord( 0, 1, 0, .95)
		option_page.img:SetSize(128, 64)
		option_page.img:SetTexture(tex)
		
		local anchor_button
		if instance_type == "Raid" then
			option_page.tlcopy_mythic = T.ClickButton(option_page, 120, {"TOPRIGHT", -10, -10}, L["M时间轴"])
			option_page.tlcopy_mythic:SetScript("OnClick", function(self)			
				T.DisplayCopyString(self, string.format("%s\n[JST%sM]%s\n%s%s", encounterName, data.engage_id, L["时间轴"], GetTimelineData(ENCID, "m"), L["战斗结束"]), L["M时间轴"].." "..L["复制粘贴"])
			end)
			
			option_page.tlcopy_heroic = T.ClickButton(option_page, 120, {"RIGHT", option_page.tlcopy_mythic, "LEFT", -5, 0}, L["H时间轴"])
			option_page.tlcopy_heroic:SetScript("OnClick", function(self)			
				T.DisplayCopyString(self, string.format("%s\n[JST%sH]%s\n%s%s", encounterName, data.engage_id, L["时间轴"], GetTimelineData(ENCID, "h"), L["战斗结束"]), L["H时间轴"].." "..L["复制粘贴"])
			end)
			
			anchor_button = option_page.tlcopy_heroic
		else
			option_page.tlcopy = T.ClickButton(option_page, 120, {"TOPRIGHT", -10, -10}, L["时间轴"])
			option_page.tlcopy:SetScript("OnClick", function(self)			
				T.DisplayCopyString(self, string.format("%s\n[JST%s]%s\n%s%s", encounterName, data.engage_id, L["时间轴"], GetTimelineData(ENCID, "all"), L["战斗结束"]), L["时间轴"].." "..L["复制粘贴"])
			end)
			
			anchor_button = option_page.tlcopy
		end
		
		option_page.mrtcopy = T.ClickButton(option_page, 120, {"RIGHT", anchor_button, "LEFT", -5, 0}, L["MRT技能模板"])
		option_page.mrtcopy:SetScript("OnClick", function(self)
			local str = ""
			for section_index, section_data in pairs(data.alerts) do
				for index, args in pairs(section_data.options) do
					if args.category == "PlateAlert" and args.type == "PlateInterrupt" and args.mrt_info then
						str = str.."\n--------------\n"
						local marks = strsplittable(",", args.mrt_info[1])
						for _, rt in pairs(marks) do
							str = str..T.GetInterruptStr(args.mobID, args.spellID, string.format("{rt%s}", rt), args.interrupt, args.mrt_info[2]).."\n"
						end
					elseif args.category == "BossMod" then
						local frame = G.BossModFrames[args.spellID]
						if frame and frame.copy_mrt then
							str = str.."\n--------------\n"
							str = str..frame:copy_mrt()
						end
					end
				end
			end
			T.DisplayCopyString(self, str)
		end)
		
		option_page.ejtoggle = T.ClickButton(option_page, 120, {"RIGHT", option_page.mrtcopy, "LEFT", -5, 0}, ENCOUNTER_JOURNAL)
		option_page.ejtoggle:SetScript("OnClick", function(self)
			if EncounterJournal.encounterID ~= ENCID then
				if not EncounterJournal:IsShown() then
					ToggleEncounterJournal()
				end
				EncounterJournal_OpenJournal(nIL, InstanceID, ENCID)
				EncounterJournal_SetTab(3)
			else
				ToggleEncounterJournal()
			end
		end)
	end
	
	option_page.bg = option_page:CreateTexture(nil, "ARTWORK")
	option_page.bg:SetPoint("TOPLEFT", 5, -5)
	option_page.bg:SetSize(560, 64)
	option_page.bg:SetTexture(select(5, EJ_GetInstanceInfo(InstanceID)))
	option_page.bg:SetTexCoord(.07, .73, .45, .55)
	option_page.bg:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, 0))

	option_page.title = T.createtext(option_page, "OVERLAY", 25, "OUTLINE", "LEFT")
	if option_page.img then
		option_page.title:SetPoint("BOTTOMLEFT", option_page.img, "BOTTOMRIGHT", 0, 0)
	else
		option_page.title:SetPoint("BOTTOMLEFT", option_page.bg, "BOTTOMLEFT", 10, 0)
	end
	option_page.title:SetText(T.GetEncounterName(ENCID))
	
	option_page:SetScript("OnShow", function() 
		G.current_encounterID = ENCID
	end)
	
	for section_index, section_data in pairs(data.alerts) do
		if next(section_data.options) then		
			CreateEncounterSectionTitle(option_page, section_data)
			
			for index, args in pairs(section_data.options) do
				local category = args.category
				local alert_type = args.type
				
				if not category then
					T.msg(string.format("encounter %s section %d option %d, category missing", ENCID, section_index, index))
				end
				
				if category and alert_type then
					AddDataTable(engageTag, category, alert_type)
					AddDataTable(mapTag, category, alert_type)
					AddCurrentDataTable(category, alert_type)
				end
				
				if category == "AlertIcon" then
					if alert_type == "aura" then
						T.CreateAura(option_page, category, args)
					elseif alert_type == "com" then
						T.CreateCom(option_page, category, args)
					elseif alert_type == "bmsg" then
						T.CreateBossMsg(option_page, category, args)
					end
				elseif category == "AlertTimerbar" then
					if alert_type == "cast" then
						T.CreateCast(option_page, category, args)
					elseif alert_type == "cleu" then
						T.CreateCLEU(option_page, category, args)
					elseif alert_type == "aura" then
						T.CreateAuraBar(option_page, category, args)
					end
				elseif category == "TextAlert" then
					if alert_type == "hp" then
						T.CreateAlertTextHealth(option_page, category, args)
					elseif alert_type == "pp" then
						T.CreateAlertTextPower(option_page, category, args)
					elseif alert_type == "spell" then
						T.CreateAlertTextSpell(option_page, category, args)
					end
				elseif category == "PlateAlert" then
					T.CreatePlateAlert(option_page, category, args)
				elseif category == "Sound" then	
					T.CreateSoundAlert(option_page, category, args)
				elseif category == "RFIcon" then	
					T.CreateRFIconAlert(option_page, category, args)
				elseif category == "HPWatch" then
					T.CreateHPWatchAlert(option_page, category, args)
				elseif category == "PhaseChangeData" then
					T.Create_Phase_Options(option_page, category, args)
				elseif category == "BossMod" then
					T.CreateBossMod(option_page, category, args)
				end
			end
		end
	end
end

--====================================================--
--[[                  -- Setup --                   ]]--
--====================================================--
local setup_frame = CreateFrame("Frame", nil, UIParent, "SettingsFrameTemplate")
setup_frame:SetSize(500, 150)
setup_frame:SetPoint("CENTER", UIParent, "CENTER")
setup_frame:SetFrameStrata("HIGH")
setup_frame:SetFrameLevel(30)
setup_frame:Hide()

setup_frame:RegisterForDrag("LeftButton")
setup_frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
setup_frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
setup_frame:SetClampedToScreen(true)
setup_frame:SetMovable(true)
setup_frame:EnableMouse(true)

setup_frame.NineSlice.Text:SetText(G.addon_cname)
setup_frame.NineSlice.Text:SetFont(G.Font, 16, "OUTLINE")
setup_frame.NineSlice.Text:SetShadowOffset(0, 0)

setup_frame.description = T.createtext(setup_frame, "OVERLAY", 14, "OUTLINE", "LEFT")
setup_frame.description:SetPoint("TOPLEFT", setup_frame, "TOPLEFT", 20, -30)

local function CreateSetupDDFrame(text, y_off, option_table, path)
	local frame = T.UIDropDownMenuFrame(setup_frame, text, {"TOPLEFT", 25, y_off})
	frame.dd:SetPoint("LEFT", frame, "LEFT", 130, 0)
	UIDropDownMenu_SetWidth(frame.dd, 300)

	local function DD_UpdateChecked(self, arg1)
		return (T.ValueFromPath(JST_CDB, path) == arg1)
	end
	
	local function DD_SetChecked(self, arg1, arg2)
		T.ValueToPath(JST_CDB, path, arg1)
		T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, arg1)
		if frame.visible_apply then frame.visible_apply() end
	end
	
	UIDropDownMenu_Initialize(frame.dd, function(self, level)
		local dd_info = UIDropDownMenu_CreateInfo()
		for i = 1, #option_table do
			dd_info.value = option_table[i][1]
			dd_info.arg1 = option_table[i][1]
			dd_info.text = option_table[i][2]
			dd_info.checked = DD_UpdateChecked
			dd_info.func = DD_SetChecked
			UIDropDownMenu_AddButton(dd_info)
		end
	end)
	
	frame:SetScript("OnShow", function()
		T.UIDropDownMenu_SetSelectedValueText(frame.dd, option_table, T.ValueFromPath(JST_CDB, path))
	end)
	
	return frame
end

local setting_dd = CreateSetupDDFrame(L["配置"], -55,
	{
		{"character", L["使用角色设置"]},
		{"account", L["使用账号设置"]},
	},
	{"SettingOption", "reset_settings"}
)

local loading_dd = CreateSetupDDFrame(L["加载规则"], -85,
	{
		{"rl", L["指挥"]},
		{"no-rl", L["非指挥"]},
		{"none", L["全部禁用"]},
	},
	{"SettingOption", "reset_role_enable_tag"}
)

do
	local ShouldShow = function()
		if setup_frame.new_character then
			if JST_CDB.SettingOption.reset_settings == "character" then
				return true
			end
		else
			return true
		end
	end
	
	createVisibleDR(ShouldShow, setting_dd, loading_dd)
end

setup_frame.confirm = ClickButton(setup_frame, 220, {"BOTTOMRIGHT", setup_frame, "BOTTOM", -10, 10}, L["加载设置"])
setup_frame.confirm:SetScript("OnClick", function()	
	if JST_CDB["SettingOption"]["reset_settings"] == "character" then
		-- 重置角色设置
		JST_CDB["SettingOption"]["settings"] = "character"
		JST_CDB["LoadOption"]["role_enable_tag"] = JST_CDB["SettingOption"]["reset_role_enable_tag"]
		
		for category, settings in pairs(JST_CDB) do
			if category ~= "LoadOption" and category ~= "SettingOption" then
				JST_CDB[category] = nil
			end
		end
	else
		JST_CDB["SettingOption"]["settings"] = "account"
		
		-- 重置账号设置
		if not setup_frame.new_character then
			JST_DB.CDB["LoadOption"]["role_enable_tag"] = JST_CDB["SettingOption"]["reset_role_enable_tag"]
			
			for category, settings in pairs(JST_DB.CDB) do
				if category ~= "LoadOption" and category ~= "SettingOption" then
					JST_DB.CDB[category] = nil
				end
			end
		end
	end	
	ReloadUI()
end)

setup_frame.close = ClickButton(setup_frame, 220, {"BOTTOMLEFT", setup_frame, "BOTTOM", 10, 10}, CLOSE)
setup_frame.close:SetScript("OnClick", function()
	setup_frame:Hide()
end)

T.ToggleSetup = function(new)
	if setup_frame:IsShown() then
		setup_frame:Hide()
	else
		if new then
			setup_frame.description:SetText(L["欢迎"])
			setup_frame.confirm:SetText(L["加载设置"])
			setup_frame.confirm:ClearAllPoints()
			setup_frame.confirm:SetPoint("BOTTOM", setup_frame, "BOTTOM", 0, 10)
			setup_frame.close:Hide()
			if new == "character" then
				setup_frame.new_character = true
			else
				setup_frame.new_character = false
			end
		else
			setup_frame.description:SetText("")
			setup_frame.confirm:SetText(L["重置设置"])
			setup_frame.confirm:ClearAllPoints()
			setup_frame.confirm:SetPoint("BOTTOMRIGHT", setup_frame, "BOTTOM", -10, 10)
			setup_frame.close:Show()
			setup_frame.new_character = false
		end
		setup_frame:Show()
	end
end