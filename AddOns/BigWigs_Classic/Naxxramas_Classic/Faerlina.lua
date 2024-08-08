--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Grand Widow Faerlina", 533, 1602)
if not mod then return end
mod:RegisterEnableMob(15953, 16505, 16506) -- Faerlina, Naxxramas Follower, Naxxramas Worshipper
mod:SetEncounterID(1110)

--------------------------------------------------------------------------------
-- Locals
--

local frenzyTimer = 0

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		28732, -- Widow's Embrace
		28798, -- Enrage
		28794, -- Rain of Fire
		30225, -- Silence
		28796, -- Poison Bolt Volley
	}
end

function mod:VerifyEnable(unit, mobId)
	if mobId == 15953 then
		return true
	elseif mobId == 16505 or mobId == 16506 then
		return self:GetHealth(unit) == 100
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "WidowsEmbrace", 28732)
	self:Log("SPELL_AURA_APPLIED", "Enrage", 28798)
	self:Log("SPELL_AURA_REMOVED", "EnrageRemoved", 28798)

	self:Log("SPELL_AURA_APPLIED", "RainOfFireDamage", 28794)
	self:Log("SPELL_PERIODIC_DAMAGE", "RainOfFireDamage", 28794)
	self:Log("SPELL_PERIODIC_MISSED", "RainOfFireDamage", 28794)
	self:Log("SPELL_AURA_APPLIED", "Silence", 30225)
	self:Log("SPELL_CAST_SUCCESS", "PoisonBoltVolley", 28796)
end

function mod:OnEngage()
	frenzyTimer = GetTime()
	self:CDBar(28798, 55) -- Enrage
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:WidowsEmbrace(args)
	if self:MobId(args.destGUID) == 15953 then
		self:Message(args.spellId, "yellow")
		self:Bar(args.spellId, 30)
		self:PlaySound(args.spellId, "info")

		local currentTime = GetTime()
		if (frenzyTimer + 30) < currentTime then
			self:CDBar(28798, 31) -- Enrage
		end
	end
end

function mod:Enrage(args)
	frenzyTimer = GetTime()
	self:StopBar(args.spellName)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "warning")
end

function mod:EnrageRemoved(args)
	self:Message(args.spellId, "green", CL.removed:format(args.spellName))
	local elapsed = GetTime() - frenzyTimer
	if elapsed < 31 then
		self:CDBar(args.spellId, 60-elapsed)
	end
end

do
	local prev = 0
	function mod:RainOfFireDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "aboveyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:Silence(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
	end
end

function mod:PoisonBoltVolley(args)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "alert")
end
