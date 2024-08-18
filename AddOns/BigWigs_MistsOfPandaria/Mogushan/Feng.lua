
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Feng the Accursed", 1008, 689)
if not mod then return end
mod:RegisterEnableMob(60009)

--------------------------------------------------------------------------------
-- Locals
--

local counter, p2, p3 = 1, nil, nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_yell = "Tender your souls, mortals! These are the halls of the dead!"

	L.phase_lightning_trigger = "Oh great spirit! Grant me the power of the earth!"
	L.phase_flame_trigger = "Oh exalted one! Through me you shall melt flesh from bone!"
	L.phase_arcane_trigger = "Oh sage of the ages! Instill to me your arcane wisdom!"
	L.phase_shadow_trigger = "Great soul of champions past! Bear to me your shield!"

	L.phase_lightning = "Lightning phase!"
	L.phase_flame = "Flame phase!"
	L.phase_arcane = "Arcane phase!"
	L.phase_shadow = "(Heroic) Shadow phase!"

	L.phase_message = "New phase soon!"
	L.shroud_message = "Shroud"
	L.shroud_can_interrupt = "%s can interrupt %s!"
	L.barrier_message = "Barrier UP!"
	L.barrier_cooldown = "Barrier cooldown"

	-- Tanks
	L.tank = "Tank Alerts"
	L.tank_desc = "Count the stacks of Lightning Lash, Flaming Spear, Arcane Shock & Shadowburn (Heroic)."
	L.tank_icon = "inv_shield_05"
	L.lash_message = "Lash"
	L.spear_message = "Spear"
	L.shock_message = "Shock"
	L.burn_message = "Burn"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		116157, 116018,
		{116784, "ICON", "FLASH", "SAY"}, 116711,
		{116417, "ICON", "SAY", "FLASH", "PROXIMITY"}, 116364,
		118071,
		115817, 115911, {"tank", "TANK"}, "stages", "berserk",
	}, {
		[116157] = L["phase_lightning"],
		[116784] = L["phase_flame"],
		[116417] = L["phase_arcane"],
		[118071] = L["phase_shadow"],
		[115817] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")

	self:Log("SPELL_CAST_START", "LightningFists", 116157, 116295)
	self:Log("SPELL_CAST_START", "Epicenter", 116018)

	self:Log("SPELL_AURA_APPLIED", "WildfireSparkApplied", 116784)
	self:Log("SPELL_AURA_REMOVED", "WildfireSparkRemoved", 116784)
	self:Log("SPELL_AURA_APPLIED", "DrawFlame", 116711)
	self:Log("SPELL_DAMAGE", "Wildfire", 116793)
	self:Log("SPELL_MISSED", "Wildfire", 116793)

	self:Log("SPELL_AURA_APPLIED", "ArcaneResonanceApplied", 116417)
	self:Log("SPELL_AURA_REMOVED", "ArcaneResonanceRemoved", 116417)
	self:Log("SPELL_AURA_APPLIED", "ArcaneVelocity", 116364)

	self:Log("SPELL_CAST_SUCCESS", "NullificationBarrier", 115817)

	-- Tanks
	self:Log("SPELL_AURA_APPLIED", "TankAlerts", 131788, 116942, 131790, 131792) -- Lash, Spear, Shock, Burn
	self:Log("SPELL_AURA_APPLIED_DOSE", "TankAlerts", 131788, 116942, 131790, 131792)

	self:Log("SPELL_CAST_SUCCESS", "Shroud", 115911)
	self:Log("SPELL_AURA_APPLIED", "LightningFistsReversal", 118302)
	self:Log("SPELL_AURA_APPLIED", "LightningFistsReversalOnBoss", 115730)

	-- needed so we can have bars up for abilities used straight after phase switches
	self:BossYell("LightningPhase", L["phase_lightning_trigger"])
	self:BossYell("FlamePhase", L["phase_flame_trigger"])
	self:BossYell("ArcanePhase", L["phase_arcane_trigger"])
	self:BossYell("ShadowPhase", L["phase_shadow_trigger"]) -- heroic only

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 60009)
end

function mod:OnEngage()
	p2, p3 = nil, nil
	counter = 1
	if self:Heroic() then
		self:RegisterUnitEvent("UNIT_HEALTH", "PhaseChangeHC", "boss1")
	else
		self:RegisterUnitEvent("UNIT_HEALTH", "PhaseChange", "boss1")
	end
	self:Berserk(600)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:LightningFistsReversalOnBoss(args)
	if not self:LFR() then
		self:StopBar(CL["other"]:format(args.sourceName, args.spellName))
		self:MessageOld(115911, "orange", "info", CL["onboss"]:format(args.spellName), args.spellId)
	end
end

function mod:LightningFistsReversal(args)
	if not self:LFR() then
		self:MessageOld(115911, "orange", nil, L["shroud_can_interrupt"]:format(args.destName, self:SpellName(116018)), args.spellId)
		self:Bar(115911, 20, CL["other"]:format(args.destName, args.spellName), args.spellId)
	end
end

function mod:Shroud(args)
	if not self:LFR() then
		self:TargetMessageOld(args.spellId, args.destName, "orange", nil, L["shroud_message"])
	end
end

function mod:NullificationBarrier(args)
	self:MessageOld(args.spellId, "orange", "info", L["barrier_message"])
	self:Bar(args.spellId, 6, L["barrier_message"])
	if not self:LFR() then
		self:Bar(args.spellId, 55, L["barrier_cooldown"])
	end
end

do
	local msgTbl = {
		[131788] = L["lash_message"],
		[116942] = L["spear_message"],
		[131790] = L["shock_message"],
		[131792] = L["burn_message"],
	}
	function mod:TankAlerts(args)
		local stack = args.amount or 1
		self:StackMessageOld("tank", args.destName, stack, "orange", stack > 1 and "info", msgTbl[args.spellId], args.spellId)
	end
end

function mod:PhaseChange(event, unit)
	local hp = self:GetHealth(unit)
	--a 5% warning is like forever away from the actual transition (especially in LFR, lol)
	if (hp < 68 and not p2) or (hp < 35) then --66/33
		self:MessageOld("stages", "green", "info", L["phase_message"], false)
		if not p2 then
			p2 = true
		else
			self:UnregisterUnitEvent(event, unit)
		end
	end
end

function mod:PhaseChangeHC(event, unit)
	local hp = self:GetHealth(unit)
	--a 5% warning is like forever away from the actual transition (especially in LFR, lol)
	if (hp < 77 and not p2) or (hp < 52 and not p3) or (hp < 27) then --75/50/25
		self:MessageOld("stages", "green", "info", L["phase_message"], false)
		if not p2 then
			p2 = true
		elseif not p3 then
			p3 = true
		else
			self:UnregisterUnitEvent(event, unit)
		end
	end
end

--------------------------------------------------------------------------------
-- LIGHTNING
--

function mod:LightningPhase()
	self:MessageOld("stages", "green", nil, L["phase_lightning"], 116363)
	self:Bar(116018, 18, CL["count"]:format(self:SpellName(116018), counter)) -- Epicenter
	self:Bar(116157, 12) -- Lightning Fists
end

function mod:LightningFists(args)
	self:MessageOld(116157, "orange")
	self:Bar(116157, 13)
end

function mod:Epicenter(args)
	self:MessageOld(args.spellId, "red", "alarm", CL["count"]:format(args.spellName, counter))
	counter = counter + 1
	self:Bar(args.spellId, 30, CL["count"]:format(args.spellName, counter))
end

--------------------------------------------------------------------------------
-- FLAME
--

function mod:FlamePhase()
	self:MessageOld("stages", "green", nil, L["phase_flame"], 116363)
	self:Bar(116711, 35, CL["count"]:format(self:SpellName(116711), counter)) -- Draw Flame
end

do
	local wildfire = mod:SpellName(116793)
	function mod:WildfireSparkApplied(args)
		self:TargetMessageOld(args.spellId, args.destName, "orange", "alert", wildfire)
		self:PrimaryIcon(args.spellId, args.destName)
		if self:Me(args.destGUID) then
			self:Flash(args.spellId)
			self:Bar(args.spellId, 5, CL["you"]:format(wildfire))
			self:Say(args.spellId, wildfire, nil, "Wildfire")
		end
	end
	function mod:WildfireSparkRemoved(args)
		self:PrimaryIcon(args.spellId)
	end

	-- Standing on the Wildfire
	local prev = 0
	function mod:Wildfire(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(116784, "blue", "info", CL["underyou"]:format(wildfire))
			self:Flash(116784)
		end
	end
end

function mod:DrawFlame(args)
	self:MessageOld(args.spellId, "red", "alarm", CL["count"]:format(args.spellName, counter))
	counter = counter + 1
	self:Bar(args.spellId, 35, CL["count"]:format(args.spellName, counter))
end

--------------------------------------------------------------------------------
-- ARCANE
--

function mod:ArcanePhase()
	self:MessageOld("stages", "green", nil, L["phase_arcane"], 116363)
	self:DelayedMessage(116364, 10, "yellow", CL["soon"]:format(self:SpellName(116364))) -- Arcane Velocity
end

do
	local resonance, resonanceTargets, resonanceMarkers, scheduled = mod:SpellName(33657), mod:NewTargetList(), {}, nil
	local function warnResonance(spellId)
		scheduled = nil
		mod:PrimaryIcon(spellId, resonanceMarkers[1])
		resonanceTargets[1] = resonanceMarkers[1]
		if resonanceMarkers[2] then
			mod:SecondaryIcon(spellId, resonanceMarkers[2])
			resonanceTargets[2] = resonanceMarkers[2]
		end
		mod:TargetMessageOld(spellId, resonanceTargets, "orange", "alert", resonance)
		resonanceMarkers = {}
	end
	function mod:ArcaneResonanceApplied(args)
		resonanceMarkers[#resonanceMarkers+1] = args.destName
		if self:Me(args.destGUID) then
			self:Flash(args.spellId)
			self:OpenProximity(args.spellId, 6)
			self:Say(args.spellId, resonance, nil, "Arcane Resonance")
		end
		if not scheduled then
			self:Bar(args.spellId, 15.4, resonance)
			scheduled = self:ScheduleTimer(warnResonance, 0.15, args.spellId)
		end
	end
	function mod:ArcaneResonanceRemoved(args)
		if self:Me(args.destGUID) then
			self:CloseProximity(args.spellId)
		end
	end
end

function mod:ArcaneVelocity(args)
	self:MessageOld(args.spellId, "red", "alarm", CL["count"]:format(args.spellName, counter))
	counter = counter + 1
	self:Bar(args.spellId, 28, CL["count"]:format(args.spellName, counter))
	self:DelayedMessage(args.spellId, 25.5, "yellow", CL["soon"]:format(CL["count"]:format(args.spellName, counter)))
end

--------------------------------------------------------------------------------
-- SHADOW (HEROIC)
--

function mod:ShadowPhase()
	self:Bar(118071, 4, CL["count"]:format(self:SpellName(118071), counter)) -- Siphoning Shield
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, _, spellId)
	if spellId == 117203 then -- Siphoning Shield
		local spellName = self:SpellName(spellId)
		self:MessageOld(118071, "red", "alarm", CL["count"]:format(spellName, counter))
		counter = counter + 1
		self:Bar(118071, 35, CL["count"]:format(spellName, counter))
	elseif spellId == 122410 then -- Throw Mainhand (end of phase)
		--SHUT. DOWN. EVERYTHING.
		self:CancelDelayedMessage(CL["soon"]:format(CL["count"]:format(self:SpellName(116364), counter)))
		self:StopBar(CL["count"]:format(self:SpellName(116364), counter)) -- Arcane Velocity
		self:StopBar(33657) -- Resonance
		self:StopBar(CL["count"]:format(self:SpellName(118071), counter)) -- Siphoning Shield
		self:StopBar(CL["count"]:format(self:SpellName(116018), counter)) -- Epicenter
		self:StopBar(116157) -- Lightning Fists
		self:StopBar(CL["count"]:format(self:SpellName(116711), counter)) -- Draw flame
		counter = 1
	end
end

