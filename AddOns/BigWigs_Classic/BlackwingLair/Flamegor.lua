--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Flamegor", 469, 1534)
if not mod then return end
mod:RegisterEnableMob(11981)
mod:SetEncounterID(615)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		23339, -- Wing Buffet
		22539, -- Shadow Flame
		23342, -- Enrage / Frenzy (different name on classic era)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "WingBuffet", 23339)
	self:Log("SPELL_CAST_START", "ShadowFlame", 22539)
	self:Log("SPELL_AURA_APPLIED", "EnrageFrenzy", 23342)
	self:Log("SPELL_DISPEL", "EnrageFrenzyDispelled", "*")
end

function mod:OnEngage()
	self:CDBar(23339, 29) -- Wing Buffet
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:WingBuffet(args)
	if self:MobId(args.sourceGUID) == 11981 then
		self:Message(args.spellId, "yellow")
		self:CDBar(args.spellId, 32)
		self:PlaySound(args.spellId, "info")
	end
end

function mod:ShadowFlame(args)
	if self:MobId(args.sourceGUID) == 11981 then
		self:Message(args.spellId, "red")
		self:PlaySound(args.spellId, "long")
	end
end

function mod:EnrageFrenzy(args)
	self:Message(args.spellId, "orange", CL.buff_boss:format(args.spellName))
	self:TargetBar(args.spellId, 10, args.destName)
	self:PlaySound(args.spellId, "alarm")
end

function mod:EnrageFrenzyDispelled(args)
	if args.extraSpellName == self:SpellName(23342) then
		self:StopBar(args.extraSpellName, args.destName)
		self:Message(23342, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end
