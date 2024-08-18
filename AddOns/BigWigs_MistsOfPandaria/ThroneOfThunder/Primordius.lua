--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Primordius", 1098, 820)
if not mod then return end
mod:RegisterEnableMob(69017)

--------------------------------------------------------------------------------
-- Locals
--

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.mutations = "Mutations |cff008000(%d)|r |cffff0000(%d)|r"
	L.acidic_spines = "Acidic Spines (Splash Damage)"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-6969,
		136037, {136050, "TANK"}, 136216, {136218, "PROXIMITY"}, {136228, "ICON"}, 136245, {136246, "PROXIMITY"}, -7830, {-6960, "FLASH"},
		"berserk",
	}, {
		[-6969] = "heroic",
		[136037] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Log("SPELL_AURA_REMOVED", "PlayerMutations", 136184, 136186, 136182, 136180, 136185, 136187, 136183, 136181)
	self:Log("SPELL_AURA_APPLIED_DOSE", "PlayerMutations", 136184, 136186, 136182, 136180, 136185, 136187, 136183, 136181)
	self:Log("SPELL_AURA_APPLIED", "PlayerMutations", 136184, 136186, 136182, 136180, 136185, 136187, 136183, 136181)
	self:Log("SPELL_DISPEL", "PlayerMutations", 136184, 136186, 136182, 136180, 136185, 136187, 136183, 136181)
	self:Log("SPELL_AURA_REMOVED", "FullyMutatedRemoved", 140546)
	self:Log("SPELL_AURA_APPLIED", "FullyMutatedApplied", 140546)
	self:Log("SPELL_AURA_REMOVED", "EruptingPustulesRemoved", 136246)
	self:Log("SPELL_AURA_APPLIED", "EruptingPustulesApplied", 136246)
	self:Log("SPELL_AURA_REMOVED", "MetabolicBoost", 136245)
	self:Log("SPELL_AURA_APPLIED_DOSE", "MetabolicBoost", 136245) -- have not seen this event yet, but lets assume it exists
	self:Log("SPELL_AURA_APPLIED", "MetabolicBoost", 136245)
	self:Log("SPELL_AURA_REMOVED", "VolatilePathogenRemoved", 136228)
	self:Log("SPELL_AURA_APPLIED", "VolatilePathogen", 136228)
	self:Log("SPELL_AURA_REMOVED", "PathogenGlandsRemoved", 136225)
	self:Log("SPELL_CAST_SUCCESS", "PathogenGlands", 136225)
	self:Log("SPELL_AURA_REMOVED", "AcidicSpinesRemoved", 136218)
	self:Log("SPELL_AURA_APPLIED", "AcidicSpinesApplied", 136218)
	self:Log("SPELL_CAST_START", "CausticGas", 136216)
	self:Log("SPELL_CAST_SUCCESS", "PrimordialStrike", 136037)
	self:Log("SPELL_AURA_APPLIED_DOSE", "MalformedBlood", 136050)

	self:Death("Win", 69017)
end

function mod:OnEngage()
	self:Berserk(480) -- confirmed 25 N live
	self:Bar(136037, 18) -- Primordial Strike
	if self:Heroic() then
		self:Bar(-6969, 12, 137000) -- Viscous Horror
		self:ScheduleTimer("ViscousHorror", 12)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ViscousHorror()
	self:MessageOld(-6969, "yellow", nil, nil, 137000)
	self:Bar(-6969, 30, 137000)
	self:ScheduleTimer("ViscousHorror", 30)
end

do
	local scheduled = nil
	local theGood = { mod:SpellName(136184), mod:SpellName(136186), mod:SpellName(136182), mod:SpellName(136180) }
	local theBad  = { mod:SpellName(136185), mod:SpellName(136187), mod:SpellName(136183), mod:SpellName(136181) }
	local function warnPlayerMutations()
		local totalP, totalN = 0, 0
		for _, spell in next, theGood do
			local _, count = mod:UnitDebuff("player", spell,
				136184, -- diff 7
				136186, -- diff 7
				136182, -- diff 5
				136180 -- diff 5
			)
			totalP = totalP + (count or 0)
		end
		for _, spell in next, theBad do
			local _, count = mod:UnitDebuff("player", spell,
				136185, -- diff 5
				136181, -- diff 5
				136183 -- diff 5
			)
			totalN = totalN + (count or 0)
		end

		mod:MessageOld(-6960, "blue", (totalP > 3 or totalN > 0) and "info", L["mutations"]:format(totalP, totalN), 136184)
		if totalP == 5 then
			mod:Flash(-6960, 136184)
		end
		scheduled = nil
	end
	function mod:PlayerMutations(args)
		if self:Me(args.destGUID) and not scheduled then
			scheduled = self:ScheduleTimer(warnPlayerMutations, 1)
		end
	end
end

function mod:FullyMutatedRemoved(args)
	if self:Me(args.destGUID) then
		self:StopBar(args.spellId)
		self:MessageOld(-7830, "blue", "info", CL["over"]:format(args.spellName), args.spellId)
	end
end

function mod:FullyMutatedApplied(args)
	if self:Me(args.destGUID) then
		self:MessageOld(-7830, "blue", "info", CL["you"]:format(args.spellName), args.spellId)
		self:Bar(-7830, 120, args.spellId)
	end
end

function mod:EruptingPustulesRemoved(args)
	if not self:UnitBuff("boss1", self:SpellName(136218)) then -- Acidic Spines
		self:CloseProximity(args.spellId)
	end
end

function mod:EruptingPustulesApplied(args)
	if not self:UnitBuff("boss1", self:SpellName(136218)) then -- Acidic Spines
		self:OpenProximity(args.spellId, 2)
	end
	self:MessageOld(args.spellId, "yellow")
end

function mod:MetabolicBoost(args)
	self:MessageOld(args.spellId, "yellow")
end

function mod:VolatilePathogenRemoved(args)
	self:PrimaryIcon(args.spellId)
	self:StopBar(args.spellId, args.destName)
end

function mod:VolatilePathogen(args)
	self:PrimaryIcon(args.spellId, args.destName)
	self:TargetMessageOld(args.spellId, args.destName, "orange", "alarm", nil, nil, self:Healer() and true)
	self:Bar(args.spellId, 30)
	if self:Healer() then
		self:TargetBar(args.spellId, 10, args.destName)
	end
end

function mod:PathogenGlandsRemoved(args)
	self:StopBar(136228)
	self:MessageOld(136228, "green", "alert", CL["over"]:format(self:SpellName(136228)))
end

function mod:PathogenGlands(args)
	self:MessageOld(136228, "red", "long", CL["incoming"]:format(self:SpellName(136228)))
end

function mod:AcidicSpinesRemoved(args)
	self:MessageOld(args.spellId, "green", "alert", CL["over"]:format(args.spellName))
	self:CloseProximity(args.spellId)
	if self:UnitBuff("boss1", self:SpellName(136246), 136246) then -- Erupting Pustules, difficulty 7
		self:OpenProximity(136246, 2)
	end
end

function mod:AcidicSpinesApplied(args)
	self:OpenProximity(args.spellId, 5)
	self:MessageOld(args.spellId, "red", "long") --, L["acidic_spines"]
end

function mod:CausticGas(args)
	self:MessageOld(args.spellId, "orange")
	self:Bar(args.spellId, 12)
end

function mod:PrimordialStrike(args)
	self:MessageOld(args.spellId, "yellow")
	self:Bar(args.spellId, 19)
end

function mod:MalformedBlood(args)
	-- 9s cooldown (6s with Metabolic Boost)
	if args.amount % 2 == 0 then
		self:StackMessageOld(args.spellId, args.destName, args.amount, "yellow", args.amount > 5 and "warning")
	end
end

