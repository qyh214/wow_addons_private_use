local T, C, L, G = unpack(select(2, ...))
local addon_name = G.addon_name


local function InRangeOfUnit(unit)
	if UnitIsUnit(unit, "player") then
		return true
	else
		local class = select(2, UnitClass(unit))
		if class == "EVOKER" then
			if G.myClass == "EVOKER" then
				return UnitInRange(unit)
			else
				return C_Item.IsItemInRange(1180, unit) --30
			end
		else
			if G.myClass == "EVOKER" then
				return C_Item.IsItemInRange(34471, unit) -- 40
			else
				return UnitInRange(unit)
			end
		end
	end
end

----------------------------------------------------------
-----------------[[    团队减伤分配    ]]-----------------
----------------------------------------------------------

local DefenseSpellPrority = G.GroupTrackedSpellsbyIndex.DefenseSupport

local DefenseSpellProrityBySpell = {}
for pro, spellID in pairs(DefenseSpellPrority) do
	DefenseSpellProrityBySpell[spellID] = pro
end

local function SortBySpellPrority(t)
	table.sort(t, function(a, b)
		local pro_a = DefenseSpellProrityBySpell[a.spellID]
		local pro_b = DefenseSpellProrityBySpell[b.spellID]
		if pro_a < pro_b then
			return true
		elseif pro_a == pro_b then
			return a.GUID < b.GUID
		end
	end)
end

local GroupSpellFrame = T.CreateSpellLineFrame("GroupSupportSpellFrame", L["团队单体减伤技能监控和分配"], 40, "BOTTOMLEFT", "BOTTOMLEFT", 30, 300)

function GroupSpellFrame:lineup()
	SortBySpellPrority(self.active_byindex)
	
	local anchor = C.DB["GeneralOption"]["group_spell_dir"]
	
	local relative_anchor = anchor == "LEFT" and "RIGHT" or "LEFT"
	local space = anchor == "LEFT" and 5 or -5
	local lastframe
	local count = 0
	for index, icon in pairs(self.active_byindex) do
		if icon:IsShown() then
			icon:ClearAllPoints()
			if not lastframe then
				icon:SetPoint("LEFT", self, "LEFT", 0, 0)
			else
				icon:SetPoint("LEFT", lastframe, "RIGHT", 5, 0)	
			end
			count = count + 1
			lastframe = icon
		end
	end
	
	count = max(count, 1)
	
	local size = C.DB["GeneralOption"]["group_spell_size"]
	self:SetHeight(size)
	self:SetWidth(size*count + abs(space)*(count-1))
end

local function CreateGroupSpellIcon(updater, parent, tag)
	local icon = T.CreateSpellIconBase(parent, tag)
	
	icon.target_text = T.createtext(icon, "OVERLAY", 12, "OUTLINE", "CENTER") -- 玩家名字
	icon.target_text:SetPoint("BOTTOMLEFT", icon, "TOPLEFT", -2, -2)
	icon.target_text:SetPoint("BOTTOMRIGHT", icon, "TOPRIGHT", 2, -2)
	icon.target_text:SetHeight(12)
	
	function icon:update_onedit(option)
		if option == "all" or option == "icon_size" then
			self:SetSize(C.DB["GeneralOption"]["group_spell_size"], C.DB["GeneralOption"]["group_spell_size"])
		end
	end
	
	function icon:update_charge()
		local used_charge = #self.targets
		local available_charge = self.charge - used_charge
		if used_charge == 0 then
			self.charge_text:SetText(self.charge)
		else
			self.charge_text:SetText(string.format("%d(%d)", self.charge, available_charge))
		end
		if available_charge == 0 then
			self.texture:SetDesaturated(true)
		else
			self.texture:SetDesaturated(false)
		end
	end
	
	function icon:update_target()
		local str = ""
		for index, GUID in pairs(self.targets) do
			if index > 1 then
				str = str.."\n"
			end
			str = str..T.ColorNickNameByGUID(GUID)
		end
		self.target_text:SetText(str)
	end
	
	function icon:update_range()
		local unit = T.GUIDToUnit(self.GUID)
		if unit then
			if InRangeOfUnit(unit) then
				self:SetAlpha(1)
			else
				self:SetAlpha(.5)
			end
		end
	end
	
	function icon:init_display(GUID, spellID, charge)
		self.GUID = GUID
		self.spellID = spellID
		self.charge = charge
		self.targets = table.wipe(self.targets)
		
		self.texture:SetTexture(C_Spell.GetSpellTexture(spellID))
		self.source_text:SetText(T.ColorNickNameByGUID(GUID))
		self:update_charge()
		self:update_target()
		self:update_range()
		
		self:update_onedit("all")
		self:Show()
	end
	
	function icon:cancel()
		self:Hide()
		self.texture:SetDesaturated(false)
	end
	
	icon.targets = {}
	
	updater.actives_bytag[tag] = icon
	
	return icon
end

local GroupSpell_Updater = T.CreateUpdater(CreateGroupSpellIcon, GroupSpellFrame)

GroupSpell_Updater.sort_cache = {}
GroupSpell_Updater.actives_byGUID = {}

function GroupSpell_Updater:GetGroupSpellIcon(filter)	
	self.sort_cache = table.wipe(self.sort_cache)
	
	for _, icon in pairs(self.actives_bytag) do
		table.insert(self.sort_cache, icon)
	end
	
	SortBySpellPrority(self.sort_cache)
	
	for _, icon in pairs(self.sort_cache) do
		local used_charge = #icon.targets
		local available_charge = icon.charge - used_charge
		if filter then -- 过滤自身技能
			if icon.GUID ~= G.PlayerGUID then
				if available_charge > 0 then
					local unit = T.GUIDToUnit(icon.GUID)
					if unit and InRangeOfUnit(unit) then
						return icon
					end
				end
			end
		else -- 不过滤自身技能
			if available_charge > 0 then
				local unit = T.GUIDToUnit(icon.GUID)
				if unit and InRangeOfUnit(unit) then
					return icon
				end
			end
		end
	end
end

function GroupSpell_Updater:DelayReleaseTarget(tag, GUID)
	C_Timer.After(5, function()
		local icon = self.actives_bytag[tag]
		if icon then
			if tContains(icon.targets, GUID) then
				tDeleteItem(icon.targets, GUID)
				icon:update_charge()
				icon:update_target()
			end
		end
	end)
end

function GroupSpell_Updater:SetIconAlphaByGUID(GUID, alpha)
	for spellID, icon in pairs(self.actives_byGUID[GUID]) do
		icon:SetAlpha(alpha)
	end
end

function GroupSpell_Updater:RemoveIconsByGUID(GUID)
	for spellID, icon in pairs(self.actives_byGUID[GUID]) do
		self:RemoveAlert(icon.tag)
	end
	self.actives_byGUID[GUID] = nil
end

function GroupSpell_Updater:UpdateStatus(receivedInfo)
    for _, entry in ipairs(receivedInfo) do       
        local spellID = entry.spellID
		local GUID = entry.GUID
		
        if DefenseSpellProrityBySpell[spellID] and GUID ~= G.PlayerGUID then
			local currentTime = GetTime()
			local expirationTime = entry.expirationTime
			local charge = 0
			
			if entry.charges > 0 then
				charge = entry.charges
			elseif expirationTime < currentTime then
				charge = 1
			end
			
			local tag = GUID.."-"..spellID
			
			if charge > 0 then
				if not self.actives_bytag[tag] then
					local icon = self:GetAlert(1, tag)
					icon:init_display(GUID, spellID, charge)
					
					if not self.actives_byGUID[GUID] then
						self.actives_byGUID[GUID] = {}
					end
					
					self.actives_byGUID[GUID][spellID] = icon
				else
					local icon = self.actives_bytag[tag]
					icon.charge = charge
					icon:update_charge()
				end
			else
				local icon = self.actives_bytag[tag]
				if icon then
					self:RemoveAlert(icon.tag)
					self.actives_byGUID[icon.GUID][icon.spellID] = nil
				end
			end
		end
    end
end

-- 唤魔师距离监控
GroupSpell_Updater.t = 0
GroupSpell_Updater:SetScript("OnUpdate", function(self, e)
	self.t = self.t + e
	if self.t > .5 then
		-- 自己是唤魔师
		if G.myClass == "EVOKER" then
			for GUID, icons in pairs(self.actives_byGUID) do
				local unit = T.GUIDToUnit(GUID)		
				if unit then
					if InRangeOfUnit(unit) then
						self:SetIconAlphaByGUID(GUID, 1)
					else
						self:SetIconAlphaByGUID(GUID, .5)
					end
				end
			end
		else
		-- 团队里的唤魔师
			for GUID, icons in pairs(self.actives_byGUID) do
				local unit = T.GUIDToUnit(GUID)
				if unit then
					local class = UnitClassBase(unit)
					if class == "EVOKER" then
						if InRangeOfUnit(unit) then
							self:SetIconAlphaByGUID(GUID, 1)
						else
							self:SetIconAlphaByGUID(GUID, .5)
						end
					end
				end
			end
		end
		self.t = 0
	end
end)

GroupSpell_Updater:SetScript("OnEvent", function(self, event, ...)	
	if event == "JST_GROUP_CD_UPDATE" then
		local receivedInfo = ...
        if not receivedInfo then return end
		
		self:UpdateStatus(receivedInfo)

	elseif event == "UNIT_IN_RANGE_UPDATE" then
		local unit, isInRange = ...
		if G.myClass ~= "EVOKER" and T.FilterGroupUnit(unit) then
			local GUID = UnitGUID(unit)
			if self.actives_byGUID[GUID] then
				local class = select(2, UnitClass(unit))
				if class ~= "EVOKER" then
					if isInRange then
						self:SetIconAlphaByGUID(GUID, 1)
					else
						self:SetIconAlphaByGUID(GUID, .5)
					end
				end
			end
		end
		
	elseif event == "GROUP_ROSTER_UPDATE" then
		for GUID, icons in pairs(self.actives_byGUID) do
			local unit = UnitTokenFromGUID(GUID)
			if not unit or not UnitInAnyGroup(unit) then
				self:RemoveIconsByGUID(GUID)
			end
		end
		
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		if sub_event == "SPELL_CAST_SUCCESS" and DefenseSpellProrityBySpell[spellID] then
			local tag = sourceGUID.."-"..spellID
			local icon = self.actives_bytag[tag]
			if icon then
				if tContains(icon.targets, destGUID) then
					tDeleteItem(icon.targets, destGUID)
					icon:update_charge()
					icon:update_target()
				end
			end
		end
	elseif event == "ADDON_MSG" then
		local channel, sender, GUID, message = ...
		if message == "ProtectMe" then
			local tag = select(5, ...)
			local icon = self.actives_bytag[tag]
			if icon then
				table.insert(icon.targets, GUID)
				icon:update_charge()
				icon:update_target()
				
				self:DelayReleaseTarget(tag, GUID)				
			end
		end
	end
end)

local group_cd_events = {	
	["JST_GROUP_CD_UPDATE"] = true,
	["UNIT_IN_RANGE_UPDATE"] = true,
	["GROUP_ROSTER_UPDATE"] = true,
	["COMBAT_LOG_EVENT_UNFILTERED"] = true,
	["ADDON_MSG"] = true,
}

local last_ask = 0
T.RequestGroupDefenseSpell = function(filter, spellStr)
	if spellStr then
		local spell_str = string.gsub(spellStr, "，", ",") -- 替换中文逗号
		local spell_names = {string.split(",", spell_str)}
		for _, spell_name in pairs(spell_names) do
			local spell_info = C_Spell.GetSpellInfo(spell_name)
			if spell_info then
				local spellID = spell_info.spellID
				if T.MySpellCheck(spellID) then
					if C.DB["GeneralOption"]["group_spell_msg"] then
						T.msg(string.format(L["技能可以用忽略技能请求"], T.GetIconLink(spellID)))
					end
					return
				end
			end
		end
	end
	
	local passed = GetTime() - last_ask
	if passed >= 5 then
		local icon = GroupSpell_Updater:GetGroupSpellIcon(filter)
		if icon then
			T.addon_msg("ProtectMe,"..icon.tag, "GROUP")
			
			local info = T.GetGroupInfobyGUID(icon.GUID)
			local target = Ambiguate(info.full_name, "none")			
			T.SendSpellRequest(target, info.format_name, icon.spellID)
			last_ask = GetTime()
		else		
			if C.DB["GeneralOption"]["group_spell_msg"] then
				T.msg(L["当前没有可用的单体减伤技能"])
			end
		end		
	else
		if C.DB["GeneralOption"]["group_spell_msg"] then
			T.msg(string.format(L["请稍后再请求单体减伤"], ceil(5 - passed)))
		end
	end
end

T.EditGroupSpellFrame = function(option)
	if option == "all" or option == "enable" then
		if C.DB["GeneralOption"]["group_spell_enable"] then
			T.RestoreDragFrame(GroupSpellFrame)
			T.RegisterEventAndCallbacks(GroupSpell_Updater, group_cd_events)	
			GroupSpellFrame:Show()
			T.GroupSpellForceUpdate()
		else
			T.ReleaseDragFrame(GroupSpellFrame)
			T.UnregisterEventAndCallbacks(GroupSpell_Updater, group_cd_events)
			GroupSpellFrame:Hide()
		end
	end
	if option == "all" or option == "icon_size" or option == "grow_dir" then
		GroupSpellFrame:lineup()
	end		
	for _, icon in pairs(GroupSpellFrame.active_byindex) do
		icon:update_onedit(option)
	end
end