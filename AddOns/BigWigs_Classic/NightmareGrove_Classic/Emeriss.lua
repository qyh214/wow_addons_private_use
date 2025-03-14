--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Emeriss Season of Discovery", 2832)
if not mod then return end
mod:RegisterEnableMob(234880)
mod:SetEncounterID(3111)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local warnHP = 80

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Emeriss"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{1213155, "ICON"}, -- Volatile Infection
		24910, -- Corruption of the Earth
		1213169, -- Spore Cloud
		-- Shared
		1213170, -- Noxious Breath
		24814, -- Seeping Fog
	},{
		[1213170] = CL.general,
	},{
		[1213170] = CL.breath, -- Noxious Breath (Breath)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "NoxiousBreath", 1213170)
	self:Log("SPELL_AURA_APPLIED", "NoxiousBreathApplied", 1213170)
	self:Log("SPELL_AURA_APPLIED_DOSE", "NoxiousBreathApplied", 1213170)
	self:Log("SPELL_CAST_SUCCESS", "SeepingFog", 24814)
	self:Log("SPELL_AURA_APPLIED", "VolatileInfection", 1213155)
	self:Log("SPELL_CAST_SUCCESS", "CorruptionOfTheEarth", 24910)
	self:Log("SPELL_AURA_APPLIED", "SporeCloudDamage", 1213169)
	self:Log("SPELL_PERIODIC_DAMAGE", "SporeCloudDamage", 1213169)
	self:Log("SPELL_PERIODIC_MISSED", "SporeCloudDamage", 1213169)
end

function mod:OnEngage()
	warnHP = 80
	self:RegisterEvent("UNIT_HEALTH")
	self:Message(1213170, "yellow", CL.custom_start_s:format(self.displayName, CL.breath, 10), false)
	self:Bar(1213170, 10, CL.breath) -- Noxious Breath
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:NoxiousBreath(args)
	self:Bar(args.spellId, 10, CL.breath)
end

function mod:NoxiousBreathApplied(args)
	local unit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID, true)
	if unit and targetUnit and self:Tanking(unit, targetUnit) then
		self:StackMessage(args.spellId, "purple", args.destName, args.amount, 4, CL.breath)
		if args.amount >= 4 then
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
end

do
	local prev = 0
	function mod:SeepingFog(args)
		if args.time-prev > 2 then
			prev = args.time
			self:Message(args.spellId, "green")
			self:PlaySound(args.spellId, "info")
			-- self:CDBar(24818, 20)
		end
	end
end

function mod:VolatileInfection(args)
	self:TargetMessage(args.spellId, "orange", args.destName)
	self:PrimaryIcon(args.spellId, args.destName)
	self:PlaySound(args.spellId, "alert", nil, args.destName)
end

function mod:CorruptionOfTheEarth(args)
	self:Message(args.spellId, "red")
	self:Bar(args.spellId, 10)
	self:PlaySound(args.spellId, "long")
end

do
	local prev = 0
	function mod:SporeCloudDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 234880 then
		local hp = self:GetHealth(unit)
		if hp < warnHP then -- 80, 55, 30
			warnHP = warnHP - 25
			if hp > warnHP then -- avoid multiple messages when joining mid-fight
				self:Message(24910, "red", CL.soon:format(self:SpellName(24910)), false) -- Corruption of the Earth
				self:PlaySound(24910, "alarm")
			end
			if warnHP < 30 then
				self:UnregisterEvent(event)
			end
		end
	end
end
