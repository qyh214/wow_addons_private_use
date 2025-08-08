--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Hakkar", 309)
if not mod then return end
mod:RegisterEnableMob(14834)
mod:SetEncounterID(793)
mod:SetRespawnTime(15)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local DelayBloodSiphon

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Hakkar"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{24324, "COUNTDOWN"}, -- Blood Siphon
		{24327, "ICON", "SAY", "SAY_COUNTDOWN"}, -- Cause Insanity
		"berserk",
	},nil,{
		[24327] = CL.mind_control, -- Cause Insanity (Mind Control)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "BloodSiphon", 24324)
	self:Log("SPELL_CAST_SUCCESS", "CauseInsanity", 24327)
	self:Log("SPELL_AURA_APPLIED", "CauseInsanityApplied", 24327)
	self:Log("SPELL_AURA_REMOVED", "CauseInsanityRemoved", 24327)
end

function mod:OnEngage()
	self:Berserk(600)

	self:Bar(24327, 20, CL.mind_control) -- Cause Insanity
	self:Bar(24324, 90) -- Blood Siphon
	self:ScheduleTimer(DelayBloodSiphon, 80)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	do
		local msg = CL.custom_sec:format(mod:SpellName(24324), 10)
		function DelayBloodSiphon()
			mod:Message(24324, "orange", msg)
			mod:PlaySound(24324, "alarm")
		end
	end

	function mod:BloodSiphon(args)
		self:Message(args.spellId, "red")
		self:Bar(args.spellId, 90)
		self:ScheduleTimer(DelayBloodSiphon, 80)
		self:PlaySound(args.spellId, "long")
	end
end

function mod:CauseInsanity(args)
	self:CDBar(args.spellId, 20, CL.mind_control)
end

function mod:CauseInsanityApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.mind_control)
	self:TargetBar(args.spellId, 10, args.destName, CL.mind_control_short)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, CL.mind_control, nil, "Mind Control")
		self:SayCountdown(args.spellId, 10, 8, 6)
	end
	self:PlaySound(args.spellId, "info", nil, args.destName)
end

function mod:CauseInsanityRemoved(args)
	self:StopBar(CL.mind_control_short, args.destName)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
	self:PrimaryIcon(args.spellId)
end
