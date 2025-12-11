local T, C, L, G = unpack(select(2, ...))

local LCG = LibStub("LibCustomGlow-1.0")

---------------------------------------------
-----------  文字倒计时通用模板  ------------
---------------------------------------------
-- frame.round = true -- 倒计时数字取整
-- frame.show_time = 4 -- 小于该秒数时显示（延迟显示类模板）
-- frame.count_down_english = true -- 英语倒数
-- frame.count_down_start = 5 -- 倒数开始数字
-- frame.floor_num = true -- 倒数时向下计数
-- frame.mute_count_down = true -- 倒数静音
-- frame.prepare_sound = "add"/{"add", "aoe"}-- 准备音效（于倒数前播放，会占用一个倒数数字）
-- frame.show_ind = true -- 显示序数（循环）
-- frame.cur_text = "" -- 实时更新的文本
-- frame.keep = true -- 结束时持续显示，需要手动隐藏

-- 文字倒计时模板(持续显示)
T.Start_Text_Timer = function(frame, dur, text, show_dur)
	frame.exp_time = GetTime() + dur
	frame.count_down = frame.count_down_start
	frame.prepare = frame.prepare_sound

	frame.text:SetText("")
	frame.collapse = false
	frame:Show()	
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > 0 then
				if self.floor_num then
					self.remain_second = floor(self.remain)
				else
					self.remain_second = ceil(self.remain)
				end
				
				if show_dur then
					if self.round then
						self.text:SetText((self.cur_text or text).." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", (self.cur_text or text), self.remain))
					end
				else
					self.text:SetText((self.cur_text or text))
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)	
						self.prepare = nil
					elseif not self.mute_count_down then
						if self.count_down_english then
							T.PlaySound("count_en\\"..self.remain_second)
						else
							T.PlaySound("count\\"..self.remain_second)
						end
					end
					self.count_down = self.remain_second - 1
				end
			else
				if self.keep then
					self.text:SetText((self.cur_text or text))
				else
					self:Hide()
				end
				self:SetScript("OnUpdate", nil)
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(倒计时小于4秒时显示)
T.Start_Text_DelayTimer = function(frame, dur, text, show_dur)
	frame.exp_time = GetTime() + dur
	frame.show_time = frame.show_time or 4
	frame.count_down = frame.count_down_start and min(frame.show_time, frame.count_down_start)
	frame.prepare = frame.prepare_sound		
	
	if dur > frame.show_time then
		frame.collapse = true
	else
		frame.collapse = false
	end
	
	frame.text:SetText("")
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > self.show_time then
				self.text:SetText("")
				if not self.collapse then
					self.collapse = true
					T.LineUpTexts(self.group)
				end
			elseif self.remain > 0 then
				if self.collapse then
					self.collapse = false
					T.LineUpTexts(self.group)
				end
				
				if self.floor_num then
					self.remain_second = floor(self.remain)
				else
					self.remain_second = ceil(self.remain)
				end
				
				if show_dur then
					if self.round then
						self.text:SetText((self.cur_text or text).." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", (self.cur_text or text), self.remain))
					end
				else
					self.text:SetText((self.cur_text or text))
				end
				
				if self.count_down and self.remain_second <= self.count_down then	
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not self.mute_count_down then	
						if self.count_down_english then
							T.PlaySound("count_en\\"..self.remain_second)
						else
							T.PlaySound("count\\"..self.remain_second)
						end
					end
					self.count_down = self.remain_second - 1
				end
			else
				if self.keep then
					self.text:SetText((self.cur_text or text))
				else
					self:Hide()
				end
				self:SetScript("OnUpdate", nil)
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(依次重复文字倒计时持续显示模板)
T.Start_Text_RowTimer = function(frame, dur_table, text_info, show_dur)
	local ind = 1
	frame.exp_time = GetTime() + dur_table[ind]
	frame.count_down = frame.count_down_start
	frame.prepare = type(frame.prepare_sound) == "table" and frame.prepare_sound[ind] or frame.prepare_sound 
	frame.str = type(text_info) == "table" and text_info[ind] or text_info		
	
	frame.text:SetText(frame.str)
	frame.collapse = false
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > 0 then
				if self.floor_num then
					self.remain_second = floor(self.remain)
				else
					self.remain_second = ceil(self.remain)
				end
				
				if show_dur then
					if self.round then
						self.text:SetText(self.str.." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", self.str, self.remain))
					end
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not self.mute_count_down then	
						if self.count_down_english then
							T.PlaySound("count_en\\"..self.remain_second)
						else
							T.PlaySound("count\\"..self.remain_second)
						end
					end
					self.count_down = self.remain_second - 1
				end
			else
				ind = ind + 1
				if dur_table[ind] then
					self.exp_time = self.exp_time + dur_table[ind]
					self.count_down = self.count_down_start
					self.prepare = type(self.prepare_sound) == "table" and self.prepare_sound[ind] or self.prepare_sound
					self.str = type(text_info) == "table" and text_info[ind] or text_info
				else
					self:Hide()
					self:SetScript("OnUpdate", nil)
				end
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(依次重复文字倒计时小于4秒时显示模板)
T.Start_Text_DelayRowTimer = function(frame, dur_table, text_info, show_dur)
	local ind = 1
	frame.exp_time = GetTime() + dur_table[ind]
	frame.show_time = frame.show_time or 4
	frame.count_down = frame.count_down_start and min(frame.show_time, frame.count_down_start)
	frame.prepare = type(frame.prepare_sound) == "table" and frame.prepare_sound[ind] or frame.prepare_sound 
	frame.str = type(text_info) == "table" and text_info[ind] or text_info
	
	if dur_table[ind] > frame.show_time then
		frame.collapse = true
	else
		frame.collapse = false
	end
	
	frame.text:SetText(frame.str)
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > self.show_time then
				if not self.collapse then
					self.collapse = true
					T.LineUpTexts(self.group)
				end
			elseif self.remain > 0 then
				if self.collapse then
					self.collapse = false
					T.LineUpTexts(self.group)
				end
				
				if self.floor_num then
					self.remain_second = floor(self.remain)
				else
					self.remain_second = ceil(self.remain)
				end
				
				if show_dur then
					if self.round then
						self.text:SetText(self.str.." "..(self.remain_second ))
					else
						self.text:SetText(string.format("%s %.1f", self.str, self.remain))
					end
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not self.mute_count_down then	
						if self.count_down_english then
							T.PlaySound("count_en\\"..self.remain_second)
						else
							T.PlaySound("count\\"..self.remain_second)
						end
					end
					self.count_down = self.remain_second - 1
				end
			else
				ind = ind + 1
				if dur_table[ind] then
					self.exp_time = self.exp_time + dur_table[ind]
					self.count_down = self.count_down_start
					self.prepare = type(self.prepare_sound) == "table" and self.prepare_sound[ind] or self.prepare_sound
					self.str = type(text_info) == "table" and text_info[ind] or text_info
				else
					self:Hide()
					self:SetScript("OnUpdate", nil)
				end
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(循环重复文字倒计时持续显示模板)
T.Start_Text_LoopTimer = function(frame, dur, text, show_dur)
	local ind = 1
	frame.exp_time = GetTime() + dur
	frame.count_down = frame.count_down_start
	frame.prepare = frame.prepare_sound 
	frame.str = (frame.show_ind and string.format("[%d] ", ind) or "")..text
	
	frame.text:SetText(frame.str)
	frame.collapse = false
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > 0 then
				if self.floor_num then
					self.remain_second = floor(self.remain)
				else
					self.remain_second = ceil(self.remain)
				end
				
				if show_dur then
					if self.round then
						self.text:SetText(self.str.." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", self.str, self.remain))
					end
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not self.mute_count_down then	
						if self.count_down_english then
							T.PlaySound("count_en\\"..self.remain_second)
						else
							T.PlaySound("count\\"..self.remain_second)
						end
					end
					self.count_down = self.count_down - 1
				end
			else
				ind = ind + 1
				self.exp_time = self.exp_time + dur
				self.count_down = self.count_down_start
				self.prepare = self.prepare_sound
				self.str = (self.show_ind and string.format("[%d] ", ind) or "")..text
			end
			self.t = 0
		end
	end)
end

-- 文字倒计时模板(循环重复文字倒计时小于4秒时显示模板)
T.Start_Text_DelayLoopTimer = function(frame, dur, text, show_dur)
	local ind = 1
	frame.exp_time = GetTime() + dur
	frame.show_time = frame.show_time or 4
	frame.count_down = frame.count_down_start and min(frame.show_time, frame.count_down_start)
	frame.prepare = frame.prepare_sound 
	frame.str = (frame.show_ind and string.format("[%d] ", ind) or "")..text
	
	if dur > frame.show_time then
		frame.collapse = true
	else
		frame.collapse = false
	end
		
	frame.text:SetText(frame.str)
	frame:Show()
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			self.remain = self.exp_time - GetTime()
			if self.remain > self.show_time then
				self.text:SetText("")
				if not self.collapse then
					self.collapse = true
					T.LineUpTexts(self.group)
				end
			elseif self.remain > 0 then
				if self.collapse then
					self.collapse = false
					T.LineUpTexts(self.group)
				end
				
				if self.floor_num then
					self.remain_second = floor(self.remain)
				else
					self.remain_second = ceil(self.remain)
				end
				
				if show_dur then
					if self.round then
						self.text:SetText(self.str.." "..self.remain_second)
					else
						self.text:SetText(string.format("%s %.1f", self.str, self.remain))
					end
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not self.mute_count_down then	
						if self.count_down_english then
							T.PlaySound("count_en\\"..self.remain_second)
						else
							T.PlaySound("count\\"..self.remain_second)
						end
					end
					self.count_down = self.remain_second - 1
				end
			else
				ind = ind + 1
				self.exp_time = self.exp_time + dur
				self.count_down = self.count_down_start
				self.prepare = self.prepare_sound
				self.str = (self.show_ind and string.format("[%d] ", ind) or "")..text
			end
			self.t = 0
		end
	end)
end

-- 停止文字倒计时
T.Stop_Text_Timer = function(frame)
	if frame then
		frame:Hide()
		frame:SetScript("OnUpdate", nil)
	end
end

---------------------------------------------
----------  团队框架动画边框模板  -----------
---------------------------------------------
T.ProcGlow_Start = LCG.ProcGlow_Start
T.ProcGlow_Stop = LCG.ProcGlow_Stop

T.PixelGlow_Start = LCG.PixelGlow_Start
T.PixelGlow_Stop = LCG.PixelGlow_Stop

local GlowRaidFramebyUnit_Show = function(glow_type, glow_key, unit, color, dur)
	local f = T.GetUnitFrame(unit)
	if f then
		if glow_type == "blz" then
			LCG.ButtonGlow_Start(f, color)
		elseif glow_type == "proc" then
			local x_offset = C.DB["RFIconOption"]["x_offset"]
			local y_offset = C.DB["RFIconOption"]["y_offset"]
			LCG.ProcGlow_Start(f, {key = glow_key, color = color, xOffset = x_offset, yOffset = y_offset})
			-- 触发高亮标签
			local glow_f = f["_ProcGlow"..glow_key]
			if glow_f then
				glow_f.name = "_ProcGlow"..glow_key
			end
		elseif glow_type == "pixel" then
			LCG.PixelGlow_Start(f, color, 12, .25, nil, 3, 0, 0, true, glow_key)
		end
		if dur then
			C_Timer.After(dur, function()
				if glow_type == "blz" then
					LCG.ButtonGlow_Stop(f)
				elseif glow_type == "proc" then
					LCG.ProcGlow_Stop(f, glow_key)
				elseif glow_type == "pixel" then
					LCG.PixelGlow_Stop(f, glow_key)
				end
			end)
		end
	end
end
T.GlowRaidFramebyUnit_Show = GlowRaidFramebyUnit_Show

local GlowRaidFramebyUnit_Hide = function(glow_type, glow_key, unit)
	local f = T.GetUnitFrame(unit)
	if f then
		if glow_type == "blz" then
			LCG.ButtonGlow_Stop(f)
		elseif glow_type == "proc" then
			LCG.ProcGlow_Stop(f, glow_key)
		elseif glow_type == "pixel" then
			LCG.PixelGlow_Stop(f, glow_key)
		end
	end
end
T.GlowRaidFramebyUnit_Hide = GlowRaidFramebyUnit_Hide

-- 隐藏高亮
local GlowRaidFrame_HideAll = function(glow_type, glow_key)
	if glow_type == "blz" then
		LCG.ButtonGlowPool:ReleaseAll()		
	elseif glow_type == "proc" then		
		if not glow_key then return end
		local current = LCG.ProcGlowPool:GetNextActive()
		while current do
			if current.name == "_ProcGlow"..glow_key then
				LCG.ProcGlowPool:Release(current)
			end
			current = LCG.ProcGlowPool:GetNextActive(current)
		end
	elseif glow_type == "pixel" then
		if not glow_key then return end
		local current = LCG.GlowFramePool:GetNextActive()
		while current do
			if current.name == "_PixelGlow"..glow_key then
				LCG.GlowFramePool:Release(current)
			end
			current = LCG.GlowFramePool:GetNextActive(current)
		end
	end
end
T.GlowRaidFrame_HideAll = GlowRaidFrame_HideAll

---------------------------------------------
-------------  姓名板标记模板  --------------
---------------------------------------------
G.NameplateTextures = {
	check = {
		w = 84,
		h = 77,
		atlas = "VAS-icon-checkmark-glw",
		hl_color = {0,1,0},
	},
	bomb = {
		w = 70,
		h = 70,
		atlas = "crosshair_crosshairs_96",
		desaturated = true,
		color = {.67, .31, 1},
		bg_w = 45,
		bg_h = 45,
		bg_tex = G.media.circle,
		text = L["炸弹"],
		fs = 16,
		fc = {1, .72, .12},
	},
	avoid = {
		w = 70,
		h = 70,
		atlas = "crosshair_crosshairs_96",
		desaturated = true,
		color = {1, 0, 0},
		bg_w = 45,
		bg_h = 45,
		bg_tex = G.media.circle,
		text = L["避开"],
		fs = 16,
		fc = {1, .72, .12},
	},
	value = {
		y_offset = -25,
		w = 35,
		h = 12,
		tex = G.media.blank,
		fs = 12,
		text = "?",
	},
}

local GetNameplateFrame = function(unit, GUID)
	if not unit then return end
	
	local GUID = GUID or UnitGUID(unit)
	if not G.Textured_GUIDs[GUID] then return end
	
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	if namePlate and namePlate.jstuf then
		return namePlate.jstuf
	end
end
T.GetNameplateFrame = GetNameplateFrame

local ShowNameplateExtraTex = function(unit, tex, GUID)
	local GUID = GUID or UnitGUID(unit)
	
	if not G.NameplateTextures[tex] then return end
	
	G.Textured_GUIDs[GUID] = tex
	
	if G.NameplateTextures[tex].hl_color then
		T.ShowPlateGlowByGUID("ExtraTex", unit, G.NameplateTextures[tex].hl_color, GUID)
	end
	
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	if namePlate and namePlate.jstuf then
		local info = G.NameplateTextures[tex]
		
		local w = info.w or 50
		local h = info.h or 50
		namePlate.jstuf.plate_texture:SetSize(w, h)			

		local x_offset = info.x_offset or 0
		local y_offset = info.y_offset or 0
		namePlate.jstuf.plate_texture:SetPoint("TOP", namePlate.jstuf, "BOTTOM", 0+x_offset, -50+y_offset)
		
		if info.w and info.h and (info.atlas or info.tex) then
			if info.atlas then
				namePlate.jstuf.plate_texture:SetAtlas(info.atlas)
			elseif info.tex then
				namePlate.jstuf.plate_texture:SetTexture(info.tex)
			end
			
			if info.color then
				namePlate.jstuf.plate_texture:SetVertexColor(unpack(info.color))
			else
				namePlate.jstuf.plate_texture:SetVertexColor(1, 1, 1)
			end
			
			if info.desaturated then
				namePlate.jstuf.plate_texture:SetDesaturated(true)
			else
				namePlate.jstuf.plate_texture:SetDesaturated(false)
			end
			
			namePlate.jstuf.plate_texture:Show()
		else
			namePlate.jstuf.plate_texture:Hide()
		end
		
		if info.bg_w and info.bg_h and (info.bg_atlas or info.bg_tex) then
			namePlate.jstuf.plate_bgtex:SetSize(info.bg_w, info.bg_h)
			if info.bg_atlas then
				namePlate.jstuf.plate_bgtex:SetAtlas(info.bg_atlas)
			elseif info.bg_tex then
				namePlate.jstuf.plate_bgtex:SetTexture(info.bg_tex)
			end
			
			if info.bg_color then
				namePlate.jstuf.plate_bgtex:SetVertexColor(unpack(info.bg_color))
			else
				namePlate.jstuf.plate_bgtex:SetVertexColor(1, 1, 1)
			end
			
			if info.bg_desaturated then
				namePlate.jstuf.plate_bgtex:SetDesaturated(true)
			else
				namePlate.jstuf.plate_bgtex:SetDesaturated(false)
			end
			
			namePlate.jstuf.plate_bgtex:Show()
		else
			namePlate.jstuf.plate_bgtex:Hide()
		end
		
		if info.text then
			namePlate.jstuf.plate_text:SetText(info.text)
			
			if info.fs then
				namePlate.jstuf.plate_text:SetFont(G.Font, info.fs, "OUTLINE")
			else
				namePlate.jstuf.plate_text:SetFont(G.Font, 20, "OUTLINE")
			end
			
			if info.fc then
				namePlate.jstuf.plate_text:SetTextColor(unpack(info.fc))
			else
				namePlate.jstuf.plate_text:SetTextColor(1, 1, 1)
			end
			
			namePlate.jstuf.plate_text:Show()
		else
			namePlate.jstuf.plate_text:Hide()
		end
	end
end
T.ShowNameplateExtraTex = ShowNameplateExtraTex

local HideNameplateExtraTex = function(unit, GUID)
	local GUID = GUID or UnitGUID(unit)
	
	G.Textured_GUIDs[GUID] = nil
	
	T.HidePlateGlowByUnit("ExtraTex", unit)		
	
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	if namePlate and namePlate.jstuf then
		namePlate.jstuf.plate_texture:Hide()
		namePlate.jstuf.plate_bgtex:Hide()
		namePlate.jstuf.plate_text:Hide()
	end
end
T.HideNameplateExtraTex = HideNameplateExtraTex

local ShowAllNameplateExtraTex = function(tex)
	for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
		ShowNameplateExtraTex(namePlate.namePlateUnitToken, tex)
	end
end
T.ShowAllNameplateExtraTex = ShowAllNameplateExtraTex

local HideAllNameplateExtraTex = function()
	G.Textured_GUIDs = table.wipe(G.Textured_GUIDs)
	
	T.HidePlateGlowByKey("ExtraTex")
	
	for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
		local unitFrame = namePlate.jstuf
		namePlate.jstuf.plate_texture:Hide()
		namePlate.jstuf.plate_bgtex:Hide()
		namePlate.jstuf.plate_text:Hide()
	end
end
T.HideAllNameplateExtraTex = HideAllNameplateExtraTex
---------------------------------------------
--------------  计时圆圈模板  ---------------
---------------------------------------------
local spinnerFunctions = {}

function spinnerFunctions.SetTexture(self, texture)
  for i = 1, 3 do
	self.textures[i]:SetTexture(texture)
  end
end

function spinnerFunctions.Color(self, r, g, b, a)
  for i = 1, 3 do
    self.textures[i]:SetVertexColor(r, g, b, a);
  end
end

function spinnerFunctions.SetProgress(self, region, angle1, angle2)
  self.region = region;
  self.angle1 = angle1;
  self.angle2 = angle2;

  local crop_x = 1.41
  local crop_y = 1.41

  local texRotation = region.effectiveTexRotation or 0
  local mirror_h = region.mirror_h or false;
  if region.mirror then
    mirror_h = not mirror_h
  end
  local mirror_v = region.mirror_v or false;

  local width = region.width + 2 * self.offset;
  local height = region.height + 2 * self.offset;

  if (angle2 - angle1 >= 360) then
    -- SHOW everything
    self.coords[1]:SetFull();
    self.coords[1]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[1]:Show();

    self.coords[2]:Hide();
    self.coords[3]:Hide();
    return;
  end
  if (angle1 == angle2) then
    self.coords[1]:Hide();
    self.coords[2]:Hide();
    self.coords[3]:Hide();
    return;
  end

  local index1 = floor((angle1 + 45) / 90);
  local index2 = floor((angle2 + 45) / 90);

  if (index1 + 1 >= index2) then
    self.coords[1]:SetAngle(width, height, angle1, angle2);
    self.coords[1]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[1]:Show();
    self.coords[2]:Hide();
    self.coords[3]:Hide();
  elseif(index1 + 3 >= index2) then
    local firstEndAngle = (index1 + 1) * 90 + 45;
    self.coords[1]:SetAngle(width, height, angle1, firstEndAngle);
    self.coords[1]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[1]:Show();

    self.coords[2]:SetAngle(width, height, firstEndAngle, angle2);
    self.coords[2]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[2]:Show();

    self.coords[3]:Hide();
  else
    local firstEndAngle = (index1 + 1) * 90 + 45;
    local secondEndAngle = firstEndAngle + 180;

    self.coords[1]:SetAngle(width, height, angle1, firstEndAngle);
    self.coords[1]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[1]:Show();

    self.coords[2]:SetAngle(width, height, firstEndAngle, secondEndAngle);
    self.coords[2]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[2]:Show();

    self.coords[3]:SetAngle(width, height, secondEndAngle, angle2);
    self.coords[3]:Transform(crop_x, crop_y, texRotation, mirror_h, mirror_v)
    self.coords[3]:Show();
  end
end

local defaultTexCoord = {ULx = 0,ULy = 0,LLx = 0,LLy = 1,URx = 1,URy = 0,LRx = 1,LRy = 1}

local function createTexCoord(texture)
  local coord = {
	ULx = 0,ULy = 0,LLx = 0,LLy = 1,URy = 0,LRx = 1,LRy = 1,ULvx = 0,
	ULvy = 0,LLvx = 0,LLvy = 0,URvx = 0,LRvx = 0,LRvy = 0,
	texture = texture
  }

  function coord:MoveCorner(width, height, corner, x, y)
    local rx = defaultTexCoord[corner .. "x"] - x
    local ry = defaultTexCoord[corner .. "y"] - y
    coord[corner .. "vx"] = -rx * width
    coord[corner .. "vy"] = ry * height

    coord[corner .. "x"] = x
    coord[corner .. "y"] = y
  end

  function coord:Hide()
    coord.texture:Hide()
  end

  function coord:Show()
    coord:Apply()
    coord.texture:Show()
  end

  function coord:SetFull()
    coord.ULx = 0;
    coord.ULy = 0;
    coord.LLx = 0;
    coord.LLy = 1;
    coord.URx = 1;
    coord.URy = 0;
    coord.LRx = 1;
    coord.LRy = 1;

    coord.ULvx = 0;
    coord.ULvy = 0;
    coord.LLvx = 0;
    coord.LLvy = 0;
    coord.URvx = 0;
    coord.URvy = 0;
    coord.LRvx = 0;
    coord.LRvy = 0;
  end

  function coord:Apply()
    coord.texture:SetVertexOffset(UPPER_RIGHT_VERTEX, coord.URvx, coord.URvy);
    coord.texture:SetVertexOffset(UPPER_LEFT_VERTEX, coord.ULvx, coord.ULvy);
    coord.texture:SetVertexOffset(LOWER_RIGHT_VERTEX, coord.LRvx, coord.LRvy);
    coord.texture:SetVertexOffset(LOWER_LEFT_VERTEX, coord.LLvx, coord.LLvy);

    coord.texture:SetTexCoord(coord.ULx, coord.ULy, coord.LLx, coord.LLy, coord.URx, coord.URy, coord.LRx, coord.LRy);
  end

  local exactAngles = {
    {0.5, 0},  -- 0°
    {1, 0},    -- 45°
    {1, 0.5},  -- 90°
    {1, 1},    -- 135°
    {0.5, 1},  -- 180°
    {0, 1},    -- 225°
    {0, 0.5},  -- 270°
    {0, 0}     -- 315°
  }

  local function angleToCoord(angle)
    angle = angle % 360;

    if (angle % 45 == 0) then
      local index = floor (angle / 45) + 1;
      return exactAngles[index][1], exactAngles[index][2];
    end

    if (angle < 45) then
      return 0.5 + tan(angle) / 2, 0;
    elseif (angle < 135) then
      return 1, 0.5 + tan(angle - 90) / 2 ;
    elseif (angle < 225) then
      return 0.5 - tan(angle) / 2, 1;
    elseif (angle < 315) then
      return 0, 0.5 - tan(angle - 90) / 2;
    elseif (angle < 360) then
      return 0.5 + tan(angle) / 2, 0;
    end
  end

  local pointOrder = { "LL", "UL", "UR", "LR", "LL", "UL", "UR", "LR", "LL", "UL", "UR", "LR" }

  function coord:SetAngle(width, height, angle1, angle2)
	local index = floor((angle1 + 45) / 90);

    local middleCorner = pointOrder[index + 1];
    local startCorner = pointOrder[index + 2];
    local endCorner1 = pointOrder[index + 3];
    local endCorner2 = pointOrder[index + 4];

    -- LL => 32, 32
    -- UL => 32, -32
    self:MoveCorner(width, height, middleCorner, 0.5, 0.5)
    self:MoveCorner(width, height, startCorner, angleToCoord(angle1));

    local edge1 = floor((angle1 - 45) / 90);
    local edge2 = floor((angle2 -45) / 90);

    if (edge1 == edge2) then
      self:MoveCorner(width, height, endCorner1, angleToCoord(angle2));
    else
      self:MoveCorner(width, height, endCorner1, defaultTexCoord[endCorner1 .. "x"], defaultTexCoord[endCorner1 .. "y"])
    end

    self:MoveCorner(width, height, endCorner2, angleToCoord(angle2));
  end

  local function TransformPoint(x, y, scalex, scaley, texRotation, mirror_h, mirror_v, user_x, user_y)
    -- 1) Translate texture-coords to user-defined center
    x = x - 0.5
    y = y - 0.5

    -- 2) Shrink texture by 1/sqrt(2)
    x = x * 1.4142
    y = y * 1.4142

    -- Not yet supported for circular progress
    -- 3) Scale texture by user-defined amount
    x = x / scalex
    y = y / scaley

    -- 4) Apply mirroring if defined
    if mirror_h then
      x = -x
    end
    if mirror_v then
      y = -y
    end

    local cos_rotation = cos(texRotation)
    local sin_rotation = sin(texRotation)

    -- 5) Rotate texture by user-defined value
    x, y = cos_rotation * x - sin_rotation * y, sin_rotation * x + cos_rotation * y

    -- 6) Translate texture-coords back to (0,0)
    x = x + 0.5
    y = y + 0.5

    x = x + (user_x or 0);
    y = y + (user_y or 0);

    return x, y
  end

  function coord:Transform(scalex, scaley, texRotation, mirror_h, mirror_v, user_x, user_y)

      coord.ULx, coord.ULy = TransformPoint(coord.ULx, coord.ULy, scalex, scaley,
                                            texRotation, mirror_h, mirror_v, user_x, user_y)
      coord.LLx, coord.LLy = TransformPoint(coord.LLx, coord.LLy, scalex, scaley,
                                            texRotation, mirror_h, mirror_v, user_x, user_y)
      coord.URx, coord.URy = TransformPoint(coord.URx, coord.URy, scalex, scaley,
                                            texRotation, mirror_h, mirror_v, user_x, user_y)
      coord.LRx, coord.LRy = TransformPoint(coord.LRx, coord.LRy, scalex, scaley,
                                            texRotation, mirror_h, mirror_v, user_x, user_y)
  end

  return coord
end

local function createSpinner(parent, layer, drawlayer)
  local spinner = {}
  spinner.textures = {}
  spinner.coords = {}
  spinner.offset = 0

  for i = 1, 3 do
    local texture = parent:CreateTexture(nil, layer)
    texture:SetSnapToPixelGrid(false)
    texture:SetTexelSnappingBias(0)
    texture:SetDrawLayer(layer, drawlayer)
    texture:SetAllPoints(parent)
    spinner.textures[i] = texture

    spinner.coords[i] = createTexCoord(texture)
  end

  for k, v in pairs(spinnerFunctions) do
    spinner[k] = v
  end

  return spinner
end

local function AdjustProgress(v, rev)
	local result
	if v < 0 then
		result = 0
	elseif v > 1 then
		result = 1
	end
	if rev then
		result = 1 - v
	else
		result = v
	end
	return result
end

local CircularSetValueFunctions = {
  ["CLOCKWISE"] = function(self, value, tag_index)
    local startAngle = 0
    local endAngle = 360	
	local progress = AdjustProgress(value)	
    local pAngle = 360 * progress
	if tag_index then
		self.tags[tag_index]:SetProgress(self, startAngle, pAngle)
	else
		self.foregroundSpinner:SetProgress(self, startAngle, pAngle)
	end
  end,
  ["ANTICLOCKWISE"] = function(self, value, tag_index)
    local startAngle = 0
    local endAngle = 360	
    local progress = AdjustProgress(value, true)
    local pAngle = 360 * progress
    if tag_index then
		self.tags[tag_index]:SetProgress(self, pAngle, endAngle)
	else
		self.foregroundSpinner:SetProgress(self, pAngle, endAngle)
	end
  end,
}

local function CreateRingCD(parent, color, cd_reverse, bg_alpha)
	local cd = CreateFrame("Frame", parent:GetName().."_JSTCircle", parent)
	
	cd.color = color
	cd.parent = parent
	cd.t = 0
	cd.tags = {}
	cd.next_color = {}
	
	cd:SetPoint("CENTER", parent, "CENTER")
	cd:Hide()
	
	local size = cd.parent:GetWidth()
	cd.width, cd.height = size, size
	cd:SetSize(size, size)
	
	cd.foregroundSpinner = createSpinner(cd, "ARTWORK", 1)
	cd.foregroundSpinner:SetTexture(G.media.ring)
	
	cd.bg = cd:CreateTexture(nil, "BACKGROUND")
	cd.bg:SetTexture(G.media.circle)
	cd.bg:SetAllPoints()
	
	cd.dur_text = T.createtext(cd, "OVERLAY", 20, "OUTLINE", "CENTER")
	cd.dur_text:SetPoint("TOP", cd, "TOP", 0, -10)
	
	cd.orientation = cd_reverse and "CLOCKWISE" or "ANTICLOCKWISE"
	cd.SetValueOnTexture = CircularSetValueFunctions[cd.orientation]

	function cd:SetColor(r, g, b)
		self.foregroundSpinner:Color(r, g, b)
		self.bg:SetVertexColor(r, g, b, bg_alpha or .1)
		self.dur_text:SetTextColor(r, g, b)
	end
		
	function cd:SetTime(duration, expirationTime)
		local progress = 1
		if (duration ~= 0) then
			local remaining = expirationTime - GetTime()
			progress = remaining / duration
			progress = progress > 0.0001 and progress or 0.0001
			self:SetValueOnTexture(progress)
		end
	end
	
	function cd:SetTag(i, duration, info)
		if not self.tags[i] then
			self.tags[i] = createSpinner(cd, "ARTWORK", i+1)
			self.tags[i]:SetTexture(G.media.ring)
		end
		
		local r, g, b = unpack(info.color)
		self.tags[i]:Color(r, g, b)
		
		local progress = 1
		if (duration ~= 0) then
			progress = info.dur / duration
			progress = progress > 0.0001 and progress or 0.0001
			self:SetValueOnTexture(progress, i)
		end
		
		info.tag_index = i
	end
	
	function cd:UpdateColorData(duration, tag_info)
		self.next_color_update = nil -- 清空
		
		if self.next_index then
			self:SetValueOnTexture(0.0001, self.next_index)
		end
			
		for i, info in pairs(tag_info) do
			self.next_color_update = info.dur
			self.next_index = info.tag_index
			for k, v in pairs(info.color) do
				self.next_color[k] = v
			end
			tDeleteItem(tag_info, info)
			break
		end
	end

	function cd:begin(exp_time, duration, tag_info)
		local size = self.parent:GetWidth()
		local r, g, b
		
		if self.color then
			r, g, b = unpack(self.color)
		else
			r, g, b = 1, 1, 1
		end
		
		self.width, self.height = size, size
		self:SetSize(size, size)
		self:SetColor(r, g, b)
		
		if tag_info then
			for i, info in pairs(tag_info) do
				self:SetTag(i, duration, info)
			end
			self.next_index = nil
			self:UpdateColorData(duration, tag_info)		
		end
		
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > 0.02 then
				local remain = exp_time - GetTime()
				if remain > 0 then
					if s.next_color_update and remain <= s.next_color_update then
						s:SetColor(unpack(self.next_color))
						s:UpdateColorData(duration, tag_info)
					end
					
					s:SetTime(duration, exp_time)
					
					if s.cur_text then
						s.dur_text:SetText(string.format("%s %.1f", cd.cur_text, remain))
					else
						s.dur_text:SetText(string.format("%.1f", remain))
					end
				else
					s:Hide()
					s:SetScript("OnUpdate", nil)
					s.dur_text:SetText("")
				end
				s.t = 0
			end
		end)
		
		self:Show()
	end
	
	function cd:stop()
		self:Hide()
		self:SetScript("OnUpdate", nil)
		self.dur_text:SetText("")
	end
	
	return cd
end
T.CreateRingCD = CreateRingCD

---------------------------------------------
---------------  计时条模板  ----------------
---------------------------------------------
local CreateTimerBar = function(parent, icon, glow, midtext, hide, width, height, rgb)
	local w = width or 160
	local h = height or 16
	local color = rgb or {1, .8, .3}

	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetWidth(w)
	bar:SetHeight(h)
	
	bar:SetStatusBarTexture(G.media.blank)
	bar:SetStatusBarColor(unpack(color))
	T.createborder(bar, .25, .25, .25, 1)
	
	if icon then
		bar.icon = bar:CreateTexture(nil, "OVERLAY")
		bar.icon:SetTexCoord( .1, .9, .1, .9)
		bar.icon:SetSize(h, h)
		bar.icon:SetPoint("RIGHT", bar, "LEFT", -2, 0)
		bar.icon:SetTexture(icon)
		
		bar.iconbd = T.createbdframe(bar.icon)	
		
		bar:HookScript("OnSizeChanged", function(self, width, height)
			self.icon:SetSize(height, height)
		end)
	end
	
	bar.rm_text = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "LEFT")
	bar.rm_text:SetPoint("LEFT", bar, "LEFT", 5, 0)
	
	bar.ficon_text = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "LEFT")
	bar.ficon_text:SetPoint("LEFT", bar.rm_text, "RIGHT", 0, 0)
	
	bar.left = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "LEFT")
	bar.left:SetPoint("LEFT", bar.ficon_text, "RIGHT", 0, 0)
	
	bar.ind_text = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "LEFT")
	bar.ind_text:SetPoint("LEFT", bar.left, "RIGHT", 5, 0)
	
	bar.right = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "RIGHT")
	bar.right:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
	
	bar.value_text = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "RIGHT")
	bar.value_text:SetPoint("RIGHT", bar.right, "LEFT", -5, 0)
	
	bar:HookScript("OnSizeChanged", function(self, width, height)
		self.rm_text:SetFont(G.Font, floor(height*.6), "OUTLINE")
		self.ficon_text:SetFont(G.Font, floor(height*.6), "OUTLINE")
		self.left:SetFont(G.Font, floor(height*.6), "OUTLINE")
		self.ind_text:SetFont(G.Font, floor(height*.6), "OUTLINE")
		self.right:SetFont(G.Font, floor(height*.6), "OUTLINE")
		self.value_text:SetFont(G.Font, floor(height*.6), "OUTLINE")
	end)
	
	if midtext then
		bar.mid = T.createtext(bar, "OVERLAY", floor(h*.6), "OUTLINE", "CENTER")
		bar.mid:SetPoint("CENTER", bar, "CENTER", 0, 0)
		bar:HookScript("OnSizeChanged", function(self, width, height)
			self.mid:SetFont(G.Font, floor(height*.6), "OUTLINE")
		end)
	end
	
	if glow then
		bar.glow = CreateFrame("Frame", nil, bar, "BackdropTemplate")
		bar.glow:SetPoint("TOPLEFT", bar, -7, 7)
		bar.glow:SetPoint("BOTTOMRIGHT", bar, 7, -7)
		bar.glow:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\AddOns\\JST\\media\\glow",
			edgeSize = 7,
				insets = { left = 7, right = 7, top = 7, bottom = 7,}
		})
		bar.glow:SetBackdropColor(0, 0, 0, 0)
		bar.glow:SetBackdropBorderColor(unpack(color))
		
		bar.anim = bar:CreateAnimationGroup()
		bar.anim:SetLooping("BOUNCE")
		
		bar.anim:SetScript("OnStop", function(self)
			bar.glow:SetAlpha(1)
		end)
		
		bar.timer = bar.anim:CreateAnimation("Alpha")
		bar.timer:SetChildKey("glow")
		bar.timer:SetDuration(.3)
		bar.timer:SetFromAlpha(1)
		bar.timer:SetToAlpha(.2)
	end

	bar.t = 0
	bar.update_rate = .02
	
	if hide then
		bar:Hide()
	end
	
	return bar
end
T.CreateTimerBar = CreateTimerBar

local CreateTagsforBar = function(bar, tag_num)
	if not bar.tag_indcators then	
		bar.tag_indcators = {}
		bar.tag_perc_data = {}		
		
		function bar:hide_tags()
			for i, tag in pairs(bar.tag_indcators) do
				tag:Hide()
			end
		end
			
		function bar:pointtag(i, perc)
			if bar.tag_indcators[i] then
				if perc then			
					bar.tag_indcators[i]:SetPoint("LEFT", bar, "LEFT", perc*bar:GetWidth(), 0)
					bar.tag_indcators[i]:Show()
					bar.tag_perc_data[i] = perc
				else				
					bar.tag_indcators[i]:ClearAllPoints()
					bar.tag_indcators[i]:Hide()
					bar.tag_perc_data[i] = 0
				end
			end
		end
		
		bar:HookScript("OnSizeChanged", function(self, width, height)
			for i, tag in pairs(bar.tag_indcators) do
				tag:SetSize(2, height)
				local cur_perc = bar.tag_perc_data[i]
				if cur_perc and cur_perc ~= 0 then
					self:pointtag(i, cur_perc)
				end
			end
		end)
	end
	
	for i = 1, tag_num do
		if not bar.tag_indcators[i] then
			local tag = bar:CreateTexture(nil, "OVERLAY")
			tag:SetTexture(G.media.blank)
			tag:SetVertexColor(0, 0, 0)
			tag:SetSize(2, bar:GetHeight())
			
			bar.tag_indcators[i] = tag		
			bar.tag_perc_data[i] = 0
		end
	end
end
T.CreateTagsforBar = CreateTagsforBar

-- bar.count_down_start = 5 -- 倒数开始数字
-- bar.floor_num = true -- 倒数时向下计数
-- bar.count_down_english = true -- 英语倒数
-- bar.mute_count_down = true -- 倒数静音
-- bar.prepare_sound = "add"/{"add", "aoe"}-- 准备音效（于倒数前播放，会占用一个倒数数字）

local StartTimerBar = function(bar, dur, show, dur_text, reverse_fill)
	bar.exp_time = GetTime() + dur
	bar.count_down = bar.count_down_start
	bar.prepare = bar.prepare_sound
	bar:SetMinMaxValues(0, dur)
	
	bar:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > self.update_rate then		
			local remain = self.exp_time - GetTime()
			if remain > 0 then
				if dur_text then
					self.right:SetText(T.FormatTime(remain))
				end
				if reverse_fill then
					self:SetValue(remain)
				else
					self:SetValue(dur - remain)
				end
				
				if self.floor_num then
					self.remain_second = floor(remain)
				else
					self.remain_second = ceil(remain)
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)	
						self.prepare = nil
					elseif not self.mute_count_down then	
						if self.count_down_english then
							T.PlaySound("count_en\\"..self.remain_second)
						else
							T.PlaySound("count\\"..self.remain_second)
						end
					end
					self.count_down = self.remain_second - 1
				end
			else
				self:SetScript("OnUpdate", nil)
				if dur_text then
					self.right:SetText("")
				end
				if reverse_fill then
					self:SetValue(0)
				else
					self:SetValue(dur)
				end
				if show then
					self:Hide()
				end
			end
			self.t = 0
		end
	end)
	if show then
		bar:Show()
	end
end
T.StartTimerBar = StartTimerBar

local StartLoopBar = function(bar, dur, loop, show, dur_text, reverse_fill)
	bar.loop = loop
	bar.exp_time = GetTime() + dur
	bar.count_down = bar.count_down_start
	bar.prepare = bar.prepare_sound 

	bar:SetMinMaxValues(0, dur)
	
	if bar.OnStartLoop then
		bar:OnStartLoop()
	end
	
	bar:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > self.update_rate then		
			local remain = self.exp_time - GetTime()
			if remain > 0 then
				if dur_text then
					self.right:SetText(T.FormatTime(remain))
				end
				
				if reverse_fill then
					self:SetValue(remain)
				else
					self:SetValue(dur - remain)
				end
				
				if self.floor_num then
					self.remain_second = floor(remain)
				else
					self.remain_second = ceil(remain)
				end
				
				if self.count_down and self.remain_second <= self.count_down then
					if self.prepare then
						T.PlaySound(self.prepare)
						self.prepare = nil
					elseif not self.mute_count_down then	
						if self.count_down_english then
							T.PlaySound("count_en\\"..self.remain_second)
						else
							T.PlaySound("count\\"..self.remain_second)
						end
					end
					self.count_down = self.count_down - 1
				end
			else
				if not self.loop then -- 无限循环
					self.exp_time = GetTime() + dur
					if self.OnLoop then
						self:OnLoop()
					end
				else
					self.loop = self.loop - 1
					if self.loop > 0 then -- 有剩余次数
						self.exp_time = GetTime() + dur
						self.count_down = self.count_down_start
						self.prepare = self.prepare_sound
						
						if self.OnLoop then
							self:OnLoop()
						end
					else -- 达到循环次数
						self:SetScript("OnUpdate", nil)
						if dur_text then
							self.right:SetText("")
						end
						if reverse_fill then
							self:SetValue(0)
						else
							self:SetValue(dur)
						end
						if show then
							self:Hide()
						end
					end
				end
			end
			self.t = 0
		end
	end)
	if show then
		bar:Show()
	end
end
T.StartLoopBar = StartLoopBar

local StopTimerBar = function(bar, hide, dur_text, reverse_fill)
	local _, max_v = bar:GetMinMaxValues()
	bar:SetScript("OnUpdate", nil)
	if dur_text then
		bar.right:SetText("")
	end
	if reverse_fill then
		bar:SetValue(0)
	else
		bar:SetValue(max_v)
	end
	if hide then
		bar:Hide()
	end
end
T.StopTimerBar = StopTimerBar

---------------------------------------------
---------------  图标模板  ----------------
---------------------------------------------

local CreateIcon = function(parent, icon_tex, size)
	local icon = CreateFrame("Frame", nil, parent)
	icon:SetSize(size, size)
	icon.t = 0
	
	T.createborder(icon)
	
	icon.tex = icon:CreateTexture(nil, "ARTWORK")
	icon.tex:SetAllPoints()
	icon.tex:SetTexCoord( .1, .9, .1, .9)
	if icon_tex then
		icon.tex:SetTexture(icon_tex)
	end
	
	icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	icon.cooldown:SetAllPoints()
	icon.cooldown:SetDrawEdge(false)
	icon.cooldown:SetHideCountdownNumbers(true)
	icon.cooldown:SetReverse(true)
	
	icon.cover = CreateFrame("Frame", nil, icon)
	icon.cover:SetAllPoints()
	
	icon.trtext = T.createtext(icon.cover, "OVERLAY", floor(size*.5), "OUTLINE", "RIGHT") -- 层数
	icon.trtext:SetPoint("TOPRIGHT", icon.cover, "TOPRIGHT")
	icon.trtext:SetTextColor(0, 1, 1)
	
	icon.rtext = T.createtext(icon.cover, "OVERLAY", floor(size*.5), "OUTLINE", "RIGHT") -- 持续时间
	icon.rtext:SetPoint("LEFT", icon.cover, "RIGHT", 2, 0)
	icon.rtext:SetTextColor(1, 1, 0)
	
	icon.ctext = T.createtext(icon.cover, "OVERLAY", floor(size*.5), "OUTLINE", "RIGHT") -- 冷却时间
	icon.ctext:SetPoint("CENTER", icon.cover, "CENTER")
	
	icon:HookScript("OnSizeChanged", function(self, width, size)
		self.trtext:SetFont(G.Font, floor(size*.3), "OUTLINE")
		self.rtext:SetFont(G.Font, floor(size*.5), "OUTLINE")
		self.ctext:SetFont(G.Font, floor(size*.5), "OUTLINE")
	end)
	
	function icon:update_texture(texture)
		self.tex:SetTexture(texture)
	end
	
	function icon:update_stack(count)
		self.trtext:SetText(count > 0 and count or "")
	end
	
	function icon:stop_cooldown(desaturated)
		self:SetScript("OnUpdate", nil)
		self.ctext:SetText("")
		
		self.cooldown:SetCooldown(0, 0)
		
		if desaturated then
			self.tex:SetDesaturated(false)
		end
	end
	
	function icon:start_cooldown(dur, exp_time, desaturated)
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > .05 then	
				local remain = exp_time - GetTime()
				if remain > 0 then
					s.ctext:SetText(T.FormatTime(remain))
				else
					s:stop_cooldown(desaturated)
				end
				s.t = 0
			end
		end)
		
		local start = exp_time - dur
		self.cooldown:SetCooldown(start, dur)
		
		if desaturated then
			self.tex:SetDesaturated(true)
		end
	end

	function icon:stop(glow)
		self:SetScript("OnUpdate", nil)
		self.rtext:SetText("")
		
		if glow then
			T.PixelGlow_Stop(self, "active_buff")
		end
	end
	
	function icon:start(exp_time, glow)		
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > .05 then	
				local remain = exp_time - GetTime()
				if remain > 0 then
					s.rtext:SetText(T.FormatTime(remain))
				else
					s:stop(glow)
				end
				s.t = 0
			end
		end)
		
		if glow then
			T.PixelGlow_Start(self, {1, 1, 0}, 6, .25, nil, 2, 0, 0, true, "active_buff")
		end
	end
	
	
	return icon
end
T.CreateIcon = CreateIcon

---------------------------------------------
----------------  小圆圈模板  ---------------
---------------------------------------------
local CreateCircle = function(frame, rm, hide)
	local circle = CreateFrame("Frame", nil, frame)
	circle:SetSize(35, 35)
	circle.t = 0
	circle.update_rate = 0.05
	
	circle.tex = circle:CreateTexture(nil, "ARTWORK")
	circle.tex:SetAllPoints()
	circle.tex:SetTexture(G.media.circle)
	
	if rm then
		circle.rt_icon = circle:CreateTexture(nil, "ARTWORK")
		circle.rt_icon:SetPoint("BOTTOM", circle, "TOP", 0, 0)
		circle.rt_icon:SetSize(15, 15)
		circle.rt_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		SetRaidTargetIconTexture(circle.rt_icon, rm)
	end
	
	circle.text = T.createtext(circle, "OVERLAY", 12, "OUTLINE", "CENTER")
	circle.text:SetPoint("CENTER", circle, "CENTER")
	
	circle.t = 0
	circle.update_rate = .05
	
	if hide then
		circle:Hide()
	end
	
	return circle
end
T.CreateCircle = CreateCircle

---------------------------------------------
-------------  可移动框体模板  --------------
---------------------------------------------
T.CreateMovableFrame = function(parent, tag, width, height, point, name, text)
	if not parent[tag] then
		local frame = CreateFrame("Frame", parent:GetName()..(name or "_SubFrame"), parent)	
		if text then
			frame.movingname = string.format("%s [%s]", parent.movingname, text)
		else
			frame.movingname = parent.movingname
		end		
		frame.movingtag = parent.movingtag
		frame:SetSize(width, height)
		frame.point = { a1 = point.a1, a2 = point.a2, x = point.x, y = point.y}
		frame.enable = true
		
		T.CreateDragFrame(frame)
		T.PlaceFrame(frame)
		
		parent[tag]	= frame
		
		if not parent.sub_frames then
			parent.sub_frames = {}
		end
		table.insert(parent.sub_frames, frame)
	end
end

---------------------------------------------
---------------  动画方向箭头  --------------
---------------------------------------------

local tex_info = {
	left = {rotation = -90, color = {1, 0, 0}},
	right = {rotation = 90, color = {0, 1, 0}},
	up = {rotation = 180, color = {1, 1, 0}},
	down = {rotation = 0, color = {1, 1, 0}},
	
	upleft = {rotation = -120, color = {0, 1, 1}},
	upright = {rotation = 120, color = {0, 1, 1}},
	downleft = {rotation = -60, color = {0, 1, 1}},
	downright = {rotation = 60, color = {0, 1, 1}},
}

T.CreateAnimArrow = function(frame)
	frame:SetSize(64, 44)
	
	frame.front_tex = frame:CreateTexture(nil, "OVERLAY") -- 前景材质
	frame.front_tex:SetAllPoints(frame)
	frame.front_tex:SetAtlas("Azerite-PointingArrow")

	frame.bg_tex = frame:CreateTexture(nil, "BORDER") -- 背景材质
	frame.bg_tex:SetPoint("TOPLEFT", frame, "TOPLEFT", -30, 30)
	frame.bg_tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 30, -30)
	frame.bg_tex:SetAtlas("Azerite-PointingArrow")
	
	frame.anim = frame:CreateAnimationGroup()
	frame.anim:SetLooping("REPEAT")
	
	frame.alpha = frame.anim:CreateAnimation("Alpha")
	frame.alpha:SetChildKey("bg_tex")
	frame.alpha:SetDuration(.6)
	frame.alpha:SetFromAlpha(1)
	frame.alpha:SetToAlpha(0.5)
    frame.alpha:SetSmoothing("IN_OUT")
	
	function frame:SetArrowDirection(dir, r, g, b)
		self.front_tex:SetRotation(tex_info[dir].rotation/180*math.pi)
		self.bg_tex:SetRotation(tex_info[dir].rotation/180*math.pi)
		if r and g and b then
			self.front_tex:SetVertexColor(r, g, b)
			self.bg_tex:SetVertexColor(r, g, b)
		else
			self.front_tex:SetVertexColor(unpack(tex_info[dir].color))
			self.bg_tex:SetVertexColor(unpack(tex_info[dir].color))
		end
	end
	
	frame:HookScript("OnShow", function(self)
		self.anim:Play()
	end)
	
	frame:HookScript("OnHide", function(self)
		self.anim:Stop()
	end)
end

--------------------------------------------------------
-------------------  小地图修改  ---------------------
--------------------------------------------------------
if not C_AddOns.IsAddOnLoaded("Blizzard_TimeManager") then C_AddOns.LoadAddOn("Blizzard_TimeManager") end
local MapData = {}
G.Minimapdata = MapData

T.UpdateMinimap = function(...)
	MapData.updated = true
	
	Minimap:EnableMouse(false)
	MinimapCluster:EnableMouse(false)
	
	--Minimap:SetPlayerTexture("Interface\\MINIMAP\\MiniMap-QuestArrow")
	--MapData.mask_tex = MinimapCluster:GetMaskTexture()
	Minimap:SetMaskTexture(G.media.blank)
	MinimapCluster:SetScale(1.2)
	MinimapCluster:SetAlpha(.7)
	Minimap:SetZoom(0)
	
	MapData.points = {Minimap:GetPoint()}
	Minimap:ClearAllPoints()
	Minimap:SetPoint(...)
	
	--MinimapCompassTexture:SetAlpha(0)
	--local BorderTopTextures = {"Center", "TopEdge", "LeftEdge", "RightEdge", "BottomEdge", "BottomLeftCorner", "BottomRightCorner", "TopLeftCorner", "TopRightCorner"}
	--for i, key in pairs(BorderTopTextures) do
	--	MinimapCluster.BorderTop[key]:SetAlpha(0)
	--end
	
	--GameTimeFrame:Hide()
	--AddonCompartmentFrame:Hide()
	--TimeManagerClockTicker:Hide()
	--MinimapCluster.Tracking:Hide()
	--MinimapCluster.ZoneTextButton:Hide()
	--MinimapCluster.IndicatorFrame.MailFrame:Hide()
	--MinimapCluster.IndicatorFrame.CraftingOrderFrame:Hide()
	--ExpansionLandingPageMinimapButton:Hide()
	--MinimapCluster.InstanceDifficulty:Hide()
end

T.RestoreMinimap = function()
	MapData.updated = false
	
	Minimap:EnableMouse(true)
	MinimapCluster:EnableMouse(true)
	
	--Minimap:SetPlayerTexture("Interface\\WorldMap\\WorldMapArrow")
	MinimapCluster:SetScale(1)
	MinimapCluster:SetAlpha(1)
	
	if MapData.points then
		Minimap:ClearAllPoints()
		Minimap:SetPoint(unpack(MapData.points))
	end
	
	--MinimapCompassTexture:SetAlpha(1)
	--local BorderTopTextures = {"Center", "TopEdge", "LeftEdge", "RightEdge", "BottomEdge", "BottomLeftCorner", "BottomRightCorner", "TopLeftCorner", "TopRightCorner"}
	--for i, key in pairs(BorderTopTextures) do
	--	MinimapCluster.BorderTop[key]:SetAlpha(1)
	--end
	
	--GameTimeFrame:Show()
	--AddonCompartmentFrame:Show()
	--TimeManagerClockTicker:Show()
	--MinimapCluster.Tracking:Show()
	--MinimapCluster.ZoneTextButton:Show()
	--MinimapCluster.IndicatorFrame.MailFrame:Show()
	--MinimapCluster.IndicatorFrame.CraftingOrderFrame:Show()
	--ExpansionLandingPageMinimapButton:Show()
	--MinimapCluster.InstanceDifficulty:Show()
end

---------------------------------------------
-----------------  选项模板  ----------------
---------------------------------------------
local function GetBossModData(frame)	
	local k, j
	for section_index, section_data in pairs(G.Encounters[frame.encounterID].alerts) do
		for index, args in pairs(section_data.options) do
			if args.category == "BossMod" and args.spellID == frame.config_id then
				k = section_index
				j = index
				break
			end
		end
	end
	return {frame.encounterID, "alerts", k, "options", j}
end
T.GetBossModData = GetBossModData

local function GetFrameInfoData(frame, key)
	if frame.info then
		for index, info in pairs(frame.info) do
			if info[key] then
				return true
			end
		end
	end
end

-- 选项模板1 点名模板
T.GetElementsCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	if frame.element_type == "circle" then
		table.insert(data.custom, {key = "size_sl", text = L["尺寸"], default = 100, min = 80, max = 150, apply = function(value, alert)
			alert:SetScale(value/100)			
		end})
	else
		table.insert(data.custom, {key = "width_sl", text = L["长度"], default = 180, min = 100, max = 300, apply = function(value, alert)
			alert:SetWidth(value)
			for _, bar in pairs(alert.elements) do
				bar:SetWidth(value)
			end
		end})
		table.insert(data.custom, {key = "height_sl", text = L["高度"], default = 20, min = 16, max = 30, apply = function(value, alert)
			alert:SetHeight((value+2)*(alert.info and #alert.info or 6) - 2 + (alert.bar and 22 or 0) + (alert.bar2 and 22 or 0))
			for _, bar in pairs(alert.elements) do
				bar:SetHeight(value)	
			end
		end})
	end
	
	if frame.raid_glow then
		if frame.raid_glow == "pixel" then
			table.insert(data.custom, {key = "raid_glow_bool", text = L["团队框架虚线动画"], default = true})
		elseif frame.raid_glow == "proc" then
			table.insert(data.custom, {key = "raid_glow_bool", text = L["团队框架发光"], default = true})
		else
			table.insert(data.custom, {key = "raid_glow_bool", text = L["团队框架高亮"], default = true})
		end
	end
	if frame.raid_index then
		table.insert(data.custom, {key = "raid_index_bool", text = L["团队序号"], default = true})
	end
	
	if GetFrameInfoData(frame, "msg_applied") or GetFrameInfoData(frame, "msg") then
		table.insert(data.custom, {key = "say_bool", text = L["喊话"], default = true})
	end
	if GetFrameInfoData(frame, "rm") then
		table.insert(data.custom, {key = "mark_bool", text = L["标记"], default = false})
	end

	if frame.pa_icon then
		table.insert(data.custom, {key = "pa_icon_bool", text = L["PA图标提示"], default = true, apply = function(value, alert)
			T.Toggle_Subframe_moving(alert, alert.paicon, value)	
		end})
		table.insert(data.custom, {key = "pa_icon_alpha_sl", text = L["PA图标提示"]..L["透明度"], default = 30, min = 10, max = 100, apply = function(value, alert)
			alert.paicon:SetAlpha(value/100)
		end})
	end
	if frame.macro_button then
		table.insert(data.custom, {key = "macro_button_bool", text = L["交互宏按钮"], default = false, apply = function(value, alert)	
			T.Toggle_Subframe_moving(alert, alert.macrobuttons, value)		
		end})
	end
	if frame.support_spells then
		table.insert(data.custom, {key = "option_list_btn", text = L["支援技能设置"], default = {}})
	end	
	if frame.copy_mrt then
		table.insert(data.custom, {key = "mrt_custom_btn"})
	end
end

-- 选项模板2 计时条组 光环组、小怪血量
T.GetBarsCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	table.insert(data.custom, {key = "width_sl", text = L["长度"], default = frame.default_bar_width or 180, min = 100, max = 300, apply = function(value, alert)
		alert:SetWidth(value)
		if alert.bars then
			for tag, bar in pairs(alert.bars) do
				bar:SetWidth(value)
			end
		end
	end})
	
	table.insert(data.custom, {key = "height_sl", text = L["高度"], default = frame.default_bar_height or 20, min = 16, max = 40, apply = function(value, alert)		
		if alert.bar_num then
			alert:SetHeight((value+2)*alert.bar_num-2)
		elseif alert.ficon == "0" then
			alert:SetHeight((value+2)*2-2)
		else
			alert:SetHeight((value+2)*4-2)
		end
		if alert.bars then
			for tag, bar in pairs(alert.bars) do
				bar:SetHeight(value)	
			end
		end
	end})
end

-- 选项模板3 单独计时条
T.GetSingleBarCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	table.insert(data.custom, {key = "width_sl", text = L["长度"], default = frame.default_bar_width or 200, min = 100, max = 500, apply = function(value, alert)
		alert:SetWidth(value)
		alert.bar:SetWidth(value)	
	end})
	
	table.insert(data.custom, {key = "height_sl", text = L["高度"], default = frame.default_bar_height or 25, min = 20, max = 40, apply = function(value, alert)
		alert:SetHeight(value)
		alert.bar:SetHeight(value)	
	end})
end

-- 选项模板4 图形大小+显示秒数 圆圈、射线
T.GetFigureCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end

	table.insert(data.custom, {key = "size_sl", text = L["大小"], default = 150, min = 80, max = 200, apply = function(value, alert)
		alert:SetSize(value, value)
	end})
	
	table.insert(data.custom, {key = "text_bool", text = L["显示秒数"], default = true, apply = function(value, alert)
		alert:ToggleText(value)		
	end})
end

-- 选项模板5 尺寸修改
T.GetScaleCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	table.insert(data.custom, {key = "scale_sl", text = L["尺寸"], default = 100, min = 80, max = 150, apply = function(value, alert)
		alert:SetScale(value/100)
	end})

	if frame.copy_mrt then
		table.insert(data.custom, {key = "mrt_custom_btn"})
	end
end

-- 选项模板6 字号修改
T.GetFontSizeCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	table.insert(data.custom, {key = "fontsize_sl", text = L["字体大小"], default = frame.default_fontsize or 25, min = 20, max = 60, apply = function(value, alert)
		alert:SetSize(alert.width or 200, value)
		alert.text:SetFont(G.Font, value, "OUTLINE")
	end})
	
	if frame.copy_mrt then
		table.insert(data.custom, {key = "mrt_custom_btn"})
	end
end

-- 选项模板7 技能分配
T.GetSpellAssignCustomData = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	if frame.raid_glow then
		if frame.raid_glow == "pixel" then
			table.insert(data.custom, {key = "raid_glow_bool", text = L["团队框架虚线动画"], default = true})
		elseif frame.raid_glow == "proc" then
			table.insert(data.custom, {key = "raid_glow_bool", text = L["团队框架发光"], default = true})
		else
			table.insert(data.custom, {key = "raid_glow_bool", text = L["团队框架高亮"], default = true})
		end
	end
	
	if frame.send_msg then
		table.insert(data.custom, {key = "say_bool", text = L["喊话"], default = true})
	end
	
	if frame.copy_mrt then
		table.insert(data.custom, {key = "mrt_custom_btn"})
	end
end

--------------------------------------------------------
--------------  [首领模块]自保技能提示 API -------------
--------------------------------------------------------

local function CreatePersonalSpellAlertBase(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end

	table.insert(data.custom, {
		key = "hp_perc_sl",
		text = L["血量阈值百分比"],
		default = frame.threshold or 65,
		min = 20,
		max = 100,
	})
	
	frame.check = false
	
	function frame:ActiveCheck()
		if not frame.check then
			frame.check = true
			T.AddPersonalSpellCheckTag("bossmod"..frame.config_id, C.DB["BossMod"][frame.config_id]["hp_perc_sl"], frame.ignore_roles)
		end
	end
	
	function frame:RemoveCheck()
		if frame.check then
			frame.check = false
			T.RemovePersonalSpellCheckTag("bossmod"..frame.config_id)
		end
	end
end
T.CreatePersonalSpellAlertBase = CreatePersonalSpellAlertBase

local function ResetPersonalSpellAlertBase(frame)
	frame:RemoveCheck()
end
T.ResetPersonalSpellAlertBase = ResetPersonalSpellAlertBase

--------------------------------------------------------
---------  [首领模块]法术圆圈计时器模板 CLEU -----------
--------------------------------------------------------
-- event: COMBAT_LOG_EVENT_UNFILTERED

--		frame.spellIDs = {
--			[8936] = {
--				event = "SPELL_AURA_APPLIED",
--				target_me = true, -- 目标是我
--				dur = 4.5, -- 持续时间
--				color = {0, 1, 0}, -- 颜色，默认白色
--				reverse = true, -- [可选]逆时针
--				sound = "dropnow", -- [可选]声音
--				msg = "%spell", -- [可选]消息
--			},
--		}

T.InitCircleTimers = function(frame)	
	frame.figures = {}	

	if frame.spellIDs then	
		for k, v in pairs(frame.spellIDs) do
			frame.figures[k] = CreateRingCD(frame, v.color, v.reverse)
		end
	end
	
	function frame:PreviewShow()
		for k, v in pairs(frame.spellIDs) do
			local circle = frame.figures[k]
			circle:begin(GetTime() + v.dur, v.dur)
			break
		end
	end
	
	function frame:PreviewHide()
		for k, v in pairs(frame.spellIDs) do
			local circle = frame.figures[k]
			circle:stop()
			break
		end
	end
	
	function frame:ToggleText(value)
		for spell, figure in pairs(self.figures) do
			figure.dur_text:SetShown(value)
		end	
	end

	T.GetFigureCustomData(frame)
end

T.UpdateCircleTimers = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
		if frame.spellIDs and frame.spellIDs[spellID] and sub_event == frame.spellIDs[spellID]["event"] then -- 开始
			local info = frame.spellIDs[spellID]
			if not info.target_me or G.PlayerGUID == destGUID then
				local cd_tex = frame.figures[spellID]
				cd_tex:begin(GetTime() + info.dur, info.dur)
				if info.sound then
					T.PlaySound(info.sound)
				end
				if info.msg then
					T.SendAuraMsg(info.msg, "SAY", spellName)
				end
			end
		end	
	end
end

T.ResetCircleTimers = function(frame)
	for k, cd_tex in pairs(frame.figures) do
		cd_tex:stop()
	end
	frame:Hide()
end

--------------------------------------------------------
-------  [首领模块]法术圆圈计时器模板 UNIT_AURA -------- 
--------------------------------------------------------
-- event: UNIT_AURA

--		frame.spellIDs = {
--			[8936] = {	
--				unit = "player", -- 监控单位 默认 "player"
--				aura_type = "HARMFUL", -- 光环类型 默认 "HARMFUL"
--				color = {0, 1, 0}, -- 颜色
--				reverse = true, -- [可选]逆时针
--				sound = "dropnow", -- [可选]声音
--				msg = "%spell", -- [可选]消息
--			},
--		} 		

T.InitUnitAuraCircleTimers = function(frame)
	frame.figures = {}
	frame.watched_units = {}
	frame.watched_auraTypes = {}
	
	for k, v in pairs(frame.spellIDs) do
		v.unit = v.unit or "player"
		v.aura_type = v.aura_type or "HARMFUL"
		
		if not frame.watched_units[v.unit] then
			frame.watched_units[v.unit] = true
		end	
		if not frame.watched_auraTypes[v.aura_type] then
			frame.watched_auraTypes[v.aura_type] = true
		end
	end
	
	for k, v in pairs(frame.spellIDs) do
		frame.preview_tex = CreateRingCD(frame, v.color, v.reverse)
		break
	end
	
	function frame:PreviewShow()
		for k, v in pairs(frame.spellIDs) do
			frame.preview_tex:begin(GetTime() + 25, 25)
			break
		end
	end
	
	function frame:PreviewHide()
		frame.preview_tex:stop()
	end
	
	function frame:ToggleText(value)
		for spell, figure in pairs(self.figures) do
			figure.dur_text:SetShown(value)
		end
		frame.preview_tex.dur_text:SetShown(value)
	end
	
	T.GetFigureCustomData(frame)
end

T.UpdateUnitAuraCircleTimers = function(frame, event, ...)
	if event == "UNIT_AURA" then
		local unit, updateInfo = ...
		if not frame.watched_units[unit] then return end
		if updateInfo == nil or updateInfo.isFullUpdate then
			for auraID, cd_tex in pairs(frame.figures) do
				cd_tex:stop()
				frame.figures[auraID] = nil
			end
			
			for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
				if frame.watched_auraTypes[auraType] then
					AuraUtil.ForEachAura(unit, auraType, nil, function(AuraData)
						local info = frame.spellIDs[AuraData.spellId]
						if info and info.unit == unit then
							local auraID = AuraData.auraInstanceID
							if not frame.figures[auraID] then
								local cd_tex = CreateRingCD(frame, info.color, info.reverse)
								
								if info.sound then
									T.PlaySound(info.sound)
								end
								if info.msg then
									T.SendAuraMsg(info.msg, "SAY", AuraData.name)
								end
								
								cd_tex:begin(AuraData.expirationTime, AuraData.duration)
								frame.figures[auraID] = cd_tex
							end
						end
					end, true)
				end
			end
		else
			if updateInfo.addedAuras ~= nil then
				for _, AuraData in pairs(updateInfo.addedAuras) do
					local auraID = AuraData.auraInstanceID
					local spellID = AuraData.spellId
					local info = frame.spellIDs[spellID]
					if info and unit == info.unit then					
						if not frame.figures[auraID] then
							local cd_tex = CreateRingCD(frame, info.color, info.reverse)
							cd_tex:begin(AuraData.expirationTime, AuraData.duration)
							
							if info.sound then
								T.PlaySound(frame.spellIDs[spellID].sound)
							end
							if info.msg then
								T.SendAuraMsg(info.msg, "SAY", AuraData.name)
							end
								
							frame.figures[auraID] = cd_tex
						end
					end
				end
			end
			if updateInfo.updatedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do		
					local cd_tex = frame.figures[auraID]
					if cd_tex then
						local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
						if AuraData then
							local spellID = AuraData.spellId
							cd_tex:begin(AuraData.expirationTime, AuraData.duration)
						else
							cd_tex:stop()
							frame.figures[auraID] = nil
						end
					end
				end
			end
			if updateInfo.removedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
					local cd_tex = frame.figures[auraID]
					if cd_tex then
						cd_tex:stop()
						frame.figures[auraID] = nil
					end				
				end
			end
		end
	end
end

T.ResetUnitAuraCircleTimers = function(frame)
	for k, cd_tex in pairs(frame.figures) do
		cd_tex:stop()
	end
	frame:Hide()
end

--------------------------------------------------------
---------  [首领模块]法术圆圈计时器模板 CAST -----------
--------------------------------------------------------
-- event: UNIT_SPELLCAST_START
-- event: UNIT_SPELLCAST_STOP
-- event: UNIT_TARGET

--		frame.spellIDs = {
--			[8936] = {
--				color = {0, 1, 0}, -- 颜色，默认白色
--				reverse = true, -- [可选]逆时针
--				sound = "dropnow", -- [可选]声音
--				msg = "%spell", -- [可选]消息
--			},
--		}

T.InitCircleCastTimers = function(frame)	
	frame.figures = {}
	frame.delay = frame.delay or .2
	
	function frame:PreviewShow()
		for k, v in pairs(self.spellIDs) do
			if not self.figures.test then
				self.figures.test = CreateRingCD(self, v.color, v.reverse)
			end
			self.figures.test:begin(GetTime() + 3, 3)
			break
		end	
	end
	
	function frame:PreviewHide()
		if not self.figures.test then
			self.figures.test:stop()
		end
	end
	
	function frame:ToggleText(value)
		for spell, figure in pairs(self.figures) do
			figure.dur_text:SetShown(value)
		end
	end

	T.GetFigureCustomData(frame)
end

T.UpdateCircleCastTimers = function(frame, event, ...)
	if event == "UNIT_SPELLCAST_START" then
		local unit, cast_GUID, cast_spellID = ...
		if unit and cast_GUID and cast_spellID then
			if frame.spellIDs and frame.spellIDs[cast_spellID] then -- 开始
				C_Timer.After(frame.delay, function()
					local target_unit = T.GetTarget(unit)
					if target_unit and UnitIsUnit(target_unit, "player") then
						local name, _, _, startTimeMS, endTimeMS = UnitCastingInfo(unit)
						if startTimeMS and endTimeMS then
							local info = frame.spellIDs[cast_spellID]
							local dur = (endTimeMS - startTimeMS)/1000
							local exp_time = endTimeMS/1000
							
							if not frame.figures[cast_GUID] then
								frame.figures[cast_GUID] = CreateRingCD(frame, info.color, info.reverse)
								frame.figures[cast_GUID]:begin(exp_time, dur)
								
								if info.sound then
									T.PlaySound(info.sound)
								end
								if info.msg then
									T.SendAuraMsg(info.msg, "SAY", name)
								end
							end
						end
					end
				end)
			end
		end
	elseif event == "UNIT_SPELLCAST_STOP" then
		local unit, cast_GUID, spellID = ...
		if cast_GUID and frame.figures[cast_GUID] then
			frame.figures[cast_GUID]:stop()
		end
	elseif event == "UNIT_TARGET" then
		local unit = ...
		if unit and UnitCastingInfo(unit) then
			local name, _, _, startTimeMS, endTimeMS, _, cast_GUID, _, cast_spellID = UnitCastingInfo(unit)
			if cast_GUID then
				local target_unit = T.GetTarget(unit)
				if target_unit and UnitIsUnit(target_unit, "player") then
					if frame.spellIDs and frame.spellIDs[cast_spellID] and not frame.figures[cast_GUID] then
						local info = frame.spellIDs[cast_spellID]
						local dur = (endTimeMS - startTimeMS)/1000
						local exp_time = endTimeMS/1000
						
						if not frame.figures[cast_GUID] then
							frame.figures[cast_GUID] = CreateRingCD(frame, info.color, info.reverse)
							frame.figures[cast_GUID]:begin(exp_time, dur)
							
							if info.msg then
								T.SendAuraMsg(info.msg, "SAY", name)
							end
							if info.sound then
								T.PlaySound(info.sound)
							end
						end
					end
				else
					if frame.figures[cast_GUID] then
						frame.figures[cast_GUID]:stop()
					end
				end
			end
		end
	end
end

T.ResetCircleCastTimers = function(frame)
	for k, cd_tex in pairs(frame.figures) do
		cd_tex:stop()
		if k ~= "test" then
			frame.figures[k] = nil
		end
	end
	frame:Hide()
end

--------------------------------------------------------
---------  [首领模块]点名密语计时圆圈 -----------
--------------------------------------------------------
-- event: CHAT_MSG_RAID_BOSS_WHISPER

--		frame.keywords = {
--			["8936"] = {
--				color = {0, 1, 0}, -- 颜色，默认白色
--				reverse = true, -- [可选]逆时针
--				sound = "dropnow", -- [可选]声音
--				msg = "%spell", -- [可选]消息			
--			},
--		}

T.InitCircleMsgTimers = function(frame)	
	frame.figures = {}
	frame.delay = frame.delay or .2
	
	function frame:PreviewShow()
		for k, v in pairs(frame.keywords) do
			if not self.figures.test then
				self.figures.test = CreateRingCD(self, v.color, v.reverse)
			end
			self.figures.test:begin(GetTime() + v.dur, v.dur)
			break
		end	
	end
	
	function frame:PreviewHide()
		if not self.figures.test then
			self.figures.test:stop()
		end
	end
	
	function frame:ToggleText(value)
		for spell, figure in pairs(self.figures) do
			figure.dur_text:SetShown(value)
		end
	end

	T.GetFigureCustomData(frame)
end

T.UpdateCircleMsgTimers = function(frame, event, ...)
	if frame.events[event] then
		local msg = ...
		for k, info in pairs(frame.keywords) do
			if string.find(msg, k)  then -- 开始
				if not frame.figures[k] then
					frame.figures[k] = CreateRingCD(frame, info.color, info.reverse)
				end
				frame.figures[k]:begin(GetTime() + info.dur, info.dur)
				
				if info.sound then
					T.PlaySound(info.sound)
				end
				if info.msg then
					local spellID = tonumber(k)
					local spellName = spellID and C_Spell.GetSpellName(spellID) or ""
					T.SendAuraMsg(info.msg, "SAY", spellName)
				end
			end	
		end
	end
end

T.ResetCircleMsgTimers = function(frame)
	for k, cd_tex in pairs(frame.figures) do
		cd_tex:stop()
		if k ~= "test" then
			frame.figures[k] = nil
		end
	end
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]自动标记模板  ---------------
--------------------------------------------------------
-- event: ENCOUNTER_ENGAGE_UNIT/ENCOUNTER_SHOW_BOSS_UNIT
-- event: NAME_PLATE_UNIT_ADDED
-- event: UNIT_TARGET

--		frame.start_mark = 6 -- 开始标记
--		frame.end_mark = 8 -- 结束标记
--		frame.mob_npcID = "181856" -- NpcID
--		frame.ignore_combat = true -- (可选 忽略是否进战斗)
--		frame.use_stored_mark = true -- (可选 同一个怪物使用相同的标记)

T.InitRaidTarget = function(frame)
	frame.marked = {}
	frame.storedGUIDs = {}
	frame.counter = frame.start_mark - 1
	
	function frame:Get_counter(GUID)
		if self.use_stored_mark and self.storedGUIDs[GUID] then
			return self.storedGUIDs[GUID]
		else
			if self.counter < self.end_mark then
				self.counter = self.counter + 1
			else
				self.counter = self.start_mark
			end
			self.storedGUIDs[GUID] = self.counter
			return self.counter
		end
	end
	
	function frame:Mark(unit, GUID)
		if (not self.trigger or self:trigger(unit, GUID)) and (not IsEncounterInProgress() or self.ignore_combat or UnitAffectingCombat(unit)) then
			local mark_index = self:Get_counter(GUID)
			T.SetRaidTarget(unit, mark_index)
			self.marked[GUID] = true
			
			local npcID = select(6, strsplit("-", GUID))
			local mark = T.FormatRaidMark(mark_index)
			T.msg(string.format(L["已标记%s"], date("%H:%M:%S"), T.GetNameFromNpcID(npcID), mark))
		end
	end
end

T.UpdateRaidTarget = function(frame, event, ...)
	if event == "ENCOUNTER_ENGAGE_UNIT" or event == "ENCOUNTER_SHOW_BOSS_UNIT" then
		local unit, GUID = ...
		local npcID = select(6, strsplit("-", GUID))
		if npcID and npcID == frame.mob_npcID and not frame.marked[GUID] then
			frame:Mark(unit, GUID)
		end
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local unit = ...
		local GUID = UnitGUID(unit)
		local npcID = select(6, strsplit("-", GUID))
		if npcID and npcID == frame.mob_npcID and not frame.marked[GUID] then
			frame:Mark(unit, GUID)
		end
	elseif event == "UNIT_TARGET" then
		local unit = ...
		if T.FilterGroupUnit(unit) then
			local target_unit = T.GetTarget(unit)
			if target_unit and not UnitIsDeadOrGhost(target_unit) then
				local GUID = UnitGUID(target_unit)
				local npcID = select(6, strsplit("-", GUID))
				if npcID and npcID == frame.mob_npcID then -- 确认过眼神
					if not frame.marked[GUID] then
						frame:Mark(target_unit, GUID)
					end
				end
			end
		end
	elseif event == "ENCOUNTER_START" then
		for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
			local unit = namePlate.namePlateUnitToken
			local GUID = UnitGUID(unit)
			local npcID = select(6, strsplit("-", GUID))
			if npcID and npcID == frame.mob_npcID and not frame.marked[GUID] then
				frame:Mark(unit, GUID)
			end
		end
	end
end

T.ResetRaidTarget = function(frame)
	frame.marked = table.wipe(frame.marked)
	frame.storedGUIDs = table.wipe(frame.storedGUIDs)
	frame.counter = frame.start_mark - 1
end

--------------------------------------------------------
------------------   小怪监控模板 API  -----------------
--------------------------------------------------------

local CreatePreviewBar = function(frame, npcID, info, i, extra_bar)	
	if not frame.bars[npcID..i] then
		local w = C.DB["BossMod"][frame.config_id]["width_sl"]
		local h = C.DB["BossMod"][frame.config_id]["height_sl"]
		
		local bar = CreateTimerBar(frame, nil, false, true, false, w, h, info.color)
		bar:SetMinMaxValues(0, 1000000)
		
		if extra_bar then
			bar.extra_bar = CreateFrame("StatusBar", nil, bar)
			bar.extra_bar:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT")
			bar.extra_bar:SetWidth(w)
			bar.extra_bar:SetHeight(h*.25)
			bar.extra_bar:SetStatusBarTexture(G.media.blank)
			bar.extra_bar:SetStatusBarColor(unpack(info.color2))
			bar.extra_bar:SetMinMaxValues(0, 100)
			
			bar:HookScript("OnSizeChanged", function(self, width, height)
				self.extra_bar:SetWidth(width)
				self.extra_bar:SetHeight(height*.25)
			end)
		end
		
		bar.rt_icon = bar:CreateTexture(nil, "OVERLAY")
		bar.rt_icon:SetSize(h, h)
		bar.rt_icon:SetPoint("LEFT", bar, "LEFT", 0, 0)
		bar.rt_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		SetRaidTargetIconTexture(bar.rt_icon, i)
		
		bar.left:ClearAllPoints()
		bar.left:SetPoint("LEFT", bar.rt_icon, "RIGHT", 5, 0)
		bar.left:SetText(info.n or T.GetNameFromNpcID(npcID))
		
		frame.bars[npcID..i] = bar
	end
	
	local bar = frame.bars[npcID..i]
	
	local hp = math.random(1000000)
	bar:SetValue(hp)
	if frame.format == "value" then
		bar.right:SetText(T.ShortValue(hp))
	else
		bar.right:SetText(floor(hp/10000))
	end
	
	if extra_bar then
		bar.extra_bar:SetValue(math.random(100))
	end
end

local InitUnitFrameMod = function(frame)
	frame.bars = {}
	frame.sort_bars = {}
	frame.watched_auraTypes = {}
	
	T.GetBarsCustomData(frame)
	
	if frame.auras then		
		for k, v in pairs(frame.auras) do
			if not frame.watched_auraTypes[v.aura_type] then
				frame.watched_auraTypes[v.aura_type] = true
			end
		end
	end
	
	function frame:lineup()
		self.sort_bars = table.wipe(self.sort_bars)
		
		for _, bar in pairs(self.bars) do
			table.insert(self.sort_bars, bar)
		end
		
		if frame.sort then
			frame:sort()
		end
		
		local lastbar
		for GUID, bar in pairs(self.sort_bars) do
			bar:ClearAllPoints()
			if not lastbar then
				bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			else
				bar:SetPoint("TOPLEFT", lastbar, "BOTTOMLEFT", 0, -2)		
			end
			lastbar = bar
		end
	end
	
	function frame:remove_bar(GUID)
		if self.bars[GUID] then
			self.bars[GUID]:Hide()
			self.bars[GUID] = nil
			self:lineup()
		end
	end
	
	function frame:PreviewShow()
		local num = self.bar_num or 2		
		for npcID, info in pairs(self.npcIDs) do
			for i = 1, num do
				CreatePreviewBar(self, npcID, info, i, info.color2)	
			end
		end		
		self:lineup()
	end
	
	function frame:PreviewHide()
		for tag, bar in pairs(self.bars) do
			bar:ClearAllPoints()
			bar:Hide()
		end
		self.bars = table.wipe(self.bars)
	end
end

local CreateAuraIcon = function(frame, bar, auraID)
	local icon_size = C.DB["BossMod"][frame.config_id]["height_sl"]
	
	local icon = CreateFrame("Frame", nil, bar)
	icon:SetSize(icon_size, icon_size)
	
	T.createborder(icon)
	icon.t = 0
	icon.tag = auraID
	
	icon.tex = icon:CreateTexture(nil, "ARTWORK")
	icon.tex:SetAllPoints()
	icon.tex:SetTexCoord( .1, .9, .1, .9)
		
	icon.count = T.createtext(icon, "OVERLAY", 12, "OUTLINE", "RIGHT")
	icon.count:SetPoint("TOPRIGHT", icon, "TOPRIGHT")
	
	icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	icon.cooldown:SetAllPoints()
	icon.cooldown:SetDrawEdge(false)
	icon.cooldown:SetHideCountdownNumbers(true)
	icon.cooldown:SetReverse(true)
	
	function icon:update_texture(texture)
		self.tex:SetTexture(texture)
	end
	
	function icon:update_stack(count)
		self.count:SetText(count > 0 and count or "")
	end
	
	function icon:stop()
		self:ClearAllPoints()
		self:Hide()
		self:SetScript("OnUpdate", nil)
		
		bar.icons[self.tag] = nil
		bar:lineup_icons()
	end
	
	function icon:start(dur, exp_time)
		if dur and exp_time and dur > 0 and exp_time - GetTime() > 0 then
			self.cooldown:SetCooldown(exp_time - dur, dur)
			self:SetScript("OnUpdate", function(s, e)
				s.t = s.t + e
				if s.t > .05 then	
					local remain = exp_time - GetTime()
					if remain < 0 then
						s:stop()
					end
					s.t = 0
				end
			end)
		end
	end
	
	return icon
end

local AuraFullCheck = function(frame, unit, bar)
	for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
		if frame.watched_auraTypes[auraType] then	
			AuraUtil.ForEachAura(unit, auraType, nil, function(AuraData)
				if frame.auras[AuraData.spellId] and not bar.icons[AuraData.auraInstanceID] then
					bar:add_auraicon(AuraData.auraInstanceID, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime)
					bar:update_color(unit)
				end
			end, true)
		end
	end
end

local CreateUFBar = function(frame, GUID, extra_bar)	
	local w = C.DB["BossMod"][frame.config_id]["width_sl"]
	local h = C.DB["BossMod"][frame.config_id]["height_sl"]
	local npcID = select(6, strsplit("-", GUID))
	local info = frame.npcIDs[npcID]
	
	local bar = CreateTimerBar(frame, nil, false, false, false, w, h, info.color)
	bar.GUID = GUID
	bar.npcID = npcID
	
	bar.absorb_bar = CreateFrame("StatusBar", nil, bar)
	bar.absorb_bar:SetPoint("LEFT", bar, "RIGHT")
	bar.absorb_bar:SetWidth(w)
	bar.absorb_bar:SetHeight(h)
	bar.absorb_bar:SetStatusBarTexture(G.media.blank)
	bar.absorb_bar:SetStatusBarColor(.6, 1, 1, .4)
	bar.absorb_bar:Hide()
	bar.absorb = 0
	
	bar:HookScript("OnSizeChanged", function(self, width, height)
		self.absorb_bar:SetWidth(width)
		self.absorb_bar:SetHeight(height)
	end)
	
	if extra_bar then
		bar.extra_bar = CreateFrame("StatusBar", nil, bar)
		bar.extra_bar:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT")
		bar.extra_bar:SetWidth(w)
		bar.extra_bar:SetHeight(h*.25)
		bar.extra_bar:SetStatusBarTexture(G.media.blank)
		bar.extra_bar:SetStatusBarColor(unpack(info.color2))
		
		bar:HookScript("OnSizeChanged", function(self, width, height)
			self.extra_bar:SetWidth(width)
			self.extra_bar:SetHeight(height*.25)
		end)
	end
	
	bar.rt_icon = bar:CreateTexture(nil, "OVERLAY")
	bar.rt_icon:SetSize(h, h)
	bar.rt_icon:SetPoint("LEFT", bar, "LEFT", 0, 0)
	bar.rt_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	bar.rt_icon:Hide()
	
	bar.left:ClearAllPoints()
	bar.left:SetPoint("LEFT", bar.rt_icon, "RIGHT", 5, 0)
	
	bar.icons = {}
	
	function bar:lineup_icons()
		local last_icon
		for auraID, icon in pairs(self.icons) do
			icon:ClearAllPoints()
			if not last_icon then
				icon:SetPoint("LEFT", self, "RIGHT", 5, 0)
			else
				icon:SetPoint("LEFT", last_icon, "RIGHT", 3, 0)
			end
			last_icon = icon
		end	
	end
	
	function bar:add_auraicon(auraID, texture, count, dur, exp_time)
		if not self.icons[auraID] then
			local icon = CreateAuraIcon(frame, self)
			
			icon:update_texture(texture)
			icon:update_stack(count)
			icon:start(dur, exp_time)

			self.icons[auraID] = icon
			
			self:lineup_icons()
		end
	end
	
	function bar:update_auraicon(auraID, texture, count, dur, exp_time)
		local icon = self.icons[auraID]
		if icon then
			icon:update_texture(texture)
			icon:update_stack(count)
			icon:start(dur, exp_time)
		end
	end
	
	function bar:remove_auraicon(auraID)
		local icon = bar.icons[auraID]
		if icon then
			icon:stop()
		end
	end
	
	function bar:update_color(unit)
		if frame.auras then
			local aura_matched
			for spellID, t in pairs(frame.auras) do
				if t.color and AuraUtil.FindAuraBySpellID(spellID, unit, t.aura_type) then
					self:SetStatusBarColor(unpack(t.color))
					aura_matched = true
					break
				end
			end
			if not aura_matched then
				self:SetStatusBarColor(unpack(info.color))
			end
		end
	end
	
	function bar:update_mark(unit)
		local mark = GetRaidTargetIndex(unit)
		if not mark then
			self.rt_icon:Hide()
		else
			SetRaidTargetIconTexture(self.rt_icon, mark)
			self.rt_icon:Show()
		end
	end
	
	function bar:update_mark_by_raidflags(raidFlags)
		local mark = T.GetRaidFlagsMark(raidFlags)
		if mark then
			SetRaidTargetIconTexture(self.rt_icon, mark)
			self.rt_icon:Show()
		else
			self.rt_icon:Hide()
		end
	end
	
	function bar:update_name(unit)		
		if frame.npcIDs[self.npcID]["n"] then
			self.left:SetText(frame.npcIDs[self.npcID]["n"])
		elseif UnitName(unit) then
			self.left:SetText(UnitName(unit))
		end
		
		if frame.post_update_name then
			frame:post_update_name(self, unit)
		end
	end
	
	function bar:update_auras(unit, updateInfo)
		if updateInfo == nil or updateInfo.isFullUpdate then	
		for auraID, icon in pairs(self.icons) do
				self:remove_auraicon(auraID)
			end
			AuraFullCheck(frame, unit, self)
		else
			if updateInfo.addedAuras ~= nil then
				for _, AuraData in pairs(updateInfo.addedAuras) do
					if frame.auras[AuraData.spellId] and not self.icons[AuraData.auraInstanceID] then
						self:add_auraicon(AuraData.auraInstanceID, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime)
						self:update_color(unit)
					end
				end
			end
			if updateInfo.updatedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do		
					if self.icons[auraID] then
						local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
						if AuraData then
							self:update_auraicon(auraID, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime)
						else
							self:remove_auraicon(auraID)
							self:update_color(unit)
						end
					end
				end
			end
			if updateInfo.removedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
					if self.icons[auraID] then
						self:remove_auraicon(auraID)
						self:update_color(unit)
					end
				end
			end
		end
	end
	
	return bar
end

local UpdateHealthbyCLEU = {
	["SWING_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15)
		bar.min = bar.min - arg12
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["SWING_HEAL"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg12
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
	["RANGE_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg15
		bar.min = bar.min - amount
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["RANGE_HEAL"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg15
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
	["ENVIRONMENTAL_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg13
		bar.min = bar.min - amount
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["ENVIRONMENTAL_HEAL"] = function(bar, arg12, arg13, arg14, arg15)
		local amount = arg13
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
	["SPELL_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15) 
		local amount = arg15
		bar.min = bar.min - amount
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["SPELL_HEAL"] = function(bar, arg12, arg13, arg14, arg15) 
		local amount = arg15
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
	["SPELL_PERIODIC_DAMAGE"] = function(bar, arg12, arg13, arg14, arg15) 
		local amount = arg15
		bar.min = bar.min - amount
		if bar.min < 0 then
			bar.min = 0
		end
	end,
	["SPELL_PERIODIC_HEAL"] = function(bar, arg12, arg13, arg14, arg15) 
		local amount = arg15
		bar.min = bar.min + amount
		if bar.min > bar.max then
			bar.min = bar.max
		end
	end,
}

local UnitFliter = function(frame, unit)
	if frame.events["ENCOUNTER_SHOW_BOSS_UNIT"] then
		return string.find(unit, "boss") or string.find(unit, "arena")
	else
		return string.find(unit, "nameplate") or string.find(unit, "target")
	end
end

--------------------------------------------------------
---------------  [首领模块]小怪血量模板  ---------------
--------------------------------------------------------
-- BOSS
-- event: ENCOUNTER_SHOW_BOSS_UNIT
-- event: ENCOUNTER_HIDE_BOSS_UNIT
-- event: UNIT_HEALTH
-- event: RAID_TARGET_UPDATE
-- event: UNIT_NAME_UPDATE(可选 需要刷新名字)
-- event: UNIT_AURA(可选 需要刷新光环)

-- NON-BOSS
-- event: NAME_PLATE_UNIT_ADDED
-- event: UNIT_TARGET
-- event: COMBAT_LOG_EVENT_UNFILTERED
-- event: UNIT_NAME_UPDATE(可选 需要刷新名字)
-- event: UNIT_AURA(可选 需要刷新光环)

--		frame.format = "value" -- "perc" 显示百分比/显示数值
--		frame:post_update_health(bar, unit)
-- 		frame:post_update_absorb(bar, unit)
--		frame:post_update_name(bar, unit)
--		frame:sort() -- 排序

--		frame.npcIDs = {
--			["182822"] = {n = "", color = {0, .3, .1}}, -- NpcID 名字，颜色
--		}
--		frame.auras = {
--			[139] = { -- 监视的光环
--				aura_type = "HELPFUL",
--				color = {0, 1, 1},
--			},
--		}

T.InitMobHealth = function(frame)
	InitUnitFrameMod(frame)
	
	function frame:create_uf_bar(unit, GUID)		
		if not self.bars[GUID] then			
			local bar = CreateUFBar(self, GUID)
			bar.absorb_bar:Show()
			
			function bar:update_value()		
				bar:SetMinMaxValues(0, bar.max)
				bar:SetValue(bar.min)
				
				bar.absorb_bar:SetMinMaxValues(0, bar.max)
				bar.absorb_bar:SetValue(bar.absorb)
				
				if frame.format == "value" then
					bar.right:SetText(T.ShortValue(bar.min))
				else
					bar.right:SetText(floor(bar.min/bar.max*100))
				end
			end
			
			function bar:update_health(unit)
				bar.min = UnitHealth(unit)
				bar.max = UnitHealthMax(unit)
				
				bar:update_value()
		
				if frame.post_update_health then
					frame:post_update_health(bar, unit)
				end
			end
			
			function bar:update_absorb(unit)
				bar.absorb = UnitGetTotalAbsorbs(unit)
				
				bar:update_value()
				
				if frame.post_update_absorb then
					frame:post_update_absorb(bar, unit)
				end
			end
			
			self.bars[GUID] = bar
			self:lineup()
		end
	end
	
	function frame:init_uf_bar(unit, GUID)
		local npcID = select(6, strsplit("-", GUID))
		if npcID and self.npcIDs[npcID] then
			if not self.bars[GUID] then
				self:create_uf_bar(unit, GUID)
			end
			local bar = self.bars[GUID]
			bar:update_name(unit)
			bar:update_mark(unit)
			bar:update_health(unit)
			bar:update_absorb(unit)	
			AuraFullCheck(self, unit, bar)
		end
	end
end

T.UpdateMobHealth = function(frame, event, ...)
	if event == "NAME_PLATE_UNIT_ADDED" then
		local unit = ...
		local GUID = UnitGUID(unit)
		frame:init_uf_bar(unit, GUID)		
	elseif event == "UNIT_TARGET" then
		local unit = ...
		if T.FilterGroupUnit(unit) then
			local target_unit = T.GetTarget(unit)
			if target_unit and not UnitIsDeadOrGhost(target_unit) then
				local GUID = UnitGUID(target_unit)
				local npcID = select(6, strsplit("-", GUID))
				if npcID and frame.npcIDs[npcID] then -- 确认过眼神
					frame:init_uf_bar(unit, GUID)
				end
			end
		end	
	elseif event == "ENCOUNTER_SHOW_BOSS_UNIT" then
		local unit, GUID = ...
		frame:init_uf_bar(unit, GUID)
	elseif event == "ENCOUNTER_HIDE_BOSS_UNIT" then
		local GUID = ...
		frame:remove_bar(GUID)
	elseif event == "RAID_TARGET_UPDATE" then
		for unit in T.IterateBoss() do
			local GUID = UnitGUID(unit)
			local bar = frame.bars[GUID]
			if bar then
				bar:update_mark(unit)
			end
		end	
	elseif event == "UNIT_NAME_UPDATE" then
		local unit = ...
		if not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		if bar then
			bar:update_name(unit)
		end
	elseif event == "UNIT_AURA" then
		local unit = ...
		
		if not frame.auras or not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		
		if bar then
			local updateInfo = select(2, ...)
			bar:update_auras(unit, updateInfo)
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, destGUID, _, _, destRaidFlags, arg12, arg13, arg14, arg15 = CombatLogGetCurrentEventInfo()
		if sub_event == "UNIT_DIED" then
			frame:remove_bar(destGUID)
		elseif UpdateHealthbyCLEU[sub_event] then
			local bar = frame.bars[destGUID]
			if bar then
				UpdateHealthbyCLEU[sub_event](bar, arg12, arg13, arg14, arg15)
				bar:update_value()
				bar:update_mark_by_raidflags(destRaidFlags)
			end
		end
	elseif event == "UNIT_HEALTH" then
		local unit = ...
		if not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		if bar then
			bar:update_health(unit)
		end
	elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
		local unit = ...
		if not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		if bar then
			bar:update_absorb(unit)
		end
	end
end

T.ResetMobHealth = function(frame)
	for tag, bar in pairs(frame.bars) do
		bar:ClearAllPoints()
		bar:Hide()
	end
	frame.bars = table.wipe(frame.bars)
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]BOSS能量模板  ---------------
--------------------------------------------------------
-- event: ENCOUNTER_SHOW_BOSS_UNIT
-- event: ENCOUNTER_HIDE_BOSS_UNIT
-- event: UNIT_POWER_UPDATE
-- event: RAID_TARGET_UPDATE
-- event: UNIT_NAME_UPDATE(可选 需要刷新名字)
-- event: UNIT_AURA(可选 需要刷新光环)

--		frame:post_update_power(bar, unit)
--		frame:post_update_name(bar, unit)
--		frame:sort() -- 排序

--		frame.npcIDs = {
--			["182822"] = {n = "", color = {0, .3, .1}}, -- NpcID 名字，颜色
--		}
--		frame.auras = {
--			[139] = { -- 监视的光环
--				aura_type = "HELPFUL",
--				color = {0, 1, 1},
--			},
--		}

T.InitMobPower = function(frame)
	InitUnitFrameMod(frame)

	function frame:create_uf_bar(unit, GUID)
		if not self.bars[GUID] then
			local bar = CreateUFBar(self, GUID)
			
			function bar:update_value()
				bar:SetMinMaxValues(0, bar.max)
				bar:SetValue(bar.min)
				
				bar.right:SetText(bar.min)
			end
			
			function bar:update_power(unit)
				bar.min = UnitPower(unit)
				bar.max = UnitPowerMax(unit)
				
				bar:update_value()
		
				if frame.post_update_power then
					frame:post_update_power(bar, unit)
				end				
			end
			
			self.bars[GUID] = bar
			self:lineup()
		end
	end
	
	function frame:init_uf_bar(unit, GUID)
		local npcID = select(6, strsplit("-", GUID))
		if npcID and self.npcIDs[npcID] then
			if not self.bars[GUID] then
				self:create_uf_bar(unit, GUID)
			end
			local bar = self.bars[GUID]
			bar:update_name(unit)
			bar:update_mark(unit)
			bar:update_power(unit)	
			AuraFullCheck(self, unit, bar)
		end
	end
end

T.UpdateMobPower = function(frame, event, ...)
	if event == "ENCOUNTER_SHOW_BOSS_UNIT" then
		local unit, GUID = ...
		frame:init_uf_bar(unit, GUID)			
	elseif event == "ENCOUNTER_HIDE_BOSS_UNIT" then
		local GUID = ...
		frame:remove_bar(GUID)
	elseif event == "RAID_TARGET_UPDATE" then
		for unit in T.IterateBoss() do
			local GUID = UnitGUID(unit)
			local bar = frame.bars[GUID]
			if bar then
				bar:update_mark(unit)
			end
		end
	elseif event == "UNIT_NAME_UPDATE" then
		local unit = ...
		if not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		if bar then
			bar:update_name(unit)
		end
	elseif event == "UNIT_AURA" then
		local unit = ...
		
		if not frame.auras or not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		
		if bar then
			local updateInfo = select(2, ...)
			bar:update_auras(unit, updateInfo)
		end
	elseif event == "UNIT_POWER_UPDATE" then
		local unit = ...
		if not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		if frame.bars[GUID] then
			local bar = frame.bars[GUID]
			bar:update_power(unit)
		end
	end
end

T.ResetMobPower = function(frame)
	for tag, bar in pairs(frame.bars) do
		bar:ClearAllPoints()
		bar:Hide()
	end
	frame.bars = table.wipe(frame.bars)
	frame:Hide()
end

--------------------------------------------------------
------------  [首领模块]BOSS血量+能量模板  -------------
--------------------------------------------------------
-- event: ENCOUNTER_SHOW_BOSS_UNIT
-- event: ENCOUNTER_HIDE_BOSS_UNIT
-- event: UNIT_HEALTH
-- event: UNIT_POWER_UPDATE
-- event: RAID_TARGET_UPDATE
-- event: UNIT_NAME_UPDATE(可选 需要刷新名字)
-- event: UNIT_AURA(可选 需要刷新光环)

--		frame.format = "value" -- "perc" 显示百分比/显示数值
--		frame:post_update_health(bar, unit)
-- 		frame:post_update_absorb(bar, unit)
--		frame:post_update_power(bar, unit)
--		frame:post_update_name(bar, unit)
--		frame:sort() -- 排序

--		frame.npcIDs = {
--			["182822"] = {n = "", color = {0, .3, .1}, color2 = {1, 1, 0}}, -- NpcID 名字，颜色
--		}
--		frame.auras = {
--			[139] = { -- 监视的光环
--				aura_type = "HELPFUL",
--				color = {0, 1, 1},
--			},
--		}

T.InitMobUF = function(frame)
	frame.default_bar_height = 30
	frame.default_bar_width = 240
	
	InitUnitFrameMod(frame)

	function frame:create_uf_bar(unit, GUID)
		if not self.bars[GUID] then
			local bar = CreateUFBar(self, GUID, true)
			
			function bar:update_value()
				bar:SetMinMaxValues(0, bar.max)
				bar:SetValue(bar.min)

				bar.absorb_bar:SetMinMaxValues(0, bar.max)
				bar.absorb_bar:SetValue(bar.absorb)
				
				if frame.format == "value" then
					bar.right:SetText(T.ShortValue(bar.min))
				else
					bar.right:SetText(floor(bar.min/bar.max*100))
				end
			end
			
			function bar:update_extra_value()
				bar.extra_bar:SetMinMaxValues(0, bar.max_power)
				bar.extra_bar:SetValue(bar.min_power)
			end
			
			function bar:update_health(unit)
				bar.min = UnitHealth(unit)
				bar.max = UnitHealthMax(unit)
				
				bar:update_value()
		
				if frame.post_update_health then
					frame:post_update_health(bar, unit)
				end
			end
			
			function bar:update_absorb(unit)
				bar.absorb = UnitGetTotalAbsorbs(unit)
				
				bar:update_value()
				
				if frame.post_update_absorb then
					frame:post_update_absorb(bar, unit)
				end
			end
			
			function bar:update_power(unit)
				bar.min_power = UnitPower(unit)
				bar.max_power = UnitPowerMax(unit)
				
				bar:update_extra_value()
		
				if frame.post_update_power then
					frame:post_update_power(bar, unit)
				end
			end
			
			self.bars[GUID] = bar
			self:lineup()
		end
	end
	
	function frame:init_uf_bar(unit, GUID)
		local npcID = select(6, strsplit("-", GUID))
		if npcID and self.npcIDs[npcID] then
			if not self.bars[GUID] then
				self:create_uf_bar(unit, GUID)
			end
			local bar = self.bars[GUID]
			bar:update_name(unit)
			bar:update_mark(unit)
			bar:update_mark(unit)
			bar:update_health(unit)
			bar:update_power(unit)
			AuraFullCheck(self, unit, bar)
		end
	end
end

T.UpdateMobUF = function(frame, event, ...)
	if event == "ENCOUNTER_SHOW_BOSS_UNIT" then
		local unit, GUID = ...
		frame:init_uf_bar(unit, GUID)			
	elseif event == "ENCOUNTER_HIDE_BOSS_UNIT" then
		local GUID = ...
		frame:remove_bar(GUID)
	elseif event == "RAID_TARGET_UPDATE" then
		for unit in T.IterateBoss() do
			local GUID = UnitGUID(unit)
			local bar = frame.bars[GUID]
			if bar then
				bar:update_mark(unit)
			end
		end
	elseif event == "UNIT_NAME_UPDATE" then
		local unit = ...
		if not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		if bar then
			bar:update_name(unit)
		end
	elseif event == "UNIT_AURA" then
		local unit = ...
		
		if not frame.auras or not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		
		if bar then
			local updateInfo = select(2, ...)
			bar:update_auras(unit, updateInfo)
		end
	elseif event == "UNIT_HEALTH" then
		local unit = ...
		if not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		if bar then
			bar:update_health(unit)
		end
	elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
		local unit = ...
		if not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		local bar = frame.bars[GUID]
		if bar then
			bar:update_absorb(unit)
		end
	elseif event == "UNIT_POWER_UPDATE" then
		local unit = ...
		if not UnitFliter(frame, unit) then return end
		
		local GUID = UnitGUID(unit)
		if frame.bars[GUID] then
			local bar = frame.bars[GUID]
			bar:update_power(unit)
		end
	end
end

T.ResetMobUF = function(frame)
	for tag, bar in pairs(frame.bars) do
		bar:ClearAllPoints()
		bar:Hide()
	end
	frame.bars = table.wipe(frame.bars)
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]吸收盾模板  -----------------
--------------------------------------------------------
-- event: COMBAT_LOG_EVENT_UNFILTERED
-- event: UNIT_ABSORB_AMOUNT_CHANGED

--		frame.unit = "boss1" -- 监控单位
--		frame.spell_id = 368684 -- 吸收盾光环SpellID
--		frame.aura_type = "HARMFUL" -- 光环类型 默认"HELPFUL"
--		frame.effect = 1 -- 吸收量的序号
--		frame.time_limit = 20 -- 附加计时条时限

T.InitAbsorbBar = function(frame)	
	frame.default_bar_width = frame.default_bar_width or 300
	T.GetSingleBarCustomData(frame)
	
	frame.spellName = C_Spell.GetSpellName(frame.spell_id)
	frame.spellIcon = C_Spell.GetSpellTexture(frame.spell_id)
	frame.bar = CreateTimerBar(frame, frame.spellIcon, false, false, true, nil, nil, {1, .8, 0})
	
	CreateTagsforBar(frame.bar, 1)
	
	frame.bar.tag_indcators[1]:SetVertexColor(1, 0, 0)
	frame.bar.tag_indcators[1]:SetWidth(4)
	frame.bar:SetAllPoints(frame)
	
	frame.absorb = 0
	frame.absorb_max = 0
	
	frame.update_absorb = function(update_max)
		if frame.absorb and frame.absorb_max and frame.absorb > 0 and frame.absorb_max > 0 then
			if update_max then
				frame.bar:SetMinMaxValues(0, frame.absorb_max)
			end
			frame.bar:SetValue(frame.absorb)
			frame.bar.right:SetText(string.format("%s |cffFFFF00%d%%|r", T.ShortValue(frame.absorb), frame.absorb/frame.absorb_max*100))
		end
	end
	
	frame.update_time = function()
		if frame.time_limit then
			local exp_time = GetTime() + frame.time_limit
			
			frame.bar.left:SetText("")
			frame.bar.tag_indcators[1]:Show()
			
			frame.bar:SetScript('OnUpdate', function(self, e)
				self.t = self.t + e
				if self.t > 0.05 then
					local remain = exp_time - GetTime()
					if remain > 0 then
						self.left:SetText(T.FormatTime(remain))
						self:pointtag(1, remain/frame.time_limit)
					else
						self:Hide()
						self.tag_indcators[1]:Hide()
						self:SetScript("OnUpdate", nil)
					end
					self.t = 0
				end
			end)
		end
		frame.bar:Show()
	end
	
	frame.stop_bar = function()
		frame.bar:Hide()
		frame.bar.tag_indcators[1]:Hide()
		frame.bar:SetScript("OnUpdate", nil)
	end
	
	function frame:GetAbsorbValue(unit, data)
		if self.effect then
			return data[frame.effect]
		else
			return UnitGetTotalAbsorbs(unit)
		end
	end
	
	function frame:PreviewShow()
		frame.absorb = 1823145
		frame.absorb_max = 2024100		
		frame.update_absorb(true)
		frame.update_time()
	end
	
	function frame:PreviewHide()
		frame.stop_bar()
	end
end

T.UpdateAbsorbBar = function(frame, event, ...)	
	if event == "UNIT_AURA" then
		local unit, updateInfo = ...
		if unit == frame.unit then
			if updateInfo == nil or updateInfo.isFullUpdate then
				if AuraUtil.FindAuraBySpellID(frame.spell_id, frame.unit, frame.aura_type or "HELPFUL") then
					if not frame.auraID then
						local AuraData = C_UnitAuras.GetAuraDataBySpellName(unit, frame.spellName, frame.aura_type or "HELPFUL")						
						local value = frame:GetAbsorbValue(unit, AuraData.points)
						frame.auraID = AuraData.auraInstanceID
						frame.absorb = value
						frame.absorb_max = value
						frame.update_absorb(true)
						frame.update_time()
					end
				else
					if frame.auraID then
						frame.auraID = nil
						frame.stop_bar()
					end
				end
			else
				if updateInfo.addedAuras ~= nil and not frame.auraID then
					for _, AuraData in pairs(updateInfo.addedAuras) do	
						if AuraData.spellId == frame.spell_id then
							local value = frame:GetAbsorbValue(unit, AuraData.points)
							frame.auraID = AuraData.auraInstanceID
							frame.absorb = value
							frame.absorb_max = value
							frame.update_absorb(true)
							frame.update_time()
						end
					end
				end
				if updateInfo.updatedAuraInstanceIDs ~= nil then
					for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do		
						if auraID == frame.auraID then
							local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
							if AuraData then
								local value = frame:GetAbsorbValue(unit, AuraData.points)
								frame.absorb = value
								frame.update_absorb()
							else					
								frame.auraID = nil
								frame.stop_bar()
							end
						end
					end
				end
				if updateInfo.removedAuraInstanceIDs ~= nil and frame.auraID then
					for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
						if auraID == frame.auraID then
							frame.auraID = nil
							frame.stop_bar()
						end
					end
				end
			end
		end
	elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
		local unit = ...
		if unit == frame.unit and not frame.effect then
			local value = frame:GetAbsorbValue(unit, AuraData.points)
			if frame.absorb_max then
				frame.absorb = value
				frame.update_absorb(true)
			else
				frame.absorb = value
				frame.absorb_max = value
				frame.update_absorb()
			end
		end
	elseif event == "ENCOUNTER_START" then
		frame.auraID = nil
		frame.absorb = 0
		frame.absorb_max = 0
	end
end

T.ResetAbsorbBar = function(frame)
	frame.stop_bar()
	frame:Hide()
end

--------------------------------------------------------
------------------  [首领模块]多人光环模板 -----------------
--------------------------------------------------------
-- event: UNIT_AURA

--		frame.spellIDs = {
--			[774] = {
--				icon = 3163628, -- 自定义图标
--				aura_type = "HARMFUL", -- 光环类型 默认 "HARMFUL"
--				color = {0.95, .5, 0}, -- 颜色 或法术颜色
--				limit = 5, -- 限制显示数量
--				hl_raid = "pixel", -- 团队框架动画
--				progress_stack = 10, -- 以层数替代时间作为进度
--				effect = 1, -- 获取光环信息
--				progress_value = 50000, -- 以数值替代时间作为进度
--				role = "TANK",
--			},
--		}

--		frame.role = true -- 显示被点名人的职责
--		frame:filter(auraID, spellID, GUID) -- 过滤
--		frame:post_create_bar(bar, auraID, spellID, GUID) -- 附加修改
--		frame:custom_update(bar, spellID, count, dur, exp_time, effect_value) -- 自定义刷新

T.InitUnitAuraBars = function(frame)
	frame.bars = {}
	frame.cache = {}
	frame.watched_auraTypes = {}
	
	T.GetBarsCustomData(frame)
	
	for spellID, info in pairs(frame.spellIDs) do
		info.icon = info.icon or C_Spell.GetSpellTexture(spellID)
		info.aura_type = info.aura_type or "HARMFUL"
		
		if not info.color then
			info.color = T.GetSpellColor(spellID)
		end
		
		if not frame.watched_auraTypes[info.aura_type] then
			frame.watched_auraTypes[info.aura_type] = true
		end
	end
	
	function frame:create_bar(auraID, spellID, GUID)
		if not frame.filter or frame:filter(auraID, spellID, GUID) then
			local info = T.GetGroupInfobyGUID(GUID)
			if info then
				local icon = self.spellIDs[spellID].icon
				local width = C.DB["BossMod"][self.config_id]["width_sl"]
				local height = C.DB["BossMod"][self.config_id]["height_sl"]
				local color = self.spellIDs[spellID].color
				
				local bar = CreateTimerBar(self, icon, false, false, false, width, height, color)
				
				-- 用于排序、控制高亮
				bar.spellID = spellID
				bar.auraID = auraID
			
				bar.unit = info.unit
				
				bar.left:SetText(info.format_name)
				
				if frame.spellIDs[spellID].hl_raid then
					GlowRaidFramebyUnit_Show(frame.spellIDs[spellID].hl_raid, "multiauras"..spellID, bar.unit, color)
				end
				
				if frame.post_create_bar then
					frame:post_create_bar(bar, auraID, spellID, GUID)
				end
				
				self.bars[auraID] = bar
				self:lineup()
			end
		end
	end
	
	function frame:update_bar(auraID, spellID, count, dur, exp_time, effect_value)
		local bar = self.bars[auraID]
		
		if bar then
			if self.custom_update then
				self:custom_update(bar, spellID, count, dur, exp_time, effect_value)
			elseif self.spellIDs[spellID]["progress_value"] then
				local total = self.spellIDs[spellID]["progress_value"]
				bar:SetMinMaxValues(0 , total)
				bar:SetValue(min(total, effect_value))
				bar.right:SetText(T.ShortValue(effect_value))
			elseif self.spellIDs[spellID]["progress_stack"] then
				local total = self.spellIDs[spellID]["progress_stack"]
				bar:SetMinMaxValues(0 , total)
				bar:SetValue(min(total, count))
				bar.right:SetText(count)
			elseif exp_time ~= 0 then -- 有持续时间
				bar:SetMinMaxValues(0 , dur)
				bar.exp = exp_time
				bar:SetScript("OnUpdate", function(s, e)
					s.t = s.t + e
					if s.t > s.update_rate then
						local remain = s.exp - GetTime()
						if remain > 0 then
							s.right:SetText((count > 0 and "|cffFFFF00["..count.."]|r " or "")..T.FormatTime(remain))
							s:SetValue(dur - remain)
						else
							self:remove_bar(auraID)
						end
						s.t = 0
					end
				end)
			else -- 无持续时间
				bar:SetMinMaxValues(0 , 1)
				bar:SetValue(1)
				bar.right:SetText((count > 0 and "|cffFFFF00["..count.."]|r " or ""))
			end
		end
	end
	
	function frame:remove_bar(auraID)
		local bar = self.bars[auraID]
		
		if bar then
			bar:Hide()
			bar:ClearAllPoints()
			bar:SetScript("OnUpdate", nil)
			
			if frame.spellIDs[bar.spellID].hl_raid then
				GlowRaidFramebyUnit_Hide(frame.spellIDs[bar.spellID].hl_raid, "multiauras"..bar.spellID, bar.unit)
			end
			
			self.bars[auraID] = nil
			self:lineup()
		end
	end
	
	function frame:lineup()
		local bar_count = {}
		
		for spellID, info in pairs(self.spellIDs) do
			if info.limit then
				bar_count[spellID] = 0 -- 需要计数
			end
		end
		
		self.cache = table.wipe(self.cache)
		
		for auraID, bar in pairs(self.bars) do
			if bar_count[bar.spellID] then
				bar_count[bar.spellID] = bar_count[bar.spellID] + 1
				if bar_count[bar.spellID] <= self.spellIDs[bar.spellID]["limit"] then
					table.insert(self.cache, bar)
					bar:SetAlpha(1)
				else
					bar:SetAlpha(0)
				end
			else
				table.insert(self.cache, bar)
			end					
		end
		
		if #self.cache > 1 then
			table.sort(self.cache, function(a, b) 
				if a.spellID < b.spellID then
					return true
				elseif a.spellID == b.spellID then	
					return a.auraID < b.auraID
				end
			end)
		end

		local lastbar
		for i, bar in pairs(self.cache) do			
			bar:ClearAllPoints()
			if not lastbar then
				bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			else
				bar:SetPoint("TOPLEFT", lastbar, "BOTTOMLEFT", 0, -2)	
			end
			lastbar = bar
		end
	end
	
	function frame:role_check(unit, role)
		if not role then
			return true
		else
			local target_role = UnitGroupRolesAssigned(unit)
			return target_role == role
		end
	end
	
	function frame:PreviewShow()
		local num
		if self.bar_num then
			num = self.bar_num
		elseif self.ficon == "0" then
			num = 2
		else
			num = 4
		end
		for spellID, info in pairs(self.spellIDs) do
			local color = info.color or {.7, .2, .1}
			for i = 1, num do
				self.bars[i] = CreateTimerBar(self, info.icon, false, false, false, C.DB["BossMod"][self.config_id]["width_sl"], C.DB["BossMod"][self.config_id]["height_sl"], color)
				self.bars[i].spellID = spellID				
				self.bars[i].auraID = i
			end
			break
		end
		self:lineup()
	end
	
	function frame:PreviewHide()
		for _, bar in pairs(self.bars) do
			bar:Hide()
			bar:ClearAllPoints()
		end
		self.bars = table.wipe(self.bars)
	end
end

T.UpdateUnitAuraBars = function(frame, event, ...)
	if event == "UNIT_AURA" then
		local unit, updateInfo = ...
		
		if not unit or not T.FilterAuraUnit(unit) then return end
		
		if updateInfo == nil or updateInfo.isFullUpdate then
			for auraID, bar in pairs(frame.bars) do
				if bar.unit == unit then
					frame:remove_bar(auraID)
				end
			end
			
			for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
				if frame.watched_auraTypes[auraType] then
					AuraUtil.ForEachAura(unit, auraType, nil, function(AuraData)
						local info = frame.spellIDs[AuraData.spellId]
						if info and frame:role_check(unit, info.role) then
							local effect_ind = info.effect
							local auraID = AuraData.auraInstanceID
							local GUID = UnitGUID(unit)
							local spellID = AuraData.spellId
							local effect_value = AuraData.points and effect_ind and AuraData.points[effect_ind] or 0
							frame:create_bar(auraID, spellID, GUID)
							frame:update_bar(auraID, spellID, AuraData.applications, AuraData.duration, AuraData.expirationTime, effect_value)						
						end
					end, true)
				end
			end
		else
			if updateInfo.addedAuras ~= nil then
				for _, AuraData in pairs(updateInfo.addedAuras) do
					local spellID = AuraData.spellId
					local info = frame.spellIDs[spellID]
					if info and frame:role_check(unit, info.role) then
						local auraID = AuraData.auraInstanceID
						if not frame.bars[auraID] then
							local GUID = UnitGUID(unit)
							frame:create_bar(auraID, spellID, GUID)
							local effect_ind = info.effect
							local effect_value = 0
							if effect_ind and AuraData.points and AuraData.points[effect_ind] then
								effect_value = AuraData.points[effect_ind]
							end
							frame:update_bar(auraID, spellID, AuraData.applications, AuraData.duration, AuraData.expirationTime, effect_value)
						end
					end
				end
			end
			if updateInfo.updatedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do		
					if frame.bars[auraID] then
						local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
						if AuraData then
							local spellID = AuraData.spellId
							local effect_ind = frame.spellIDs[spellID].effect
							local effect_value = 0
							if effect_ind and AuraData.points and AuraData.points[effect_ind] then
								effect_value = AuraData.points[effect_ind]
							end
							frame:update_bar(auraID, spellID, AuraData.applications, AuraData.duration, AuraData.expirationTime, effect_value)
						else					
							frame:remove_bar(auraID)
						end
					end
				end
			end
			if updateInfo.removedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
					if frame.bars[auraID] then	
						frame:remove_bar(auraID)
					end
				end
			end
		end
	end
end

T.ResetUnitAuraBars = function(frame)
	for spellID, info in pairs(frame.spellIDs) do
		GlowRaidFrame_HideAll(info.hl_raid, "multiauras"..spellID)
	end
	for auraID, bar in pairs(frame.bars) do		
		bar:Hide()
		bar:SetScript("OnUpdate", nil)
	end		
	frame.bars = table.wipe(frame.bars)
	frame:Hide()
end

--------------------------------------------------------
------------------  [首领模块]团队框架吸收治疗 ----------------
--------------------------------------------------------
-- event: UNIT_HEAL_ABSORB_AMOUNT_CHANGED

T.InitRFHealAbsorbValues = function(frame)	
	function frame:show_value(unit, value)		
		local unit_frame = T.GetUnitFrame(unit)
		if unit_frame then					
			T.CreateRFValue(unit_frame, T.ShortValue(value))
		end
	end
	
	function frame:remove_value(unit)
		local unit_frame = T.GetUnitFrame(unit)
		if unit_frame then					
			T.HideRFValuebyParent(unit_frame)			
		end
	end
end

T.UpdateRFHealAbsorbValues = function(frame, event, ...)
	if event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then		
		local unit = ...
		
		if not unit or not T.FilterAuraUnit(unit) then return end
		
		local value = UnitGetTotalHealAbsorbs(unit)
		if value > 0 then
			frame:show_value(unit, value)
		else
			frame:remove_value(unit)
		end
	end
end

T.ResetRFHealAbsorbValues = function(frame)
	T.HideAllRFValue()
end

--------------------------------------------------------
-----------------  [首领模块]团队框架光环数值 -----------------
--------------------------------------------------------
-- event: UNIT_AURA

--		frame.spellIDs = {
--			[774] = {
--				aura_type = "HARMFUL", -- 光环类型 默认 "HARMFUL"
--				hl_raid = "pixel", -- 团队框架动画
--				effect = 1, -- 获取光环信息
--			},
--		}

--		frame:filter(unit, spellID, value, GUID) -- 过滤

T.InitRFAuraValues = function(frame)
	frame.watched_auraTypes = {}
	frame.cache = {}
	
	for spellID, info in pairs(frame.spellIDs) do		
		info.aura_type = info.aura_type or "HARMFUL"
		
		if not frame.watched_auraTypes[info.aura_type] then
			frame.watched_auraTypes[info.aura_type] = true
		end
	end
	
	function frame:show_value(auraID, unit, spellID, value)
		if not frame.filter or frame:filter(unit, spellID, value) then				
			local unit_frame = T.GetUnitFrame(unit)
			if unit_frame then					
				T.CreateRFValue(unit_frame, T.ShortValue(value))
				
				if frame.spellIDs[spellID].hl_raid then
					local r = C.DB["RFIconOption"]["RFValue_color"]["r"]
					local g = C.DB["RFIconOption"]["RFValue_color"]["g"]
					local b = C.DB["RFIconOption"]["RFValue_color"]["b"]					
					GlowRaidFramebyUnit_Show(frame.spellIDs[spellID].hl_raid, "rfvalue"..spellID, unit, {r, g, b})
				end
				
				frame.cache[auraID] = spellID
			end
		end
	end
	
	function frame:remove_value(auraID, unit)
		local unit_frame = T.GetUnitFrame(unit)
		if unit_frame then					
			T.HideRFValuebyParent(unit_frame)
			
			local spellID = frame.cache[auraID]
			if frame.spellIDs[spellID].hl_raid then
				GlowRaidFramebyUnit_Hide(frame.spellIDs[spellID].hl_raid, "rfvalue"..spellID, unit)
			end
			
			frame.cache[auraID] = nil
		end
	end
end

T.UpdateRFAuraValues = function(frame, event, ...)
	if event == "UNIT_AURA" then
		
		local unit, updateInfo = ...
		
		if not unit or not T.FilterAuraUnit(unit) then return end
		
		if updateInfo == nil or updateInfo.isFullUpdate then
			frame:remove_value(unit)
			
			for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
				if frame.watched_auraTypes[auraType] then
					AuraUtil.ForEachAura(unit, auraType, nil, function(AuraData)
						local spellID = AuraData.spellId
						local info = frame.spellIDs[spellID]
						if info then
							local effect_ind = info.effect
							local effect_value = AuraData.points and effect_ind and AuraData.points[effect_ind] or 0
							frame:show_value(unit, spellID, effect_value)
						end
					end, true)
				end
			end
		else
			if updateInfo.addedAuras ~= nil then
				for _, AuraData in pairs(updateInfo.addedAuras) do
					local spellID = AuraData.spellId
					local info = frame.spellIDs[spellID]
					if info then
						local auraID = AuraData.auraInstanceID
						if not frame.cache[auraID] then
							local effect_ind = info.effect
							local effect_value = AuraData.points and effect_ind and AuraData.points[effect_ind] or 0
							frame:show_value(auraID, unit, spellID, effect_value)
						end
					end
				end
			end
			if updateInfo.updatedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do		
					if frame.cache[auraID] then
						local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
						if AuraData then
							local spellID = AuraData.spellId
							local effect_ind = frame.spellIDs[spellID].effect
							local effect_value = AuraData.points and effect_ind and AuraData.points[effect_ind] or 0
							frame:show_value(auraID, unit, spellID, effect_value)
						else					
							frame:remove_value(auraID, unit)
						end
					end
				end
			end
			if updateInfo.removedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
					if frame.cache[auraID] then	
						frame:remove_value(auraID, unit)
					end
				end
			end
		end
	end
end

T.ResetRFAuraValues = function(frame)
	for spellID, info in pairs(frame.spellIDs) do
		GlowRaidFrame_HideAll(info.hl_raid, "rfvalue"..spellID)
	end
	T.HideAllRFValue()
	frame.cache = table.wipe(frame.cache)
end

--------------------------------------------------------
------------  [首领模块]点名统计 模板  -----------------
--------------------------------------------------------
-- 共用
--		frame.aura_id = 48438 -- 监控光环
--		frame.element_type = "circle" -- circle/bar 显示样式，默认"bar"
--		frame.send_msg_channel = "YELL" -- 默认为"SAY"
--		frame.color = {.7, .2, .1} -- 计时条颜色/团队框架动画颜色
--		frame.role = true -- 显示职责
--		frame.raid_glow = "pixel" -- 团队框架动画
--		frame.raid_index = true -- 显示团队框架序号
--		frame.disable_copy_mrt = true -- 禁用粘贴模板
--		frame.mrt_copy_custom = true -- 模板里包含指定位置讯息
--		frame.mrt_copy_reverse = true -- 模板里包含反向排列讯息
--		frame.support_spells = 10 -- 给技能提示(技能轮数)
--		frame.supprot_index = 4 -- 给技能提示(序号个数)
-- 		frame.show_backup = true -- 显示候补人员

-- Atlas:DungeonSkull

--		frame.graph_tex_info = { -- 按表格生成示意图图案
--			line = {layer = "BACKGROUND", tex = G.media.blank, color = {1, 1, 0}, w = 100, h = 10, points = {"TOPLEFT", 0, 0}}, -- 图案
--			star = {layer = "ARTWORK", rm = 1, points = {"TOPLEFT", 0, 0}}, -- 标记
--			boss = {layer = "ARTWORK", displayID = 111794, size = 50, points = {"TOPLEFT", 0, 0}},	-- 首领头像 
--			str = {layer = "ARTWORK", text = L["集合"], fs = 20, color = {1, 1, 1}, points = {"TOPLEFT", 0, 0}},	-- 文字
--		}
--		id, name, description, displayInfo, iconImage, uiModelSceneID = EJ_GetCreatureInfo(i)

--		function frame:filter(GUID) 过滤
--		function frame:pre_update_auras() -- 触发时挂载功能 可配合frame.skip 跳过轮次
--		function frame:post_update_auras(total) -- 分配结束时挂载功能 仅适用于整体排序
--		function frame:post_display(element, index, unit, GUID) 队友获得序号时挂载功能
--		function frame:post_remove(element, index, unit, GUID) 队友移除光环时挂载功能

-- 示意图类
--		frame.frame_width = 100 -- 圆圈示意图模式控制框架尺寸
--	 	frame.frame_height = 100 -- 圆圈示意图模式控制框架尺寸
-- 		frame.info = { -- 按表格生成喊话、声音、标记、站位标点讯息
--			{text = T.FormatRaidMark("1"), msg_applied = L["左"].."%name", msg = L["左"].."%dur", sound = "[left]cd3", rm = 1, x = 50, y = 50}, -- 相对于BOTTOMLEFT的绝对位置（xy必需）
--		}

-- 计时条类
-- 		frame.info = { -- 按表格生成喊话、声音、标记、站位标点讯息
--			{text = T.FormatRaidMark("1"), msg_applied = L["右"].."%name", msg = L["右"].."%dur", sound = "[left]cd3", x_offset = -25， y_offset = -25}, -- 相对于上一项的相对位置（x_offset、y_offset可选）
--		}

-- 整体排序根据难度改变点名总数以加快分配，否则直接获取frame.info条目数量
--		frame.diffculty_num = {
--			[14] = 2, -- PT
--			[15] = 3, -- H
--			[16] = 4, -- M
--			[17] = 1, -- LFG
--		}

-- 逐个填坑MRT模板，以便反向排序
--	frame.copy_reverse

-- 光环

-- event: COMBAT_LOG_EVENT_UNFILTERED

--		T.InitAuraMods_ByMrt(frame)
--		T.UpdateAuraMods_ByMrt(frame, event, ...)
--		T.ResetAuraMods_ByMrt(frame)

--		T.InitAuraMods_ByTime(frame)
--		T.UpdateAuraMods_ByTime(frame, event, ...)
--		T.ResetAuraMods_ByTime(frame)

-- 交互宏

-- event: ADDON_MSG
-- event: UNIT_SPELLCAST_START/UNIT_SPELLCAST_SUCCEEDED

--		frame.cast_info = {	-- 轮次事件和法术
--			["UNIT_SPELLCAST_START"] = {[426519] = true,[426519] = true, [426519] = true},
--			["UNIT_SPELLCAST_SUCCEEDED"] = {[426519] = true,[426519] = true, [426519] = true},
--		}
--		frame.dur = 20 -- 轮次持续时间
--		frame.pa_icon = true -- Private Auras 图标
--		frame.macro_button = true -- 宏按钮

--		T.InitMacroMods_ByMRT(frame)
--		T.UpdateMacroMods_ByMRT(frame, event, ...)
--		T.ResetMacroMods_ByMRT(frame)

--		T.InitMacroMods_ByTime(frame)
--		T.UpdateMacroMods_ByTime(frame, event, ...)
--		T.ResetMacroMods_ByTime(frame)
--------------------------------------------------------
------------  [首领模块]点名统计 共用API  --------------
--------------------------------------------------------
local function UpdateTexture(f, data)
	if data.tex or data.atlas or data.displayID then
		if not f.tex then
			f.tex = f:CreateTexture(nil, data.layer, nil, data.sub_layer)
			f.tex:SetAllPoints(f)
		end
		
		if data.tex then
			f.tex:SetTexture(data.tex)
		elseif data.atlas then
			f.tex:SetAtlas(data.atlas)
		elseif data.displayID then
			SetPortraitTextureFromCreatureDisplayID(f.tex, data.displayID)
		end
		
		if data.fade then
			f.tex:SetDesaturated(true)
		end
		
		if data.color then
			f.tex:SetVertexColor(unpack(data.color))
		end
		
		if data.coords then
			f.tex:SetTexCoord(unpack(data.coords))
		end
		
		if data.rotation then
			if type(data.rotation) == "number" then
				f.tex:SetRotation(data.rotation/180*math.pi)
			else
				f.tex:SetRotation(data.rotation[1], CreateVector2D(data.rotation[2], data.rotation[3]))
			end
		end
	end
	
	if data.rm then
		if not f.rm_tex then
			f.rm_tex = f:CreateTexture(nil, data.layer, nil, data.sub_layer)
			f.rm_tex:SetPoint("CENTER")
			f.rm_tex:SetSize(data.w or 20, data.w or 20)
			f.rm_tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		end		
		SetRaidTargetIconTexture(f.rm_tex, data.rm)
	end
	
	if data.tag then
		if not f.tagtext then
			f.tagtext = T.createtext(f, "OVERLAY", 10, "OUTLINE", "CENTER")
			f.tagtext:SetPoint("CENTER", f, "TOP")
			f.tagtext:SetTextColor(1, 1, 0)
		end
		f.tagtext:SetText(data.tag)
	end
end

local function UpdateText(f, data)
	if not f.text then
		f.text = T.createtext(f, data.layer, data.fs, "OUTLINE", "CENTER")
		f.text:SetAllPoints(f)
	end
	
	if data.color then
		f.text:SetTextColor(unpack(data.color))
	end
	
	f.text:SetText(data.text)
end

-- 示意图图案
local UpdateGraphTextures = function(frame, anchor_frame, hide_bg)
	if frame.graph_tex_info then	
		if not frame.graphs then
			frame.graphs = {}
		end
		
		if not hide_bg then
			T.createborder(anchor_frame or frame) -- 背景边框
		end
		
		for name, data in pairs(frame.graph_tex_info) do -- 背景图案
			if not frame.graphs[name] then
				frame.graphs[name] = CreateFrame("Frame", nil, anchor_frame or frame)
			end
			
			local f = frame.graphs[name]
			
			if data.w and data.h then
				f:SetSize(data.w, data.h)
			elseif data.fs then
				f:SetSize(data.fs*6, data.fs)
			else
				f:SetSize(data.size or 30, data.size or 30)
			end
			
			if data.points then
				f:ClearAllPoints()
				f:SetPoint(unpack(data.points))
			end
			
			if data.tex or data.atlas or data.displayID or data.rm or data.tag then				
				UpdateTexture(f, data)			
			elseif data.text then
				UpdateText(f, data)			
			end
		end
		
		for name, f in pairs(frame.graphs) do -- 去掉已删除标记
			if not frame.graph_tex_info[name] then
				f:Hide()
				frame.graphs[name] = nil
			end
		end
	end
end
T.UpdateGraphTextures = UpdateGraphTextures

-- MRT模板生成
local Copy_Mrt_Raidlist = function(frame, rev, custom)
	local players = {}
	local rev_player = {}
	local custom_players = {}
	local raidlist = ""
	
	local i = 1
	for unit in T.IterateGroupMembers() do
		i = i + 1
		local name = UnitName(unit)
		
		if rev and mod(i, 2) == 0 then
			table.insert(rev_player, name)
		else
			table.insert(players, name)
		end
			
		if i <= 3 then
			table.insert(custom_players, name)
		end
	end
	
	raidlist = table.concat(players, " ")
	
	if rev then
		raidlist = raidlist.."\n"..L["反向"]..":"..table.concat(rev_player, " ")
	end
	
	if custom then
		raidlist = raidlist.."\n"..string.format("%s:%s:%s:%s", L["指定"], L["所有轮次"], string.format(L["%d号位"], 1),  custom_players[1])
		raidlist = raidlist.."\n"..string.format("%s:%s:%s:%s", L["指定"], string.format(L["第%d轮"], 2), string.format(L["%d号位"], 2), custom_players[2] or custom_players[1])
		raidlist = raidlist.."\n"..string.format("%s:%s:%s:%s", L["指定"], string.format(L["第%d轮"], 2), string.format(L["%d号位"], 3), custom_players[3] or custom_players[1])
	end
	
	local spellName = C_Spell.GetSpellName(frame.config_id)
	raidlist = string.format("#%dstart%s\n%s\nend", frame.config_id, spellName, raidlist).."\n"
	
	return raidlist
end
T.Copy_Mrt_Raidlist = Copy_Mrt_Raidlist

-- 获取/生成团队信息 ByIndex
local function GetAssignmentByIndex(frame)
	frame.assignment = table.wipe(frame.assignment)
	frame.custom_assignment = table.wipe(frame.custom_assignment)

	local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
	local tagmatched
	
	if text then
		local betweenLine
		local tag = string.format("#%dstart", frame.config_id)
		for line in text:gmatch('[^\r\n]+') do
			if line == "end" then
				betweenLine = false
			end
			if betweenLine then
				if string.find(line, L["指定"]..":") then
					local count, index = select(2, string.split(":",line))
					count = string.match(count, "%d") and tonumber(string.match(count, "%d")) or "all"
					index = string.match(index, "%d") and tonumber(string.match(index, "%d"))
					if index then
						if not frame.custom_assignment[count] then
							frame.custom_assignment[count] = {}
						end
						if not frame.custom_assignment[count][index] then
							frame.custom_assignment[count][index] = {}
						end
						T.InsertGUIDtoArray(line, frame.custom_assignment[count][index])
					end				
				else
					T.InsertGUIDtoArray(line, frame.assignment)
				end
			end
			if line:match(tag) then
				betweenLine = true
				tagmatched = true
			end
		end
	end
		
	local cache = {}
	
	for unit in T.IterateGroupMembers() do
		local GUID = UnitGUID(unit)
		if not tContains(frame.assignment, GUID) then
			table.insert(cache, GUID)
		end
	end
	
	if frame.custom_sort then
		frame:custom_sort(cache)
	end
	
	for _, GUID in pairs(cache) do
		table.insert(frame.assignment, GUID)
	end
end

-- 获取/生成团队信息 ByName
local function GetAssignmentByName(frame)
	frame.positive_assignment = table.wipe(frame.positive_assignment)
	frame.reverse_assignment = table.wipe(frame.reverse_assignment)

	local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
	local tagmatched
	
	if text then
		local betweenLine
		local tag = string.format("#%dstart", frame.config_id)
		for line in text:gmatch('[^\r\n]+') do
			if line == "end" then
				betweenLine = false
			end
			if betweenLine then
				if string.find(line, L["反向"]..":") then
					T.FillArrayByGUID(line, frame.reverse_assignment)
				else
					T.FillArrayByGUID(line, frame.positive_assignment)
				end
			end
			if line:match(tag) then
				betweenLine = true
				tagmatched = true
			end
		end
	end
	
	for unit in T.IterateGroupMembers() do
		local GUID = UnitGUID(unit)
		if not (frame.positive_assignment[GUID] or frame.reverse_assignment[GUID]) then
			frame.positive_assignment[GUID] = true
		end
	end
end

-- 候补功能
local CreateBackupText = function(frame, anchor_frame)
	frame.backups = {}
	
	frame.backup_text = T.createtext(anchor_frame, "OVERLAY", 16, "OUTLINE", "LEFT")
	frame.backup_text:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT")
	frame.backup_text:SetWidth(200)
	
	if not frame.show_backup then
		frame.backup_text:Hide()
	end
	
	function frame:UpdateBackupInfo()
		local t = ""
		for GUID in pairs(self.backups) do
			t = t.." "..T.ColorNickNameByGUID(GUID)
		end
		self.backup_text:SetText(t)
	end
	
	function frame:AddBackup(GUID)
		if not self.backups[GUID] then
			self.backups[GUID] = true
			self:UpdateBackupInfo()
		end
	end
	
	function frame:RemoveBackup(GUID)
		if self.backups[GUID] then
			self.backups[GUID] = nil
			self:UpdateBackupInfo()
		end
	end
	
	function frame:RemoveAllBackups()
		table.wipe(self.backups)
		self:UpdateBackupInfo()
	end
end

-- 获取下一个可用项
local GetNextElementAvailable = function(frame, rev)
	if rev then
		for i = #frame.elements, 1, -1 do
			if frame.elements[i].available then
				return frame.elements[i]
			end
		end
	else
		for i = 1, #frame.elements, 1 do
			if frame.elements[i].available then
				return frame.elements[i]
			end
		end
	end
end
T.GetNextElementAvailable = GetNextElementAvailable

-- 玩家获得光环动作（喊话和声音）
local AuraAction = function(frame, my_index)
	if C.DB["BossMod"][frame.config_id]["say_bool"] or C.DB["BossMod"][frame.config_id]["sound_bool"] then
		local info = frame.info[my_index]
		local tag = info.rm and string.format("{rt%d}", info.rm) or my_index
		
		local count, exp_time, remain
		if C_UnitAuras.AuraIsPrivate(frame.aura_id) then
			count = 0
			exp_time = frame.last_exp
		else
			count = select(3, AuraUtil.FindAuraBySpellID(frame.aura_id, "player", G.TestMod and "HELPFUL" or "HARMFUL"))
			exp_time = select(6, AuraUtil.FindAuraBySpellID(frame.aura_id, "player", G.TestMod and "HELPFUL" or "HARMFUL"))
			remain = exp_time and exp_time - GetTime() or 0
		end
		
		if info.msg_applied then
			T.SendAuraMsg(info.msg_applied, frame.send_msg_channel or "SAY", frame.aura_name, count, remain, tag)
		end
		
		if info.msg then
			frame.msg_countdown = floor(remain)
		end
		
		if info.sound then
			local sound_file = string.match(info["sound"], "%[(.+)%]")
			if sound_file then
				T.PlaySound(sound_file)
			end
			local cd = string.match(info["sound"], "cd(%d+)")
			if cd then
				frame.voi_countdown = tonumber(cd)
			end
		end
		
		if frame.msg_countdown or frame.voi_countdown then
			frame:SetScript("OnUpdate", function(self, e)
				self.t = self.t + e
				if self.t > .05 then
					local remain = exp_time - GetTime()
					if remain > 0 then
						local second = ceil(remain)
						
						if self.msg_countdown and second < self.msg_countdown then -- 发言频率1秒		
							T.SendAuraMsg(info.msg, self.send_msg_channel or "SAY", self.aura_name, count, remain, tag)
							self.msg_countdown = self.msg_countdown - 1
						end
						
						if self.voi_countdown and second <= self.voi_countdown then -- 倒数频率1秒
							T.PlaySound("count\\"..second)
							self.voi_countdown = second - 1
						end
					else
						self:SetScript("OnUpdate", nil) -- 停止刷新
					end				
					self.t = 0
				end
			end)
		end
	end
end

local Raidrole_tags = {
	["HEALER"] = L["治疗颜色"],
	["MELEE"] = L["近战颜色"],
	["RANGED"] = L["远程颜色"],
	["TANK"] = L["坦克颜色"],
}

local UpdateRoleTag = function(role, pos)
	if not role then
		return ""
	elseif role == "HEALER" or role == "TANK" then
		return Raidrole_tags[role]
	else
		return Raidrole_tags[pos]
	end
end
T.UpdateRoleTag = UpdateRoleTag

-- 点名出现
local function OnElementDisplayed(frame, self, text, i, GUID)
	self.GUID = GUID
	self.available = false
	
	local info = T.GetGroupInfobyGUID(GUID)
	local role_tag = frame.role and UpdateRoleTag(info.role, info.pos) or ""
	local mark = frame.info[i]["rm"] and T.FormatRaidMark(frame.info[i]["rm"]) or ""
	local tag = frame.info[i]["text"] or ""

	text:SetText(string.format("%s%s%s %s", role_tag, mark, tag, info.format_name))
	
	if T.IsInPreview() then
		self:SetMinMaxValues(0, 1)
		self:SetValue(1)
	else
		frame.actives[GUID] = self
	
		-- 输出讯息
		T.msg(string.format("%s"..L["第%d轮"]..L["%d号位"].."%s%s %s %s", T.GetIconLink(frame.aura_id), frame.count, i, mark, tag, info.format_name, self.custom and L["优先级高"] or ""))
	
		-- 框架高亮
		if frame.raid_glow and C.DB["BossMod"][frame.config_id]["raid_glow_bool"] then
			if frame.color then
				GlowRaidFramebyUnit_Show(frame.raid_glow, "debuff"..frame.config_id, info.unit, frame.color)
			else
				GlowRaidFramebyUnit_Show(frame.raid_glow, "debuff"..frame.config_id, info.unit, {.7, .2, .1})
			end
		end
	
		-- 框架序号
		if frame.raid_index and C.DB["BossMod"][frame.config_id]["raid_index_bool"] then					
			T.CreateRFIndex(GUID, i)
		end
	
		-- 上标记
		if frame.info[i].rm and C.DB["BossMod"][frame.config_id]["mark_bool"] then
			T.SetRaidTarget(info.unit, frame.info[i].rm)
		end
	
		-- 喊话和声音
		if UnitIsUnit(info.unit, "player") then
			AuraAction(frame, i)		
		end
	
		if frame.support_spells then
			for _, v in pairs(JST_CDB["BossMod"][frame.config_id]["option_list_btn"]) do
				if v.spell_count == frame.count and v.spell_ind == i then				
					if v.all_spec then
						T.FormatAskedSpell(GUID, v.support_spellID, 4)
						T.msg(string.format(L["需要给技能%s"], T.GetIconLink(frame.aura_id), frame.count, i, info.format_name, T.GetIconLink(v.support_spellID)))
					else
						if info.spec_id and v.spec_info[info.spec_id] then
							T.FormatAskedSpell(GUID, v.support_spellID, 4)
							T.msg(string.format(L["需要给技能%s"], T.GetIconLink(frame.aura_id), frame.count, i, info.format_name, T.GetIconLink(v.support_spellID)))
						end
					end
				end
			end
		end
		
		-- 其他
		if frame.post_display then
			frame:post_display(self, i, info.unit, GUID)
		end
	end
end

-- 点名取消
local function OnElementRemoved(frame, self, text, i)
	if self.GUID then
		local info = T.GetGroupInfobyGUID(self.GUID)
		
		if frame.actives[info.GUID] then
			frame.actives[info.GUID] = nil
			
			-- 框架高亮
			if frame.raid_glow and C.DB["BossMod"][frame.config_id]["raid_glow_bool"] then
				GlowRaidFramebyUnit_Hide(frame.raid_glow, "debuff"..frame.config_id, info.unit)
			end
			
			-- 团队框架序号
			if frame.raid_index and C.DB["BossMod"][frame.config_id]["raid_index_bool"] then
				local unit_frame = T.GetUnitFrame(info.unit)
				if unit_frame then	
					T.HideRFIndexbyParent(unit_frame)
				end
			end
			
			-- 喊话和声音
			if UnitIsUnit(info.unit, "player") then
				frame:SetScript("OnUpdate", nil)
			end
			
			-- 其他
			if frame.post_remove then
				frame:post_remove(self, i, info.unit, self.GUID)
			end
		end	
	end
	
	self.GUID = nil
	self.available = true
	
	text:SetText(i)
end

-- 计时条
local function CreateElementBar(frame, i)
	local icon = C_Spell.GetSpellTexture(frame.aura_id)
	local bar = CreateTimerBar(frame.graph_bg, icon, false, true)
	
	bar.index = i
	
	bar.mid:ClearAllPoints()
	bar.mid:SetPoint("RIGHT", bar.right, "LEFT", 0, 0)
	
	if i == 1 then
		bar:SetPoint("TOPLEFT", frame.graph_bg, "TOPLEFT", frame.info[i].x_offset or 0, frame.info[i].y_offset or 0)
	else
		bar:SetPoint("TOPLEFT", frame.elements[i-1], "BOTTOMLEFT", frame.info[i].x_offset or 0, frame.info[i].y_offset or -2)
	end
	
	if frame.color then
		bar:SetStatusBarColor(unpack(frame.color))
	else
		bar:SetStatusBarColor( .7, .2, .1) 
	end
	
	bar:SetAlpha(0)
	bar.left:SetText(i)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	bar.available = true
	
	function bar:display(GUID, custom)
		self.custom = custom
		self:SetAlpha(1)
		
		OnElementDisplayed(frame, self, self.left, i, GUID)
	end
	
	function bar:remove()
		self:SetAlpha(0)
		
		self:SetScript("OnUpdate", nil)
		
		self.mid:SetText("")
		self.right:SetText("")
		self:SetMinMaxValues(0, 1)
		self:SetValue(0)
			
		OnElementRemoved(frame, self, self.left, i)
	end
	
	table.insert(frame.elements, bar)
	
	return bar
end

-- 圆圈
local function CreateElementCircle(frame, i)
	local circle = CreateCircle(frame.graph_bg, frame.info[i].rm)
	circle:SetPoint("BOTTOMLEFT", frame.graph_bg, "BOTTOMLEFT", frame.info[i].x, frame.info[i].y)
	
	circle.index = i
	
	circle.tex:SetVertexColor(.5, .5, .5)
	circle.text:SetText(i)
	circle.available = true
	
	function circle:display(GUID, custom)	
		self.custom = custom
		
		if GUID == G.PlayerGUID then
			self.tex:SetVertexColor(1, .3, 0)
		else
			self.tex:SetVertexColor(0, .6, .6)
		end
		
		OnElementDisplayed(frame, self, self.text, i, GUID)
	end
	
	function circle:remove()	
		self.tex:SetVertexColor(.5, .5, .5)
		
		self:SetScript("OnUpdate", nil)
			
		OnElementRemoved(frame, self, self.text, i)
	end
	
	table.insert(frame.elements, circle)
	
	return circle
end

-- 整体排序初始化
local function InitModsByMrt(frame)
	frame.graphs = {}
	frame.elements = {}
	frame.actives = {}
	frame.assignment = {}
	frame.custom_assignment = {}
	frame.pos_order_cache = {}
	
	frame.aura_name = C_Spell.GetSpellName(frame.aura_id)
	
	frame.count = 0
	frame.aura_num = 0
	
	if not frame.disable_copy_mrt then
		function frame:copy_mrt()
			return Copy_Mrt_Raidlist(self, false, self.mrt_copy_custom)
		end
	end
	T.GetElementsCustomData(frame)
	
	if frame.frame_width and frame.frame_height then
		frame:SetSize(frame.frame_width, frame.frame_height)
	end
	
	frame.graph_bg = CreateFrame("Frame", nil, frame)
	frame.graph_bg:SetAllPoints(frame)
	frame.graph_bg:Hide()
	
	CreateBackupText(frame, frame.graph_bg)
	UpdateGraphTextures(frame, frame.graph_bg)
end

-- 逐个填坑初始化
local function InitModByTime(frame)
	frame.graphs = {}
	frame.elements = {}
	frame.actives = {}
	frame.positive_assignment = {}
	frame.reverse_assignment = {}
	
	frame.aura_name = C_Spell.GetSpellName(frame.aura_id)
	
	frame.count = 0
	
	if frame.copy_reverse then
		function frame:copy_mrt()
			return Copy_Mrt_Raidlist(self, self.mrt_copy_reverse)
		end
	end
	T.GetElementsCustomData(frame)
	
	if frame.frame_width and frame.frame_height then
		frame:SetSize(frame.frame_width, frame.frame_height)
	end
	
	frame.graph_bg = CreateFrame("Frame", nil, frame)
	frame.graph_bg:SetAllPoints(frame)
	frame.graph_bg:Hide()
	
	CreateBackupText(frame, frame.graph_bg)
	UpdateGraphTextures(frame, frame.graph_bg)
end

-- 难度检测
local function GetTotalAuraNumber(frame)
	if frame.total_aura_num then
		return frame.total_aura_num
	elseif frame.diffculty_num and frame.difficultyID and frame.diffculty_num[frame.difficultyID] then
		return frame.diffculty_num[frame.difficultyID]
	else
		return #frame.info
	end
end
--------------------------------------------------------
------------  [首领模块]光环统计 共用API  --------------
--------------------------------------------------------
-- 光环计时条
local CreateAuraBar = function(frame, i)	
	local bar = CreateElementBar(frame, i)
	
	function bar:update(count, dur, exp_time)
		self.mid:SetText((count and count > 0 and string.format("|cffFFFF00[%d]|r ", count) or ""))
		
		self.dur = dur
		self.exp_time = exp_time
		
		if dur and exp_time and exp_time ~= 0 then
			if not self:GetScript("OnUpdate") then
				self:SetMinMaxValues(0, self.dur)
				self:SetValue(0)
				self:SetScript("OnUpdate", function(s, e)
					s.t = s.t + e
					if s.t > s.update_rate then
						s.remain = s.exp_time - GetTime()
						if s.remain > 0 then
							s.right:SetText(T.FormatTime(s.remain))
							s:SetValue(s.dur - s.remain)
						else
							s:remove()
						end
						s.t = 0
					end
				end)
			end
		else
			self.right:SetText("")
			self:SetMinMaxValues(0, 1)
			self:SetValue(1)		
		end
	end
end

-- 光环圆圈
local CreateAuraCircle = function(frame, i)
	local circle = CreateElementCircle(frame, i)
	
	function circle:update(count, dur, exp_time)
		self.exp_time = exp_time
		
		if exp_time ~= 0 then
			if not self:GetScript("OnUpdate") then
				self:SetScript("OnUpdate", function(s, e)
					s.t = s.t + e
					if s.t > s.update_rate then
						s.remain = s.exp_time - GetTime()
						if s.remain < 0 then
							s:remove()
						end
						s.t = 0
					end
				end)
			end
		end
	end
end

--------------------------------------------------------
------------  [首领模块]光环统计 整体排序  -------------
--------------------------------------------------------

T.InitAuraMods_ByMrt = function(frame)
	InitModsByMrt(frame)
	
	frame.last_update_time = 0

	for i in pairs(frame.info) do
		if frame.element_type == "circle" then
			CreateAuraCircle(frame, i)
		else
			CreateAuraBar(frame, i)
		end
	end
	
	function frame:Prepare()
		self.count = self.count + 1
		
		if self.pre_update_auras then
			self:pre_update_auras()
		end
		
		-- 跳过这一轮
		if self.skip then return end
		
		self.graph_bg:Show()
		
		C_Timer.After(3, function() -- 强制刷新
			if GetTime() - self.last_update_time >= 5 then
				self:Display()
				self.last_update_time = GetTime() -- 刷新时间
				if self.post_update_auras then
					local total = T.GetTableNum(self.actives)
					self:post_update_auras(total)
				end
			end
		end)
	end
	
	function frame:Update(GUID)
		if self.actives[GUID] then
			local unit_id = T.GUIDToUnit(GUID)
			local count, _, dur, exp_time = select(3, AuraUtil.FindAuraBySpellID(self.aura_id, unit_id, G.TestMod and "HELPFUL" or "HARMFUL"))
			self.actives[GUID]:update(count, dur, exp_time)
		end
	end
	
	function frame:Display()	
		-- 第一轮排序：指定位置
		local custom_count_key
		if self.custom_assignment[self.count] then
			custom_count_key = self.count
		elseif self.custom_assignment["all"] then
			custom_count_key = "all"
		end
		if custom_count_key then
			for index, players in pairs(self.custom_assignment[custom_count_key]) do
				for _, GUID in pairs(players) do
					if self.backups[GUID] then
						local element = self.elements[index]
						if element.available then
							element:display(GUID, true)						
							self:Update(GUID)
							self:RemoveBackup(GUID)
							break
						end
					end
				end
			end
		end
		
		-- 第二轮排序：常规排序
		for _, GUID in pairs(self.assignment) do
			if self.backups[GUID] then
				local element = GetNextElementAvailable(self)
				if element then
					element:display(GUID)
					self:Update(GUID)
					self:RemoveBackup(GUID)
				end
			end
		end
	end
	
	function frame:Remove(GUID)
		local element = self.actives[GUID]
		if element then
			element:remove()
			self:Display()
			self:UpdateBackupInfo()
		end
		self:RemoveBackup(GUID)
	end
	
	function frame:PreviewShow()
		for i, element in pairs(self.elements) do
			element:display(G.PlayerGUID)
		end
		self.graph_bg:Show()
	end
	
	function frame:PreviewHide()
		for i, element in pairs(self.elements) do
			element:remove()
		end
		self.graph_bg:Hide()
	end
end

T.UpdateAuraMods_ByMrt = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, sub_event, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if sub_event == "SPELL_AURA_APPLIED" and spellID == frame.aura_id then
			frame.aura_num = frame.aura_num + 1
			
			if frame.aura_num == 1 then -- 点出第一个
				frame:Prepare()
			end
			
			if tContains(frame.assignment, destGUID) and (not frame.filter or frame:filter(destGUID)) then
				frame:AddBackup(destGUID)
				if frame.aura_num == GetTotalAuraNumber(frame) then
					frame:Display()
					frame.last_update_time = GetTime() -- 刷新时间
					if frame.post_update_auras then
						frame:post_update_auras(frame.aura_num)
					end
				end
			end
		elseif (sub_event == "SPELL_AURA_APPLIED_DOSE" or sub_event == "SPELL_AURA_REMOVED_DOSE" or sub_event == "SPELL_AURA_REFRESH") and spellID == frame.aura_id and destGUID then
			frame:Update(destGUID)
		elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.aura_id then
			frame.aura_num = frame.aura_num - 1
			
			if frame.aura_num == 0 then -- 全部消除
				frame.graph_bg:Hide()
			end
			
			frame:Remove(destGUID)
		end
	elseif event == "ENCOUNTER_START" then
		frame.aura_num = 0
		frame.count = 0
		frame.last_update_time = 0
		frame.difficultyID = select(3, ...)
		
		-- 获取分组数据	
		GetAssignmentByIndex(frame)
	end
end

T.ResetAuraMods_ByMrt = function(frame)
	for _, element in pairs(frame.actives) do
		element:remove()
	end
	if frame.raid_index then
		T.HideAllRFIndex()
	end
	frame:RemoveAllBackups()
	frame.graph_bg:Hide()
	frame:Hide()
end

--------------------------------------------------------
------------  [首领模块]光环统计 逐个填坑  -------------
--------------------------------------------------------

T.InitAuraMods_ByTime = function(frame)
	InitModByTime(frame)
	
	frame.aura_num = 0
	frame.cur_index = 0
	
	for i, data in pairs(frame.info) do		
		if frame.element_type == "circle" then
			CreateAuraCircle(frame, i)
		else
			CreateAuraBar(frame, i)
		end
	end
	
	function frame:Prepare()
		self.count = self.count + 1
		
		if self.pre_update_auras then
			self:pre_update_auras()
		end
		
		-- 跳过这一轮
		if self.skip then return end
		
		self.graph_bg:Show()
	end
	
	function frame:Update(GUID)
		if self.actives[GUID] then
			local unit_id = T.GUIDToUnit(GUID)
			local count, _, dur, exp_time = select(3, AuraUtil.FindAuraBySpellID(self.aura_id, unit_id, G.TestMod and "HELPFUL" or "HARMFUL"))
			self.actives[GUID]:update(count, dur, exp_time)
		end
	end
	
	function frame:Display(GUID)
		if self.reset_index then
			local element = self.elements[self.cur_index]
			if element then
				element:display(GUID)
				self:RemoveBackup(GUID)
				self:Update(GUID)
			end
		elseif self.positive_assignment[GUID] then
			local element = GetNextElementAvailable(self)
			if element then
				element:display(GUID)
				self:RemoveBackup(GUID)
				self:Update(GUID)
			end
		elseif self.reverse_assignment[GUID] then
			local element = GetNextElementAvailable(self, true)
			if element then
				element:display(GUID)
				self:RemoveBackup(GUID)
				self:Update(GUID)
			end	
		end
	end
	
	function frame:Remove(GUID)
		local element = self.actives[GUID]
		if element then
			element:remove()
			for GUID in pairs(self.backups) do -- 从候补中补充
				self:Display(GUID)
			end
			self:UpdateBackupInfo()
		end
		self:RemoveBackup(GUID)
	end
	
	function frame:PreviewShow()
		for _, element in pairs(self.elements) do
			element:display(G.PlayerGUID)
		end
		self.graph_bg:Show()
	end
	
	function frame:PreviewHide()
		for _, element in pairs(self.elements) do
			element:remove()
		end
		self.graph_bg:Hide()
	end
end

T.UpdateAuraMods_ByTime = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, sub_event, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if sub_event == "SPELL_AURA_APPLIED" and spellID == frame.aura_id then
		
			frame.aura_num = frame.aura_num + 1
			
			if frame.reset_index then
				if frame.cur_index < frame.reset_index then
					frame.cur_index = frame.cur_index + 1
				else
					frame.cur_index = 1
				end
				if frame.cur_index == 1 then -- 点出第一个
					frame:Prepare()
				end
			else
				if frame.aura_num == 1 then -- 点出第一个
					frame:Prepare()
				end
			end
			
			if (frame.positive_assignment[destGUID] or frame.reverse_assignment[destGUID]) and (not frame.filter or frame:filter(destGUID)) then
				frame:AddBackup(destGUID)
				frame:Display(destGUID)
			end
		elseif (sub_event == "SPELL_AURA_APPLIED_DOSE" or sub_event == "SPELL_AURA_REMOVED_DOSE" or sub_event == "SPELL_AURA_REFRESH") and spellID == frame.aura_id and destGUID then
			frame:Update(destGUID)
		elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.aura_id then
			frame.aura_num = frame.aura_num - 1
			
			if frame.aura_num == 0 then -- 全部消除
				if frame.reset_index then
					if frame.cur_index == frame.reset_index then
						frame.graph_bg:Hide()
					end
				else
					frame.graph_bg:Hide()
				end					
			end

			frame:Remove(destGUID)
		end
	elseif event == "ENCOUNTER_START" then
		frame.aura_num = 0
		frame.count = 0
		frame.cur_index = 0
		
		-- 获取分组数据
		GetAssignmentByName(frame)
	end
end

T.ResetAuraMods_ByTime = function(frame)
	for _, element in pairs(frame.actives) do
		element:remove()
	end
	if frame.raid_index then
		T.HideAllRFIndex()
	end
	frame.graph_bg:Hide()
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]交互统计 API  ---------------
--------------------------------------------------------

-- 交互宏按钮
local CreateMacroButton = function(frame)
	if frame.macro_button then	
		T.CreateMovableFrame(frame, "macrobuttons", #frame.msg_info*50, 50, {a1 = "BOTTOMRIGHT", a2 =  "BOTTOMRIGHT", x = -200, y = 100}, "_MacroButton", L["交互宏按钮"]) -- 有选项
		
		frame.macrobuttons:Hide()
		frame.macrobuttons.buttons = {}
				
		for i, data in pairs(frame.msg_info) do
			local button = CreateFrame("Button", nil, frame.macrobuttons)
			button:SetSize(40, 40)
			button:SetPoint("LEFT", frame.macrobuttons, "LEFT", 5+50*(i-1), 0)
			
			T.createborder(button)
			
			button.text = T.createtext(button, "OVERLAY", 15, "OUTLINE", "LEFT")
			button.text:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT")
			button.text:SetText("/jst add"..data.msg)
			
			button.tex = button:CreateTexture(nil, "ARTWORK")
			button.tex:SetAllPoints()
			button.tex:SetTexture(C_Spell.GetSpellTexture(data.spellID))
			button.tex:SetTexCoord( .1, .9, .1, .9)
			
			button:RegisterForClicks("LeftButtonDown", "RightButtonDown", "LeftButtonUp", "RightButtonUp")
			button:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" then
					T.FireEvent("JST_MACRO_PRESSED", "TargetMe", data.msg)
					T.msg(L["已按宏"]..data.msg)
					self.sd:SetBackdropBorderColor(0, 1, 0)
				else
					T.FireEvent("JST_MACRO_PRESSED", "RemoveMe", data.msg)
					T.msg(L["已按取消宏"]..data.msg)
					self.sd:SetBackdropBorderColor(1, 0, 0)
				end
			end)
			button:SetScript("OnMouseUp", function(self, button)
				self.sd:SetBackdropBorderColor(0, 0, 0)
			end)
			
			table.insert(frame.macrobuttons.buttons, button)
		end
	end
	
	function frame:ShowMacroButton()
		if self.macrobuttons and C.DB["BossMod"][self.config_id]["macro_button_bool"] then
			self.macrobuttons:Show()
		end
	end
	
	function frame:HideMacroButton()
		if self.macrobuttons and C.DB["BossMod"][frame.config_id]["macro_button_bool"] then
			self.macrobuttons:Hide()
		end
	end
end
T.CreateMacroButton = CreateMacroButton

--------------------------------------------------------
----------  [首领模块]技能轮次安排模板  ----------------
--------------------------------------------------------
-- event: COMBAT_LOG_EVENT_UNFILTERED
-- event: JST_SPELL_ASSIGN（可选）

--		frame.sub_event = "SPELL_CAST_SUCCESS" -- 轮次锚点事件（按战斗记录提醒）
--		frame.cast_id = 404732 -- 轮次刷新法术（按战斗记录提醒）
-- 		frame:start_countdown(dur) -- 倒计时触发下一轮提醒（需要提前准备）
-- 		frame:stop_countdown() -- 停止倒计时

--		frame.assign_count = 4 -- mrt模板轮次 默认为4
--		frame.loop = false -- 循环使用人员安排

--		frame.alert_text = L["快去接圈"] -- 中间文字 默认 法术名称+快去
--		frame.alert_dur = 5 -- 文字倒计时和框架高亮时间，默认为5
--		frame.show_dur_text = true -- 显示倒计时秒数

--		frame.sound = "sharedmg" -- 声音 默认 sound_boxing

--		frame.send_msg = "%name [%count]" -- 到我的轮次喊话
--		frame.send_msg_num = 5 -- 默认为5 喊话重复次数(每秒1次)
--		frame.send_msg_channel = "YELL" -- 默认为"SAY"

--		frame.raid_glow = "pixel" -- 团队框架动画
--		frame.raid_glow_color = {.2, .4, 1} -- 团队框架动画颜色

--		frame.update_id = 404732 -- 易伤光环 需要添加 frame:override_player_text(GUID, index)

--		frame:filter(count, display_count) -- 提醒我时的条件过滤
--		frame:override_action(count, display_count, GUIDs, index) -- 覆盖动作 中央文字、声音、喊话
--		frame:override_action_inactive(count, display_count) -- 覆盖未轮到我的动作 中央文字、声音、喊话
--		frame:pre_update_count_up(count, display_count) -- 计数前刷新
--		frame:post_update_count_up(count, display_count) -- 计数后刷新


local function Copy_Mrt_Spelllist(frame)
	local str, raidlist = "", ""
	local loop_type = frame.loop and L["循环"] or L["不循环"]
	local count = frame.assign_count or 4
	
	for ind = 1, count do
		raidlist = raidlist..string.format('\n[%d]', ind) -- 换行
		local i = 0
		for unit in T.IterateGroupMembers() do
			i = i + 1
			if i <= 3 then
				local name = UnitName(unit)
				raidlist = raidlist.." "..name
			end
		end
	end
	
	str = string.format("#%sstart%s[%s]%s\nend\n", frame.config_id, frame.spell, loop_type, raidlist)
	
	return str
end
T.Copy_Mrt_Spelllist = Copy_Mrt_Spelllist

T.InitSpellBars = function(frame)
	frame:SetSize(180, 45)
	
	frame.spell = C_Spell.GetSpellName(frame.config_id)
	frame.assignment = {}
	frame.count = 0
	
	frame.text = T.createtext(frame, "OVERLAY", 14, "OUTLINE", "LEFT", "TOP")
	frame.text:SetAllPoints(frame)
	
	frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
	
	function frame:copy_mrt()
		return Copy_Mrt_Spelllist(self)
	end
	
	T.GetSpellAssignCustomData(frame)
		
	function frame:GetMrtAssignment()
		self.assignment = table.wipe(self.assignment)
		
		if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1 then
			local tag = string.format("#%dstart", self.config_id)
			local text = _G.VExRT.Note.Text1
			
			local betweenLine = false
			local count = 0
			
			for line in text:gmatch('[^\r\n]+') do
				if line == "end" then
					betweenLine = false
				end
				if betweenLine then
					count = count + 1
					self.assignment[count] = T.LineToGUIDArray(line)
				end
				if line:match(tag) then
					betweenLine = true
				end
			end
		end
	end
	
	function frame:GetPlayerStatusStr()
		local count = self.display_count
		local str = ""
		for index, GUID in pairs(self.assignment[count]) do
			local name = ""
			if self.override_player_text then
				name = self:override_player_text(GUID, index)
			else
				name = T.ColorNickNameByGUID(GUID)
			end
			local unit = T.GUIDToUnit(GUID)
			if UnitIsDeadOrGhost(unit) then
				name = "|cff969696[D]|r"..name
			end
			str = str.." "..name
		end
		return str
	end
	
	function frame:UpdateAssignText()
		if self.assignment[self.display_count] then
			self.text:SetText(string.format("[%d] %s", self.display_count, self:GetPlayerStatusStr()))
		else
			self.text:SetText(string.format("[%d] %s", self.display_count, L["无"]))
		end
	end
	
	function frame:start_countdown(dur)
		self.exp_time = GetTime() + dur
		self:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > .5 then
				s.remain = s.exp_time - GetTime()
				if s.remain < 0 then
					T.FireEvent("JST_SPELL_ASSIGN", self.config_id)
					s:SetScript("OnUpdate", nil)
				end
				s.t = 0
			end
		end)
	end
		
	function frame:SpellAction(GUIDs, my_index)
		if self.override_action then
			self:override_action(self.count, self.display_count, GUIDs, my_index)
		else
			-- 声音
			T.PlaySound(self.sound or "sound_boxing")
			
			-- 文字
			T.Start_Text_Timer(self.text_frame, self.alert_dur or 5, gsub(self.alert_text or self.spell, "%%count", self.count), self.show_dur_text)
		
			-- 喊话
			if self.send_msg then
				local msg = self.send_msg:gsub("%%name", G.PlayerName):gsub("%%count", self.count)			
				local channel = self.send_msg_channel or "SAY"
				T.SendChatMsg(msg, self.send_msg_num or 5, channel)
			end
		end
	end
	
	function frame:SpellActionInactive()
		if self.override_action_inactive then
			self:override_action_inactive(self.count, self.display_count)
		end
	end
	
	function frame:CountUp()
		self.count = self.count + 1
		
		if self.loop and #self.assignment > 0 then
			self.display_count = mod(self.count-1, #self.assignment)+1
		else
			self.display_count = self.count
		end
		
		if self.pre_update_count_up then
			self:pre_update_count_up(self.count, self.display_count)
		end
		
		-- 检查这一轮有没有分配数据
		if self.assignment[self.display_count] then
			T.msg(string.format(L["MRT轮次分配"], T.GetIconLink(self.config_id), self.count, self:GetPlayerStatusStr()))
			
			local found
						
			for index, GUID in pairs(self.assignment[self.display_count]) do
				if self.raid_glow and C.DB["BossMod"][self.config_id]["raid_glow_bool"] then
					local unit_id = T.GUIDToUnit(GUID)
					GlowRaidFramebyUnit_Show(self.raid_glow, "debuff"..self.config_id, unit_id, self.raid_glow_color or {.2, .4, 1}, self.alert_dur or 5) -- 团队框架动画
				end
				
				-- 这轮有我
				if GUID == G.PlayerGUID and (not self.filter or self:filter(self.count, self.display_count)) then
					self:SpellAction(self.assignment[self.display_count], index)
					found = true
				end
			end
			
			if not found then
				self:SpellActionInactive()
			end
		else
			T.msg(string.format(L["MRT该轮次数据未找到"], T.GetIconLink(self.config_id), self.count))
		end
		
		if self.post_update_count_up then
			self:post_update_count_up(self.count, self.display_count)
		end
		
		self:UpdateAssignText()
		self.text:Show()
		
		C_Timer.After(self.alert_dur, function()
			self.text:Hide()
		end)
	end

	function frame:PreviewShow()		
		self.text:SetText(string.format("[%d] %s", 1, T.ColorNickNameByGUID(G.PlayerGUID)))
		self.text:Show()
	end
	
	function frame:PreviewHide()
		self.text:Hide()
	end
end

T.UpdateSpellBars = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if frame.sub_event and frame.cast_id and sub_event == frame.sub_event and spellID == frame.cast_id then
			frame:CountUp()
		elseif sub_event == "UNIT_DIED" or sub_event == "UNIT_RESURRECT" then
			frame:UpdateAssignText()
		elseif string.find(sub_event, "SPELL_AURA") and spellID == frame.update_id then
			frame:UpdateAssignText()
		end
	elseif event == "JST_SPELL_ASSIGN" then
		local spellID = ...
		if spellID == frame.config_id then
			frame:CountUp()
		end
	elseif event == "ENCOUNTER_START" then
		frame:GetMrtAssignment()		
		frame.count = 0
	end
end

T.ResetSpellBars = function(frame)
	if frame.raid_glow and C.DB["BossMod"][frame.config_id]["raid_glow_bool"] then
		GlowRaidFrame_HideAll(frame.raid_glow, "debuff"..frame.config_id)
	end
	T.Stop_Text_Timer(frame.text_frame)
	frame:SetScript("OnUpdate", nil)
	frame.text:Hide()
	frame:Hide()
end

--------------------------------------------------------
---------------  [首领模块]计时条模板 ---------------
--------------------------------------------------------
-- event: COMBAT_LOG_EVENT_UNFILTERED

--		frame.spell_info = {
--			["SPELL_CAST_START"] = {
--				[404732] = {
--					target_me = true, -- 目标是我
--					dur = 10, -- 时间
--					wait_dur = 30, -- 等待时间
--					hide_icon = true, -- 隐藏图标
--					color = {1, 1, 0}, -- 默认黄色
--					reverse_fill = true, -- 反向
--					count = true, -- 计数
--					sound = "aoe", -- 开始声音
--					prepare_sound = "aoe", -- 准备声音
--					mute_count_down = true, -- 静默倒数
--					count_down_english = true, -- 英语倒数
--					count_down = 3, -- 倒数
--					divide_info = {
--						dur = {4, 4.8, 5.6, 6.4}, -- 分段讯息
--						black_tag = true, -- 黑色分割线
--						time = true, -- 分段时间
--						sound = "sound_dd", -- 分段声音 "sound_dd"/"count"
--						count_english = true,
--					},
--				},
--			},
--		}

--		function frame:filter(sub_event, spellID) -- 过滤条件
--		function frame:stop_filter(sub_event, spellID) -- 隐藏过滤条件
--		function frame:progress_update(sub_event, spellID, remain) -- 过程中伴随效果
--		function frame:post_update_show(sub_event, spellID) -- 出现时伴随效果
--		function frame.post_update_hide() -- 消失时伴随效果

local function InitTags(frame, info)
	for i = 1, frame.tag_num do
		local tag = frame.bar.tag_indcators[i]
		
		if i > #info.divide_info.dur then
			tag:Hide()
		else
			frame.bar:pointtag(i, info.divide_info.dur[i]/info.dur)
			tag:Show()
		end
		
		local timer = frame.bar["timer"..i]
		
		if info.divide_info.time and i == 1 then
			timer:Show()
		else
			timer:Hide()
		end
	end
end

local function UpdateCountDown(frame)
	local second = ceil(frame.remain)
	if frame.voi_countdown and second <= frame.voi_countdown and second > 0 then -- 倒数频率1秒
		if frame.prepare then
			if not T.IsInPreview() then
				T.PlaySound(frame.prepare)
			end
			frame.prepare = nil
		elseif not frame.mute_count_down and not T.IsInPreview() then
			if frame.count_down_english then
				T.PlaySound("count_en\\"..second)
			else
				T.PlaySound("count\\"..second)
			end
		end
		frame.voi_countdown = second - 1
	end
end

local function ShowSpellCastBar(frame, sub_event, spellID)
	if not frame.bar:IsShown() then
		frame.bar:Show()
		if frame.spell_info[sub_event][spellID].sound and not T.IsInPreview() then
			T.PlaySound(frame.spell_info[sub_event][spellID].sound)
		end
		if frame.post_update_show then
			frame:post_update_show(sub_event, spellID)
		end
	end
end

local function HideSpellCastBar(frame)
	if frame.bar:IsShown() then
		frame.bar:Hide()
		if frame.post_update_hide then
			frame:post_update_hide()
		end
	end
end

local function UpdateDivInfo(frame, info)
	if info.divide_info.dur[frame.index] and frame.passed > info.divide_info.dur[frame.index] then
		if info.divide_info.sound and not T.IsInPreview() then
			if info.divide_info.sound == "count" then
				if info.divide_info.count_english then
					T.PlaySound("count_en\\"..(frame.total + 1 - frame.index))
				else
					T.PlaySound("count\\"..(frame.total + 1 - frame.index))
				end
			else
				T.PlaySound(info.divide_info.sound)
			end
		end
			
		if info.divide_info.time then
			frame.bar["timer"..frame.index]:Hide()
			if frame.bar["timer"..frame.index+1] then
				frame.bar["timer"..frame.index+1]:Show()
			end
		end
		frame.index = frame.index + 1
	end
	
	if info.divide_info.time then
		for i = 1, frame.tag_num do
			timer = frame.bar["timer"..i]
			if timer:IsShown() then
				timer:SetText(T.FormatTime(frame.remain - (info.dur - info.divide_info.dur[i]), true))
			end
		end
	else
		frame.bar.right:SetText(T.FormatTime(frame.remain, true))
	end
end

local function StartSpellCastBar(frame, info, sub_event, spellID)	
	frame:SetScript("OnUpdate", function(self, e) 
		self.t = self.t + e
		if self.t > 0.02 then		
			self.remain = self.exp_time - GetTime()
			self.passed = info.dur - self.remain
			
			if self.remain > 0 then
				if self.remain <= info.dur then
					UpdateCountDown(self)
					ShowSpellCastBar(self, sub_event, spellID)
					
					self.bar:SetValue(info.reverse_fill and self.remain or self.passed)
					
					if info.divide_info then
						UpdateDivInfo(self, info)
					else
						frame.bar.right:SetText(T.FormatTime(frame.remain, true))
					end
					
					if self.progress_update then
						self:progress_update(sub_event, spellID, self.remain)
					end
				else
					HideSpellCastBar(self)
				end
			else
				self:SetScript("OnUpdate", nil)
				if info.divide_info then
					UpdateDivInfo(self, info)
				end
				HideSpellCastBar(self)				
			end
			self.t = 0
		end
	end)
end

local function Reset_Spell_Count(frame)
	for sub_event, data in pairs(frame.spell_counts) do
		for spell, count in pairs(data) do
			frame.spell_counts[sub_event][spell] = 0
		end
	end
end

T.InitSpellCastBar = function(frame)
	frame.default_bar_width = frame.default_bar_width or 300
	T.GetSingleBarCustomData(frame)
	
	frame.spell_counts = {}
	frame.count = 0
	frame.tag_num = 0
	frame.t = 0
	
	for sub_event, data in pairs(frame.spell_info) do
		frame.spell_counts[sub_event] = {}
		
		for spellID, info in pairs(data) do
			frame.spell_counts[sub_event][spellID] = 0
			
			info.icon = C_Spell.GetSpellTexture(spellID)
			
			if not info.color then -- 默认颜色
				info.color = {0.19, 0.56, 0.9}
			end
			
			if info.divide_info then
				frame.tag_num = max(frame.tag_num, #info.divide_info.dur)
			end
		end
	end
	
	frame.bar = CreateTimerBar(frame, G.media.blank, false, true, true)
	frame.bar:SetAllPoints(frame)
	
	CreateTagsforBar(frame.bar, frame.tag_num)
	
	for i = 1, frame.tag_num do
		frame.bar["timer"..i] = T.createtext(frame.bar, "OVERLAY", 12, "OUTLINE", "LEFT")
		frame.bar["timer"..i]:SetPoint("BOTTOM", frame.bar.tag_indcators[i], "TOP", 0, 2)
	end
	
	function frame:start(sub_event, spellID)
		local info = self.spell_info[sub_event][spellID]
		
		self.count = self.count + 1
		
		self.bar:SetStatusBarColor(unpack(info.color))
		self.bar:SetMinMaxValues(0, info.dur)
		self.bar:SetReverseFill(info.reverse_fill or false)
		
		self.bar.icon:SetTexture(info.icon)
		self.bar.left:SetText(info.count and string.format("[%d]", self.count) or "")
		
		if info.hide_icon then
			self.bar.icon:Hide()
			self.bar.iconbd:Hide()
		else
			self.bar.icon:Show()
			self.bar.iconbd:Show()
		end
		
		if info.divide_info then
			InitTags(self, info)
			self.bar.right:SetShown(not info.divide_info.time)
			
			self.index = 1
			self.total = #info.divide_info.dur
		else
			self.bar.right:Show()
		end
		
		self.exp_time = GetTime() + (info.wait_dur or 0) + info.dur
		self.prepare = info.prepare_sound
		self.mute_count_down = info.mute_count_down
		self.count_down_english = info.count_down_english
		self.voi_countdown = info.count_down
			
		StartSpellCastBar(self, info, sub_event, spellID)
	end
	
	function frame:stop()
		self:SetScript("OnUpdate", nil)
		HideSpellCastBar(self)
	end	
	
	function frame:PreviewShow()
		for sub_event, data in pairs(self.spell_info) do
			for spellID, info in pairs(data) do
				self:start(sub_event, spellID)
				break
			end
		end
	end
	
	function frame:PreviewHide()
		self:stop()
	end
end

T.UpdateSpellCastBar = function(frame, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if frame.spell_info[sub_event] and frame.spell_info[sub_event][spellID] and (not frame.spell_info[sub_event][spellID]["target_me"] or destGUID == G.PlayerGUID) then
			frame.spell_counts[sub_event][spellID] = frame.spell_counts[sub_event][spellID] + 1
			if not frame.filter or frame:filter(sub_event, spellID) then
				frame:start(sub_event, spellID)
			end
		end
	elseif event == "ENCOUNTER_START" then
		frame.count = 0		
	end
end

T.ResetSpellCastBar = function(frame)
	Reset_Spell_Count(frame)
	frame:stop()
	frame:Hide()
end

--------------------------------------------------------
-----------------  [文字提示]首领技能倒计时 ----------------
--------------------------------------------------------

-- 技能倒计时模板
local function GetCooldownData(self)
	if not self.data.info then return end
	if self.data.info[self.dif] and self.data.info[self.dif][self.phase] then
		for index, v in pairs(self.data.info[self.dif][self.phase]) do			
			if type(v) == "table" then
				if self.data.info[self.dif][self.phase][self.phase_count] then
					return self.data.info[self.dif][self.phase][self.phase_count][self.count]
				end
			else
				return self.data.info[self.dif][self.phase][self.count]
			end
			break
		end		
	elseif self.data.info["all"] and self.data.info["all"][self.phase] then
		for index, v in pairs(self.data.info["all"][self.phase]) do
			if type(v) == "table" then
				if self.data.info["all"][self.phase][self.phase_count] then
					return self.data.info["all"][self.phase][self.phase_count][self.count]
				end
			else
				return self.data.info["all"][self.phase][self.count]
			end
			break
		end
	end
end
T.GetCooldownData = GetCooldownData

T.UpdateCooldownTimer = function(cast_event, cast_unit, cast_spellID, text, self, event, ...)
	if event == cast_event then
		local unit, cast_GUID, spellID = ...
		if T.CheckUnit(unit, cast_unit) and cast_GUID and self.count then
			if type(cast_spellID) == "table" then
				for _, sub_spellID in pairs(cast_spellID) do
					if spellID == sub_spellID then
						self.count = self.count + 1
						local cd = GetCooldownData(self)
						if cd then
							T.Start_Text_DelayTimer(self, cd, text, true)
						end
					end
				end
			elseif spellID == cast_spellID then
				self.count = self.count + 1
				local cd = GetCooldownData(self)
				if cd then
					T.Start_Text_DelayTimer(self, cd, text, true)
				end
			end
		end
	elseif event == "ENCOUNTER_PHASE" then
		self.phase, self.phase_count = ...
		if self.phase == 1 then
			self.phase_count = self.phase_count + 1
		end
		self.count = 1
		
		T.Stop_Text_Timer(self)
		
		local cd = GetCooldownData(self)
		if cd then
			T.Start_Text_DelayTimer(self, cd, text, true)
		end
	elseif event == "ENCOUNTER_START" then
		self.dif = select(3, ...)
		self.phase = 1
		self.phase_count = 1
		self.count = 1
		
		if self.data.cd_args then
			for k, v in pairs(self.data.cd_args) do
				self[k] = v
			end
		end

		local cd = GetCooldownData(self)
		if cd then
			T.Start_Text_DelayTimer(self, cd, text, true)
		end
	end
end

--------------------------------------------------------
-----------------  [首领模块]小怪技能倒计时 ----------------
--------------------------------------------------------
-- event: UNIT_ENTERING_COMBAT
-- event: GROUP_LEAVING_COMBAT
-- event: COMBAT_LOG_EVENT_UNFILTERED

--	frame.cast_npcID = {
--		["167532"] = { -- 粉碎者赫文
--			engage_cd = 2.3,
--			cast_cd = 17.8,
--			cast_gap = 5,
--		},
--		["162744"] = { -- 裂伤者耐克萨拉
--			engage_cd = 8.0,
--			cast_cd = 17.8,
--			cast_gap = 5,
--		},
--	}

--	frame.cast_spellID = 465827
--	frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["全团AE"]
-- 	frame.text_color = T.GetSpellColor(frame.cast_spellID)

-- 	frame.sound_default = false -- 默认开启音效(可选) true
--	frame.count_voice = "en" (可选) "cn"
--	frame.sub_event = "SPELL_CAST_SUCCESS" (可选) "SPELL_CAST_START"
--	frame.show_time = 5 显示时间(可选)
--	frame.only_trash = true

T.InitMobCooldownText = function(frame)
	local path = T.GetBossModData(frame)
	local data = T.ValueFromPath(G.Encounters, path)
	if not data.custom then
		data.custom = {}
	end
	
	if frame.sound_default == nil then
		frame.sound_default = true
	end
	
	table.insert(data.custom, 
		{
			key = "sound_bool", 
			text = L["音效"],
			default = frame.sound_default,
		}
	)
	
	table.insert(data.custom, 
		{
			key = "sound_dd", 
			text = L["倒数语音"],
			default = frame.count_voice or "cn",
			key_table = {
				{"cn", "中文"},
				{"en", "English"},
			},
			apply = function(value, frame)
				if value == "en" then
					frame.text_frame.count_down_english = true
				else
					frame.text_frame.count_down_english = nil
				end
			end,
		}
	)
	
	local min_cast_gap
	for npcID, info in pairs(frame.cast_npcID) do
		if not min_cast_gap then
			min_cast_gap = info.cast_gap
		else
			min_cast_gap = min(min_cast_gap, info.cast_gap)
		end
	end
	
	frame.engage_mobs = {}
	frame.last_exp = 0
	frame.last_count = 0
	frame.sub_event = frame.sub_event or "SPELL_CAST_START"
	
	local count_down_time = min(5, frame.show_time or floor(min_cast_gap))
	frame.show_time = count_down_time
	frame.count_down_start = count_down_time
	
	frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1, frame.text_color)
	frame.text_frame.show_time = frame.show_time
	frame.text_frame.round = true
	frame.text_frame.keep = true

	function frame:UpdateCD(sourceGUID)
		for GUID, exp_time in pairs(self.engage_mobs) do
			local npcID = select(6, strsplit("-", sourceGUID))
			if GUID == sourceGUID then
				local cast_cd = frame.cast_npcID[npcID].cast_cd
				self.engage_mobs[GUID] = GetTime() + cast_cd
			else
				local cast_gap = frame.cast_npcID[npcID].cast_gap
				self.engage_mobs[GUID] = max(GetTime() + cast_gap, exp_time)
			end
		end
	end
	
	function frame:GetNextCooldown()
		local next_exp
		for GUID, exp_time in pairs(self.engage_mobs) do
			if not next_exp then
				next_exp = exp_time
			else
				next_exp = min(exp_time, next_exp)
			end
		end
		
		local count = 0
		local mob_count = T.GetTableNum(self.engage_mobs)
		for GUID, exp_time in pairs(self.engage_mobs) do
			if exp_time - next_exp < min_cast_gap*mob_count then
				count = count + 1
			end
		end
		
		if next_exp then
			local cd = next_exp - GetTime()
			if cd > 0 then
				if next_exp ~= self.last_exp then
					local count_str = count > 1 and string.format("[%d]", count) or ""
					self.text_frame.cur_text = self.cast_str..count_str
					
					if cd < 2 then
						self.text_frame.count_down_start = nil
						T.Start_Text_DelayTimer(self.text_frame, cd, self.text_frame.cur_text)
					else
						if C.DB["BossMod"][self.config_id]["sound_bool"] then
							self.text_frame.count_down_start = frame.count_down_start
						else
							self.text_frame.count_down_start = nil
						end
						T.Start_Text_DelayTimer(self.text_frame, cd, self.text_frame.cur_text, true)
					end
					
					self.last_exp = next_exp
					self.last_count = count
				elseif count ~= self.last_count then
					local count_str = count > 1 and string.format("[%d]", count) or ""
					self.text_frame.cur_text = self.cast_str..count_str
					
					self.last_count = count
				end
			else
				T.Stop_Text_Timer(self.text_frame)
			end
		else
			T.Stop_Text_Timer(self.text_frame)
		end
	end
end

T.UpdateMobCooldownText = function(frame, event, ...)
	if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" then
		for npcID in pairs(frame.cast_npcID) do
			T.RegisterMobEngage(npcID)
		end
	elseif event == "UNIT_ENTERING_COMBAT" then
		if frame.only_trash and T.GetCurrentEngageID() then return end
		local unit, GUID, npcID = ...
		if frame.cast_npcID[npcID] then
			frame.engage_mobs[GUID] = GetTime() + frame.cast_npcID[npcID].engage_cd
			frame:GetNextCooldown()
		end
	elseif event == "GROUP_LEAVING_COMBAT" then
		frame.engage_mobs = table.wipe(frame.engage_mobs)	
		frame.last_exp = 0
		frame.last_count = 0
		T.Stop_Text_Timer(frame.text_frame)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if frame.only_trash and T.GetCurrentEngageID() then return end
		local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if sub_event == frame.sub_event and spellID == frame.cast_spellID and frame.engage_mobs[sourceGUID] then
			frame:UpdateCD(sourceGUID)
			frame:GetNextCooldown()
		elseif sub_event == "UNIT_DIED" and frame.engage_mobs[destGUID] then
			frame.engage_mobs[destGUID] = nil
			frame:GetNextCooldown()
		end
	elseif event == "ENCOUNTER_START" then
		if frame.only_trash then
			T.Stop_Text_Timer(frame.text_frame)
		end
	end
end

T.ResetMobCooldownText = function(frame)	
	frame.engage_mobs = table.wipe(frame.engage_mobs)	
	frame.last_exp = 0
	frame.last_count = 0
	T.Stop_Text_Timer(frame.text_frame)
end

--------------------------------------------------------
------------------  [首领模块]嘲讽提示 -----------------
--------------------------------------------------------
-- event: UNIT_AURA_ADD
-- event: UNIT_AURA_REMOVED
-- event: UNIT_SPELLCAST_START
-- event: UNIT_SPELLCAST_STOP
-- event: UNIT_THREAT_SITUATION_UPDATE

--	frame.aura_spellIDs = {
--		[1219439] = 1,
--		[1220618] = 1,
--	}
--	frame.cast_spellIDs = {
--		[1219263] = true,
--		[1220489] = true,
--	}

--	frame.taunt_text = L["嘲讽"].." BOSS" (可选)
--	frame.boss_npcID = "237660"
--	function frame:override_my_tank_debuffed() (可选)
--	function frame:override_other_tank_debuffed() (可选)
--	function frame:override_check_boss() (可选)

T.InitTauntAlert = function(frame)
	frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
	frame.text_frame.text:SetText(string.format("|cffff0000%s|r", frame.taunt_text or L["嘲讽"].." BOSS"))
	
	function frame:IsTanking()
		if self.boss_npcID then
			for unit in T.IterateBoss() do
				local npcID = T.GetUnitNpcID(unit)
				if npcID == self.boss_npcID then
					local isTanking = UnitDetailedThreatSituation("player", unit)
					return isTanking
				end
			end
		else
			local isTanking = UnitDetailedThreatSituation("player", "boss1")
			return isTanking
		end
	end
	
	function frame:my_tank_debuffed()
		if self.override_my_tank_debuffed then
			return self:override_my_tank_debuffed()
		else
			for spellID, value in pairs(self.aura_spellIDs) do
				if value == 1 then
					if AuraUtil.FindAuraBySpellID(spellID, "player", "HARMFUL") then
						return true
					end
				else
					local count = select(3, AuraUtil.FindAuraBySpellID(spellID, "player", "HARMFUL"))
					if count and count >= value then
						return true
					end
				end
			end
		end
	end
	
	function frame:other_tank_debuffed()
		if self.override_other_tank_debuffed then
			return self:override_other_tank_debuffed()
		else
			for unit in T.IterateCoTank() do
				for spellID, value in pairs(self.aura_spellIDs) do
					if value == 1 then
						if AuraUtil.FindAuraBySpellID(spellID, unit, "HARMFUL") then
							return true
						end
					else
						local count = select(3, AuraUtil.FindAuraBySpellID(spellID, unit, "HARMFUL"))
						if count and count >= value then
							return true
						end
					end
				end
			end
		end
	end
	
	function frame:check_boss()
		if self.override_check_boss then
			return self:override_check_boss()
		else
			local pass
			
			for unit in T.IterateBoss() do
				spellID = select(9, UnitCastingInfo(unit))
				if spellID and self.cast_spellIDs[spellID] then
					pass = true
					return
				end
			end
	
			if not pass then
				return true
			end
		end
	end
	
	function frame:check()
		--T.msg("IsTanking", self:IsTanking()  and "true" or "nil", "my_tank_debuffed", self:my_tank_debuffed() and "true" or "nil", "other_tank_debuffed", self:other_tank_debuffed() and "true" or "nil", "check_boss", self:check_boss() and "true" or "nil")
		if T.GetMyRole() == "TANK"
			and not self:IsTanking() 
			and not self:my_tank_debuffed() 
			and self:other_tank_debuffed()
			and self:check_boss() 
		then
			if not self.text_frame:IsShown() then								
				self.text_frame:Show()
				T.PlaySound("taunt")
			end
		else
			self.text_frame:Hide()
		end
	end
end

T.UpdateTauntAlert = function(frame, event, ...)
	if event == "UNIT_AURA_ADD" or event == "UNIT_AURA_REMOVED" then
		local unit, spellID = ...
		if frame.aura_spellIDs[spellID] then
			frame:check()
		end
	elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" then
		local unit, _, spellID = ...
		if string.find(unit, "boss") and frame.cast_spellIDs[spellID] then
			frame:check()
		end
	elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
		local unit = ...
		if unit == "player" then
			frame:check()
		end
	elseif event == "ENCOUNTER_START" then
		for spellID in pairs(frame.aura_spellIDs) do
			T.RegisterWatchAuraSpellID(spellID)
		end
	end
end

T.ResetTauntAlert = function(frame)
	frame.text_frame:Hide()
	for spellID in pairs(frame.aura_spellIDs) do
		T.UnregisterWatchAuraSpellID(spellID)
	end
end
--------------------------------------------------------
------------------  读取战术板信息 ---------------------
--------------------------------------------------------
-- Usage: <for lineCount, line in T.IterateNoteAssignment(tag, noteOverride) do>

T.IterateNoteAssignment = function(tag, noteOverride)
	local tag = string.format("#%sstart", tag)
	local note = noteOverride or (VMRT and VMRT.Note and VMRT.Note.Text1)
	local lineCount = 1
    local lines = {}
    	
    if note then
        local betweenLine = false
        
        for line in note:gmatch("[^\r\n]+") do			
            if line == "end" then
                betweenLine = false
            end
            
            if betweenLine then
                table.insert(lines, line)	
            end
            
            if line:match(tag) then
                betweenLine = true
            end
        end
    end
    
    return function()
        local line = lines[lineCount]
        
        if line then
            lineCount = lineCount + 1
            
            return lineCount - 1, line
        end
    end
end

-- Returns an array of GUIDs (sorted) of all units in a certain raid subgroup
local function groupToGUIDArray(groupNumber)
    local GUIDs = {}
    
    for raidIndex = 1, 40 do
        local _, _, subgroup = GetRaidRosterInfo(raidIndex)
        
        if subgroup == groupNumber then
            local unit = "raid" .. raidIndex
            local GUID = UnitGUID(unit)
            
            if GUID then
                table.insert(GUIDs, GUID)
            end
        end
    end
    
    table.sort(GUIDs)
    
    return GUIDs
end

-- Usage: <local GUIDs, containsPlayerGUID, mark = T.LineToGUIDArray(line, [allowDuplicates])>
T.LineToGUIDArray = function(line, allowDuplicates)
    local guidArray = {}
    
    line = line:gsub("||c%x%x%x%x%x%x%x%x", " ")
    line = line:gsub("||r", " ")
    line = T.gsubMarks(line)
	
	local mark = line:match("^{rt(%d)}")
    
    -- 去掉标记，以免因忘记在名字前加空格读取不到名字
    if mark then
        line = line:match("{rt%d}%s-(.+)")
    end
	
	for word in line:gmatch("%S+") do
        local subgroup = word:match("^group(%d)$")
		
        if subgroup then
            subgroup = tonumber(subgroup)
            
            local GUIDs = groupToGUIDArray(subgroup)
            
            for _, GUID in ipairs(GUIDs) do
                if allowDuplicates then
                    table.insert(guidArray, GUID)
                else
                    tInsertUnique(guidArray, GUID)
                end
            end
        else
            local GUID = T.GetGroupGUIDbyName(word)
			if GUID then
                if allowDuplicates then
                    table.insert(guidArray, GUID)
                else
                    tInsertUnique(guidArray, GUID)
                end
            end
        end
    end
    
    return guidArray, tContains(guidArray, G.PlayerGUID), tonumber(mark)
end

-- Usage: <T.InsertGUIDtoArray(line, GUIDs, [allowDuplicates])>
-- Usage: <local containsPlayerGUID = T.InsertGUIDtoArray(line, GUIDs, [allowDuplicates])>
T.InsertGUIDtoArray = function(line, GUIDs, allowDuplicates)
    local containsPlayerGUID = false
	
    line = line:gsub("||c%x%x%x%x%x%x%x%x", " ")
    line = line:gsub("||r", " ")
    
    for word in line:gmatch("%S+") do
        local GUID = T.GetGroupGUIDbyName(word)
        
        if GUID and (allowDuplicates or not tContains(GUIDs, GUID)) then
            table.insert(GUIDs, GUID)
            
            if GUID == G.PlayerGUID then
                containsPlayerGUID = true
            end
        end
    end
    
    return containsPlayerGUID
end

-- Usage: <T.FillArrayByGUID(line, GUIDs)>
-- Usage: <local containsPlayerGUID = T.FillArrayByGUID(line, GUIDs)>
T.FillArrayByGUID = function(line, GUIDs)
    local containsPlayerGUID = false
	
    line = line:gsub("||c%x%x%x%x%x%x%x%x", " ")
    line = line:gsub("||r", " ")
    
    for word in line:gmatch("%S+") do
        local GUID = T.GetGroupGUIDbyName(word)
        
        if GUID then
            GUIDs[GUID] = true
            
            if GUID == G.PlayerGUID then
                containsPlayerGUID = true
            end
        end
    end
    
    return containsPlayerGUID
end

T.GetColoredNameListByArray = function(GUIDs, start_str, mark)
	local str = ""
	if start_str then
		str = str .. start_str
	end
	if mark then
		str = str .. T.FormatRaidMark(mark)
	end
	for _, GUID in pairs(GUIDs) do
		str = str .." ".. T.ColorNickNameByGUID(GUID)
	end
	return str 
end