
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Elegon", 1008, 726)
if not mod then return end
mod:RegisterEnableMob(60410)

--------------------------------------------------------------------------------
-- Locals
--

local drawPowerCounter, annihilateCounter = 0, 0
local phaseCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_yell = "Entering defensive mode.  Disabling output failsafes."

	L.last_phase = "Last Phase"
	L.overcharged_total_annihilation = "Overcharge %d! A bit much?"

	L.floor = "Floor Despawn"
	L.floor_desc = "Warnings for when the floor is about to despawn."
	L.floor_icon = "ability_vehicle_launchplayer"
	L.floor_message = "The floor is falling!"

	L.adds = "Adds"
	L.adds_desc = "Warnings for when a Celestial Protector is about to spawn."
	L.adds_icon = 117954
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		117960, "adds", -6186, {117878, "FLASH"},
		119360,
		{"floor", "FLASH", "EMPHASIZE", "COUNTDOWN"},
		"stages", "berserk",
	}, {
		[117960] = -6174,
		[119360] = -6175,
		["floor"] = -6176,
		stages = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Overcharged", 117878)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Overcharged", 117878)
	self:Log("SPELL_AURA_APPLIED", "StabilityFlux", 117911)
	self:Log("SPELL_CAST_START", "CelestialBreath", 117960)
	self:Log("SPELL_CAST_START", "TotalAnnihilation", 129711)
	self:Log("SPELL_CAST_START", "MaterializeProtector", 117954)
	self:Log("SPELL_AURA_REMOVED", "UnstableEnergyRemoved", 116994)
	self:Log("SPELL_AURA_APPLIED", "DrawPower", 119387)
	self:Log("SPELL_AURA_APPLIED_DOSE", "DrawPower", 119387)
	self:Log("SPELL_CAST_SUCCESS", "Phase2", 124967)

	self:Log("SPELL_DAMAGE", "StabilityFluxDamage", 117912)
	self:Log("SPELL_MISSED", "StabilityFluxDamage", 117912)

	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "FloorRemoved", "boss1")
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 60410)
end

function mod:OnEngage()
	self:Bar(117960, 8.5) -- Celestial Breath
	self:Bar("adds", 12, CL["next_add"], L.adds_icon)
	self:Berserk(570)
	drawPowerCounter, annihilateCounter = 0, 0
	phaseCount = 0
	self:RegisterUnitEvent("UNIT_HEALTH", "PhaseWarn", "boss1")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:FloorRemoved(_, _, _, spellId)
	-- Trigger Phase A when the spark hits the conduit
	if spellId == 118189 then
		self:Bar("floor", 6, L["floor"], L.floor_icon)
		self:MessageOld("floor", "blue", "alarm", L["floor_message"], L.floor_icon)
		self:Flash("floor", L.floor_icon)
	end
end

function mod:Overcharged(args)
	if self:Me(args.destGUID) and InCombatLockdown() then
		if (args.amount or 1) >= 6 and args.amount % 2 == 0 then
			self:MessageOld(args.spellId, "blue", nil, CL["count"]:format(args.spellName, args.amount))
		end
	end
end

function mod:DrawPower(args)
	drawPowerCounter = drawPowerCounter + 1
	self:MessageOld(119360, "yellow", nil, CL["count"]:format(args.spellName, drawPowerCounter))
end

function mod:Phase2()
	self:StopBar(CL["next_add"]) -- Materialize Protector
	self:StopBar(117960) -- Celestial Breath
	self:MessageOld("stages", "green", nil, CL["phase"]:format(2), false)
end

function mod:CelestialBreath(args)
	self:Bar(args.spellId, 18)
end

do
	local overcharged = mod:SpellName(117878)
	function mod:StabilityFlux(args)
		-- this gives an 1 sec warning before damage
		local playerOvercharged, stack = self:UnitDebuff("player", overcharged)
		local hc = self:Heroic()
		if playerOvercharged and ((hc and stack > 9) or (not hc and stack > 14)) then
			self:Flash(117878)
			self:MessageOld(117878, "blue", nil, L["overcharged_total_annihilation"]:format(stack)) -- needs no sound since total StabilityFlux has one already
		end
	end
	-- This will spam, but it is apparantly needed for some people
	local prev = 0
	function mod:StabilityFluxDamage(args)
		local playerOvercharged, stack = self:UnitDebuff("player", overcharged)
		local hc = self:Heroic()
		if playerOvercharged and ((hc and stack > 9) or (not hc and stack > 14)) then
			local t = GetTime()
			if t-prev > 1 then --getting like 30 messages a second was *glasses* a bit much
				prev = t
				self:Flash(117878)
				self:MessageOld(117878, "blue", "info", L["overcharged_total_annihilation"]:format(stack)) -- Does need the sound spam too!
			end
		end
	end
end

function mod:TotalAnnihilation(args)
	annihilateCounter = annihilateCounter + 1
	self:MessageOld(-6186, "red", "alert", CL["count"]:format(args.spellName, annihilateCounter))
	self:Bar(-6186, 4, CL["cast"]:format(args.spellName))
end

function mod:MaterializeProtector(args)
	self:MessageOld("adds", "yellow", nil, CL["add_spawned"], args.spellId)
	self:Bar("adds", self:Heroic() and 26 or 40, CL["next_add"], args.spellId)
end

function mod:UnstableEnergyRemoved(args)
	if phaseCount == 2 then
		self:MessageOld("stages", "green", nil, L["last_phase"], false)
	else
		drawPowerCounter, annihilateCounter = 0, 0
		self:MessageOld("stages", "green", nil, CL["phase"]:format(1), false)
		self:Bar("adds", 15, CL["next_add"], 117954)
		self:RegisterUnitEvent("UNIT_HEALTH", "PhaseWarn", "boss1")
	end
end

function mod:PhaseWarn(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 88 and phaseCount == 0 then -- phase starts at 85
		self:MessageOld("stages", "green", "info", CL["soon"]:format(CL["phase"]:format(2)), false)
		phaseCount = 1
		self:UnregisterUnitEvent(event, unit)
	elseif hp < 53 and phaseCount == 1 then
		self:MessageOld("stages", "green", "info", CL["soon"]:format(CL["phase"]:format(2)), false)
		phaseCount = 2
		self:UnregisterUnitEvent(event, unit)
	end
end

