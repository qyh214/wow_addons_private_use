--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Anub'Rekhan", 533, 1601)
if not mod then return end
mod:RegisterEnableMob(15956)
mod:SetEncounterID(1107)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local swarmCount = 1

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{28783, "SAY", "ME_ONLY_EMPHASIZE"}, -- Impale
		{28785, "CASTBAR"}, -- Locust Swarm
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Impale", 28783)
	self:Log("SPELL_CAST_START", "LocustSwarm", 28785)
	self:Log("SPELL_AURA_APPLIED", "LocustSwarmApplied", 28785)
	self:Log("SPELL_AURA_REMOVED", "LocustSwarmRemoved", 28785)
end

function mod:OnEngage()
	swarmCount = 1
	self:Message(28785, "yellow", CL.custom_start_s:format(self.displayName, self:SpellName(28785), 90), false)
	self:DelayedMessage(28785, 80, "orange", CL.custom_sec:format(self:SpellName(28785), 10))
	self:CDBar(28785, 90, CL.count:format(self:SpellName(28785), swarmCount)) -- Locust Swarm
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function printTarget(self, player, guid)
		self:TargetMessage(28783, "yellow", player)
		if self:Me(guid) then
			self:Say(28783, nil, nil, "Impale")
			self:PlaySound(28783, "warning", nil, player)
		else
			self:PlaySound(28783, "alert", nil, player)
		end
	end
	function mod:Impale(args)
		self:GetUnitTarget(printTarget, 0.3, args.sourceGUID)
	end
end

function mod:LocustSwarm(args)
	self:StopBar(CL.count:format(args.spellName, swarmCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, swarmCount))
	self:PlaySound(args.spellId, "long")
end

function mod:LocustSwarmApplied(args)
	swarmCount = swarmCount + 1
	self:CastBar(args.spellId, 20)
end

function mod:LocustSwarmRemoved(args)
	self:Message(args.spellId, "green", CL.over:format(args.spellName))
	self:CDBar(args.spellId, 65, CL.count:format(args.spellName, swarmCount)) -- Swings between 82s-102s between cast start, minus 20s duration
	self:DelayedMessage(args.spellId, 55, "red", CL.custom_sec:format(args.spellName, 10))
	self:PlaySound(args.spellId, "info")
end
