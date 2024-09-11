
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Tsulong", 996, 742)
if not mod then return end
mod:RegisterEnableMob(62442)

--------------------------------------------------------------------------------
-- Locals
--
local bigAddCounter = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_yell = "You do not belong here! The waters must be protected... I will cast you out, or slay you!"
	L.kill_yell = "I thank you, strangers. I have been freed."

	L.phases = "Phases"
	L.phases_desc = "Warning for phase changes."

	L.unstable_sha, L.unstable_sha_desc = -6320, -6320
	L.unstable_sha_icon = 122938

	L.embodied_terror, L.embodied_terror_desc = -6316, -6316
	L.embodied_terror_icon = 130142 -- white and black sha-y icon

	L.sunbeam_spawn = "New Sunbeam!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-6550,
		122752, 122768, 122789, {122777, "PROXIMITY", "FLASH", "SAY"},
		122855, "unstable_sha", 123011, "embodied_terror",
		"phases", "berserk",
	}, {
		[-6550] = "heroic",
		[122752] = -6310,
		[122855] = -6315,
		phases = "general",
	}
end

function mod:VerifyEnable(unit)
	local hp = self:GetHealth(unit)
	if hp > 8 and UnitCanAttack("player", unit) then
		return true
	end
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_CAST_START", "SunBreath", 122855)
	self:Log("SPELL_CAST_SUCCESS", "ShadowBreath", 122752)
	self:Log("SPELL_CAST_SUCCESS", "Terrorize", 123011)
	self:Log("SPELL_AURA_APPLIED_DOSE", "DreadShadows", 122768)
	self:Log("SPELL_AURA_APPLIED", "Sunbeam", 122789)
	self:Emote("SunbeamSpawn", "122789")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "target", "boss1", "boss2", "boss3")
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "EngageCheck")

	self:Death("EmbodiedTerrorDeath", 62969)
end

function mod:OnEngage(diff)
	self:OpenProximity(122777, 8)
	self:Berserk(self:LFR() and 900 or 490)
	self:Bar("phases", 121, -6315, "spell_holy_circleofrenewal") -- The Day
	self:Bar(122777, 15.6) -- Nightmares
	self:Bar(122752, 10) -- Shadow Breath
	bigAddCounter = 0
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.kill_yell, nil, true) then
		self:UnregisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "target", "boss1", "boss2", "boss3")
		self:Win()
	end
end

function mod:SunbeamSpawn()
	self:MessageOld(122789, "green", nil, L["sunbeam_spawn"])
	self:Bar(122789, 42)
end

function mod:EngageCheck()
	self:CheckBossStatus()
	if UnitExists("boss2") and self:MobId(self:UnitGUID("boss2")) == 62969 then
		bigAddCounter = bigAddCounter + 1
		if bigAddCounter < 3 then
			self:Bar("embodied_terror", 40, CL["count"]:format(L["embodied_terror"], bigAddCounter+1), L.embodied_terror_icon)
		end
		self:MessageOld("embodied_terror", "yellow", nil, CL["count"]:format(L["embodied_terror"], bigAddCounter), L.embodied_terror_icon)
		self:Bar(123011, 5) -- Terrorize (overwrites the previous bar)
	end
end

function mod:Terrorize(args)
	self:MessageOld(args.spellId, "red", self:Dispeller("magic") and "alert")
	self:Bar(args.spellId, 41)
end

function mod:DreadShadows(args)
	if self:Me(args.destGUID) and args.amount > (self:Heroic() and 5 or self:LFR() and 13 or 9) and args.amount % 2 == 0 then
		self:MessageOld(args.spellId, "blue", "info", CL["count"]:format(args.spellName, args.amount))
	end
end

function mod:Sunbeam(args)
	if self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "green", nil, CL["removed"]:format(self:SpellName(122768)))
	end
end

function mod:SunBreath(args)
	self:Bar(args.spellId, 29)
	self:MessageOld(args.spellId, "orange")
end

function mod:ShadowBreath(args)
	self:Bar(args.spellId, 25)
	self:MessageOld(args.spellId, "orange")
end

do
	local function printTarget(self, name, guid) -- Nightmares
		self:TargetMessageOld(122777, name, "red", "alert")
		if self:Me(guid) then
			self:Flash(122777)
			self:Say(122777, nil, nil, "Nightmares")
		end
	end

	local prev = 0
	function mod:UNIT_SPELLCAST_SUCCEEDED(event, unitId, _, spellId)
		if spellId == 124176 then
			self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
			self:UnregisterUnitEvent(event, "target", "boss1", "boss2", "boss3")
			self:Win() -- Gold Active
		elseif unitId:find("boss", nil, true) then
			if spellId == 123252 then -- Dread Shadows Cancel (start of day phase)
				bigAddCounter = 0
				self:CloseProximity(122777)
				self:StopBar(122777) -- Nightmares
				self:StopBar(122752) -- Shadow Breath
				self:StopBar(122789) -- Sunbeam
				self:StopBar(-6550) -- The Dark of Night
				self:MessageOld("phases", "green", nil, -6315, "spell_holy_circleofrenewal") -- The Day
				self:Bar("phases", 121, -6310, 122768) -- The Night
				self:Bar(122855, 32) -- Sun Breath
				self:Bar("unstable_sha", 18, 122953, 122938)
				self:Bar("embodied_terror", 11, ("~%s (%d)"):format(L["embodied_terror"], 1), L.embodied_terror_icon)
			elseif spellId == 122767 then -- Dread Shadows (start of night phase)
				self:StopBar(122953) -- Summon Unstable Sha
				self:StopBar(122855) -- Sun Breath
				self:OpenProximity(122777, 8)
				self:Bar(122777, 15) -- Nightmares
				self:MessageOld("phases", "green", nil, -6310, 122768) -- The Night
				self:Bar("phases", 121, -6315, "spell_holy_circleofrenewal") -- The Day
				self:Bar(122752, 10) -- Shadow Breath
				if self:Dispeller("magic", true) then
					local name = self:UnitBuff("boss1", nil, "Magic") -- well any magic actually not just HoTs
					if name then
						self:MessageOld("phases", "yellow", "alert", CL.buff_boss:format(name), false)
					end
				end
			elseif spellId == 122953 then -- Summon Unstable Sha
				local t = GetTime()
				if t-prev > 2 then
					prev = t
					self:MessageOld("unstable_sha", "red", "alert", self:SpellName(spellId), 122938)
					self:Bar("unstable_sha", 18, self:SpellName(spellId), 122938)
				end
			elseif spellId == 122775 then -- Nightmares
				self:Bar(122777, 15)
				if self:Difficulty() == 3 or self:Difficulty() == 5 then -- Only 1 nightmare spawns in 10 man modes
					self:GetBossTarget(printTarget, 0.7, self:UnitGUID(unitId))
				else
					self:MessageOld(122777, "yellow")
				end
			elseif spellId == 123813 then -- The Dark of Night (heroic)
				self:Bar(-6550, 30, 130013)
				self:MessageOld(-6550, "orange", "alarm", 130013)
			end
		end
	end
end

function mod:EmbodiedTerrorDeath()
	self:StopBar(123011)
end

