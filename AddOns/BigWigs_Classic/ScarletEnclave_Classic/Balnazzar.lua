--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Balnazzar", 2856)
if not mod then return end
mod:RegisterEnableMob(240811)
mod:SetEncounterID(3185)
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
		{1231837, "SAY", "ME_ONLY_EMPHASIZE"}, -- Carrion Swarm
		{1231844, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Circle of Domination
		1231901, -- Summon Infernal
		"stages",
		"berserk",
	},nil,{
		[1231844] = CL.mind_control, -- Circle of Domination (Mind Control)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "SuppressingDarkness", 1231776)
	self:Log("SPELL_CAST_SUCCESS", "SummonInfernal", 1231901)
	self:Log("SPELL_CAST_START", "CarrionSwarm", 1231840)
	self:Log("SPELL_AURA_APPLIED", "CarrionSwarmApplied", 1231837)
	self:Log("SPELL_AURA_REMOVED", "CarrionSwarmRemoved", 1231837)
	self:Log("SPELL_AURA_APPLIED", "CircleOfDominationApplied", 1231844)
end

function mod:OnEngage()
	carrionOnMe = false
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:CDBar(1231837, 9.5) -- Carrion Swarm
	self:Berserk(480, true) -- No engage message
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:SuppressingDarkness()
	self:StopBar(1231837) -- Carrion Swarm
	self:SetStage(2)
	self:Message("stages", "cyan", CL.percent:format(70, CL.stage:format(2)), false)
	self:PlaySound("stages", "long")
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
	end
end

function mod:CarrionSwarm(args)
	self:Message(1231837, "red", CL.incoming:format(args.spellName))
	self:CDBar(1231837, 32.4)
	self:PlaySound(1231837, "alert")
end

do
	local function RepeatCarrionSwarmSay()
		if not mod:IsEngaged() or not carrionOnMe then return end
		mod:SimpleTimer(RepeatCarrionSwarmSay, 4)
		mod:Say(1231837, nil, nil, "Carrion Swarm")
	end

	function mod:CarrionSwarmApplied(args)
		self:TargetMessage(args.spellId, "orange", args.destName)
		if self:Me(args.destGUID) then
			carrionOnMe = true
			self:Say(args.spellId, nil, nil, "Carrion Swarm")
			self:SimpleTimer(RepeatCarrionSwarmSay, 4)
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
end

function mod:CarrionSwarmRemoved(args)
	if self:Me(args.destGUID) then
		carrionOnMe = false
	end
end

function mod:CircleOfDominationApplied(args)
	self:TargetMessage(args.spellId, "red", args.destName, CL.mind_control)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, CL.mind_control, nil, "Mind Control")
		self:SayCountdown(args.spellId, 6)
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end
