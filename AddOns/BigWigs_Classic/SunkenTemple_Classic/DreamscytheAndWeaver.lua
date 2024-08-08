--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Dreamscythe and Weaver Discovery", 109)
if not mod then return end
mod:RegisterEnableMob(220833, 220864) -- Dreamscythe, Weaver
mod:SetEncounterID(2955)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Dreamscythe and Weaver"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		442622, -- Acid Breath
		{443766, "CASTBAR"}, -- Wing Buffet
		443856, -- Caustic Overflow
	},nil,{
		[443766] = CL.knockback, -- Wing Buffet (Knockback)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "AcidBreathApplied", 442622)
	self:Log("SPELL_AURA_APPLIED_DOSE", "AcidBreathApplied", 442622)
	self:Log("SPELL_CAST_START", "WingBuffet", 443766, 443793) -- Both directions
	self:Log("SPELL_CAST_START", "DelayedWingBuffet", 443830, 443827) -- Both directions
	self:Log("SPELL_AURA_APPLIED", "EmeraldWardApplied", 443302)
	self:Log("SPELL_AURA_REMOVED", "EmeraldWardRemoved", 443302)
	self:Log("SPELL_AURA_APPLIED", "CausticOverflowDamage", 443856)
	self:Log("SPELL_PERIODIC_DAMAGE", "CausticOverflowDamage", 443856)
	self:Log("SPELL_PERIODIC_MISSED", "CausticOverflowDamage", 443856)
end

function mod:OnEngage()
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:AcidBreathApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 2)
		if args.amount then
			self:PlaySound(args.spellId, "alert")
		end
	else
		local bossUnit = self:GetUnitIdByGUID(args.sourceGUID)
		if bossUnit and self:Tanking(bossUnit, args.destName) then
			self:StackMessage(args.spellId, "purple", args.destName, args.amount, 2)
			if args.amount then
				self:PlaySound(args.spellId, "alert")
			end
		end
	end
end

function mod:WingBuffet()
	self:Message(443766, "yellow", CL.knockback)
	if self:GetStage() < 3 then
		self:CastBar(443766, 2, CL.knockback)
	else
		self:CastBar(443766, 2, CL.count:format(CL.knockback, 1))
	end
	self:PlaySound(443766, "info")
end

function mod:DelayedWingBuffet()
	if self:GetStage() < 3 then
		self:Message(443766, "yellow", CL.knockback)
		self:CastBar(443766, 3.5, CL.knockback)
		self:PlaySound(443766, "info")
	else
		self:CastBar(443766, 3.5, CL.count:format(CL.knockback, 2))
	end
end

function mod:EmeraldWardApplied(args)
	if self:MobId(args.destGUID) == 220833 then -- Dreamscythe
		self:SetStage(2)
		self:Message("stages", "cyan", CL.percent:format(80, CL.stage:format(2)), false)
		self:PlaySound("stages", "long")
	end
end

function mod:EmeraldWardRemoved(args)
	if self:MobId(args.destGUID) == 220833 then -- Dreamscythe
		self:SetStage(3)
		self:Message("stages", "cyan", CL.percent:format(60, CL.stage:format(3)), false)
		self:PlaySound("stages", "long")
	end
end

do
	local prev = 0
	function mod:CausticOverflowDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 6 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
