--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Broodlord Lashlayer", 469, 1531)
if not mod then return end
mod:RegisterEnableMob(12017)
mod:SetEncounterID(612)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{24573, "ICON"}, -- Mortal Strike
		23331, -- Blast Wave
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "MortalStrike", 24573)
	self:Log("SPELL_AURA_REMOVED", "MortalStrikeOver", 24573)
	self:Log("SPELL_CAST_SUCCESS", "BlastWave", 23331)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MortalStrike(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:PrimaryIcon(args.spellId, args.destName)
	self:TargetBar(args.spellId, 5, args.destName)
	self:PlaySound(args.spellId, "long")
end

function mod:MortalStrikeOver(args)
	self:StopBar(args.spellName, args.destName)
	self:PrimaryIcon(args.spellId)
end

function mod:BlastWave(args)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "info")
end
