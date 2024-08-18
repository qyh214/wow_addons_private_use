--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Grand Widow Faerlina", 533, 1602)
if not mod then return end
mod:RegisterEnableMob(15953, 16505, 16506) -- Faerlina, Follower, Worshipper
mod:SetEncounterID(1110)
-- mod:SetRespawnTime(0) -- resets, doesn't respawn

--------------------------------------------------------------------------------
-- Locals
--

local frenzied = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.silencewarn = "Silenced!"
	L.silencewarn5sec = "Silence ends in 5 sec"
	L.silence = "Silence"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		28732, -- Widow's Embrace
		{28794, "FLASH"}, -- Rain of Fire
		28798, -- Frenzy
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "WidowsEmbrace", 28732, 54097)
	self:Log("SPELL_AURA_APPLIED", "RainOfFire", 28794, 54099)
	self:Log("SPELL_AURA_APPLIED", "Frenzy", 28798, 54100)
end

function mod:OnEngage()
	frenzied = nil
	self:Message(28798, "yellow", CL.custom_start_s:format(self.displayName, self:SpellName(28798), 60), false)
	self:DelayedMessage(28798, 50, "red", CL.soon:format(self:SpellName(28798)))
	self:CDBar(28798, 60) -- Frenzy
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:WidowsEmbrace(args)
	if self:MobId(args.destGUID) ~= 15953 then return end

	if not frenzied then
		-- preemptive, 30s silence
		self:Message(28732, "green", L.silencewarn)
		self:Bar(28732, 30, L.silence)
		self:PlaySound(28732, "info")
		self:DelayedMessage(28732, 25, "orange", L.silencewarn5sec)
	else
		-- Reactive enrage removed
		self:Message(28798, "green", CL.removed:format(self:SpellName(28798)))
		self:PlaySound(28732, "info")
		self:DelayedMessage(28798, 50, "red", CL.soon:format(self:SpellName(28798)))
		self:CDBar(28798, 60)

		self:Bar(28732, 30, L.silence)
		self:DelayedMessage(28732, 25, "orange", L.silencewarn5sec)
		frenzied = nil
	end
end

function mod:RainOfFire(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(28794)
		self:PlaySound(28794, "underyou")
		self:Flash(28794)
	end
end

function mod:Frenzy(args)
	if self:MobId(args.destGUID) ~= 15953 then return end

	self:StopBar(28798)
	self:CancelDelayedMessage(CL.soon:format(self:SpellName(28798)))

	frenzied = true
	self:Message(28798, "orange")
	self:PlaySound(28798, "warning")
end

