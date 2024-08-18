
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Thok the Bloodthirsty", 1136, 851)
if not mod then return end
mod:RegisterEnableMob(71529)
mod.engageId = 1599

--------------------------------------------------------------------------------
-- Locals
--
local accCount = 0
local yetiChargeTimer
local mythicAdd

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.adds = CL.adds
	L.adds_desc = "Warnings for when the Yeti or Bats enter the fight."
	L.adds_icon = "ability_hunter_pet_bat"

	L.cage_opened = "Cage opened"

	L.npc_akolik = "Akolik"
	L.npc_waterspeaker_gorai = "Waterspeaker Gorai"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		148145, "adds",
		-7963, 143428, 143777, 143783, -- stage 1
		-7981, {-7980, "ICON", "FLASH", "SAY"}, {146589, "FLASH"}, {145974, "DISPEL"},-- stage 2
		{143766, "TANK"}, {143780, "TANK"}, {143767, "TANK"}, {143773, "TANK"},
		"proximity", "berserk",
	}, {
		[148145] = "mythic",
		[-7963] = -7960, -- stage 1
		[-7981] = -7961, -- stage 2
		[143766] = INLINE_TANK_ICON..TANK,
		["proximity"] = "general",
	}
end

function mod:OnBossEnable()
	-- Mythic
	self:Log("SPELL_AURA_APPLIED", "YetCharge", 148145)
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "PrisonerTracker")
	-- stage 2
	self:Log("SPELL_AURA_APPLIED_DOSE", "BloodFrenzy", 143442)
	self:Log("SPELL_AURA_REMOVED", "SkeletonKeyRemoved", 146589)
	self:Log("SPELL_AURA_APPLIED", "SkeletonKey", 146589)
	self:Log("SPELL_AURA_REMOVED", "BloodFrenzyOver", 143440)
	self:Log("SPELL_AURA_REMOVED", "FixateRemoved", 143445)
	self:Log("SPELL_AURA_APPLIED", "FixateApplied", 143445)
	self:Log("SPELL_AURA_APPLIED", "Enrage", 145974)
	self:Emote("BloodFrenzyPhase", "143440")
	-- stage 1
	self:Log("SPELL_PERIODIC_DAMAGE", "BurningBlood", 143783)
	self:Log("SPELL_PERIODIC_MISSED", "BurningBlood", 143783)
	self:Log("SPELL_DAMAGE", "BurningBlood", 143783)
	self:Log("SPELL_MISSED", "BurningBlood", 143783)
	self:Log("SPELL_AURA_APPLIED", "FrozenSolid", 143777)
	self:Log("SPELL_CAST_SUCCESS", "TailLash", 143428)
	self:Log("SPELL_AURA_APPLIED", "Acceleration", 143411)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Acceleration", 143411)
	self:Log("SPELL_AURA_APPLIED", "TankDebuff", 143766, 143780, 143773, 143767) -- Panic, Acid Breath, Freezing Breath, Scorching Breath
	self:Log("SPELL_AURA_APPLIED_DOSE", "TankDebuff", 143766, 143780, 143773, 143767)
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "TankDebuffCasts", "boss1")

	self:Death("YetiDeath", 73526) -- Starved Yeti
end

function mod:OnEngage()
	if self:Mythic() then
		yetiChargeTimer = nil
		mythicAdd = nil
	end
	accCount = 0
	self:Berserk(600)
	self:OpenProximity("proximity", 10) -- Too close to another group. Tactic dependant - needed for mythic
	self:Bar(-7963, self:LFR() and 18 or 14) -- Deafening Screech
	self:Bar(143766, 12, 143426, 143766) -- Fearsome Roar with correct icon
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Mythic

function mod:PrisonerTracker(_, _, sender)
	if sender == L.npc_akolik then
		mythicAdd = "bats"
	elseif sender == L.npc_waterspeaker_gorai then
		mythicAdd = "yeti"
	end
end

function mod:YetCharge(args)
	self:Bar(args.spellId, 15)
	if not yetiChargeTimer then
		yetiChargeTimer = self:ScheduleTimer("MessageOld", 15, args.spellId, "red", "warning", CL.soon:format(args.spellName))
	end
end

-- stage 2

function mod:BloodFrenzy(args)
	-- this may feel like double message, but knowing exact stack count on phase change can help plan the rest of the fight
	self:MessageOld(-7981, "yellow", nil, CL.count:format(args.spellName, args.amount))
end

function mod:Enrage(args)
	if self:Tank() or self:Dispeller("enrage", true, args.spellId) then
		self:TargetMessageOld(args.spellId, args.destName, "orange", "alert")
	end
end

function mod:SkeletonKeyRemoved(args)
	self:MessageOld(args.spellId, "green", "alert", L.cage_opened)
	self:StopBar(args.spellId, args.destName)
	self:Bar(-7981, 13, CL.over:format(self:SpellName(-7981))) -- Blood Frenzy
end

function mod:SkeletonKey(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow", "warning")
	self:TargetBar(args.spellId, 60, args.destName)
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
	end
end

do
	local function checkPrisonerKilled()
		if mythicAdd then
			-- XXX maybe add scheduled message once we know exact timer (videos)
			-- timer still need verification and still looking for a better event to start bars (don't seem to be any)
			if mythicAdd == "bats" then
				mod:Bar("adds", 12, mod:SpellName(-8584), 24733) -- bat icon
			elseif mythicAdd == "yeti" then
				mod:Bar("adds", 10, mod:SpellName(-8582), 26010) -- yeti icon
				mythicAdd = nil
			end
		end
	end
	function mod:BloodFrenzyOver(args)
		self:OpenProximity("proximity", 10)
		self:MessageOld(-7981, "cyan", "long", CL.over:format(args.spellName))
		self:Bar(-7963, self:LFR() and 18 or 14) -- Deafening Screech
		self:Bar(143766, 12, 17086, "ability_hunter_pet_devilsaur") -- Breath. 143766 isn't exactly a combined option but it's one of the breaths.
		if self:Mythic() then
			self:ScheduleTimer(checkPrisonerKilled, 10)
		end
	end
end

function mod:FixateRemoved(args)
	self:PrimaryIcon(-7980)
	self:StopBar(-7980, args.destName)
	if self:Me(args.destGUID) then
		self:MessageOld(-7980, "green", nil, CL.over:format(args.spellName))
	end
end

function mod:FixateApplied(args)
	if self:Me(args.destGUID) then
		self:Say(-7980, nil, nil, "Fixate")
		self:Flash(-7980)
	end
	self:TargetMessageOld(-7980, args.destName, "orange", "alarm")
	self:TargetBar(-7980, 12, args.destName)
	self:PrimaryIcon(-7980, args.destName)
end

function mod:BloodFrenzyPhase()
	self:MessageOld(-7963, "yellow", nil, CL.count:format(self:SpellName(143411), accCount))
	accCount = 0
	self:StopBar(143428) -- Tail Lash
	self:StopBar(143426) -- Fearsome Roar
	self:StopBar(143780) -- Acid Breath
	self:StopBar(143773) -- Freezing Breath
	self:StopBar(143767) -- Scorching Breath
	self:StopBar(-7963) -- Deafening Screech
	self:CloseProximity("proximity")
	self:MessageOld(-7981, "cyan", "long")
end

-- stage 1

do
	local prev = 0
	function mod:BurningBlood(args)
		if self:Me(args.destGUID) then
			local t = GetTime()
			if t-prev > 2 then
				prev = t
				self:MessageOld(args.spellId, "blue", "info", CL.underyou:format(args.spellName))
			end
		end
	end
end

do
	local frozenSolid, scheduled = mod:NewTargetList(), nil
	local function warnFrozenSolid(spellId)
		scheduled = nil
		mod:TargetMessageOld(spellId, frozenSolid, "yellow")
	end
	function mod:FrozenSolid(args)
		frozenSolid[#frozenSolid+1] = args.destName
		if not scheduled then
			scheduled = self:ScheduleTimer(warnFrozenSolid, 0.2, args.spellId)
		end
	end
end

function mod:TailLash(args)
	self:Bar(args.spellId, 10) -- don't think this needs a message
end

do
	local accTimes = {10.9, 7.2, 4.8, 3.6}
	function mod:Acceleration(args)
		accCount = args.amount or 1
		if accTimes[accCount] then -- Beyond this is too short a timer to care (2.1-2.4)
			self:Bar(-7963, accTimes[accCount])
		end
		if accCount < 6 or accCount % 3 == 0 then
			self:MessageOld(-7963, "yellow", nil, CL.count:format(args.spellName, accCount))
		end
	end
end

function mod:TankDebuffCasts(_, _, _, spellId)
	if spellId == 143426 then -- Fearsome Roar
		self:Bar(143766, 11, spellId, 143766) -- Blizzard gave Fearsome Roar the wrong icon
	elseif spellId == 143780 or spellId == 143773 or spellId == 143767 then -- Acid Breath, Freezing Breath, Scorching Breath
		self:Bar(spellId, 11) -- 11-15s
	end
end

function mod:TankDebuff(args)
	self:StackMessageOld(args.spellId, args.destName, args.amount, "yellow", not self:Me(args.destGUID) and "warning")
end

function mod:YetiDeath(args)
	self:CancelTimer(yetiChargeTimer)
	yetiChargeTimer = nil
	mythicAdd = nil
end

