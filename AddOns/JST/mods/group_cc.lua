local T, C, L, G = unpack(select(2, ...))
local addon_name = G.addon_name

----------------------------------------------------------
---------------------[[    Data    ]]---------------------
----------------------------------------------------------
local CCNpcs = {}
local CCSpells = {}
local RaidCCSpells = G.RaidCCSpells
local DungeonCCSpells = G.DungeonCCSpells

T.LoadMobData = function(ChallengeMapID)
	if not G.MobData[ChallengeMapID] then return end
	for npcID, args in pairs(G.MobData[ChallengeMapID]) do
		if args.cc then
			CCNpcs[npcID] = args.cc			
		else
			CCNpcs[npcID] = {
				["CC_Grip"] = true,
				["CC_Other"] = true,
				["CC_Stun"] = true,
				["CC_Silence"] = true,
				["CC_Disorient"] = true,
				["CC_Fear"] = true,
				["CC_KnockOff"] = true,
				["CC_KnockBack"] = true,
			}
		end
	end
	
	for npcID, args in pairs(G.MobData[ChallengeMapID]) do
		if args.spell then
			for event, spellIDs in pairs(args.spell) do
				if not CCSpells[event] then
					CCSpells[event] = {}
				end
				
				for _, spellID in pairs(spellIDs) do
					CCSpells[event][spellID] = true
				end
			end
		end
	end
end
----------------------------------------------------------
---------------------[[    API    ]]----------------------
----------------------------------------------------------

local function IsInDungeon()
	local instanceType = select(2, GetInstanceInfo())
	return instanceType == "party"
end

local function GetLineInfo(line, show_error)
	local GUIDs = T.LineToGUIDArray(line)
    local GUID = GUIDs[1]
	
	local matched_spellID, use_spellID
	for word in line:gmatch("%S+") do
		if tonumber(word) then
			local spellID = tonumber(word)
			if C_Spell.GetSpellName(spellID) then
				matched_spellID = spellID
				break
			end
			use_spellID = true
		elseif G.GroupTrackedSpellsbyName[word] then
			local spellID = G.GroupTrackedSpellsbyName[word]
			matched_spellID = spellID
			break
		end
	end
	
	if show_error and not GUID and not string.find(line, L["可以继续写"]) then
        T.msg(string.format("%s %s", L["名字错误"], line))
    end
	
    if show_error and not matched_spellID and not string.find(line, L["可以继续写"]) then
		if not use_spellID then
			T.msg(string.format("%s %s", L["请使用法术ID"], line))
		else
			T.msg(string.format("%s %s", L["法术ID错误"], line))
		end
    end
	
	if GUID and matched_spellID then
		return GUID, matched_spellID
	end
end

----------------------------------------------------------
-----------------[[    控制链框架    ]]-------------------
----------------------------------------------------------

local ControlSpellFrame = T.CreateSpellLineFrame("GroupSpellFrame", L["队伍控制链监控"], 40, "CENTER", "CENTER", 0, 360)
ControlSpellFrame.actives_bytag = {}

function ControlSpellFrame:lineup()
	local lastframe
	for _, icon in pairs(self.active_byindex) do
		if icon:IsShown() then
			icon:ClearAllPoints()
			if not lastframe then
				icon:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			else
				icon:SetPoint("TOPLEFT", lastframe, "TOPRIGHT", 5, 0)	
			end
			lastframe = icon
		end
	end
end

function ControlSpellFrame:CreatePreviewCCIcon(tag, i)
	local icon = T.CreateSpellIconBase(ControlSpellFrame, tag)
	T.SetHighLightBorderColor(icon, icon, {0, 1, 0}, 3)
	
	local spellID = RaidCCSpells[i]
	icon.texture:SetTexture(C_Spell.GetSpellTexture(spellID))
	icon.source_text:SetText(T.ColorNickNameByGUID(G.PlayerGUID))
	
	function icon:update_onedit(option)
		if option == "all" or option == "icon_size" then
			self:SetSize(C.DB["GeneralOption"]["control_spell_size"], C.DB["GeneralOption"]["control_spell_size"])
		end
	end
	
	self.actives_bytag[tag] = icon
	
	return icon
end

function ControlSpellFrame:PreviewShow()
	local cur_num = 0
	for tag in pairs(self.actives_bytag) do
		if not string.find(tag, "preview") then
			cur_num = cur_num + 1
		end
	end
	local lack_num = max(0, 6 - cur_num)

	if lack_num > 0 then
		local my_index = math.random(lack_num)
		for i = 1, lack_num do
			local tag = "preview"..i
			local icon = self.actives_bytag[tag] or self:CreatePreviewCCIcon(tag, i)
			
			if i == my_index then
				icon.innerBD:Show()
			else
				icon.innerBD:Hide()
			end
			
			icon:update_onedit("all")
			
			icon:Show()
		end
	end
	
	self:Show()
end

function ControlSpellFrame:PreviewHide()
	for i = 1, 6 do
		local tag = "preview"..i
		local icon = self.actives_bytag[tag]
		
		if icon then
			icon:Hide()
		end
	end	
	self:Hide()
end

local function CreateControlSpellIcon(updater, parent, tag)	
	local icon = T.CreateSpellIconBase(parent, tag)
	
	T.SetHighLightBorderColor(icon, icon, {0, 1, 0}, 3)
	
	function icon:update_onedit(option)
		if option == "all" or option == "icon_size" then
			self:SetSize(C.DB["GeneralOption"]["control_spell_size"], C.DB["GeneralOption"]["control_spell_size"])
		end
	end
	
	function icon:display_charge(charge)
		if charge and charge > 1 then
			self.charge_text:SetText(charge)
		else
			self.charge_text:SetText("")
		end
	end
	
	function icon:display_cd(expirationTime, dur)
		self.expirationTime = expirationTime
		
		if expirationTime - GetTime() > 0 then
			local start = expirationTime - dur
			self.cooldown:SetCooldown(start, dur)
			self.texture:SetDesaturated(true)
			self.innerBD:SetBackdropBorderColor(.7, .7, .7)
			self:SetAlpha(.5)
		else
			self.cooldown:SetCooldown(0, 0)
			self.texture:SetDesaturated(false)
			self.texture:SetDesaturated(false)
			self.innerBD:SetBackdropBorderColor(0, 1, 0)
			self:SetAlpha(1)
		end
	end
	
	function icon:init_display(index, GUID, spellID)
		self.GUID = GUID
		self.spellID = spellID
		self.index = index
		
		self.texture:SetTexture(C_Spell.GetSpellTexture(spellID))
		self.source_text:SetText(T.ColorNickNameByGUID(GUID))
		
		if self.GUID == G.PlayerGUID then
			self.innerBD:Show()
		else
			self.innerBD:Hide()
		end
		
		self:update_onedit("all")		
		self:Show()
	end
	
	function icon:cancel()
		self:Hide()
	end
	
	updater.actives_bytag[tag] = icon
	
	return icon
end

----------------------------------------------------------
-----------------[[    团本控制链    ]]-------------------
----------------------------------------------------------
local ControlSpell_Updater = T.CreateUpdater(CreateControlSpellIcon, ControlSpellFrame)

ControlSpell_Updater.active_byGUID = {}
ControlSpell_Updater.order = {}
ControlSpell_Updater.cooldownInfo = {} -- [GUID][spellID] = {expirationTime = <number>, duration = <number>, charges = <number>}
ControlSpell_Updater.finishedCasts = {}
ControlSpell_Updater.ttsPlayed = {}
ControlSpell_Updater.set = 0

function ControlSpell_Updater:ReadNote(tag, analyze, title, sub_titles)
	self.cooldownInfo = table.wipe(self.cooldownInfo)
	self.finishedCasts = table.wipe(self.finishedCasts)
	self.ttsPlayed = table.wipe(self.ttsPlayed)
    self.order = table.wipe(self.order)
	self.set = 0
	
    local setNumber = 1
	local indexNumber = 0
	local title_displayed
	local spellCount = T.GetCCSpellCount()
	
	local ccTag = "CC"..(tag or "")
    for _, line in T.IterateNoteAssignment(ccTag) do
	
		if analyze and not title_displayed then
			T.msg(string.format(L["开始读取%s控制链信息"], title))
			title_displayed = true
		end
		
        line = line:gsub("||c%x%x%x%x%x%x%x%x", "")
        line = line:gsub("||r", "")
        
        local set = line:lower():match("^set(%d+)")
        
        set = tonumber(set)
        
        if set then
            setNumber = set
			indexNumber = 0
			
            if analyze then
				if sub_titles and sub_titles[set] then
					T.divideline(string.format("%d%s", set, sub_titles[set]))
				else
					T.divideline(set)
				end
            end
        else
			line = gsub(line, "{spell:(%d+)}", " %1 ")
			
            local GUID, spellID = GetLineInfo(line, true)
            
            if GUID and spellID then
                if not G.GroupTrackedSpellsbySpellID[spellID] then
					spellCount = spellCount + 1
					G.GroupTrackedSpellsbySpellID[spellID] = {
						index = spellCount,
						spell_type = "CC_Other",
					}
				end
				
				if not self.order[setNumber] then
					self.order[setNumber] = {}
				end
				
				if not self.finishedCasts[setNumber] then
					self.finishedCasts[setNumber] = {}
				end
				
				if not self.ttsPlayed[setNumber] then
					self.ttsPlayed[setNumber] = {}
				end
				
                indexNumber = indexNumber + 1
               
                if analyze then
					T.msg(string.format("[%d-%d] %s %s", setNumber, indexNumber, T.ColorNickNameByGUID(GUID), T.GetIconLink(spellID)))
                end
                
                if not self.cooldownInfo[GUID] then
					self.cooldownInfo[GUID] = {}
				end
				
                if not self.cooldownInfo[GUID][spellID] then
					self.cooldownInfo[GUID][spellID] = {}
				end
                
                table.insert(self.order[setNumber],
                    {
                        GUID = GUID,
                        spellID = spellID,
                        icon = C_Spell.GetSpellTexture(spellID),
                    }
                )
            end
        end
    end
end

function ControlSpell_Updater:UpdateExpirationTimes(receivedInfo)
    for _, entry in ipairs(receivedInfo) do
        local GUID = entry.GUID
        local spellID = entry.spellID
        local cooldownInfo = self.cooldownInfo[GUID] and self.cooldownInfo[GUID][spellID]
		
        if cooldownInfo then
            cooldownInfo.duration = entry.duration or 0
            cooldownInfo.expirationTime = entry.expirationTime or 0
			cooldownInfo.charges = entry.charges or 0
        end
    end
end

function ControlSpell_Updater:NotifyNext()
    local currentTime = GetTime()
    local order = self.order[self.set]
    
    if not order then return end
    
    for _, entry in ipairs(order) do
        local GUID = entry.GUID
        local spellID = entry.spellID
        local expirationTime = self.cooldownInfo[GUID][spellID].expirationTime
        local isReady = expirationTime and expirationTime < currentTime
        
        if isReady then
			T.FireEvent("JST_GROUP_CC_NEXT", GUID, spellID, self.set)
            return
        end
    end
end

function ControlSpell_Updater:BuildStates()
	local alwaysShow = C.DB["GeneralOption"]["control_always_show"]
    local order = self.order[self.set]
    
    for _, icon in pairs(self.actives_bytag) do
		self:RemoveAlert(icon.tag)
    end
    
    if not order then return end
	
    -- Check if we are included in the order
    if not alwaysShow then
        local included = false
        
        for _, entry in ipairs(order) do
            if entry.GUID == G.PlayerGUID then
                included = true
            end
        end
        
        if not included then return end
    end
    
    local currentTime = GetTime()
	
    for index, entry in ipairs(order) do
        local GUID = entry.GUID
		
        local spellID = entry.spellID
        local cooldownInfo = self.cooldownInfo[GUID] and self.cooldownInfo[GUID][spellID]
        local duration = cooldownInfo and cooldownInfo.duration
        local expirationTime = cooldownInfo and cooldownInfo.expirationTime
		local charges = cooldownInfo and cooldownInfo.charges
        local isReady = expirationTime and expirationTime < currentTime + 15
        
        if isReady then
           local tag = GUID.."-"..spellID
		   
		   if not self.actives_bytag[tag] then
				local icon = self:GetAlert(1, tag)
				icon:init_display(index, GUID, spellID)
				
				if not self.active_byGUID[GUID] then
					self.active_byGUID[GUID] = {}
				end
				
				self.active_byGUID[GUID][spellID] = icon
			end
			
			local icon = self.actives_bytag[tag]
			
			icon:display_charge(charge)
			icon:display_cd(expirationTime, duration)
			icon:Show()
        end
    end
end

ControlSpell_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "JST_GROUP_CD_UPDATE" then
		local receivedInfo = ...
        if not receivedInfo then return end
		
		self:UpdateExpirationTimes(receivedInfo)
		
		if ControlSpellFrame:IsShown() then
			self:BuildStates()
			self:NotifyNext()
		end
		
	elseif event == "JST_GROUP_CC_NEXT" then
		local GUID, spellID, set = ...
		
		if GUID == G.PlayerGUID then
			if not self.finishedCasts[set][spellID] then
				ControlSpellFrame.text_frame.text:SetText(T.GetSpellIcon(spellID)..L["准备"])
				ControlSpellFrame.text_frame:Show()
				self.cur_spellID = spellID
			end
			
			if not self.ttsPlayed[self.set][spellID] then
				self.ttsPlayed[self.set][spellID] = true
				if C.DB["GeneralOption"]["control_tts"] then
					T.PlaySound("prepare")
					C_Timer.After(.5, function()
						T.SpeakText(C_Spell.GetSpellName(spellID))
					end)
				end
			end
		else
			ControlSpellFrame.text_frame:Hide()
			self.cur_spellID = nil
		end
	
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellID = ...
        
        if unit ~= "player" or not castGUID then return end
		
        if self.set > 0 and self.cur_spellID == spellID and not self.finishedCasts[self.set][spellID] then
			self.finishedCasts[self.set][spellID] = true
			ControlSpellFrame.text_frame:Hide()
			self.cur_spellID = nil
		end
	end
end)

----------------------------------------------------------
----------------[[    团本控制链  API  ]]-----------------
----------------------------------------------------------
T.GenerateGroupCCNote = function(tag, title, set, continued, sub_titles)	
	local str, full_set_str, short_set_str = "", "", ""
	
	for index, spellID in pairs(RaidCCSpells) do
		local spellName = C_Spell.GetSpellName(spellID)
		local spell = string.format("%s {spell:%d}%s", G.PlayerName, spellID, spellName)
		
		full_set_str = full_set_str..spell.."\n"
		
		if index <= 3 then
			short_set_str = short_set_str..spell.."\n"
		end
	end
	
	for i = 1, set do
		local sub_title = "set"..i
		
		if sub_titles and sub_titles[i] then
			sub_title = sub_title..sub_titles[i]
		end
		
		if i == 1 then
			str = str..sub_title.."\n"..full_set_str.."\n"
		else
			str = str..sub_title.."\n"..short_set_str.."\n"
		end
	end
	
	if continued then
		str = str..L["可以继续写"]
	end

	str = string.format("#CC%sstart%s\n%s\nend", tag, title, str)
	
	return str
end

T.ReadGroupCCNote = function(tag, analyze, title, sub_titles)
	ControlSpell_Updater:ReadNote(tag, analyze, title, sub_titles)
end

T.DisplayGroupCCFrame = function(set)
	if not C.DB["GeneralOption"]["control_spell_enable"] then return end
	if ControlSpell_Updater.order[set] then
		ControlSpell_Updater.set = set
		ControlSpell_Updater.finishedCasts[set] = table.wipe(ControlSpell_Updater.finishedCasts[set])
		ControlSpell_Updater.ttsPlayed[set] = table.wipe(ControlSpell_Updater.ttsPlayed[set])
		
        ControlSpell_Updater:BuildStates()
		ControlSpell_Updater:NotifyNext()
		ControlSpellFrame:Show()
    end
end

T.HideGroupCCFrame = function(set)
	ControlSpellFrame:Hide()
	if ControlSpellFrame.text_frame then
		ControlSpellFrame.text_frame:Hide()
	end
end

----------------------------------------------------------
------------------[[    大秘境控制链 ]]-------------------
----------------------------------------------------------
local DungeonCC_Updater = T.CreateUpdater(CreateControlSpellIcon, ControlSpellFrame)

DungeonCC_Updater.active_byGUID = {}
DungeonCC_Updater.order = {}
DungeonCC_Updater.cooldownInfo = {} -- [GUID][spellID] = {expirationTime = <number>, duration = <number>, charges = <number>}

function DungeonCC_Updater:GenerateGroupSpells()
	self.cooldownInfo = table.wipe(self.cooldownInfo)	
	self.order = table.wipe(self.order)	
	
	local indexNumber = 0
		
	for i, spellID in ipairs(DungeonCCSpells) do
		if T.ValueFromDB({"GeneralOption", "control_spells", spellID}) then
			for unit in T.IterateGroupMembers(false, true) do
				
				local GUID = UnitGUID(unit)
				
				local _, exp_time, duration, _, _, charges = T.GetGroupCooldown(GUID, spellID)
				
				if exp_time and duration then
					indexNumber = indexNumber + 1
					
					if not self.cooldownInfo[GUID] then
						self.cooldownInfo[GUID] = {}
					end
					
					if not self.cooldownInfo[GUID][spellID] then
						self.cooldownInfo[GUID][spellID] = {}
						self.cooldownInfo[GUID][spellID].expirationTime = exp_time
						self.cooldownInfo[GUID][spellID].duration = duration
						self.cooldownInfo[GUID][spellID].charges = charges
					end
					
					local ccType = G.GroupTrackedSpellsbySpellID[spellID].spell_type
					
					table.insert(self.order,
						{
							GUID = GUID,
							spellID = spellID,
							icon = C_Spell.GetSpellTexture(spellID),
							index = indexNumber,
							ccType = ccType,
						}
					)
				end
			end
		end
	end
end

function DungeonCC_Updater:UpdateExpirationTimes(receivedInfo)
    for _, entry in ipairs(receivedInfo) do
        local GUID = entry.GUID
        local spellID = entry.spellID
        local cooldownInfo = self.cooldownInfo[GUID] and self.cooldownInfo[GUID][spellID]
		
        if cooldownInfo then
            cooldownInfo.duration = entry.duration or 0
            cooldownInfo.expirationTime = entry.expirationTime or 0
			cooldownInfo.charges = entry.charges or 0
        end
    end
end

function DungeonCC_Updater:NotifyNext(GUID)
    local npcID = select(6, string.split("-", GUID))
	if CCNpcs[npcID] then
		local currentTime = GetTime()
		
		if not next(self.order) then return end
		
		for _, entry in ipairs(self.order) do
			local GUID = entry.GUID
			local spellID = entry.spellID
			local ccType = entry.ccType
			local expirationTime = self.cooldownInfo[GUID][spellID].expirationTime
			local isReady = expirationTime and expirationTime < currentTime
			local isControllable = CCNpcs[npcID][ccType]
			
			if isReady and isControllable then
				T.FireEvent("JST_DUNGEON_CC_NEXT", GUID, spellID)
				return
			end
		end
	else
		--T.msg(npcID, "群控数据缺失")
	end
end

function DungeonCC_Updater:BuildStates()
	local alwaysShow = C.DB["GeneralOption"]["control_always_show"]
  
    for _, icon in pairs(self.actives_bytag) do
		self:RemoveAlert(icon.tag)
    end
    
    -- Check if we are included in the order
    if not alwaysShow then
        local included = false
        
        for _, entry in ipairs(self.order) do
            if entry.GUID == G.PlayerGUID then
                included = true
            end
        end
        
        if not included then return end
    end
	
    local currentTime = GetTime()
	
	table.sort(self.order, function(a, b)	
		local AcooldownInfo = self.cooldownInfo[a.GUID] and self.cooldownInfo[a.GUID][a.spellID]
		local BcooldownInfo = self.cooldownInfo[b.GUID] and self.cooldownInfo[b.GUID][b.spellID]
		
		local AexpirationTime = AcooldownInfo and AcooldownInfo.expirationTime
		local BexpirationTime = BcooldownInfo and BcooldownInfo.expirationTime
		
		local Aready = AexpirationTime and AexpirationTime - currentTime <= 0
		local Bready = BexpirationTime and BexpirationTime - currentTime <= 0
		
		if Aready and Bready and a.index ~= b.index then
			return a.index < b.index
		elseif AexpirationTime and BexpirationTime and AexpirationTime ~= BexpirationTime then
			return AexpirationTime < BexpirationTime
		elseif AexpirationTime and not BexpirationTime then
			return true
		elseif a.index ~= b.index then
			return a.index < b.index
		else
			return a.GUID < b.GUID
		end
	end)
	
    for index, entry in ipairs(self.order) do
        local GUID = entry.GUID
        local spellID = entry.spellID
        local cooldownInfo = self.cooldownInfo[GUID] and self.cooldownInfo[GUID][spellID]
        local duration = cooldownInfo and cooldownInfo.duration
        local expirationTime = cooldownInfo and cooldownInfo.expirationTime
		local charges = cooldownInfo and cooldownInfo.charges
		
		if expirationTime and duration then
			local tag = GUID.."-"..spellID
			
			if not self.actives_bytag[tag] then
				local icon = self:GetAlert(1, tag)
				icon:init_display(index, GUID, spellID)
				
				if not self.active_byGUID[GUID] then
					self.active_byGUID[GUID] = {}
				end
				
				self.active_byGUID[GUID][spellID] = icon
			end
			
			local icon = self.actives_bytag[tag]
			
			icon:display_charge(charge)
			icon:display_cd(expirationTime, duration)
			icon:Show()
		end
    end
end

function DungeonCC_Updater:Toggle()
	local show
	if C.DB["GeneralOption"]["control_spell_enable"] and IsInDungeon() then
		if IsEncounterInProgress() then -- BOSS
			if C.DB["GeneralOption"]["control_bossfighthide"] then
				show = false
			else
				show = true
			end
		elseif UnitAffectingCombat("player") then -- 杂兵战斗
			show = true
		else
			if C.DB["GeneralOption"]["control_oochide"] then -- 脱战
				show = false
			else
				show = true
			end
		end
	else
		show = false
	end
	
	if show then 
		ControlSpellFrame:Show()
	else
		ControlSpellFrame:Hide()
		if ControlSpellFrame.text_frame then
			ControlSpellFrame.text_frame:Hide()
			DungeonCC_Updater.cur_spellID = nil
		end
	end
end

DungeonCC_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "JST_GROUP_CD_UPDATE" then
		local receivedInfo = ...
        if not IsInDungeon() or not receivedInfo then return end
		
		self:UpdateExpirationTimes(receivedInfo)
		
		if ControlSpellFrame:IsShown() then
			self:BuildStates()
		end
		
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
		
		if IsInDungeon() and CCSpells[sub_event] and CCSpells[sub_event][spellID] and C.DB["GeneralOption"]["control_assign"] and ControlSpellFrame:IsShown() then
			self:NotifyNext(sourceGUID)
		end

	elseif event == "JST_DUNGEON_CC_NEXT" then
		local GUID, spellID = ...
		if not IsInDungeon() then return end
		 
		if GUID == G.PlayerGUID then
			if not self.cur_spellID then			
				local icon = T.GetSpellIcon(spellID)
				local name = C_Spell.GetSpellName(spellID)
				
				ControlSpellFrame.text_frame.text:SetText(icon..name)
				ControlSpellFrame.text_frame:Show()
				self.cur_spellID = spellID
				
				if C.DB["GeneralOption"]["control_tts"] then
					T.SpeakText(C_Spell.GetSpellName(spellID))
				end
			end
		else
			ControlSpellFrame.text_frame:Hide()
			self.cur_spellID = nil
		end
	
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellID = ...
        if not IsInDungeon() or unit ~= "player" or not castGUID then return end
		
        if self.cur_spellID == spellID then
			ControlSpellFrame.text_frame:Hide()
			self.cur_spellID = nil
		end
		
	elseif event == "PLAYER_DEAD" then
		if not IsInDungeon() then return end
		
		ControlSpellFrame.text_frame:Hide()
		self.cur_spellID = nil

	elseif event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
		C_Timer.After(.5, function()
			self:Toggle()
		end)
		
	elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
		self:Toggle()
		
	elseif event == "JST_CooldownListUpdate" then
		if not C.DB["GeneralOption"]["control_spell_enable"] then return end
		
		if IsInDungeon() then
			self:GenerateGroupSpells()
			self:BuildStates()
		end	
	end
end)

T.RegisterEventAndCallbacks(DungeonCC_Updater, {
	["ENCOUNTER_START"] = true,
	["ENCOUNTER_END"] = true,
	["PLAYER_REGEN_DISABLED"] = true,
	["PLAYER_REGEN_ENABLED"] = true,
	["PLAYER_ENTERING_WORLD"] = true,
	["JST_CooldownListUpdate"] = true,
})

----------------------------------------------------------
------------------[[    设置修改    ]]--------------------
----------------------------------------------------------
T.UpdateCCFrameSpells = function()
	if IsInDungeon() then
		DungeonCC_Updater:GenerateGroupSpells()
		DungeonCC_Updater:BuildStates()
	end
end

T.EditGroupCCFrame = function(option)
	local cc_events = {	
		["JST_GROUP_CD_UPDATE"] = true,
		["JST_GROUP_CC_NEXT"] = true,
		["UNIT_SPELLCAST_SUCCEEDED"] = true,
	}
	
	local dungeon_cc_events = {	
		["JST_GROUP_CD_UPDATE"] = true,
		["JST_DUNGEON_CC_NEXT"] = true,
		["UNIT_SPELLCAST_SUCCEEDED"] = true,
		["COMBAT_LOG_EVENT_UNFILTERED"] = true,
	}
	
	if option == "all" or option == "enable" then
		if C.DB["GeneralOption"]["control_spell_enable"] then
			T.RestoreDragFrame(ControlSpellFrame)
			T.RegisterEventAndCallbacks(ControlSpell_Updater, cc_events)
			T.RegisterEventAndCallbacks(DungeonCC_Updater, dungeon_cc_events)
			T.UpdateCCFrameSpells()
		else
			T.ReleaseDragFrame(ControlSpellFrame)
			T.UnregisterEventAndCallbacks(ControlSpell_Updater, cc_events)
			T.UnregisterEventAndCallbacks(DungeonCC_Updater, dungeon_cc_events)
			
			ControlSpellFrame:Hide()
		end
	end
	
	if option == "all" or option == "icon_size" then
		ControlSpellFrame:SetSize(C.DB["GeneralOption"]["control_spell_size"]*6+25, C.DB["GeneralOption"]["control_spell_size"])
	end
	
	if option == "all" or option == "visible" then
		DungeonCC_Updater:Toggle()
	end
	
	for _, icon in pairs(ControlSpellFrame.active_byindex) do
		icon:update_onedit(option)
	end
	
	if not ControlSpellFrame.text_frame then
		ControlSpellFrame.text_frame = T.CreateAlertTextShared("CCSpell", 2)
		ControlSpellFrame.text_frame.text:SetTextColor(0, 1, 0)
	end
end