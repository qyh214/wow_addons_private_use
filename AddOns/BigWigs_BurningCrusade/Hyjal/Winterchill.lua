--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Rage Winterchill", 534, 1577)
if not mod then return end
mod:RegisterEnableMob(17767)
if mod:Classic() then
	mod:SetEncounterID(620)
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{31258, "FLASH"}, {31249, "ICON"}, "berserk"
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Icebolt", 31249)
	self:Log("SPELL_AURA_APPLIED", "DeathAndDecay", 31258)

	if self:Classic() then
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	else
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	end
	self:Death("Win", 17767)
end

function mod:OnEngage()
	self:Berserk(600)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Icebolt(args)
	self:TargetMessageOld(args.spellId, args.destName, "red", "alert")
	self:PrimaryIcon(args.spellId, args.destName)
end

function mod:DeathAndDecay(args)
	if self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "blue", "alarm")
		self:Flash(args.spellId)
	end
end

