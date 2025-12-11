local T, C, L, G = unpack(select(2, ...))
local addon_name = G.addon_name
local FrameHolder = G.FrameHolder

local aura_check_units = {"player", "boss1", "boss2", "boss3", "boss4", "boss5"}
local update_rate = .05
----------------------------------------------------------
-------------------[[    图标提示    ]]--------------------
----------------------------------------------------------
local IconAlertGroupFrames = {}
G.IconAlertGroupFrames = IconAlertGroupFrames

local function CreateIconAlertGroupFrame(name, text, anchor, x, y, pa)
	local frame = CreateFrame("Frame", addon_name..name, FrameHolder)
	frame:SetSize(70,70)
	frame.is_pa_anchor = pa
	
	frame.movingname = text
	frame.point = { a1 = anchor, a2 = "CENTER", x = x, y = y}
	T.CreateDragFrame(frame)
	
	frame.active_byindex = {}
	
	function frame:lineup()
		local grow_dir = C.DB["IconAlertOption"]["grow_dir"]
		local space = C.DB["IconAlertOption"]["icon_space"]
		local font_space = C.DB["IconAlertOption"]["font_size"]
		local lastframe
		
		for index, icon in pairs(self.active_byindex) do
			if icon:IsShown() then
				icon:ClearAllPoints()
				if not lastframe then
					icon:SetPoint(grow_dir, self, grow_dir, 0, 0)
				elseif grow_dir == "BOTTOM" then
					icon:SetPoint(grow_dir, lastframe, "TOP", 0, space+font_space)
				elseif grow_dir == "TOP" then
					icon:SetPoint(grow_dir, lastframe, "BOTTOM", 0, -space-font_space)
				elseif grow_dir == "LEFT" then
					icon:SetPoint(grow_dir, lastframe, "RIGHT", space, 0)
				elseif grow_dir == "RIGHT" then
					icon:SetPoint(grow_dir, lastframe, "LEFT", -space, 0)	
				end
				lastframe = icon
			end
		end
	end
	
	table.insert(IconAlertGroupFrames, frame)
	
	return frame
end

local AlertFrame = CreateIconAlertGroupFrame("AlertFrame", L["图标提示1"], "BOTTOMRIGHT", -300, 90)
local AlertFrame2 = CreateIconAlertGroupFrame("AlertFrame2", L["图标提示2"], "BOTTOMRIGHT", -300, 0)
local AlertFrame3 = CreateIconAlertGroupFrame("AlertFrame3", L["PA图标提示"], "BOTTOMRIGHT", -300, -90, true)

T.EditIconAlertFrames = function(option)
	if option == "all" or option == "enable" then
		if C.DB["IconAlertOption"]["enable_pa"] then
			T.RestoreDragFrame(AlertFrame3)
			AlertFrame3:Show()
		else
			T.ReleaseDragFrame(AlertFrame3)
			AlertFrame3:Hide()
		end
	end
	
	if option == "all" or option == "icon_size" then
		for i, frame in pairs(IconAlertGroupFrames) do
			if frame.is_pa_anchor then
				frame:SetSize(C.DB["IconAlertOption"]["privateaura_icon_size"], C.DB["IconAlertOption"]["privateaura_icon_size"])
			else
				frame:SetSize(C.DB["IconAlertOption"]["icon_size"], C.DB["IconAlertOption"]["icon_size"])
			end
		end
	end
	
	if option == "all" or option == "alpha" then
		AlertFrame3:SetAlpha(C.DB["IconAlertOption"]["privateaura_icon_alpha"])
	end
	
	if option == "all" or option == "grow_dir" then
		for i, frame in pairs(IconAlertGroupFrames) do
			frame:lineup()
		end
	end
	
	for i, frame in pairs(IconAlertGroupFrames) do
		for _, icon in pairs(frame.active_byindex) do
			icon:update_onedit(option)
		end
	end
end

-- 获取图标
local CreateAlertIcon = function(updater, parent, tag)
	local icon = T.CreateAnimSpellIcon(parent, tag)
	
	icon.t = 0
	
	function icon:update_onedit(option) -- 载入配置
		if option == "all" or option == "enable" then
			if self.path then
				if not T.ValueFromDB(self.path)["enable"] then
					self:cancel()
					self.tag = nil
					updater.actives_bytag[tag] = nil
				end
			end
		end
		
		if option == "all" or option == "icon_size" then
			self:SetSize(C.DB["IconAlertOption"]["icon_size"], C.DB["IconAlertOption"]["icon_size"])
		end
		
		if option == "all" or option == "font_size" then
			self.text:SetFont(G.Font, C.DB["IconAlertOption"]["font_size"], "OUTLINE")
			self.brtext:SetFont(G.Font, C.DB["IconAlertOption"]["font_size"], "OUTLINE")
			self.brtext:SetHeight(C.DB["IconAlertOption"]["font_size"])
		end
		
		if option == "all" or option == "ifont_size" then
			self.toptext:SetFont(G.Font, C.DB["IconAlertOption"]["ifont_size"], "OUTLINE")
			self.toptext:SetHeight(C.DB["IconAlertOption"]["ifont_size"])
			self.bottomtext:SetFont(G.Font, C.DB["IconAlertOption"]["ifont_size"], "OUTLINE")
		end
		
		if option == "all" or option == "spelldur" then
			if C.DB["IconAlertOption"]["show_spelldur"] then
				self.text:Show()
			else
				self.text:Hide()
			end
		end
	end
	
	function icon:display(args)
		if args.type and args.spellID then
			self.edit_key = args.type.."_"..args.spellID
			
			if args.type ~= "test" then
				if not self.path then
					self.path = {}
					self.path[1] = "AlertIcon"
				end
				
				self.path[2] = args.type
				self.path[3] = args.spellID
			end
		end
		
		-- Init
		self.GUID = nil
		
		self:update_onedit("all")
		
		if args.hl and args.hl ~= "" then
			self.innerBD:SetBackdropBorderColor(unpack(G.hl_colors[gsub(args.hl, "_flash", "")]))
			self.innerBD:Show()
		else
			self.innerBD:Hide()
		end
		
		local spellName = C_Spell.GetSpellName(args.spellID)
		local spellIcon = C_Spell.GetSpellTexture(args.spellID)
		
		self.texture:SetTexture(args.icon_tex or spellIcon)	
		self.toptext:SetText(spellName)
		self.bottomtext:SetText(args.tip)
		self.ficontext:SetText(T.GetFlagIconStr(args.ficon, true))
		self.brtext:SetText("")
		
		self:Show()
	end
	
	function icon:cancel()
		self.edit_key = nil
		self.path = nil
		
		self:Hide()
		self:SetScript("OnUpdate", nil)
		self.cooldown:SetCooldown(0, 0)
		self.anim:Stop()			
	end
	
	if updater then
		updater.actives_bytag[tag] = icon
	end
	
	return icon
end

-- 获取喊话讯息
local GetAuraMsg = function(str, spellID)
	local spellName = C_Spell.GetSpellName(spellID)
	local msg
	msg = T.MarkMsgtoStr(str)
	msg = gsub(msg, "%%name", G.PlayerName)
	msg = gsub(msg, "%%spell", spellName)
	msg = gsub(msg, "%%stack", 2)
	msg = gsub(msg, "%%dur", 3)
	return msg
end

local GetMsgInfo = function(info, spellID)
	local str = ""
	if info.str_applied then
		str = str.." "..GetAuraMsg(info.str_applied, spellID)
	end
	if info.str_cd then
		str = str.." "..GetAuraMsg(info.str_cd, spellID)
	end
	if info.str_rep then
		str = str.." "..GetAuraMsg(info.str_rep, spellID)
	end
	if info.str_stack then
		str = str.." "..GetAuraMsg(info.str_stack, spellID)
	end
	return str
end

-- 图标：光环
local AlertIcon_Aura_Updater = T.CreateUpdater(CreateAlertIcon, AlertFrame, AlertFrame2)

AlertIcon_Aura_Updater.MultiSpellIDs = {}

T.CreateAura = function(option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	
	if args.msg then
		details.msg_bool = true
		table.insert(detail_options, {key = "msg_bool", text = L["喊话"]..GetMsgInfo(args.msg, args.spellID), default = true})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_AlertIcon_Options(option_page, category, path, args, detail_options)
	
	if args.spellIDs then
		for _, spellID in pairs(args.spellIDs) do
			AlertIcon_Aura_Updater.MultiSpellIDs[spellID] = args.spellID
		end
	end
	
	T.AddData(args, option_page.engageTag, option_page.mapTag, category, args.spellID)
end

local PlayNumberSound = function(sound, count)
	if string.match(sound, "%[(.+)%]") then
		C_Timer.After(1, function()
			if count <= 10 then
				T.PlaySound("count\\"..count)
			else
				T.SpeakText(tostring(count))
			end
		end)
	else
		if count <= 10 then
			T.PlaySound("count\\"..count)
		else
			T.SpeakText(tostring(count))
		end
	end
end

function AlertIcon_Aura_Updater:update(aura_tag, icon, args, GUID, aura_data, applied)
	icon:display(args)
	
	local name = aura_data.name
	local count = aura_data.applications
	local amount = (args.effect and aura_data.points and aura_data.points[args.effect]) or 0
	local start_time = aura_data.expirationTime - aura_data.duration
	local exp_time = aura_data.expirationTime	
	local duration = aura_data.duration
	
	if applied then
		-- 喊话
		if args.msg and T.ValueFromDB(icon.path)["msg_bool"] then -- 消息
			if args.msg.str_applied then
				T.SendAuraMsg(args.msg.str_applied, args.msg.channel, name, count)
			end
			if args.msg.str_rep then
				if duration > 0 then
					icon.msg_countdown = duration
				else
					icon.msg_update = GetTime()
				end
			end
			if args.msg.str_cd then
				icon.msg_countdown = args.msg.cd or 3
			end
		end
		
		-- 声音
		if args.sound and T.ValueFromDB(icon.path)["sound_bool"] then -- 音效
			T.PlaySound(string.match(args.sound, "%[(.+)%]"))
			if string.match(args.sound, "cd(%d+)") then
				icon.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
			end
		end
		
		-- 动画
		if args.hl and string.find(args.hl, "_flash") then
			icon.anim:Play()
		end
		
		icon.GUID = GUID
		icon.count_old = nil
		icon.duration_old = nil
		icon.exp_time_old = nil
	end
	
	-- 层数或数量刷新
	if amount > 0 then
		icon.brtext:SetText(string.format("|cff00BFFF%s|r", T.ShortValue(amount)))
	else
		icon.brtext:SetText(string.format("|cffFFFF00%s|r", count > 0 and count or ""))
	end
	
	-- 层数变化的文字
	if args.tip and string.match(args.tip, "%%s(%d+)") then -- 显示法术效果（如易伤20%，减速40%）
		local value = tonumber(string.match(args.tip, "%%s(%d+)"))
		icon.bottomtext:SetText(args.tip:gsub("(%d+)", ""):gsub("%%s", value*count))
	end
		
	-- 层数刷新
	if icon.count_old ~= count then
		-- 层数变化的声音
		if args.sound and string.find(args.sound, "stack") and T.ValueFromDB(icon.path)["sound_bool"] then -- 声音
			if string.match(args.sound, "stackmore(%d+)") then
				local num = tonumber(string.match(args.sound, "stackmore(%d+)"))
				if count >= num then
					PlayNumberSound(args.sound, count)
				end
			elseif string.match(args.sound, "stackless(%d+)") then
				local num = tonumber(string.match(args.sound, "stackless(%d+)"))
				if count <= num then
					PlayNumberSound(args.sound, count)
				end
			elseif string.find(args.sound, "stacksfx") then
				if not applied then
					T.PlaySound(string.match(args.sound, "%[(.+)%]"))
				end
			else
				PlayNumberSound(args.sound, count)
			end
		end
		
		-- 层数变化的喊话
		if not applied and args.msg and args.msg.str_stack and T.ValueFromDB(icon.path)["msg_bool"] then -- 聊天讯息 层数
			if args.msg.max then
				if count <= args.msg.max then
					T.SendAuraMsg(args.msg.str_stack, args.msg.channel, name, count)
				end
			elseif args.msg.min then
				if count >= args.msg.min then
					T.SendAuraMsg(args.msg.str_stack, args.msg.channel, name, count)
				end
			else
				T.SendAuraMsg(args.msg.str_stack, args.msg.channel, name, count)
			end
		end
		
	end
	
	-- 时间刷新	
	if icon.duration_old ~= duration or icon.exp_time_old ~= exp_time then
		if duration > 0 and exp_time > 0 then
			icon.cooldown:SetCooldown(start_time, duration) 
			icon:SetScript("OnUpdate", function(s, e)
				s.t = s.t + e
				if s.t > update_rate then	
					s.remain = exp_time - GetTime()
					if s.remain > 0 then
						s.text:SetText(T.FormatTime(s.remain))
						
						s.remain_second = ceil(s.remain)
						
						if args.sound and s.voi_countdown then -- 声音
							if s.remain_second == s.voi_countdown then
								T.PlaySound("count\\"..s.remain_second)
								s.voi_countdown = s.voi_countdown - 1
							end
						end
						
						if args.msg and s.msg_countdown then -- 聊天讯息 倒数
							if s.remain_second <= s.msg_countdown then
								if args.msg.str_cd then
									T.SendAuraMsg(args.msg.str_cd, args.msg.channel, name, count, s.remain_second)
								end
								if args.msg.str_rep then
									T.SendAuraMsg(args.msg.str_rep, args.msg.channel, name, count, s.remain_second)
								end
								s.msg_countdown = s.msg_countdown - 1
							end
						end
					else
						self:RemoveAlert(aura_tag)
					end
					s.t = 0
				end
			end)
		else
			icon.text:SetText("∞")
			icon:SetScript("OnUpdate", function(s, e)
				s.t = s.t + e
				if s.t > update_rate then
					if args.msg and args.msg.str_rep and s.msg_update then-- 聊天讯息 重复
						if GetTime() - s.msg_update > 0 then
							T.SendAuraMsg(args.msg.str_rep, args.msg.channel, name, count)
							s.msg_update = GetTime() + 1.5
						end
					end
					s.t = 0
				end
			end)
		end
	end
	
	icon.count_old = count
	icon.duration_old = duration
	icon.exp_time_old = exp_time
end

function AlertIcon_Aura_Updater:AuraFullCheck(unit, GUID)
	for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
		AuraUtil.ForEachAura(unit, auraType, nil, function(aura_data)
			local spellID = self.MultiSpellIDs[aura_data.spellId] or aura_data.spellId
			local args = T.ValueFromPath(G.Current_Data, {"AlertIcon", "aura", spellID})
			if args and T.CheckUnit(unit, args.unit) and T.CheckAuraType(args.aura_type, aura_data) then
				local enable = T.ValueFromDB({"AlertIcon", "aura", spellID, "enable"})
				local aura_tag = GUID.."-"..aura_data.auraInstanceID
				if enable and not self.actives_bytag[aura_tag] then					
					local icon = self:GetAlert(args.hl and 1 or 2, aura_tag)
					self:update(aura_tag, icon, args, GUID, aura_data, true)
				end
			end
		end, true)
	end
end

AlertIcon_Aura_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_AURA" then
		local unit, updateInfo = ...
		if unit and T.FilterAuraUnit(unit) then
			if updateInfo == nil or updateInfo.isFullUpdate then
				local GUID = UnitGUID(unit)				
				if not GUID then return end
				
				for _, icon in pairs(self.actives_bytag) do
					if icon.GUID == GUID then
						self:RemoveAlert(icon.tag)
					end
				end
				
				self:AuraFullCheck(unit, GUID)
			else				
				if updateInfo.addedAuras ~= nil then
					for _, aura_data in pairs(updateInfo.addedAuras) do
						local spellID = self.MultiSpellIDs[aura_data.spellId] or aura_data.spellId
						local args = T.ValueFromPath(G.Current_Data, {"AlertIcon", "aura", spellID})
						if args and T.CheckUnit(unit, args.unit) and T.CheckAuraType(args.aura_type, aura_data) then
							local enable = T.ValueFromDB({"AlertIcon", "aura", spellID, "enable"})
							local GUID = UnitGUID(unit)
							local aura_tag = GUID and GUID.."-"..aura_data.auraInstanceID
							if enable and aura_tag and not self.actives_bytag[aura_tag] then
								local icon = self:GetAlert(args.hl and 1 or 2, aura_tag)
								self:update(aura_tag, icon, args, GUID, aura_data, true)
							end
						end
					end
				end
				if updateInfo.updatedAuraInstanceIDs ~= nil then
					for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
						local GUID = UnitGUID(unit)
						local aura_tag = GUID and GUID.."-"..auraID
						local icon = aura_tag and self.actives_bytag[aura_tag]
						if icon then
							local aura_data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
							if aura_data then
								local spellID = self.MultiSpellIDs[aura_data.spellId] or aura_data.spellId
								local args = T.ValueFromPath(G.Current_Data, {"AlertIcon", "aura", spellID})
								if args then
									self:update(aura_tag, icon, args, GUID, aura_data)
								end
							else
								self:RemoveAlert(icon.tag)
							end
						end
					end
				end
				if updateInfo.removedAuraInstanceIDs ~= nil then
					for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
						local GUID = UnitGUID(unit)
						local aura_tag = GUID and GUID.."-"..auraID
						local icon = aura_tag and self.actives_bytag[aura_tag]
						if icon then
							self:RemoveAlert(icon.tag)
						end
					end
				end
			end
		end
	elseif event == "DATA_ADDED" then
		for _, unit in pairs(aura_check_units) do
			if UnitExists(unit) then
				local GUID = UnitGUID(unit)
				if not GUID then return end
				self:AuraFullCheck(unit, GUID)
			end
		end
	elseif event == "DATA_REMOVED" then
		for _, icon in pairs(self.actives_bytag) do
			self:RemoveAlert(icon.tag)
		end
	elseif event == "ENCOUNTER_ENGAGE_UNIT" then
		local unit, GUID = ...
		if T.FilterAuraUnit(unit) then
			self:AuraFullCheck(unit, GUID)
		end
	end
end)

T.RegisterEventAndCallbacks(AlertIcon_Aura_Updater, {
	["UNIT_AURA"] = true,
	["DATA_ADDED"] = true,
	["DATA_REMOVED"] = true,
	["ENCOUNTER_ENGAGE_UNIT"] = true,
})

-- 图标：私人光环
local CreatePrivateAura = function(index)
	local frame = CreateFrame("Frame", nil, AlertFrame3)
	frame:SetSize(70, 70)
	frame:Hide()
	--T.createborder(frame)
	
	function frame:ShowPrivateAuraIcon()
		if not self.auraAnchorID then
			self.auraAnchorID = C_UnitAuras.AddPrivateAuraAnchor({
				unitToken = "player",
				auraIndex = index,
				parent = self,
				showCountdownFrame = true,
				showCountdownNumbers = true,
				iconInfo = {
					iconWidth = C.DB["IconAlertOption"]["privateaura_icon_size"],
					iconHeight = C.DB["IconAlertOption"]["privateaura_icon_size"],
					iconAnchor = {
						point = "CENTER",
						relativeTo = self,
						relativePoint = "CENTER",
						offsetX = 0,
						offsetY = 0,
					},
				},
				durationAnchor = {
					point = "TOP",
					relativeTo = self,
					relativePoint = "BOTTOM",
					offsetX = 0,
					offsetY = -1,
				},
			})
		end
		self:Show()
		AlertFrame3:lineup()
	end
	
	function frame:HidePrivateAuraIcon()
		if self.auraAnchorID then
			C_UnitAuras.RemovePrivateAuraAnchor(self.auraAnchorID)
			self.auraAnchorID = nil
		end
		self:Hide()
	end
	
	function frame:update_onedit(option) -- 载入配置
		if option == "all" or option == "enable" then
			if C.DB["IconAlertOption"]["enable_pa"] then
				self:ShowPrivateAuraIcon()
			else
				self:HidePrivateAuraIcon()
			end
		end
		
		if option == "all" or option == "icon_size" then
			self:SetSize(C.DB["IconAlertOption"]["privateaura_icon_size"], C.DB["IconAlertOption"]["privateaura_icon_size"])
			self:HidePrivateAuraIcon()
			self:ShowPrivateAuraIcon()
		end
	end
	
	table.insert(AlertFrame3.active_byindex, frame)
end

for i = 1, 4 do
	CreatePrivateAura(i)
end

-- 图标：对我施法
local AlertIcon_Com_Updater = T.CreateUpdater(CreateAlertIcon, AlertFrame, AlertFrame2)

AlertIcon_Com_Updater.MultiSpellIDs = {}

T.CreateCom = function(option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	
	if args.msg then
		details.msg_bool = true
		table.insert(detail_options, {key = "msg_bool", text = L["喊话"]..GetMsgInfo(args.msg, args.spellID), default = true})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_AlertIcon_Options(option_page, category, path, args, detail_options)
	
	if args.spellIDs then
		for _, spellID in pairs(args.spellIDs) do
			AlertIcon_Com_Updater.MultiSpellIDs[spellID] = args.spellID
		end
	end
	
	T.AddData(args, option_page.engageTag, option_page.mapTag, category, args.spellID)
end

function AlertIcon_Com_Updater:update(cast_GUID, icon, args, startTimeMS, endTimeMS)	
	icon:display(args)
	
	local name = C_Spell.GetSpellName(args.spellID)
	local start_time = startTimeMS/1000
	local exp_time = endTimeMS/1000
	local duration = exp_time - start_time
	
	-- 喊话
	if args.msg and T.ValueFromDB(icon.path)["msg_bool"] then
		if args.msg.str_applied then
			T.SendAuraMsg(args.msg.str_applied, args.msg.channel, name)
		end
		if args.msg.str_rep then
			icon.msg_countdown = floor(duration)
		end
		if args.msg.str_cd then
			icon.msg_countdown = args.msg.cd or 3
		end
	end
	
	-- 声音
	if args.sound and T.ValueFromDB(icon.path)["sound_bool"] then -- 音效
		T.PlaySound(string.match(args.sound, "%[(.+)%]"))
		if string.match(args.sound, "cd(%d+)") then
			icon.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
		end
	end
	
	-- 动画
	if args.hl and string.find(args.hl, "_flash") then
		icon.anim:Play()
	end
	
	-- 计时
	if duration > 0 and exp_time > 0 then
		icon.cooldown:SetCooldown(start_time, duration)
		icon:SetScript("OnUpdate", function(s, e)
			s.t = s.t + e
			if s.t > update_rate then
				s.remain = exp_time - GetTime()
				if s.remain > 0 then
					s.text:SetText(T.FormatTime(s.remain))
					
					s.remain_second = ceil(s.remain)
					
					if args.sound and s.voi_countdown then -- 声音
						if s.remain_second <= s.voi_countdown then
							T.PlaySound("count\\"..s.remain_second)
							s.voi_countdown = s.voi_countdown - 1
						end
					end
					
					if args.msg and s.msg_countdown then -- 喊话
						if s.remain_second <= s.msg_countdown then
							if args.msg.str_cd then
								T.SendAuraMsg(args.msg.str_cd, args.msg.channel, name, count, s.remain_second)
							end
							if args.msg.str_rep then
								T.SendAuraMsg(args.msg.str_rep, args.msg.channel, name, count, s.remain_second)
							end
							s.msg_countdown = s.msg_countdown - 1
						end
					end
				else
					self:RemoveAlert(cast_GUID)
				end
				s.t = 0
			end
		end)
	end
end

AlertIcon_Com_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_SPELLCAST_START" then
		local unit, cast_GUID, cast_spellID = ...
		if unit and cast_GUID and cast_spellID then
			local spellID = self.MultiSpellIDs[cast_spellID] or cast_spellID
			local args = T.ValueFromPath(G.Current_Data, {"AlertIcon", "com", spellID})
			if args then
				local enable = T.ValueFromDB({"AlertIcon", "com", spellID, "enable"})
				if enable then	
					C_Timer.After(.2, function()
						local target_unit = T.GetTarget(unit)
						if target_unit and UnitIsUnit(target_unit, "player") then
							local startTimeMS, endTimeMS = select(4, UnitCastingInfo(unit))
							if not self.actives_bytag[cast_GUID] and startTimeMS and endTimeMS then
								local icon = self:GetAlert(args.hl and 1 or 2, cast_GUID)
								self:update(cast_GUID, icon, args, startTimeMS, endTimeMS)
							end
						end
					end)
				end
			end
		end
	elseif event == "UNIT_SPELLCAST_STOP" then
		local unit, cast_GUID, spellID = ...
		if cast_GUID and self.actives_bytag[cast_GUID] then
			self:RemoveAlert(cast_GUID)
		end
	elseif event == "UNIT_TARGET" then
		local unit = ...
		if unit and UnitCastingInfo(unit) then
			local startTimeMS, endTimeMS, _, cast_GUID, _, cast_spellID = select(4, UnitCastingInfo(unit))
			if cast_GUID then
				local target_unit = T.GetTarget(unit)
				if target_unit and UnitIsUnit(target_unit, "player") then
					if not self.actives_bytag[cast_GUID] then
						local spellID = self.MultiSpellIDs[cast_spellID] or cast_spellID
						local args = T.ValueFromPath(G.Current_Data, {"AlertIcon", "com", spellID})
						if args then
							local enable = T.ValueFromDB({"AlertIcon", "com", spellID, "enable"})
							if enable then
								local icon = self:GetAlert(args.hl and 1 or 2, cast_GUID)
								self:update(cast_GUID, icon, args, startTimeMS, endTimeMS)
							end
						end
					end
				else
					if self.actives_bytag[cast_GUID] then
						self:RemoveAlert(cast_GUID)
					end
				end
			end
		end
	end
end)

T.RegisterEventAndCallbacks(AlertIcon_Com_Updater, {
	["UNIT_SPELLCAST_START"] = true,
	["UNIT_SPELLCAST_STOP"] = true,
	["UNIT_TARGET"] = true,
})

-- 图标：BOSS消息
local AlertIcon_Msg_Updater = T.CreateUpdater(CreateAlertIcon, AlertFrame, AlertFrame2)

T.CreateBossMsg = function(option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	if args.msg then
		details.msg_bool = true
		table.insert(detail_options, {key = "msg_bool", text = L["喊话"]..GetMsgInfo(args.msg, args.spellID), default = true})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_AlertIcon_Options(option_page, category, path, args, detail_options)
	
	T.AddData(args, option_page.engageTag, option_page.mapTag, category, args.spellID)
end

function AlertIcon_Msg_Updater:update(msg_key, icon, args)
	icon:display(args)
	
	local name = C_Spell.GetSpellName(args.spellID)
	
	-- 喊话
	if args.msg and T.ValueFromDB(icon.path)["msg_bool"] then
		if args.msg.str_applied then
			T.SendAuraMsg(args.msg.str_applied, args.msg.channel, name)
		end
		if args.msg.str_rep then
			icon.msg_countdown = args.dur
		end
		if args.msg.str_cd then
			icon.msg_countdown = args.msg.cd or 3
		end
	end
	
	-- 声音
	if args.sound and T.ValueFromDB(icon.path)["sound_bool"] then
		T.PlaySound(string.match(args.sound, "%[(.+)%]"))
		if string.match(args.sound, "cd(%d+)") then
			icon.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
		end
	end
	
	-- 动画
	if args.hl and string.find(args.hl, "_flash") then
		icon.anim:Play()
	end
	
	-- 计时
	icon.cooldown:SetCooldown(GetTime(), args.dur)
	icon.exp_time = GetTime() + args.dur
	icon:SetScript("OnUpdate", function(s, e)
		s.t = s.t + e
		if s.t > update_rate then	
			s.remain = s.exp_time - GetTime()
			if s.remain > 0 then
				s.text:SetText(T.FormatTime(s.remain))
				
				s.remain_second = ceil(s.remain)
				
				if args.sound and s.voi_countdown then -- 声音
					if s.remain_second == s.voi_countdown then
						T.PlaySound("count\\"..s.remain_second)
						s.voi_countdown = s.voi_countdown - 1
					end
				end
				
				if args.msg and s.msg_countdown then -- 喊话
					if s.remain_second == s.msg_countdown then
						if args.msg.str_cd then
							T.SendAuraMsg(args.msg.str_cd, args.msg.channel, name, nil, s.remain_second)
						end
						if args.msg.str_rep then
							T.SendAuraMsg(args.msg.str_rep, args.msg.channel, name, nil, s.remain_second)
						end
						s.msg_countdown = s.msg_countdown - 1
					end
				end
			else
				self:RemoveAlert(msg_key)
			end
			s.t = 0
		end
	end)
end

AlertIcon_Msg_Updater:SetScript("OnEvent", function(self, event, ...)
	local msg = ...
	if msg and G.Current_Data["AlertIcon"] and G.Current_Data["AlertIcon"]["bmsg"] then
		for spellID, args in pairs(G.Current_Data["AlertIcon"]["bmsg"]) do
			if args.event == event and string.find(msg, args.boss_msg) then
				local enable = T.ValueFromDB({"AlertIcon", "bmsg", spellID, "enable"})
				if enable and not self.actives_bytag[args.boss_msg] then
					local icon = self:GetAlert(args.hl and 1 or 2, args.boss_msg)
					self:update(args.boss_msg, icon, args)
				end
			end
		end
	end
end)

T.RegisterEventAndCallbacks(AlertIcon_Msg_Updater, {
	["CHAT_MSG_RAID_BOSS_WHISPER"] = true,
	["CHAT_MSG_RAID_BOSS_EMOTE"] = true,
	["CHAT_MSG_MONSTER_YELL"] = true,
	["CHAT_MSG_MONSTER_WHISPER"] = true,
	["CHAT_MSG_MONSTER_EMOTE"] = true,
	["CHAT_MSG_MONSTER_PARTY"] = true,
	["CHAT_MSG_MONSTER_SAY"] = true,
})

-- 图标：测试
local AlertIcon_Test_Updater = T.CreateUpdater(CreateAlertIcon, AlertFrame, AlertFrame2)

function AlertIcon_Test_Updater:update(key, icon, args)
	icon:display(args)
		
	-- 动画
	if args.hl and string.find(args.hl, "_flash") then
		icon.anim:Play()
	end
	
	-- 计时
	icon.cooldown:SetCooldown(GetTime(), args.dur)
	icon.exp_time = GetTime() + args.dur
	icon:SetScript("OnUpdate", function(s, e)
		s.t = s.t + e
		if s.t > update_rate then	
			s.remain = s.exp_time - GetTime()
			if s.remain > 0 then
				s.text:SetText(T.FormatTime(s.remain))				
			else
				self:RemoveAlert(key)
			end
			s.t = 0
		end
	end)
end

local TestAlertIcons = {
	{type = "test", spellID = 426010, hl = "red_flash", dur = 5, tip = "Tip1"},
	{type = "test", spellID = 425093, hl = "gre", dur = 17, tip = "Tip2"},
	{type = "test", spellID = 200580, dur = 18, tip = "Tip3"},
}

function AlertFrame:PreviewShow()
	for i, args in pairs(TestAlertIcons) do
		local icon = AlertIcon_Test_Updater:GetAlert(args.hl and 1 or 2, args.spellID)
		AlertIcon_Test_Updater:update(args.spellID, icon, args)
	end
end

function AlertFrame:PreviewHide()
	for i, args in pairs(TestAlertIcons) do		
		AlertIcon_Test_Updater:RemoveAlert(args.spellID)
	end
end
