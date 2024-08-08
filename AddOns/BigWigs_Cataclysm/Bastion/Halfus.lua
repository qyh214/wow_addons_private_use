--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Halfus Wyrmbreaker", 671, 156)
if not mod then return end
mod:RegisterEnableMob(44600, 44645, 44652, 44650, 44797, 44641) -- Halfus, Nether Scion, Slate Dragon, Storm Rider, Time Warden, Orphaned Emerald Whelp
mod:SetEncounterID(1030)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local furiousRoarCount = 1
local scorchingBreathCount = 1
local shadowNovaCount = 1
local previousRoar = 0
local furiousRoarCurrentCasts = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.strikes_message = "Strikes"
	L.freed_message = "%s freed %s"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{83908, "TANK"}, -- Malevolent Strikes
		{84030, "CASTBAR"}, -- Paralysis
		83707, -- Scorching Breath
		{83710, "CASTBAR"}, -- Furious Roar
		{83706, "CASTBAR"}, -- Fireball Barrage
		83703, -- Shadow Nova
		83589, -- Free Dragon
		"berserk",
	},nil,{
		[83908] = L.strikes_message, -- Malevolent Strikes (Strikes)
		[83707] = CL.breath, -- Scorching Breath (Breath)
		[83710] = CL.roar, -- Furious Roar (Roar)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "FuriousRoar", 83710)
	self:Log("SPELL_AURA_APPLIED", "ParalysisApplied", 84030, 84591) -- Paralysis/Petrification, used with Slate Dragon active
	self:Log("SPELL_AURA_REMOVED", "ParalysisRemoved", 84030, 84591)
	self:Log("SPELL_AURA_APPLIED_DOSE", "MalevolentStrikesApplied", 83908) -- Used with Slate Dragon ready
	self:Log("SPELL_CAST_START", "ScorchingBreath", 83707) -- Used by Proto-Behemoth with whelps ready
	self:Log("SPELL_CAST_SUCCESS", "FireballBarrage", 83706) -- Used by Proto-Behemoth
	self:Log("SPELL_CAST_START", "ShadowNova", 83703)
	self:Log("SPELL_CAST_SUCCESS", "FreeDragon", 83589, 83590, 83591, 83447)
end

function mod:OnEngage()
	furiousRoarCount = 1
	scorchingBreathCount = 1
	shadowNovaCount = 1
	previousRoar = 0
	furiousRoarCurrentCasts = 0
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
	if self:Heroic() then -- May or may not happen on normal
		self:CDBar(83707, 11, CL.count:format(CL.breath, scorchingBreathCount)) -- Scorching Breath
	end
	self:Berserk(360, true) -- All the dragon "freed" messages happen on engage
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:FuriousRoar(args)
	if args.time - previousRoar > 10 then
		previousRoar = args.time
		furiousRoarCurrentCasts = 0
		self:StopBar(CL.count:format(CL.roar, furiousRoarCount))
		furiousRoarCount = furiousRoarCount + 1
		self:CDBar(args.spellId, 30.7, CL.count:format(CL.roar, furiousRoarCount))
	end
	furiousRoarCurrentCasts = furiousRoarCurrentCasts + 1
	local msg = CL.count_amount:format(CL.roar, furiousRoarCurrentCasts, 3)
	self:CastBar(args.spellId, 1.5, msg)
	self:Message(args.spellId, "orange", msg)
	self:PlaySound(args.spellId, "info")
end

-- Slate Dragon: Stone Touch (83603), 35 sec internal cd, resulting in Paralysis, 12 sec stun
-- Next Stone Touch after 23 sec, hence delaying Furious Roar if less then 12 sec left
do
	local prevParalysis = 0
	function mod:ParalysisApplied(args)
		prevParalysis = args.time
		self:StopBar(CL.cast:format(CL.count_amount:format(CL.roar, furiousRoarCurrentCasts, 3))) -- Stop Furious Roar if it's casting
		self:Message(84030, "yellow", CL.onboss:format(args.spellName))
		self:CastBar(84030, 12, args.spellName)
		if furiousRoarCount > 1 and ((previousRoar + 30.7) - args.time) < 12 then -- Only if Furious Roar has been cast, and the time left is < 12s
			self:CDBar(83710, 13, CL.count:format(CL.roar, furiousRoarCount)) -- Furious Roar
		end
		self:PlaySound(84030, "long")
	end

	function mod:ParalysisRemoved(args)
		self:StopBar(CL.cast:format(args.spellName))
		self:Bar(84030, prevParalysis > 0 and (35 - (args.time-prevParalysis)) or 23, args.spellName) -- Show the bar after paralysis ends on the boss
	end
end

function mod:MalevolentStrikesApplied(args)
	if self:Player(args.destFlags) and args.amount >= (self:Heroic() and 6 or 8) then -- Players, not pets. 8% in heroic, 6% in normal, announce around 50-60% reduced healing
		self:StackMessage(args.spellId, "purple", args.destName, args.amount, self:Heroic() and 7 or 10, L.strikes_message)
	end
end

do
	local prevBreath = 0
	function mod:ScorchingBreath(args)
		prevBreath = args.time
		self:StopBar(CL.count:format(CL.breath, scorchingBreathCount))
		self:Message(args.spellId, "red", CL.count:format(CL.breath, scorchingBreathCount))
		scorchingBreathCount = scorchingBreathCount + 1
		self:CDBar(args.spellId, 20, CL.count:format(CL.breath, scorchingBreathCount))
		self:PlaySound(args.spellId, "warning")
	end

	function mod:FireballBarrage(args)
		self:Message(args.spellId, "red")
		self:CastBar(args.spellId, 10)
		if scorchingBreathCount > 1 and ((prevBreath + 20) - args.time) < 10 then -- Only if Scorching Breath has been cast, and the time left is < 10s
			self:CDBar(83707, 11, CL.count:format(CL.breath, scorchingBreathCount))
		end
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:ShadowNova(args)
	shadowNovaCount = shadowNovaCount + 1

	local isPossible, isReady = self:Interrupter(args.sourceGUID)
	if isPossible then
		self:Message(args.spellId, "yellow", CL.count:format(args.spellName, shadowNovaCount))
		if isReady then
			self:PlaySound(args.spellId, "alert")
		end
	end
end

function mod:FreeDragon(args)
	self:Message(83589, "cyan", L.freed_message:format(self:ColorName(args.sourceName), args.destName))
end

function mod:UNIT_HEALTH(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 55 then
		self:UnregisterUnitEvent(event, unit)
		if hp > 50 then
			self:Message(83710, "cyan", CL.soon:format(CL.count:format(CL.roar, furiousRoarCount)), false)
			self:PlaySound(83710, "info")
		end
	end
end
