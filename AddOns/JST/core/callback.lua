local T, C, L, G = unpack(select(2, ...))

----------------------------------------------------------
---------------[[        Callbacks        ]]--------------
----------------------------------------------------------

do
	local callbacks = {}

	function fireEvent(event, ...)
		if not callbacks[event] then return end
		for _, v in ipairs(callbacks[event]) do
		    securecall(v, event, ...)
		end
	end

	T.FireEvent = function(event, ...)
		fireEvent(event, ...)
	end

	T.IsCallbackRegistered = function (event, f)
		if not event or type(f) ~= "function" then
			error("Usage: IsCallbackRegistered(event, callbackFunc)", 2)
		end
		if not callbacks[event] then return end
		for i = 1, #callbacks[event] do
			if callbacks[event][i] == f then return true end
		end
		return false
	end

	T.RegisterCallback = function(event, f)
		if not event or type(f) ~= "function" then
			error("Usage: T.RegisterCallback(event, callbackFunc)", 2)
		end
		callbacks[event] = callbacks[event] or {}
		tinsert(callbacks[event], f)
		return #callbacks[event]
	end

	T.UnregisterCallback = function(event, f)
		if not event or not callbacks[event] then return end
		if f then
			if type(f) ~= "function" then
				error("Usage: T.UnregisterCallback(event, callbackFunc)", 2)
			end
			--> checking from the end to start and not stoping after found one result in case of a func being twice registered.
			for i = #callbacks[event], 1, -1 do
				if callbacks[event][i] == f then
					tremove(callbacks[event], i)
				end
			end
		else
			error("Usage: T.UnregisterCallback(event, callbackFunc)", 2)
		end
	end
end

----------------------------------------------------------
----------------------[[    API    ]]---------------------
----------------------------------------------------------

local CallbackEvents = {
	["TIMELINE_START"] = true,
	["TIMELINE_STOP"] = true,
	["TIMELINE_PASSED"] = true,
	["ENCOUNTER_PHASE"] = true,
	["ADDON_MSG"] = true,
	["JST_CUSTOM"] = true,
	["JST_SPELL_ASSIGN"] = true,
	["DATA_ADDED"] = true,
	["DATA_REMOVED"] = true,
	["DB_UPDATE"] = true,
	["UNIT_ENTERING_COMBAT"] = true,
	["GROUP_LEAVING_COMBAT"] = true,
	["UNIT_AURA_ADD"] = true,
	["UNIT_AURA_UPDATE"] = true,
	["UNIT_AURA_REMOVED"] = true,
	["ENCOUNTER_ENGAGE_UNIT"] = true,
	["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
	["ENCOUNTER_HIDE_BOSS_UNIT"] = true,
	["UNIT_RAID_BOSS_WHISPER"] = true,
	["JST_UNIT_ALIVE"] = true,
	["JST_UNIT_DEAD"] = true,
	["JST_MACRO_PRESSED"] = true,
	["JST_PRIVATE_AURA_EVENT"] = true,
	["JST_PRIVATE_AURA_CANCEL_EVENT"] = true,
	["JST_DISPEL_EVENT"] = true,
	["JST_CooldownListUpdate"] = true,
	["JST_CooldownListWipe"] = true,
	["JST_CooldownUpdate"] = true,
	["JST_CooldownAdded"] = true,
	["JST_CooldownRemoved"] = true,
	["JST_GROUP_CD_UPDATE"] = true,
	["JST_GROUP_CC_NEXT"] = true,
	["JST_DUNGEON_CC_NEXT"] = true,
	["UNIT_SPELLCAST_TARGET"] = true,
	["MRT_NOTE_EDIT"] = true,
}

T.RegisterEventAndCallbacks = function(frame, events, update)
	if events then
		for event, units in pairs(events) do
			if CallbackEvents[event] then
				if not frame.CallbackRegisted then
					frame.CallbackRegisted = {}
				end
				if not frame.CallbackRegisted[event] then
					frame.CallbackRegisted[event] = function(...)
						frame:GetScript("OnEvent")(frame, ...)
					end
					T.RegisterCallback(event, frame.CallbackRegisted[event])
				end
			else
				if type(units) == "table" then
					frame:RegisterUnitEvent(event, unpack(units))
				else
					frame:RegisterEvent(event)
				end
			end
		end
	end
end

T.UnregisterEventAndCallbacks = function(frame, events)
	if events then
		for event in pairs(events) do
			if CallbackEvents[event] then
				if frame.CallbackRegisted and frame.CallbackRegisted[event] then
					T.UnregisterCallback(event, frame.CallbackRegisted[event])
					frame.CallbackRegisted[event] = nil
				end
			else
				frame:UnregisterEvent(event)
			end
		end
	end
end

----------------------------------------------------------
------------------[[     自定义事件    ]]-----------------
----------------------------------------------------------

local eventframe = CreateFrame("Frame", nil, UIParent)

eventframe.engaged = {}
eventframe.active = {}

eventframe:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if prefix == "jstpaopao" then
			local GUID, MSG_TYPE, msg = string.split(",", message)
			
			if MSG_TYPE == "boss_whisper" then
				local unit = T.GUIDToUnit(GUID)
				T.FireEvent("UNIT_RAID_BOSS_WHISPER", unit, GUID, msg)
				
			elseif MSG_TYPE == "unit_alive" then
				local unit = T.GUIDToUnit(GUID)
				T.FireEvent("JST_UNIT_ALIVE", unit, GUID)
				
			elseif MSG_TYPE == "target_me" then
				local unit = T.GUIDToUnit(GUID)
				T.FireEvent("JST_PRIVATE_AURA_EVENT", unit, GUID)
				
			elseif MSG_TYPE and string.match(MSG_TYPE, "target_me(%d+)") then
				local index = string.match(MSG_TYPE, "target_me(%d+)")
				local unit = T.GUIDToUnit(GUID)
				T.FireEvent("JST_PRIVATE_AURA_EVENT", unit, GUID, tonumber(index))
				
			elseif MSG_TYPE == "remove_me" then
				local unit = T.GUIDToUnit(GUID)
				T.FireEvent("JST_PRIVATE_AURA_CANCEL_EVENT", unit, GUID)
				
			elseif MSG_TYPE and string.match(MSG_TYPE, "remove_me(%d+)") then
				local index = string.match(MSG_TYPE, "remove_me(%d+)")
				local unit = T.GUIDToUnit(GUID)
				T.FireEvent("JST_PRIVATE_AURA_CANCEL_EVENT", unit, GUID, tonumber(index))
				
			elseif MSG_TYPE == "dispel_event" then
				local spellID = tonumber(msg)
				local unit = T.GUIDToUnit(GUID)
				T.FireEvent("JST_DISPEL_EVENT", unit, GUID, spellID)
				
			elseif message then
				T.FireEvent("ADDON_MSG", channel, sender, string.split(",", message))
			end
			
		end
	elseif event == "CHAT_MSG_RAID_BOSS_WHISPER" then
		local msg = ...
		T.addon_msg("boss_whisper,"..msg, "GROUP")
		
	elseif event == "PLAYER_ALIVE" then
		T.addon_msg("unit_alive", "GROUP")
		
	elseif event == "ENCOUNTER_START" then
		self.engaged = table.wipe(self.engaged)
		self.active = table.wipe(self.active)
		
	elseif event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
		C_Timer.After(.5, function()
			for GUID in pairs(self.active) do
				local unit = UnitTokenFromGUID(GUID)
				if not unit then
					self.active[GUID] = nil
					T.FireEvent("ENCOUNTER_HIDE_BOSS_UNIT", GUID)
				end
			end
			for unit in T.IterateBoss() do
				local GUID = UnitGUID(unit)
				if not self.engaged[GUID] then
					self.engaged[GUID] = true
					T.FireEvent("ENCOUNTER_ENGAGE_UNIT", unit, GUID)
				end
				if not self.active[GUID] then
					self.active[GUID] = true
					T.FireEvent("ENCOUNTER_SHOW_BOSS_UNIT", unit, GUID)
				end
			end
		end)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, sourceGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
		if sub_event == "UNIT_DIED" then
			local unit = T.GUIDToUnit(destGUID)
			if unit then
				T.FireEvent("JST_UNIT_DEAD", unit, destGUID)
			end
		end
	end
end)

eventframe:RegisterEvent("CHAT_MSG_ADDON")
eventframe:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER")
eventframe:RegisterEvent("PLAYER_ALIVE")
eventframe:RegisterEvent("ENCOUNTER_START")
eventframe:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
eventframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

----------------------------------------------------------
-----------------[[    队伍技能事件    ]]-----------------
----------------------------------------------------------
local LibOpenRaid = LibStub:GetLibrary("LibOpenRaid-1.0", true)

--[[
	local unitData = openRaidLib.GetAllUnitsCooldown()
	return a table with unit names as key and a table with unit cooldowns as the value
	table format: [playerName] = {[spellId] = cooldownInfo}

	local unitCooldowns = openRaidLib.GetUnitCooldowns(unit[, filter])
	return a table with all the unit cooldowns
	table format: [spellId] = cooldownInfo

	local cooldownInfo = openRaidLib.GetUnitCooldownInfo(unit, spellId)
	return a table containing values about the cooldown time
	values returned: {timeLeft, charges, timeOffset, duration, updateTime, auraDuration}
]]

local callbacks = {
    CooldownListUpdate = function(...)
		T.FireEvent("JST_CooldownListUpdate", ...)
		-- unit, unitCooldowns, unitData = ...
	end,
    CooldownListWipe = function(...) 
		T.FireEvent("JST_CooldownListWipe", ...)
		-- unitData = ...
	end,
    CooldownUpdate = function(...)
		T.FireEvent("JST_CooldownUpdate", ...)
		-- unit, spellID, cooldownInfo, unitCooldownTable, unitData = ...
	end,
    CooldownAdded = function(...)
		T.FireEvent("JST_CooldownAdded", ...)
		-- unit, spellID, cooldownInfo, unitCooldownTable, unitData = ...
	end,
	CooldownRemoved = function(...)
		T.FireEvent("JST_CooldownRemoved", ...)
		-- unit, spellID, unitCooldownTable, unitData = ...
	end,
}

LibOpenRaid.RegisterCallback(callbacks, "CooldownListUpdate", "CooldownListUpdate")
LibOpenRaid.RegisterCallback(callbacks, "CooldownListWipe", "CooldownListWipe")
LibOpenRaid.RegisterCallback(callbacks, "CooldownUpdate", "CooldownUpdate")
LibOpenRaid.RegisterCallback(callbacks, "CooldownAdded", "CooldownAdded")
LibOpenRaid.RegisterCallback(callbacks, "CooldownRemoved", "CooldownRemoved")

G.GroupTrackedSpellsbySpellID = {}
G.GroupTrackedSpellsbyName = {}

G.GroupTrackedSpellsbyIndex = {
	CC_Other = {
		372048, -- 压迫怒吼（✓）
	},
	
	CC_Stun = {
		179057, -- 混乱新星（✓）
		119381, -- 扫堂腿（✓）
		30283, -- 暗影之怒（✓）
		192058, -- 电能图腾（✓）
		46968, -- 震荡波（✓）
		109248, -- 束缚射击（✓）
	},
	
	CC_Disorient = {
		31661,  -- 龙息术（✓）
		207167, -- 致盲冰雨（✓）
		115750, -- 盲目之光（✓）
		99, -- 夺魂咆哮（✓）
	},
	
	CC_Fear = {
		8122, -- 心灵尖啸（✓）
		5246, -- 破胆怒吼（✓）
		5484, -- 恐惧嚎叫（✓）
		207684, -- 悲苦咒符（✓）
	},
	
	CC_Grip = {
		108199, -- 血魔之握（✓）
		202138, -- 锁链咒符（✓）
	},
	
	CC_Root = {
		358385, -- 山崩（✓）
		102359, -- 群体缠绕（✓）
		376079, -- 勇士之矛（✓）
	},
	
	CC_Silence = {
		386071, -- 瓦解怒吼（✓）
		202137, -- 沉默符咒（✓）
		78675,  -- 日光术（✓）
	},
	
	CC_KnockOff = {
		462031, -- 内爆陷阱（✓）
		368970, -- 扫尾（✓）
		51490, -- 雷霆风暴（✓）
		458513, -- 引力失效（✓）
	},
	
	CC_KnockBack = {
		357214, -- 飞翼打击（✓）
		132469, -- 台风（✓）
		116844, -- 平心之环（✓）
		102793, -- 乌索尔旋风（✓）
	},
	
	Immuse = { -- 免疫
		45438, -- 寒冰屏障
		196555, -- 虚空行走
		186265, -- 灵龟守护
		642, -- 圣盾术
		31224, -- 暗影斗篷
	},
	
	Defense = { -- 减伤
		47585, -- 消散
		22812, -- 树皮术
		108271, -- 星界转移
	},
	
	DefenseSupport = { -- 队伍技能
		357170, -- 时间膨胀
		116849, -- 作茧缚命
		33206, -- 痛苦压制
		47788, -- 守护之魂
		102342, -- 铁木树皮
		6940, -- 牺牲祝福
	},
	
	OtherSupport = {
		--73325, -- 信仰飞跃
		--370665, -- 营救
		--1044, -- 自由祝福
		--1022, -- 保护祝福
		--204018, -- 破咒祝福
	},
}

G.RaidCCSpells = {}
local RaidCCPro = {
	"CC_Other",
	"CC_Grip",
	"CC_Root",
	"CC_Stun",
	"CC_KnockOff",
	"CC_KnockBack",
}

for _, SpellType in ipairs(RaidCCPro) do
	local data = G.GroupTrackedSpellsbyIndex[SpellType]
	for _, spellID in ipairs(data) do
		table.insert(G.RaidCCSpells, spellID)
	end
end

G.DungeonCCSpells = {}
local DungeonCCPro = {
	"CC_Grip",
	"CC_Stun",
	"CC_Silence",
	"CC_Disorient",
	"CC_Fear",
	"CC_KnockOff",
	"CC_KnockBack",
}

for _, SpellType in ipairs(DungeonCCPro) do
	local data = G.GroupTrackedSpellsbyIndex[SpellType]
	for _, spellID in ipairs(data) do
		table.insert(G.DungeonCCSpells, spellID)
	end
end

local GroupTrackedSpellTypePro = {
	"CC_Grip",
	"CC_Other",
	"CC_Stun",
	"CC_Silence",
	"CC_Disorient",
	"CC_Fear",
	"CC_KnockOff",
	"CC_KnockBack",
	"CC_Root",
	"Immuse",
	"Defense",
	"DefenseSupport",
	"OtherSupport",
}

local index = 0
for _, SpellType in ipairs(GroupTrackedSpellTypePro) do
	local data = G.GroupTrackedSpellsbyIndex[SpellType]
	for _, spellID in pairs(data) do
		index = index + 1
		G.GroupTrackedSpellsbySpellID[spellID] = {
			index = index,
			spell_type = SpellType, 
		}
		
		local spell = C_Spell.GetSpellName(spellID)
		G.GroupTrackedSpellsbyName[spell] = spellID
	end
end

local GSFrame = CreateFrame("Frame", nil, UIParent)

GSFrame.entries = {}

function GSFrame:GetEntry(GUID, spellID)
	for _, entry in ipairs(self.entries) do
        if entry.GUID == GUID and entry.spellID == spellID then
            return entry
        end
    end
end

function GSFrame:UpdateEntry(GUID, spellID, cooldownInfo)
	if not spellID or not G.GroupTrackedSpellsbySpellID[spellID] then return end
    if not GUID or not cooldownInfo then return end
    
    local entry = self:GetEntry(GUID, spellID)
    
    -- If no entry for this GUID/spellID combination exists, create it
    if not entry then
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        
        table.insert(self.entries,
            {
                GUID = GUID,
                spellID = spellID,
                spellName = spellInfo.name,
                spellIcon = spellInfo.iconID,
            }
        )
        
        entry = self.entries[#self.entries]
    end
    
    -- Update expirationTime/duration for the entry
    local _, _, timeLeft, charges, _, _, _, duration = LibOpenRaid.GetCooldownStatusFromCooldownInfo(cooldownInfo)
    local expirationTime = charges >= 1 and 0 or GetTime() + timeLeft
	
    entry.charges = charges
    entry.duration = duration
    entry.expirationTime = expirationTime
end

function GSFrame:RemoveEntry(GUID, spellID)
	if not GUID then return end
	
	for i, entry in ipairs(self.entries) do
        if entry.GUID == GUID and entry.spellID == spellID then
            table.remove(self.entries, i)
			break
        end
    end
end

function GSFrame:RemoveEntriesByGUID(GUID)
	if not GUID then return end
	
	for i, entry in ipairs(self.entries) do
        if entry.GUID == GUID then
			table.remove(self.entries, i)
        end
    end
end

function GSFrame:UpdateAllEntries(allUnitsCooldown)
    -- Wipe all info
    self.entries = table.wipe(self.entries)
    
    -- Update entries
    if allUnitsCooldown then
        for playerName, unitCooldowns in pairs(allUnitsCooldown) do
            local GUID = UnitGUID(playerName)

			for spellID, cooldownInfo in pairs(unitCooldowns) do
				self:UpdateEntry(GUID, spellID, cooldownInfo)
			end
        end
    end
    
    -- Sort entries
    table.sort(self.entries,
        function(entryA, entryB)
            local spellA = entryA.spellID
            local spellB = entryB.spellID
            
            local indexA = G.GroupTrackedSpellsbySpellID[spellA].index
            local indexB = G.GroupTrackedSpellsbySpellID[spellB].index
            
            if indexA ~= indexB then
                return indexA < indexB
            end
            
			if entryA.GUID and entryB.GUID then
				return entryA.GUID < entryB.GUID
			end
        end
    )
    
    LibOpenRaid.RequestAllData()
end

function GSFrame:Notify()
    T.FireEvent("JST_GROUP_CD_UPDATE", self.entries)
end

GSFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "JST_CooldownListUpdate" then
        local unit, unitCooldowns = ...  
        local GUID = UnitGUID(unit)
		
        self:RemoveEntriesByGUID(GUID)
		
        if unitCooldowns then
            for spellID, cooldownInfo in pairs(unitCooldowns) do
                self:UpdateEntry(GUID, spellID, cooldownInfo)
            end
        end
		
        self:Notify()
		
    elseif event == "JST_CooldownListWipe" then
		local unitData = ...
		
        self:UpdateAllEntries(unitData)
        self:Notify()
		
	elseif event == "JST_CooldownAdded" then
		local unit, spellID, cooldownInfo = ...
		local GUID = UnitGUID(unit)
		
		self:UpdateEntry(GUID, spellID, cooldownInfo)
		self:Notify()
		
    elseif event == "JST_CooldownUpdate" then
        local unit, spellID, cooldownInfo = ...
        local GUID = UnitGUID(unit)
        
        self:UpdateEntry(GUID, spellID, cooldownInfo)
        self:Notify()
		
	elseif event == "JST_CooldownRemoved" then		
		local unit, spellID = ...
		local GUID = UnitGUID(unit)
		
		self:RemoveEntry(GUID, spellID)
        self:Notify()
		
    elseif event == "ENCOUNTER_START" then
		local unitData = LibOpenRaid.GetAllUnitsCooldown()
        self:UpdateAllEntries(unitData)
        self:Notify()
		
	elseif event == "PLAYER_ENTERING_WORLD" then
        local unitData = LibOpenRaid.GetAllUnitsCooldown()
		self:UpdateAllEntries(unitData)
        self:Notify()
    end
end)

T.RegisterEventAndCallbacks(GSFrame, {
	["JST_CooldownListUpdate"] = true,
	["JST_CooldownListWipe"] = true,
	["JST_CooldownUpdate"] = true,
	["JST_CooldownAdded"] = true,
	["JST_CooldownRemoved"] = true,
	["ENCOUNTER_START"] = true,
	["PLAYER_ENTERING_WORLD"] = true,
})

T.GroupSpellForceUpdate = function()
	local unitData = LibOpenRaid.GetAllUnitsCooldown()
	GSFrame:UpdateAllEntries(unitData)
	GSFrame:Notify()
end

T.GetGroupCooldown = function(GUID, spellID)
	local unit = T.GUIDToUnit(GUID)
	
	if not unit then return end
	
	local cooldownInfo = LibOpenRaid.GetUnitCooldownInfo(unit, spellID)

	if cooldownInfo then
		local remain, charges, timeOffset, duration, updateTime, auraDuration = unpack(cooldownInfo)
		local exp_time = GetTime() + remain
		local start = exp_time - duration
		local ready = remain <= 0 and true or false
		
		return ready, exp_time, duration, remain, start, charges
	end
end

T.GetCCSpellCount = function()
	local count = 0
	for key, data in pairs(G.GroupTrackedSpellsbyIndex) do
		if string.find(key, "CC") then
			count = count + #data
		end
	end
	return count
end

--引力失效
LIB_OPEN_RAID_COOLDOWNS_INFO[449700] = {
    cooldown = 40,
    duration = 3,
    specs = {62, 63, 64},
    talent = false,
    charges = 1,
    class = "MAGE",
    type = 8
}

----------------------------------------------------------
----------------[[    怪物进战斗事件    ]]----------------
----------------------------------------------------------

G.engage_watched_npcs = {}
local engagedGUIDs = {}
local activeNameplates = {}
local GetNamePlates = C_NamePlate.GetNamePlates

local activeNameplateUtilityFrame = CreateFrame("Frame")
activeNameplateUtilityFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
activeNameplateUtilityFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")

local inactiveNameplateUtilityFrame = CreateFrame("Frame")
inactiveNameplateUtilityFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

local nameplateWatcher = activeNameplateUtilityFrame:CreateAnimationGroup()
nameplateWatcher:SetLooping("REPEAT")
local nameplateanim = nameplateWatcher:CreateAnimation()
nameplateanim:SetDuration(0.5)

activeNameplateUtilityFrame:SetScript("OnEvent", function(self, event, unit)
	if event == "NAME_PLATE_UNIT_ADDED" then
		activeNameplates[unit] = true
	elseif event == "PLAYER_ENTERING_WORLD" then
		local _, instanceType = GetInstanceInfo()
		if instanceType ~= "none" then
			if not nameplateWatcher:IsPlaying() then	
				local nameplates = GetNamePlates()
				for i = 1, #nameplates do
					local nameplateFrame = nameplates[i]
					if nameplateFrame.namePlateUnitToken and UnitCanAttack("player", nameplateFrame.namePlateUnitToken) then
						activeNameplates[nameplateFrame.namePlateUnitToken] = true
					end
				end
				nameplateWatcher:Play()
			end
		else
			nameplateWatcher:Stop()
			G.engage_watched_npcs = table.wipe(G.engage_watched_npcs)
		end
	end
end)

inactiveNameplateUtilityFrame:SetScript("OnEvent", function(self, event, unit)
	activeNameplates[unit] = nil
end)

nameplateWatcher:SetScript("OnLoop", function()
	for unit in next, activeNameplates do
		local guid = UnitGUID(unit)
		local engaged = engagedGUIDs[guid]
		if not engaged and UnitAffectingCombat(unit) then
			engagedGUIDs[guid] = true
			local npcID = select(6, strsplit("-", guid))
			if npcID and G.engage_watched_npcs[npcID] then
				T.FireEvent("UNIT_ENTERING_COMBAT", unit, guid, npcID)
			end
		elseif engaged and not UnitAffectingCombat(unit) then
			engagedGUIDs[guid] = nil
		end
	end
end)

T.IsMobEngaged = function(guid)
	return engagedGUIDs[guid] and true or false
end

T.RegisterMobEngage = function(npcID)
	G.engage_watched_npcs[npcID] = true
end

----------------------------------------------------------
----------------[[    队伍进战斗事件    ]]----------------
----------------------------------------------------------

local groupUtilityFrame = CreateFrame("Frame")
groupUtilityFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
groupUtilityFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
groupUtilityFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local groupWatcher = groupUtilityFrame:CreateAnimationGroup()
groupWatcher:SetLooping("REPEAT")
local groupanim = groupWatcher:CreateAnimation()
groupanim:SetDuration(0.5)
local group_in_combat

local GetGroupCombatStatus = function()
	local combat = false
	
	for unit in T.IterateGroupMembers() do
		if UnitAffectingCombat(unit) then
			combat = true
			break
		end
	end
	
	return combat
end

groupUtilityFrame:SetScript("OnEvent", function(self, event, unit)
	if event == "PLAYER_ENTERING_WORLD" then
		if InCombatLockdown() then
			groupWatcher:Stop()
			group_in_combat = true
		else
			groupWatcher:Play()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		groupWatcher:Play()
	elseif event == "PLAYER_REGEN_DISABLED" then
		groupWatcher:Stop()
		group_in_combat = true
	end
end)

groupWatcher:SetScript("OnLoop", function()
	if GetGroupCombatStatus() then
		group_in_combat = true
	else
		if group_in_combat then
			T.FireEvent("GROUP_LEAVING_COMBAT")
		end
		group_in_combat = false
	end
end)

----------------------------------------------------------
---------------[[    重要单位光环事件    ]]---------------
----------------------------------------------------------

local auraUtilityFrame = CreateFrame("Frame")
auraUtilityFrame:RegisterEvent("UNIT_AURA")

local aura_cache = {}
local aura_event_spellIDs = {
	[404468] = true,
}

T.RegisterWatchAuraSpellID = function(spellID)
	aura_event_spellIDs[spellID] = true
end

T.UnregisterWatchAuraSpellID = function(spellID)
	aura_event_spellIDs[spellID] = nil
end

auraUtilityFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_AURA" then
		local unit, updateInfo = ...
		if unit and T.FilterAuraUnit(unit) then
			local GUID = UnitGUID(unit)				
			if not GUID then return end
			
			if not aura_cache[GUID] then
				aura_cache[GUID] = {}
			end
			
			if updateInfo == nil or updateInfo.isFullUpdate then
				for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
					AuraUtil.ForEachAura(unit, auraType, nil, function(aura_data)
						local spellID = aura_data.spellId
						if aura_event_spellIDs[spellID] then
							local auraID = aura_data.auraInstanceID
							if not aura_cache[GUID][auraID] then
								aura_cache[GUID][auraID] = spellID
								T.FireEvent("UNIT_AURA_ADD", unit, spellID, auraID)
							end
						end
					end, true)
				end
			else
				if updateInfo.addedAuras ~= nil then
					for _, aura_data in pairs(updateInfo.addedAuras) do
						local spellID = aura_data.spellId
						if aura_event_spellIDs[spellID] then
							local auraID = aura_data.auraInstanceID
							if not aura_cache[GUID][auraID] then
								aura_cache[GUID][auraID] = spellID
								T.FireEvent("UNIT_AURA_ADD", unit, spellID, auraID)
							end
						end
					end
				end
				if updateInfo.updatedAuraInstanceIDs ~= nil then
					for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
						local spellID = aura_cache[GUID][auraID]
						if spellID then
							T.FireEvent("UNIT_AURA_UPDATE", unit, spellID, auraID)
						end
					end
				end
				if updateInfo.removedAuraInstanceIDs ~= nil then
					for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
						local spellID = aura_cache[GUID][auraID]
						if spellID then
							aura_cache[GUID][auraID] = nil
							T.FireEvent("UNIT_AURA_REMOVED", unit, spellID, auraID)
						end
					end
				end
			end
		end
	end
end)

----------------------------------------------------------
-----------------[[    施法目标事件    ]]-----------------
----------------------------------------------------------

local castUtilityFrame = CreateFrame("Frame")
castUtilityFrame:RegisterEvent("UNIT_SPELLCAST_START")
castUtilityFrame:RegisterEvent("UNIT_TARGET")

local cast_cache = {}
local CastTargetDelay = {}
local TestSpells = {
	--[432565] = true, -- 黑暗之霰
}

T.RegisterCastTargetDelay = function(spellID, delay)
	CastTargetDelay[spellID] = delay
end

castUtilityFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_SPELLCAST_START" then
		local unit, cast_GUID, cast_spellID = ...
		if unit and UnitIsEnemy("player", unit) and cast_GUID and cast_spellID then
			local wait = .2 or CastTargetDelay[cast_spellID]
			C_Timer.After(wait, function()
				local target_unit = T.GetTarget(unit)
				local GUID = target_unit and UnitGUID(target_unit)
				if GUID and not cast_cache[cast_GUID] then
					T.FireEvent("UNIT_SPELLCAST_TARGET", unit, cast_GUID, cast_spellID, GUID)
					cast_cache[cast_GUID] = GUID
					
					if TestSpells[cast_spellID] then
						local startTimeMS, endTimeMS = select(4, UnitCastingInfo(unit))
						local spell = C_Spell.GetSpellName(cast_spellID)
						local dur = endTimeMS/1000 - startTimeMS/1000
						local remain = endTimeMS/1000 - GetTime()
						T.msg(string.format("%s %s→%s |cffffff00延迟判定 %.3f|r %s %.2f %.2f", spell, UnitName(unit), T.ColorNickNameByGUID(GUID), wait, cast_GUID, dur, remain))
					end
				end
			end)
		end
	elseif event == "UNIT_TARGET" then
		local unit = ...
		if unit and UnitIsEnemy("player", unit) and UnitCastingInfo(unit) then
			local startTimeMS, endTimeMS, _, cast_GUID, _, cast_spellID = select(4, UnitCastingInfo(unit))
			if cast_GUID and not cast_cache[cast_GUID] and cast_spellID then
				local target_unit = T.GetTarget(unit)
				local GUID = target_unit and UnitGUID(target_unit)
				if GUID then
					T.FireEvent("UNIT_SPELLCAST_TARGET", unit, cast_GUID, cast_spellID, GUID)
					cast_cache[cast_GUID] = GUID
					if TestSpells[cast_spellID] then
						local spell = C_Spell.GetSpellName(cast_spellID)
						local wait = GetTime() - startTimeMS/1000
						local dur = endTimeMS/1000 - startTimeMS/1000
						local remain = endTimeMS/1000 - GetTime()
						T.msg(string.format("%s %s→%s |cff00ff00目标判定 %.3f|r %s %.2f %.2f", spell, UnitName(unit), T.ColorNickNameByGUID(GUID), wait, cast_GUID, dur, remain))
					end
				end
			end
		end
	end
end)

----------------------------------------------------------
-------------[[    MRT战术板编辑事件    ]]----------------
----------------------------------------------------------

T.RegisterInitCallback(function()
	if MRTNote and MRTNote.text then	
		hooksecurefunc(MRTNote.text, "SetText", function()
			T.FireEvent("MRT_NOTE_EDIT")
		end)
	end
end)
