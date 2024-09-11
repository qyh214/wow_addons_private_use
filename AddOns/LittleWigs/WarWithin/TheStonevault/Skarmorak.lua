--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Skarmorak", 2652, 2579)
if not mod then return end
mod:RegisterEnableMob(210156) -- Skarmorak
mod:SetEncounterID(2880)
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local fortifiedShellCount = 1

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		422233, -- Crystalline Smash
		423200, -- Fortified Shell
		423538, -- Unstable Crash
		-- Mythic
		423572, -- Unstable Energy
	}, {
		[423572] = CL.mythic,
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "CrystallineSmash", 422233)
	self:Log("SPELL_CAST_START", "FortifiedShell", 423200)
	self:Log("SPELL_AURA_APPLIED", "FortifiedShellApplied", 423228)
	self:Log("SPELL_AURA_REMOVED", "FortifiedShellRemoved", 423228)
	self:Log("SPELL_CAST_START", "UnstableCrash", 423538)

	-- Mythic
	self:Log("SPELL_AURA_APPLIED", "UnstableEnergyApplied", 423572)
	self:Log("SPELL_AURA_APPLIED_DOSE", "UnstableEnergyApplied", 423572)
	self:Log("SPELL_AURA_REFRESH", "UnstableEnergyRefresh", 423572)
	self:Log("SPELL_AURA_REMOVED", "UnstableEnergyRemoved", 423572)
end

function mod:OnEngage()
	fortifiedShellCount = 1
	self:SetStage(1)
	self:CDBar(422233, 3.9) -- Crystalline Smash
	self:CDBar(423538, 10.9) -- Unstable Crash
	self:CDBar(423200, 37.5, CL.count:format(self:SpellName(423200), fortifiedShellCount)) -- Fortified Shell
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CrystallineSmash(args)
	self:Message(args.spellId, "purple")
	self:CDBar(args.spellId, 16.6)
	self:PlaySound(args.spellId, "alert")
end

function mod:FortifiedShell(args)
	self:StopBar(422233) -- Crystalline Smash
	self:StopBar(423538) -- Unstable Crash
	self:StopBar(CL.count:format(args.spellName, fortifiedShellCount))
	self:SetStage(2)
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, fortifiedShellCount))
	self:PlaySound(args.spellId, "long")
	fortifiedShellCount = fortifiedShellCount + 1
end

do
	local fortifiedShellStart = 0

	function mod:FortifiedShellApplied(args)
		fortifiedShellStart = args.time
	end

	function mod:FortifiedShellRemoved(args)
		local fortifiedShellDuration = args.time - fortifiedShellStart
		self:SetStage(1)
		self:Message(423200, "green", CL.removed_after:format(args.spellName, fortifiedShellDuration)) -- Fortified Shell
		self:CDBar(422233, 6.9) -- Crystalline Smash
		self:CDBar(423538, 14.2) -- Unstable Crash
		self:CDBar(423200, 40.9, CL.count:format(self:SpellName(423200), fortifiedShellCount)) -- Fortified Shell
		self:PlaySound(423200, "info") -- Fortified Shell
	end
end

function mod:UnstableCrash(args)
	self:Message(args.spellId, "orange")
	self:CDBar(args.spellId, 19.4)
	self:PlaySound(args.spellId, "alarm")
end

-- Mythic

function mod:UnstableEnergyApplied(args)
	if self:Me(args.destGUID) then
		-- not using StackMessage in order to preserve message color, since alerts are just for the player
		self:Message(args.spellId, "green", CL.stackyou:format(args.amount or 1, args.spellName))
		self:PlaySound(args.spellId, "info", nil, args.destName)
		self:TargetBar(args.spellId, 30, args.destName)
	end
end

function mod:UnstableEnergyRefresh(args)
	if self:Me(args.destGUID) then
		self:TargetBar(args.spellId, 30, args.destName)
	end
end

function mod:UnstableEnergyRemoved(args)
	if self:Me(args.destGUID) then
		self:StopBar(args.spellName, args.destName)
	end
end
