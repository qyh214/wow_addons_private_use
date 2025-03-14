--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ebonroc", 469, 1533)
if not mod then return end
mod:RegisterEnableMob(14601)
mod:SetEncounterID(614)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		23339, -- Wing Buffet
		22539, -- Shadow Flame
		23340, -- Shadow of Ebonroc
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			22539, -- Shadow Flame
			23340, -- Shadow of Ebonroc
			368515, -- Brand of Shadow
		}
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "ShadowFlame", 22539)
	self:Log("SPELL_AURA_APPLIED", "ShadowOfEbonrocApplied", 23340)
	self:Log("SPELL_AURA_REMOVED", "ShadowOfEbonrocRemoved", 23340)
	if self:GetSeason() == 2 then
		self:Log("SPELL_CAST_START", "ShadowFlameSoD", 368942)
		self:Log("SPELL_AURA_APPLIED_DOSE", "BrandOfShadowApplied", 368515)
	else
		self:Log("SPELL_CAST_START", "WingBuffet", 23339)
	end
end

function mod:OnEngage()
	if self:GetSeason() ~= 2 then
		self:CDBar(23339, 29) -- Wing Buffet
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:WingBuffet(args)
	if self:MobId(args.sourceGUID) == 14601 then
		self:Message(args.spellId, "yellow")
		self:CDBar(args.spellId, 32)
		self:PlaySound(args.spellId, "info")
	end
end

function mod:ShadowFlame(args)
	if self:MobId(args.sourceGUID) == 14601 then
		self:Message(args.spellId, "red")
		self:PlaySound(args.spellId, "long")
	end
end

function mod:ShadowFlameSoD(args)
	if self:MobId(args.sourceGUID) == 14601 then
		local unit = self:GetUnitIdByGUID(args.sourceGUID)
		if not unit or self:UnitWithinRange(unit, 35) or args.sourceGUID == self:UnitGUID("target") then
			self:Message(22539, "red")
			self:PlaySound(22539, "long")
		end
	end
end

function mod:ShadowOfEbonrocApplied(args)
	self:TargetMessage(args.spellId, "orange", args.destName)
	self:TargetBar(args.spellId, 8, args.destName)
	self:PlaySound(args.spellId, "alarm")
end

function mod:ShadowOfEbonrocRemoved(args)
	self:StopBar(args.spellName, args.destName)
end

function mod:BrandOfShadowApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 3)
		if args.amount >= 3 then
			self:PlaySound(args.spellId, "alert", nil, args.destName)
		end
	end
end
