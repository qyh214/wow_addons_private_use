--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Firemaw", 469, 1532)
if not mod then return end
mod:RegisterEnableMob(11983)
mod:SetEncounterID(613)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		23339, -- Wing Buffet
		22539, -- Shadow Flame
		23341, -- Flame Buffet
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "WingBuffet", 23339)
	self:Log("SPELL_CAST_START", "ShadowFlame", 22539)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FlameBuffetApplied", 23341)
end

function mod:OnEngage()
	self:CDBar(23339, 29) -- Wing Buffet
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:WingBuffet(args)
	if self:MobId(args.sourceGUID) == 11983 then
		self:Message(args.spellId, "yellow")
		self:CDBar(args.spellId, 32)
		self:PlaySound(args.spellId, "info")
	end
end

function mod:ShadowFlame(args)
	if self:MobId(args.sourceGUID) == 11983 then
		self:Message(args.spellId, "red")
		self:PlaySound(args.spellId, "long")
	end
end

function mod:FlameBuffetApplied(args)
	if self:Me(args.destGUID) and args.amount >= 4 and args.amount % 2 == 0 then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 6)
		if args.amount >= 6 then
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
end
