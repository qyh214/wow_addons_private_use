--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Balnazzar Scarlet Enclave", 2856)
if not mod then return end
mod:RegisterEnableMob(240811)
mod:SetEncounterID(3185)
mod:SetRespawnTime(10)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local carrionOnMe = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Balnazzar"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- Balnazzar
		1231837, -- Carrion Swarm
		{1231844, "ME_ONLY", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Circle of Domination
		1231901, -- Summon Infernal
		"stages",
		"berserk",
		-- Screeching Terror
		{1231885, "NAMEPLATE"}, -- Screeching Fear
	},{
		[1231837] = L.bossName, -- Balnazzar
		[1231885] = 1231842, -- Screeching Terror
	},{
		[1231844] = CL.mind_control, -- Circle of Domination (Mind Control)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:VerifyEnable(unit)
	return self:GetHealth(unit) > 8
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "LightsHopeOrSuppressingDarkness", 1232177, 1231776) -- Light's Hope, Suppressing Darkness
	self:Log("SPELL_CAST_SUCCESS", "SummonInfernal", 1231901)
	self:Log("SPELL_CAST_START", "CarrionSwarm", 1231840)
	self:Log("SPELL_AURA_APPLIED", "CarrionSwarmApplied", 1231837)
	self:Log("SPELL_AURA_REFRESH", "CarrionSwarmApplied", 1231837)
	self:Log("SPELL_AURA_APPLIED", "CircleOfDominationApplied", 1231844)
	self:Log("SPELL_CAST_START", "ScreechingFear", 1231885)
	self:Death("ScreechingTerrorDeath", 243007)
end

function mod:OnEngage()
	carrionOnMe = false
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:CDBar(1231837, 9.5) -- Carrion Swarm
	self:Berserk(600, true) -- No engage message
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:LightsHopeOrSuppressingDarkness() -- Light's Hope or Suppressing Darkness, whichever comes first
	if self:GetStage() == 1 then
		self:StopBar(1231837) -- Carrion Swarm
		self:SetStage(2)
		self:Message("stages", "cyan", CL.percent:format(70, CL.stage:format(2)), false)
		self:PlaySound("stages", "long")
	end
end

function mod:SummonInfernal(args)
	self:CDBar(args.spellId, 21)
	if self:GetStage() < 3 then
		self:SetStage(3)
		self:Message("stages", "cyan", CL.percent:format(40, CL.stage:format(3)), false)
		self:CDBar(1231837, 27) -- Carrion Swarm
		self:PlaySound("stages", "long")
	else
		self:Message(args.spellId, "yellow")
		self:PlaySound(args.spellId, "info")
	end
end

function mod:CarrionSwarm(args)
	self:Message(1231837, "red", CL.incoming:format(args.spellName))
	self:CDBar(1231837, 32.4)
	self:PlaySound(1231837, "alert")
end

function mod:CarrionSwarmApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
	end
end

function mod:CircleOfDominationApplied(args)
	self:TargetMessage(args.spellId, "red", args.destName, CL.mind_control)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, CL.mind_control, nil, "Mind Control")
		self:SayCountdown(args.spellId, 6)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:ScreechingFear(args)
	self:Nameplate(args.spellId, 11.3, args.sourceGUID)
end

function mod:ScreechingTerrorDeath(args)
	self:StopNameplate(1231885, args.destGUID)
end
