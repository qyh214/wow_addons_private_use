--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Taerar Season of Discovery", 2832)
if not mod then return end
mod:RegisterEnableMob(235197)
mod:SetEncounterID(3113)
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
	L.bossName = "Taerar"

	L["1214028_icon"] = "spell_shadow_psychicscream"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		1214028, -- Bellowing Roar
		1214008, -- Summon Shade of Taerar
		-- Shared
		24818, -- Noxious Breath
		24814, -- Seeping Fog
	},{
		[24818] = CL.general,
	},{
		[1214028] = CL.fear, -- Bellowing Roar (Fear)
		[1214008] = CL.adds, -- Summon Shade of Taerar (Adds)
		[24818] = CL.breath, -- Noxious Breath (Breath)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "NoxiousBreath", 24818)
	self:Log("SPELL_AURA_APPLIED", "NoxiousBreathApplied", 24818)
	self:Log("SPELL_AURA_APPLIED_DOSE", "NoxiousBreathApplied", 24818)
	self:Log("SPELL_CAST_SUCCESS", "SeepingFog", 24814)
	self:Log("SPELL_CAST_START", "BellowingRoar", 1214028)
	self:Log("SPELL_CAST_SUCCESS", "SummonShadeOfTaerar", 1214008)
end

function mod:OnEngage()
	warnHP = 80
	self:RegisterEvent("UNIT_HEALTH")
	self:Message(24818, "yellow", CL.custom_start_s:format(self.displayName, CL.breath, 10), false)
	self:Bar(24818, 10, CL.breath) -- Noxious Breath
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

function mod:BellowingRoar(args)
	self:Message(args.spellId, "orange", CL.incoming:format(CL.fear), L["1214028_icon"])
	self:Bar(args.spellId, 30, CL.fear, L["1214028_icon"])
end

function mod:SummonShadeOfTaerar(args)
	self:Message(args.spellId, "cyan", CL.incoming:format(CL.adds), false)
	self:PlaySound(args.spellId, "long")
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 235197 then
		local hp = self:GetHealth(unit)
		if hp < warnHP then -- 80, 55, 30
			warnHP = warnHP - 25
			if hp > warnHP then -- avoid multiple messages when joining mid-fight
				self:Message(1214008, "cyan", CL.soon:format(CL.adds), false)
			end
			if warnHP < 30 then
				self:UnregisterEvent(event)
			end
		end
	end
end
