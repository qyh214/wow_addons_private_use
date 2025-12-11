local T, C, L, G = unpack(select(2, ...))

local addon_name = G.addon_name
local font = G.Font

local LGF = LibStub("LibGetFrame-1.0")
local LRC = LibStub("LibRangeCheck-3.0")

--====================================================--
--[[                 -- 公用功能 --                 ]]--
--====================================================--

-- 上标记
T.SetRaidTarget = function(unit, rm)
	if not C.DB["GeneralOption"]["disable_rmark"] then
		SetRaidTarget(unit, rm) -- 上标记
	end
end

-- 获取姓名板
T.GetUnitNameplate = function(unit)
	local f = LGF.GetUnitNameplate(unit)
	return f
end

-- 获取团队框架
T.GetUnitFrame = function(unit)
	local f = LGF.GetUnitFrame(unit)
	return f
end

-- 刷新框架
T.ScanForUnitFrames = function()
	LGF:ScanForUnitFrames()
end

T.UnitInRange = function(unit)
	if unit then
		return UnitIsUnit(unit, "player") or UnitInRange(unit)
	end
end

-- 获取距离
T.GetRange = function(unit, checkVisible)
  return LRC:GetRange(unit, checkVisible)
end

-- 在距离内（50码）
T.IsUnitInRange = function(unit)	
	if C_Item.IsItemInRange(116139, unit) then
		return true
	end
end

--  [50]116139, -- Haunting Memento
--  [55]74637, -- Kiryn's Poison Vial
--  [60]32825, -- Soul Cannon
--  [60]37887, -- Seeds of Nature's Wrath
--  [70]41265, -- Eyesore Blaster

-- 获取目标
T.GetTarget = function(unit)
	local target_unit
	if unit == "player" then
		target_unit = "target"
	else
		target_unit = unit.."target"
	end
	if UnitExists(target_unit) then
		return target_unit
	end
end

-- 根据专精获取我的当前职责
T.GetMyRole = function()
	local my_spec_index = GetSpecialization()
	local role = select(5, GetSpecializationInfo(my_spec_index))
	return role
end

local Spec_Pos = {
	-- Death Knight
	[250] = "MELEE", -- Blood (Tank)
	[251] = "MELEE", -- Frost (DPS)
	[252] = "MELEE", -- Unholy (DPS)
	-- Demon Hunter
	[577] = "MELEE", -- Havoc (DPS)
	[581] = "MELEE", -- Vengeance (Tank)
	-- Druid
	[102] = "RANGED", -- Balance (DPS Owl)
	[103] = "MELEE", -- Feral (DPS Cat)
	[104] = "MELEE", -- Guardian (Tank Bear)
	[105] = "RANGED", -- Restoration (Heal)
	-- Evoker
	[1467] = "RANGED", -- Devastation (DPS)
	[1468] = "RANGED", -- Preservation (Heal)
	[1473] = "RANGED", -- Augmentation (DPS)
	-- Hunter
	[253] = "RANGED", -- Beast Mastery
	[254] = "RANGED", -- Marksmanship
	[255] = "MELEE", -- Survival
	-- Mage
	[62] = "RANGED", -- Arcane
	[63] = "RANGED", -- Fire
	[64] = "RANGED", -- Frost
	-- Monk
	[268] = "MELEE", -- Brewmaster (Tank)
	[269] = "MELEE", -- Windwalker (DPS)
	[270] = "MELEE", -- Mistweaver (Heal)
	-- Paladin
	[65] = "MELEE", -- Holy (Heal)
	[66] = "MELEE", -- Protection (Tank)
	[70] = "MELEE", -- Retribution (DPS)
	-- Priest
	[256] = "RANGED", -- Discipline (Heal)
	[257] = "RANGED", -- Holy (Heal)
	[258] = "RANGED", -- Shadow (DPS)
	-- Rogue
	[259] = "MELEE", -- Assassination
	[260] = "MELEE", -- Outlaw
	[261] = "MELEE", -- Subtlety
	-- Shaman
	[262] = "RANGED", -- Elemental (DPS)
	[263] = "MELEE", -- Enhancement (DPS)
	[264] = "RANGED", -- Restoration (Heal)
	-- Warlock
	[265] = "RANGED", -- Affliction
	[266] = "RANGED", -- Demonology
	[267] = "RANGED", -- Destruction
	-- Warrior
	[71] = "MELEE", -- Arms (DPS)
	[72] = "MELEE", -- Fury (DPS)
	[73] = "MELEE", -- Protection (Tank)
}

-- 根据专精获取我的当前位置
T.GetMyPos = function()
	local my_spec_index = GetSpecialization()
	local my_spec_ID = GetSpecializationInfo(my_spec_index)
	local pos = Spec_Pos[my_spec_ID]
	return pos
end

-- 延迟生效功能
local delayframe = CreateFrame("Frame")
delayframe.t = 0
delayframe.func = {}

local DelayFunc = function(delay, func)
	local t = {action = func, wait = delay}
	if not tContains(delayframe.func, t) then
		table.insert(delayframe.func, t)
		if not delayframe:GetScript("OnUpdate") then
			delayframe:SetScript("OnUpdate", function(self, elapsed)
				self.t = self.t + elapsed
				if self.t > 0.1 then
					if delayframe.func[1] then
						delayframe.func[1].wait = delayframe.func[1].wait - self.t
						if delayframe.func[1].wait <= 0 then
							local cur_func = delayframe.func[1].action
							table.remove(delayframe.func, 1)
							cur_func()	
						end
					else
						self:SetScript("OnUpdate", nil)
					end
					self.t = 0
				end
			end)
		end
	end
end
T.DelayFunc = DelayFunc

--====================================================--
--[[                   -- 法术 --                   ]]--
--====================================================--

-- 通过ID查找光环
do
	local function SpellIDPredicate(auraSpellIDToFind, _, _, _, _, _, _, _, _, _, _, _, spellID)
		return auraSpellIDToFind == spellID
	end
	
	function AuraUtil.FindAuraBySpellID(spellID, unit, filter)
		return AuraUtil.FindAura(SpellIDPredicate, unit, filter, spellID)
	end
end

-- 检查自身法术可用
T.MySpellCheck = function(spellID, isPet)
	local spellBank = isPet and 1 or 0
	if not C_SpellBook.IsSpellKnown(spellID, spellBank) then
		return
	end
	
	local charges = C_Spell.GetSpellCharges(spellID)	
	if charges and charges.currentCharges > 0 then
		return true, charges.currentCharges
	else
		local cd_info = C_Spell.GetSpellCooldown(spellID)
		local start, dur = cd_info.startTime, cd_info.duration
		if start and dur < 2 then
			return true, 1
		end
	end
end

--====================================================--
--[[                -- 首领和副本 --                ]]--
--====================================================--
-- 检查难度
local CheckDifficulty = function(ficon, v)
	if G.TestMod or not ficon then
		return true
	elseif not (string.find(ficon, "3") or string.find(ficon, "12")) then
		return true
	elseif string.find(ficon, "3") and v == 15 then
		return true
	elseif string.find(ficon, "12") and v == 16 then
		return true
	end
end
T.CheckDifficulty = CheckDifficulty

-- 获取存在的BOSS单位
-- <for unit in T.IterateBoss() do>
T.IterateBoss = function()
  local BossMembers = 8
  local ArenaBossMembers = 5
  local totalBossMembers = BossMembers + ArenaBossMembers
  local i = 1
  return function()
    local ret
    if i <= BossMembers then
		ret = "boss" .. i
	elseif i <= totalBossMembers then
		ret = "arena" .. (i - BossMembers)
    end
    i = i + 1
	if UnitExists(ret) then
		return ret
	end
  end
end

T.GetBossUnitbyNpcID = function(target_npcID)
	local matched = {}
	if target_npcID then
		for unit in T.IterateBoss() do
			local GUID = UnitGUID(unit)
			local npcID = select(6, strsplit("-", GUID))
			if npcID == target_npcID then
				table.insert(matched, unit)
			end
		end
	end
	
	if next(matched) then
		return matched[1], matched
	end
end

T.GetBossUnitbyGUID = function(target_GUID)
	if target_GUID then
		for unit in T.IterateBoss() do
			local GUID = UnitGUID(unit)
			if GUID == target_GUID then
				return unit
			end
		end
	end
end

T.GetCurrentTank = function(k) -- GUID/npcID
	local boss_unit
	if string.find(k, "-") then -- GUID
		boss_unit = T.GetBossUnitbyGUID(k)
	elseif k then -- NpcID
		boss_unit = T.GetBossUnitbyNpcID(k)
	else
		boss_unit = "boss1"
	end
	
	if boss_unit then
		for unit in Lib:IterateGroupMembers() do
			local isTanking = UnitDetailedThreatSituation(unit, boss_unit)
            if isTanking then                  
                return unit
            end
		end
	end
end

T.CheckEncounter = function(npcIDs, ficon)
	local difficultyID = select(3, GetInstanceInfo())
	if CheckDifficulty(ficon, difficultyID) then -- 难度符合
		for unit in T.IterateBoss() do
			local npcID = T.GetUnitNpcID(unit)
			if tContains(npcIDs, npcID) then
				return true
			end
		end
	end
end

T.CheckDungeon = function(mapID)
	local map = select(8, GetInstanceInfo())
	if map == mapID then
		return true	
	end
end

local FlagRoles = {
	["0"] = "TANK",
	["1"] = "DAMAGER",
	["2"] = "HEALER",
}

T.CheckRole = function(ficon)
	if not ficon or not C.DB["GeneralOption"]["role_enable"] then
		return true
	else
		local ficons = strsplittable(",", ficon)
		local str = ""
		for i, ficon in pairs(ficons) do
			if FlagRoles[ficon] then
				str = str..FlagRoles[ficon]..","
			end
		end
		if str == "" then
			return true	
		else
			local tree = GetSpecialization()
			if tree then
				local role = select(5, GetSpecializationInfo(tree))
				if role and string.find(str, role) then
					return true
				end
			end
		end		
	end
end

-- 首领名字
T.GetEncounterName = function(ENCID)
	if type(ENCID) == "number" then
		local name = EJ_GetEncounterInfo(ENCID)
		return name
	else
		return L["杂兵"]
	end
end

--====================================================--
--[[                  -- NPC功能 --                 ]]--
--====================================================--

-- 获取NPCID
T.GetUnitNpcID = function(unit)
	local GUID = unit and UnitGUID(unit)
	if GUID then
		return select(6, strsplit("-", GUID))
	end
end

-- 获取NPC名字
local scanTooltip = CreateFrame("GameTooltip", "NPCNameToolTip", nil, "GameTooltipTemplate") --fake tooltipframe used for reading localized npc names -- by lunaic
T.GetNameFromNpcID = function(npcID)
	local name
	if JST_DB and JST_DB["NpcNames"][npcID] then
		name = JST_DB["NpcNames"][npcID]
	else
		scanTooltip:SetOwner(UIParent,"ANCHOR_NONE")
		scanTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0000000000", npcID))
		if scanTooltip:NumLines()>0 then
			name = NPCNameToolTipTextLeft1:GetText()
			scanTooltip:Hide()
			if name and JST_DB then
				JST_DB["NpcNames"][npcID] = name
			end
		end
	end
	
	if name then
		return name
	else
		T.msg(string.format(L["加载失败"], npcID))
		return "npc"..npcID	
	end
end

-- 获取NPC名字带文本格式
T.GetFomattedNameFromNpcID = function(npcID)
	local name = T.GetNameFromNpcID(npcID)
	return string.format("|cffFFFFFF[%s]|r", name)
end

--====================================================--
--[[                    -- 表格 --                  ]]--
--====================================================--
-- 获取表内讯息
T.GetTableInfoByValue = function(t, k, v)
	for i, info in pairs(t) do
		if info[k] == v then
			return info
		end
	end
end

-- 获取下一个可用项
T.GetNextValueAvailable = function(t, t2)
	for i, name in pairs(t) do
		if not t2[name] then
			t2[name] = true
			return name
		end
	end
end

-- 表格子项目数量
T.GetTableNum = function(t)
	local num = 0
	for k, v in pairs(t) do
		num = num + 1
	end
	return num
end

-- 复制并插入表格
T.CopyTableInsertElement = function(copy_t, new_element)
	local target_t = {}
	for k, v in pairs(copy_t) do
		target_t[k] = v
	end
	table.insert(target_t, new_element)
	return target_t
end

--====================================================--
--[[                 -- 音效/朗读 --                ]]--
--====================================================--

-- 获取语音包路径
T.apply_sound_pack = function()
	local var = C.DB["GeneralOption"]["sound_pack"]
	local info = T.GetTableInfoByValue(G.SoundPacks, 1, var)
	if info then
		C.DB["GeneralOption"]["sound_file"] = info[3]
	else
		T.msg(string.format(L["语音包缺失"], var))
	end
end

-- 播放音效
T.PlaySound = function(sound, sound2)
	if C.DB["GeneralOption"]["disable_sound"] or not sound then return end
	
	local soundChannel = C.DB["GeneralOption"]["sound_channel"]
	
	local soundPlayed = PlaySoundFile(C.DB["GeneralOption"]["sound_file"]..sound..".ogg", soundChannel)
	if not soundPlayed then
		PlaySoundFile([[Interface\AddOns\JST_SoundPackCN\sounds\]]..sound..".ogg", soundChannel)
	end
	
	if sound2 then
		C_Timer.After(.8, function()
			local soundPlayed = PlaySoundFile(C.DB["GeneralOption"]["sound_file"]..sound2..".ogg", soundChannel)
			if not soundPlayed then
				PlaySoundFile([[Interface\AddOns\JST_SoundPackCN\sounds\]]..sound2..".ogg", soundChannel)
			end
		end)
	end
end

local cd_frame = CreateFrame("Frame")
cd_frame.t = 0
cd_frame.exp_time = 0
cd_frame.data = {}

-- 开始倒数
T.StartCountDown = function(key, exp_time, count_down, prepare_sound, stop_sound, count_down_english)
	local tag = key or #cd_frame.data + 1
	
	if not cd_frame.data[tag] then
		cd_frame.data[tag] = {
			exp_time = exp_time,
			count_down = count_down,
			prepare = prepare_sound,
			stop = stop_sound,
			count_down_english = count_down_english,
		}
	end
	
	if cd_frame:GetScript("OnUpdate") then return end
	
	cd_frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > 0.05 then
			if T.GetTableNum(self.data) == 0 then
				self:SetScript("OnUpdate", nil)
			end
			
			for tag, info in pairs(self.data) do
				info.remain_second = ceil(info.exp_time - GetTime())
				
				if info.remain_second <= 0 then
					if info.stop then
						T.PlaySound(info.stop)
					end
					self.data[tag] = nil
					
				elseif info.remain_second <= info.count_down then
					if info.prepare then
						T.PlaySound(info.prepare)	
						info.prepare = nil
					else
						if info.count_down_english then
							T.PlaySound("count_en\\"..info.remain_second)
						else
							T.PlaySound("count\\"..info.remain_second)
						end
					end
					info.count_down = info.remain_second - 1
				end
			end
			
			self.t = 0
		end
	end)
end

-- 停止倒数
T.StopCountDown = function(tag)
	if cd_frame.data[tag] then
		cd_frame.data[tag] = nil
		if T.GetTableNum(cd_frame.data) == 0 then
			cd_frame:SetScript("OnUpdate", nil)
		end
	end
end

-- 朗读
T.SpeakText = function(script)
	if C.DB["GeneralOption"]["disable_sound"] then return end
	C_VoiceChat.StopSpeakingText()
	C_Timer.After(.1, function() C_VoiceChat.SpeakText(C.DB["GeneralOption"]["tts_speaker"], script, 1, 0, C.DB["GeneralOption"]["tl_sound_volume"]) end)
end
--====================================================--
--[[                 -- 消息/喊话 --                ]]--
--====================================================--

-- 发消息
T.SendChatMsg = function(msg, rp, channel)
	if not C.DB["GeneralOption"]["disbale_msg"] then
		if rp then
			local ticker = C_Timer.NewTicker(1, function(self)
				local remain = rp - floor(GetTime() - self.start) + 1
				local msg_rp = gsub(msg, "%%dur", remain)
				SendChatMessage(msg_rp.."..", channel or "SAY")
			end, rp)
			ticker.start = GetTime()
			
			return ticker
		else
			SendChatMessage(msg.."..", channel or "SAY")
		end
	end
end

-- 循环消息
T.StartMsgTicker = function(parent, msg, rp, channel)
	if rp then
		if parent.msg_ticker then
			parent.msg_ticker:Cancel()
		end
		parent.msg_ticker = C_Timer.NewTicker(1, function(self)
			local remain = rp - floor(GetTime() - self.start) + 1
			local msg_rp = gsub(msg, "%%dur", remain)
			SendChatMessage(msg_rp.."..", channel or "SAY")
		end, rp)
		parent.msg_ticker.start = GetTime()
	else
		if parent.msg_ticker then
			parent.msg_ticker:Cancel()
		end
		parent.msg_ticker = C_Timer.NewTicker(1, function(self)	
			SendChatMessage(msg.."..", channel or "SAY")
		end)
	end
end

-- 停止循环消息
T.StopMsgTicker = function(parent)
	if parent.msg_ticker then
		parent.msg_ticker:Cancel()
	end
end

-- 发消息（光环讯息）
T.SendAuraMsg = function(str, channel, spell, stack, dur, tag)
	local msg
	msg = gsub(str, "%%name", G.PlayerName)
	if spell then
		msg = gsub(msg, "%%spell", spell)
	end
	if stack then
		msg = gsub(msg, "%%stack", stack)
	end
	if dur then
		msg = gsub(msg, "%%dur", function(a) return ceil(dur) end)
	end
	if tag then
		msg = gsub(msg, "%%tag", tag)
	end
	T.SendChatMsg(msg, nil, channel or "SAY")
end


--====================================================--
--[[                 -- 颜色处理 --                 ]]--
--====================================================--

-- 插件主题色
T.color_text = function(text)
	return string.format(G.addon_colorStr.."%s|r", text)
end

-- 染色
T.hex_str = function(str, color)
	local r, g, b = unpack(color)
	return ('|cff%02x%02x%02x%s|r'):format(r * 255, g * 255, b * 255, str)
end

T.ColorByProgress = function(value, gre)
	local v
	v = min(value, 1)
	v = max(0, v)
	
	local r, g, b = 1, 1, 1
	if gre then-- 1 绿 .5 黄 0 红
		if v >= .5 then
			r = (1 - v)*2
			g = 1
			b = 0
		else
			r = 1
			g = v*2
			b = 0
		end
	else -- 1 红 .5 黄 0 绿
		if v >= .5 then
			r = 1
			g = (1-v)*2
			b = 0
		else										
			r = v*2
			g = 2
			b = 0	
		end
	end
	return r, g, b
end

-- 团队标记颜色
RM_Colors = {
	{.95, 1, .29}, -- 1
	{.92, .58, .07}, -- 2
	{.89, .44, .88}, -- 3
	{.36, 1, .33}, -- 4
	{.87, .96, .98}, -- 5
	{.03, .77, .91}, -- 6
	{.97, .35, .23}, -- 7
	{.93, .91, .89}, -- 8
}

T.GetRaidMarkColor = function(index)
	return unpack(RM_Colors[index])
end

local printed = {}

-- 法术颜色
T.GetSpellColor = function(spellID)
	local icon = C_Spell.GetSpellTexture(spellID)
	if icon and G.IconColor[icon] then
		return G.IconColor[icon]
	else
		if icon then
			if not printed[icon] then 
				printed[icon] = true
				T.msg(string.format("%s[%d] = {},", T.GetTextureStr(icon), icon))
			end
		else
			T.msg(string.format("法术|cffffff00[%d]|r获取不到图标，无法提取颜色", spellID))
		end
		return {1, 1, 1}		
	end
end

-- 图标颜色
T.GetTexColor = function(icon)
	if icon and G.IconColor[icon] then
		return G.IconColor[icon]
	elseif not printed[icon] then
		T.msg(string.format("%s[%d] = {},", T.GetTextureStr(icon), icon))
		printed[icon] = true
		return {1, 1, 1}
	end
end

-- 渐变颜色
T.ColorGradient = function(perc, ...)
	local num = select("#", ...)
	local hexes = type(select(1, ...)) == "string"

	if perc == 1 then
		return select(num-2, ...), select(num-1, ...), select(num, ...)
	end

	num = num / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2
	r1, g1, b1 = select((segment*3)+1, ...), select((segment*3)+2, ...), select((segment*3)+3, ...)
	r2, g2, b2 = select((segment*3)+4, ...), select((segment*3)+5, ...), select((segment*3)+6, ...)

	if not r2 or not g2 or not b2 then
		return r1, g1, b1
	else
		return r1 + (r2-r1)*relperc,
		g1 + (g2-g1)*relperc,
		b1 + (b2-b1)*relperc
	end
end

-- From https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
T.hsvToRgb = function(h, s, v)
    local r, g, b
    
    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);
    
    i = i % 6
    
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return r, g, b
end
--====================================================--
--[[                 -- 文本处理 --                  ]]--
--====================================================--

-- UTF-8 缩写
T.Utf8Sub = function(input, size)
  local output = ""
  input = tostring(input)
  if type(input) ~= "string" then
    return output
  end
  local i = 1
  while (size > 0) do
    local byte = input:byte(i)
    if not byte then
      return output
    end
    if byte < 128 then
      -- ASCII byte
      output = output .. input:sub(i, i)
      size = size - 1
    elseif byte < 192 then
      -- Continuation bytes
      output = output .. input:sub(i, i)
    elseif byte < 244 then
      -- Start bytes
      output = output .. input:sub(i, i)
      size = size - 1
    end
    i = i + 1
  end

  -- Add any bytes that are part of the sequence
  while (true) do
    local byte = input:byte(i)
    if byte and byte >= 128 and byte < 192 then
      output = output .. input:sub(i, i)
    else
      break
    end
    i = i + 1
  end

  return output
end

-- 聊天框提示（一般讯息）
T.msg = function(...)
	local msg = strjoin(" ", ...)
	print(G.addon_colorStr.."JST|r> "..msg)
end

-- 分割线
T.divideline = function(str)
	local msg
	if str then
		local lenth = string.len(str)
		local num = max(5, 20-floor(lenth/10))
		local side = string.rep("-", num)
		msg = string.format("%s%s%s", side, str, side)
	else
		msg = "--------------------------------"
	end
	print(G.addon_colorStr.."JST|r> "..msg)
end

-- 聊天框提示（测试讯息）
T.test_msg = function(...)
	if G.TestMod then
		local msg = strjoin(" ", ...)
		print(G.addon_colorStr.."JST TEST|r> "..msg)
	end
end

local SendAddonMessageResult = {
	--[0] = "成功 Success",
	[1] = "发送插件讯息失败，前缀无效 Invalid Prefix",
	[2] = "发送插件讯息失败，讯息无效 Invalid Message",
	[3] = "发送插件讯息失败，插件讯息受限 Addon Message Throttle",	
	[4] = "发送插件讯息失败，聊天类型无效 Invalid ChatType",
	[5] = "发送插件讯息失败，不在队伍中 Not In Group",
	[6] = "发送插件讯息失败，需要接收目标 Target Required",	
	[7] = "发送插件讯息失败，频道无效 Invalid channel",
	[8] = "发送插件讯息失败，频道受限 channel Throttle",
	[9] = "发送插件讯息失败，其他错误 General Error",	
}

local GetChannel = function(str)
	local CHANNEL
	if IsInGroup() and str == "GROUP" then		
		CHANNEL = (IsInRaid(1) and "RAID") or (IsInGroup(1) and "PARTY") or (IsInGroup(2) and "INSTANCE_CHAT")
	elseif IsInRaid() and str == "RAID" then
		CHANNEL = (IsInRaid(1) and "RAID") or (IsInRaid(2) and "INSTANCE_CHAT")
	elseif IsInGroup() and str == "PARTY" then
		CHANNEL = (IsInGroup(1) and "PARTY") or (IsInGroup(2) and "INSTANCE_CHAT")
	elseif str == "WHISPER" then
		CHANNEL = str
	end
	return CHANNEL
end

-- 插件消息
T.addon_msg = function(msg, channel, whisper_tar)
	if whisper_tar then
		local succeed, reason = C_ChatInfo.SendAddonMessage("jstpaopao", G.PlayerGUID..","..msg, "WHISPER", whisper_tar)
		if reason and SendAddonMessageResult[reason] then
			T.test_msg(SendAddonMessageResult[reason].." "..msg.." "..whisper_tar)
		end
	else
		local CHANNEL = GetChannel(channel)
		if CHANNEL then
			local succeed, reason = C_ChatInfo.SendAddonMessage("jstpaopao", G.PlayerGUID..","..msg, CHANNEL)
			if reason and SendAddonMessageResult[reason] then
				T.test_msg(SendAddonMessageResult[reason].." "..msg)
			end
		end
	end
end

-- 时间格式
local day, hour, minute = 86400, 3600, 60
T.FormatTime = function(s, v)
    if v then
		return format("%.1f", s)
	elseif s >= day then
        return format("%dd", floor(s/day + 0.5))
    elseif s >= hour then
        return format("%dh", floor(s/hour + 0.5))
    elseif s >= minute then
        return format("%dm", floor(s/minute + 0.5))
	elseif s >= 2 then
		return format("%d", s)
	else
		return format("%.1f", s)
    end
end

-- 内存格式
T.memFormat = function(num)
	if num > 1024 then
		return format("%.2f mb", (num / 1024))
	else
		return format("%.1f kb", floor(num))
	end
end

-- 数值缩短
T.ShortValue = function(val)
	if type(val) == "number" then
		if G.Client == "zhCN" or G.Client == "zhTW" then
			if (val >= 1e7) then
				return ("%.1fkw"):format(val / 1e7)
			elseif (val >= 1e4) then
				return ("%.1fw"):format(val / 1e4)
			else
				return ("%d"):format(val)
			end
		else
			if (val >= 1e6) then
				return ("%.1fm"):format(val / 1e6)
			elseif (val >= 1e3) then
				return ("%.1fk"):format(val / 1e3)
			else
				return ("%d"):format(val)
			end
		end
	else
		return val
	end
end

-- 法术图标
T.GetSpellIcon = function(spellID)
	local icon = C_Spell.GetSpellTexture(spellID)
	if icon then
		return "|T"..icon..":12:12:0:0:64:64:4:60:4:60|t"
	end
end

-- 法术图标和链接
T.GetIconLink = function(spellID)
	local icon = C_Spell.GetSpellTexture(spellID)	
	local name = C_Spell.GetSpellName(spellID)
	return (icon and "|T"..icon..":12:12:0:0:64:64:4:60:4:60|t" or "").."|cff71d5ff["..name.."]|r"
end

-- 材质转文本
T.GetTextureStr = function(tex)
	return "|T"..tex..":12:12:0:0:64:64:4:60:4:60|t"
end

-- 打断模板
T.GetInterruptStr = function(mobID, spellID, rt, interrupt, backup)
	local mobs = {string.split(",", mobID)}
	local result = ""
	for ind, npcID in pairs(mobs) do
		local spell = C_Spell.GetSpellName(spellID)
		local npcName = T.GetNameFromNpcID(npcID)
		local title = string.format(L["打断模板"], npcName, spell)
		local str = string.format("#%s-%d-%d-%s", title, npcID, interrupt, rt)..strrep("( )", interrupt)
		if backup then
			str = string.format(str..string.format("(%s: )", L["替补"]))
		end
		if ind == 1 then
			result = result..str
		else
			result = result.."\n"..str
		end
	end
	return result
end

local ClassIDs = {
	WARRIOR		= 1,
	PALADIN 	= 2,
	HUNTER		= 3,
	ROGUE		= 4,	
	PRIEST		= 5,
	DEATHKNIGHT	= 6,
	SHAMAN		= 7,
	MAGE	    = 8,
	WARLOCK	    = 9,
	MONK        = 10,
	DRUID	    = 11,
	DEMONHUNTER = 12,
	EVOKER		= 13,
}

T.GetClassMrtStr = function(classFile)
	local classID = ClassIDs[classFile]
	if classID then
		local className = GetClassInfo(classID)
		local str = string.format("||c%s%s||r", G.Ccolors[classFile].colorStr, className)
		return str
	end
end
--====================================================--
--[[                 -- 团队标记 --                  ]]--
--====================================================--
-- 团队标记
T.FormatRaidMark = function(text)
	if type(text) == "number" then
		return string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t", text)
	else
		local marks = strsplittable(",", text)
		local result = ""
		for _, mark in pairs(marks) do
			result = result..string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t", mark)
		end
		return result
	end
end

-- 标记喊话转文本
T.MarkMsgtoStr = function(text)
	local result = gsub(text, "{rt(%d)}", function(e) return string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t", e) end)
	return result
end

-- 本地标记结转序号
local markToNumber = {
    -- Raid Target Icon (ID)
    ["{rt1}"] = 1,
    ["{rt2}"] = 2,
    ["{rt3}"] = 3,
    ["{rt4}"] = 4,
    ["{rt5}"] = 5,
    ["{rt6}"] = 6,
    ["{rt7}"] = 7,
    ["{rt8}"] = 8,
    
    -- Raid Target Icon (ENG)
    ["{star}"] = 1,
    ["{circle}"] = 2,
    ["{diamond}"] = 3,
    ["{triangle}"] = 4,
    ["{moon}"] = 5,
    ["{square}"] = 6,
    ["{cross}"] = 7,
    ["{skull}"] = 8,
    
    -- Raid Target Icon (DE)
    ["{stern}"] = 1,
    ["{kreis}"] = 2,
    ["{diamant}"] = 3,
    ["{dreieck}"] = 4,
    ["{mond}"] = 5,
    ["{quadrat}"] = 6,
    ["{kreuz}"] = 7,
    ["{totenschädel}"] = 8,
    
    -- Raid Target Icon (FR)
    ["{étoile}"] = 1,
    ["{cercle}"] = 2,
    ["{losange}"] = 3,
    ["{lune}"] = 5,
    ["{carré}"] = 6,
    ["{croix}"] = 7,
    ["{crâne}"] = 8,
    
    -- Raid Target Icon (IT)
    ["{stella}"] = 1,
    ["{cerchio}"] = 2,
    ["{rombo}"] = 3,
    ["{triangolo}"] = 4,
    ["{luna}"] = 5,
    ["{quadrato}"] = 6,
    ["{croce}"] = 7,
    ["{teschio}"] = 8,
    
    -- Raid Target Icon (ES)
    ["{estrella}"] = 1,
    ["{círculo}"] = 2,
    ["{diamante}"] = 3,
    ["{triángulo}"]= 4,
    ["{cuadrado}"] = 6,
    ["{cruz}"] = 7,
    ["{calavera}"] = 8,
    
    -- Raid Target Icon (RU)
    ["{звезда}"] = 1,
    ["{круг}"] = 2,
    ["{ромб}"] = 3,
    ["{треугольник}"] = 4,
    ["{полумесяц}"] = 5,
    ["{квадрат}"] = 6,
    ["{крест}"] = 7,
    ["{череп}"] = 8,
    
    -- Raid Target Icon (CN)
    ["{星形}"] = 1,
    ["{圆形}"] = 2,
    ["{菱形}"] = 3,
    ["{三角}"] = 4,
    ["{月亮}"] = 5,
    ["{方块}"] = 6,
    ["{十字}"] = 7,
    ["{骷髅}"] = 8,
    
    -- Raid Target Icon (KR)
    ["{별}"] = 1,
    ["{동그라미}"] = 2,
    ["{다이아몬드}"] = 3,
    ["{세모}"] = 4,
    ["{달}"] = 5,
    ["{네모}"] = 6,
    ["{가위표}"] = 7,
    ["{해골}"] = 8,
}

T.MarkToNumber = function(mark)
    return mark and markToNumber[mark]
end

-- 读取本地化标记转通用标记格式
local gsubMarks = {}

for mark, number in pairs(markToNumber) do
    gsubMarks[mark] = string.format("{rt%d}", number)
end

T.gsubMarks = function(text)
    return text:gsub("{.-}", gsubMarks)
end

-- RaidFlags转标记序号
local code_of_raid_marks = {
    [128] = 8, -- skull
	[64] = 7, -- cross
	[32] = 6, -- square
	[16] = 5, -- moon
	[8] = 4, -- triangle
	[4] = 3, -- diamond
	[2] = 2, -- circle
	[1] = 1, -- star
}

T.GetRaidFlagsMark = function(RaidFlags)
	if RaidFlags and RaidFlags > 0 then
		local check = bit.band(RaidFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)
		if check and code_of_raid_marks[check] then
			return code_of_raid_marks[check]
		end
	end
end

--====================================================--
--[[               -- 地下城手册标记 --             ]]--
--====================================================--

-- 小标记
local filtermarks = {
	[3] = true,
	[12] = true,
}

local custommarks = {
	[14] = "|TInterface\\AddOns\\JST\\media\\interrupt_red.png:0:0:0:0:64:64:0:64:0:64|t"
}

-- 序号转字串
--EncounterJournal_SetFlagIcon
T.GetFlagIconStr = function(ficon, filter)
	local str = ""
	if ficon then 
		local marks = {string.split(",", ficon)}
		for i, mark in pairs(marks) do
			local index = tonumber(mark)
			if not filter or not filtermarks[index] then
				if custommarks[index] then
					local icon = custommarks[index]
					str = str..icon
				else
					local iconSize = 32
					local columns = 256/iconSize -- 8
					local rows = 64/iconSize -- 2
					local l = mod(index, columns)*iconSize+8
					local r = l+iconSize-14
					local t = floor(index/columns)*iconSize+8
					local b = t+iconSize-14
					
					local icon = string.format("|TInterface\\EncounterJournal\\UI-EJ-Icons:0:0:0:0:256:64:%d:%d:%d:%d|t", l, r, t, b)
					str = str..icon
				end
			end
		end
	end
	return str
end

-- 序号转文字
T.CreateFlagIconText = function(parent, size, ficon, anchor, filter, ...)
	local text = T.createtext(parent, "OVERLAY", size, "OUTLINE", anchor)
	text:SetPoint(...)
	text:SetText(T.GetFlagIconStr(ficon, filter))
end

-- 图标材质
T.EncounterJournal_SetFlagIcon = function(texture, index)
	if index == 0 then
		texture:Hide()
	else
		local iconSize = 32
		local columns = 256/iconSize
		local rows = 64/iconSize
		local l = mod(index, columns) / columns
		local r = l + (1/columns)
		local t = floor(index/columns) / rows
		local b = t + (1/rows)
		texture:SetTexCoord(l, r, t, b)
		texture:Show()
	end
end

--====================================================--
--[[                  -- 外观功能 --                ]]--
--====================================================--
-- 边框
T.createborder = function(f, r, g, b, a)
	if f.style then return end
	
	f.sd = CreateFrame("Frame", nil, f, "BackdropTemplate")
	local lvl = f:GetFrameLevel()
	f.sd:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
	f.sd:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\AddOns\\JST\\media\\glow",
		edgeSize = 3,
		insets = { left = 3, right = 3, top = 3, bottom = 3,}
	})
	f.sd:SetPoint("TOPLEFT", f, -3, 3)
	f.sd:SetPoint("BOTTOMRIGHT", f, 3, -3)
	if not (r and g and b) then
		f.sd:SetBackdropColor(.05, .05, .05, .7)
		f.sd:SetBackdropBorderColor(0, 0, 0)
	else
		f.sd:SetBackdropColor(r, g, b, a)
		f.sd:SetBackdropBorderColor(0, 0, 0)
	end
	f.style = true
end

-- 边框框体
T.createbdframe = function(f)
	local bg
	
	if f:GetObjectType() == "Texture" then
		bg = CreateFrame("Frame", nil, f:GetParent(), "BackdropTemplate")
		local lvl = f:GetParent():GetFrameLevel()
		bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	else
		bg = CreateFrame("Frame", nil, f, "BackdropTemplate")
		local lvl = f:GetFrameLevel()
		bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	end
	
	bg:SetPoint("TOPLEFT", f, -3, 3)
	bg:SetPoint("BOTTOMRIGHT", f, 3, -3)
	
	bg:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\AddOns\\JST\\media\\glow",
		edgeSize = 3,
			insets = { left = 3, right = 3, top = 3, bottom = 3,}
		})
		
	bg:SetBackdropColor(.05, .05, .05, .5)
	bg:SetBackdropBorderColor(0, 0, 0)
	
	return bg
end

T.createGUIbd = function(f, a)
	f.sd = CreateFrame("Frame", nil, f, "BackdropTemplate")
	
	local lvl = f:GetFrameLevel()
	f.sd:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
	f.sd:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 12,
		insets = { left = 3, right = 3, top = 2, bottom = 3 }
	})
	f.sd:SetPoint("TOPLEFT", f, -3, 3)
	f.sd:SetPoint("BOTTOMRIGHT", f, 3, -3)
	
	f.sd:SetBackdropColor(.12, .12, .12, a or 0.8)
	f.sd:SetBackdropBorderColor(.5, .5, .5)
end

-- 彩色边框
local hl_colors = {
	["red"] = {1, 0, 0},
	["gre"] = {.23, .96, .23},
	["blu"] = {.32, .65, .93},
	["pur"] = {.77, .45, 1},
	["org"] = {1, .5, 0},
	["yel"] = {1, .89, .12},
}

-- 图标粗边框
T.SetHighLightBorderColor = function(frame, anchor, color, edgeSize)
	local size = edgeSize or 5
	
	frame.innerBD = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	frame.innerBD:SetFrameLevel(frame:GetFrameLevel()+1)
	frame.innerBD:SetAllPoints(anchor)
	frame.innerBD:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = size,
		insets = { left = size, right = size, top = size, bottom = size}
	})
	frame.innerBD:SetBackdropColor(0, 0, 0, 0)
	
	if type(color) == "table" then
		frame.innerBD:SetBackdropBorderColor(unpack(color))
	else
		local color_key = gsub(color, "_flash", "")
		frame.innerBD:SetBackdropBorderColor(unpack(hl_colors[color_key]))
	end
end

-- 文本
T.createtext = function(frame, layer, fontsize, flag, justifyh, justifyv)
	local text = frame:CreateFontString(nil, layer)
	text:SetFont(font, fontsize, flag)
	
	if justifyh then
		text:SetJustifyH(justifyh)
	end
	
	if justifyv then
		text:SetJustifyV(justifyv)
	end
	
	return text
end

--====================================================--
--[[                    -- 配置 --                  ]]--
--====================================================--

-- 获取路径值
do
	local ValueFromPath
	ValueFromPath = function(data, path)
		if not data then
			return nil
		end
		if (#path == 0) then
			return data
		elseif(#path == 1) then
			return data[path[1]]
		else
			local reducedPath = {}
			for i= 2, #path do
				reducedPath[i-1] = path[i]
			end
			return ValueFromPath(data[path[1]], reducedPath)
		end
	end
	T.ValueFromPath = ValueFromPath
end

-- 路径赋值
do
	local ValueToPath
	function ValueToPath(data, path, value)
		if not data then
			return
		end
		if(#path == 1) then
			data[path[1]] = value
		else
			local reducedPath = {}
			for i= 2, #path do
				reducedPath[i-1] = path[i]
			end
			if data[path[1]] == nil then
				data[path[1]] = {}
			end
			ValueToPath(data[path[1]], reducedPath, value)
		end
	end
	T.ValueToPath = ValueToPath
end

T.ValueFromDB = function(path)
	local value
	if C.UseAccountSettings then
		value = T.ValueFromPath(JST_DB.CDB, path)
	else
		value = T.ValueFromPath(JST_CDB, path)
	end
	return value
end

T.ValueToDB = function(path, value)
	if C.UseAccountSettings then
		T.ValueToPath(JST_DB.CDB, path, value)
	else
		T.ValueToPath(JST_CDB, path, value)
	end
end

T.ValueToString = function(value)
	local valuetext
	if value == false then
		return "false"
	elseif value == true then
		return "true"
	elseif type(value) == "number" then
		return string.format("<num%d>", value)
	else
		return value
	end
end

T.StringToValue = function(str_value)
	if str_value == "true" then
		return true	
	elseif str_value == "false" then
		return false	
	elseif string.match(str_value, "<num(%d+)>") then
		return tonumber(string.match(str_value, "<num(%d+)>"))
	else
		return str_value
	end
end

T.ValueToMsg = function(value)
	local valuetext
	if value == false then
		return L["不启用"]
	elseif value == true then
		return L["启用"]
	else
		return value
	end
end

T.PathToString = function(path)
	local t = CopyTable(path)
	for k, v in pairs(t) do
		t[k] = T.ValueToString(v)
	end
	return table.concat(t, "-")
end

T.StringToPath = function(str)
	local path = {string.split("-", str)}
	for k, v in pairs(path) do
		path[k] = T.StringToValue(v)
	end
	return path
end