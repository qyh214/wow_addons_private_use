--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Moam", 509, 1539)
if not mod then return end
mod:RegisterEnableMob(15340)
mod:SetEncounterID(720)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{25685, "CASTBAR"}, -- Energize
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Energize", 25685)
	self:Log("SPELL_AURA_REMOVED", "EnergizeRemoved", 25685)
end

function mod:OnEngage()
	self:Message(25685, "yellow", CL.custom_start_s:format(self.displayName, self:SpellName(25685), 90), false)
	self:Bar(25685, 90) -- Energize
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Energize(args)
	-- Adds spawned
	self:Message(args.spellId, "red")
	local duration = 90
	-- Need to find the mana regen rate because he comes back at 100% regardless
	-- local unit = self:GetUnitIdByGUID(args.sourceGUID)
	-- if unit then
	-- 	duration = math.min(90, (100 - UnitPower(unit)) / mps)
	-- end
	self:CastBar(args.spellId, duration)
	self:PlaySound(args.spellId, "long")
end

function mod:EnergizeRemoved(args)
	self:StopBar(CL.cast:format(args.spellName))

	self:Message(args.spellId, "yellow", CL.over:format(args.spellName))
	self:Bar(args.spellId, 90)
	self:PlaySound(args.spellId, "long")
end
