--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Gara'jal the Spiritbinder", 1008, 682)
if not mod then return end
mod:RegisterEnableMob(60143, 60385) -- Gara'jal, Zandalari War Wyvern
mod:SetEncounterID(1434)
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local totemCounter, shadowCounter = 1, 1
local totemTime = 36.5
local voodooList = {}
local crossedOverOnMe = false
local tempDollCheck = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.engage_yell = "It be dyin' time, now!"

	L.totem_message = "Totem (%d)"
	L.shadowy_message = "Attack (%d)"
	L.banish_message = "Tank Banished"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		122151,
		116174,
		116272,
		{116161, "EMPHASIZE", "COUNTDOWN"},
		117752, -- Frenzy
		-6698,
		"berserk",
	},{
		[122151] = CL.stage:format(1),
		[117752] = CL.stage:format(2),
		[-6698] = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Frenzy", 117752)
	self:Log("SPELL_AURA_APPLIED", "VoodooDollsApplied", 122151)
	self:Log("SPELL_AURA_REMOVED", "VoodooDollsRemoved", 122151) -- Used in 3rd party modules
	self:Log("SPELL_CAST_SUCCESS", "SpiritTotem", 116174)
	self:Log("SPELL_CAST_SUCCESS", "Banishment", 116272)
	self:Log("SPELL_AURA_REMOVED", "SoulSeverRemoved", 116278)
	self:Log("SPELL_AURA_APPLIED", "CrossedOver", 116161, 116260) -- Norm/Hc, LFR
	self:Log("SPELL_AURA_REMOVED", "CrossedOverRemoved", 116161, 116260)

	self:RegisterMessage("BigWigs_BossComm")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")
end

function mod:OnEngage()
	totemCounter, shadowCounter = 1, 1
	voodooList = {}
	crossedOverOnMe = false
	tempDollCheck = false
	local diff = self:Difficulty()
	if diff == 3 or diff == 5 then
		totemTime = 36.5 -- 10
	elseif diff == 4 or diff == 6 then
		totemTime = 20.5 -- 25
	elseif diff == 7 then
		totemTime = 30 -- LFR
	end
	self:SetStage(1)
	self:Bar(116174, totemTime, L["totem_message"]:format(totemCounter))
	if not self:Solo() then
		self:Bar(116272, self:Heroic() and 71 or 65, L["banish_message"])
	end
	if not self:LFR() then
		self:Berserk(360)
	end
	if self:Heroic() then
		self:Bar(-6698, 6.7, L["shadowy_message"]:format(shadowCounter), 117222)
	end
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, _, spellId)
	if spellId == 116964 then
		self:Sync("Totem") -- LFR only, no combat log event for some reason
	elseif (spellId == 117215 or spellId == 117218 or spellId == 117219 or spellId == 117222) and self:Heroic() then
		self:Sync("Shadowy")
	end
end

do
	local voodooDollList = mod:NewTargetList()
	local times = {
		["Totem"] = 0,
		["Shadowy"] = 0,
		["Frenzy"] = 0,
		["Banish"] = 0,
	}
	local function wipe()
		voodooList = {}
	end
	function mod:BigWigs_BossComm(_, msg, guid)
		if msg == "DollsApplied" and not voodooList[guid] then
			voodooList[guid] = true
			for unit in self:IterateGroup() do
				if guid == self:UnitGUID(unit) then
					voodooDollList[#voodooDollList+1] = self:UnitName(unit)
					if #voodooDollList == 1 then
						self:ScheduleTimer("TargetMessageOld", 0.3, 122151, voodooDollList, "red")
						self:ScheduleTimer(wipe, 0.3)
					end
					break
				end
			end
		elseif times[msg] then
			local t = GetTime()
			if t-times[msg] > 5 then
				times[msg] = t
				if msg == "Totem" then
					self:MessageOld(116174, "yellow", nil, L["totem_message"]:format(totemCounter))
					totemCounter = totemCounter + 1
					self:Bar(116174, totemTime, L["totem_message"]:format(totemCounter))
				elseif msg == "Shadowy" then
					shadowCounter = shadowCounter + 1
					self:Bar(-6698, 8.3, L["shadowy_message"]:format(shadowCounter), 117222)
				elseif msg == "Frenzy" then
					if not self:LFR() then
						self:StopBar(L["totem_message"]:format(totemCounter))
						self:StopBar(L["banish_message"])
					end
					self:SetStage(2)
					self:Message(117752, "red", CL.percent:format(20, self:SpellName(117752)))
					self:PlaySound(117752, "long")
				elseif msg == "Banish" then
					self:Bar(116272, self:Heroic() and 70 or 65, L["banish_message"])
					self:MessageOld(116272, "orange", self:Tank() and "alarm" or nil, L["banish_message"])
				end
			end
		end
	end
end

function mod:VoodooDollsApplied(args)
	-- Using GUID instead of names for cross realm group compatibility
	self:Sync("DollsApplied", args.destGUID)
	if crossedOverOnMe and not tempDollCheck then
		tempDollCheck = true
		self:Message(122151, "red", "VD")
	end
end

function mod:VoodooDollsRemoved(args)
	-- Used in 3rd party modules
	self:Sync("DollsRemoved", args.destGUID)
end

function mod:CrossedOver(args)
	if self:Me(args.destGUID) then
		crossedOverOnMe = true
		self:Bar(116161, 30)
	end
end

function mod:CrossedOverRemoved(args)
	if self:Me(args.destGUID) then
		crossedOverOnMe = false
		self:StopBar(args.spellName)
	end
end

function mod:SpiritTotem()
	self:Sync("Totem")
	if crossedOverOnMe then
		self:MessageOld(116174, "yellow", nil, L["totem_message"]:format(totemCounter))
	end
end

function mod:Banishment(args)
	if self:Me(args.destGUID) then
		self:Bar(116161, 30) -- Crossed Over
	end
	self:Sync("Banish", args.destGUID)
end

function mod:SoulSeverRemoved(args)
	if self:Me(args.destGUID) then
		self:StopBar(116161) -- Crossed Over
	end
end

function mod:UNIT_HEALTH(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 25 then
		self:UnregisterUnitEvent(event, unit)
		if hp > 20 then -- Make sure we're not too late
			self:Message(117752, "red", CL.soon:format(self:SpellName(117752)))
		end
	end
end

function mod:Frenzy(args)
	self:Sync("Frenzy")
	if crossedOverOnMe then
		self:Message(117752, "red", CL.percent:format(20, self:SpellName(117752)))
		--self:PlaySound(117752, "long")
	end
end
