--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Feng the Accursed", 1008, 689)
if not mod then return end
mod:RegisterEnableMob(60009)
mod:SetEncounterID(1390)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local counter, p2, p3 = 1, nil, nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
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

--------------------------------------------------------------------------------
-- Initialization
--

local arcaneResonanceMarker = mod:AddMarkerOption(false, "player", 1, 116417, 1, 2) -- Arcane Resonance
function mod:GetOptions()
	return {
		116157, -- Lightning Fists
		116018, -- Epicenter
		{116784, "ICON", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Wildfire Spark
		116793, -- Wildfire
		116711, -- Draw Flame
		{116417, "SAY", "ME_ONLY_EMPHASIZE"}, -- Arcane Resonance
		arcaneResonanceMarker,
		116364, -- Arcane Velocity
		118071, -- Siphoning Shield
		115817, -- Nullification Barrier
		115911, -- Shroud of Reversal
		{"tank", "TANK"},
		"stages",
		"berserk",
	},{
		[116157] = L.phase_lightning,
		[116784] = L.phase_flame,
		[116417] = L.phase_arcane,
		[118071] = L.phase_shadow,
		[115817] = "general",
	},{
		[116793] = CL.underyou:format(mod:SpellName(116793)), -- Wildfire (Wildfire under YOU)
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")

	self:Log("SPELL_CAST_START", "LightningFists", 116157, 116295)
	self:Log("SPELL_CAST_START", "Epicenter", 116018)

	self:Log("SPELL_AURA_APPLIED", "WildfireSparkApplied", 116784)
	self:Log("SPELL_AURA_REMOVED", "WildfireSparkRemoved", 116784)
	self:Log("SPELL_AURA_APPLIED", "DrawFlame", 116711)
	self:Log("SPELL_DAMAGE", "WildfireDamage", 116793)
	self:Log("SPELL_MISSED", "WildfireDamage", 116793)

	self:Log("SPELL_AURA_APPLIED", "ArcaneResonanceApplied", 116417, 116576, 116574, 116577)
	self:Log("SPELL_AURA_REMOVED", "ArcaneResonanceRemoved", 116417, 116576, 116574, 116577)
	self:Log("SPELL_AURA_APPLIED", "ArcaneVelocity", 116364)

	self:Log("SPELL_CAST_SUCCESS", "NullificationBarrier", 115817)

	-- Tanks
	self:Log("SPELL_AURA_APPLIED", "TankAlerts", 131788, 116942, 131790, 131792) -- Lash, Spear, Shock, Burn
	self:Log("SPELL_AURA_APPLIED_DOSE", "TankAlerts", 131788, 116942, 131790, 131792)

	self:Log("SPELL_CAST_SUCCESS", "Shroud", 115911)
	self:Log("SPELL_AURA_APPLIED", "LightningFistsReversal", 118302)
	self:Log("SPELL_AURA_APPLIED", "LightningFistsReversalOnBoss", 115730)
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

function mod:CHAT_MSG_MONSTER_YELL(_, msg, boss, _, _, destName)
	-- Needed so we can have bars up for abilities used straight after phase switches
	if msg:find(L.phase_lightning_trigger, nil, true) then
		self:LightningPhase()
	elseif msg:find(L.phase_flame_trigger, nil, true) then
		self:FlamePhase()
	elseif msg:find(L.phase_arcane_trigger, nil, true) then
		self:ArcanePhase()
	elseif msg:find(L.phase_shadow_trigger, nil, true) then
		self:ShadowPhase()
	end
end

function mod:LightningFistsReversalOnBoss(args)
	if not self:LFR() then
		self:StopBar(CL["other"]:format(args.sourceName, args.spellName))
		self:Message(115911, "orange", CL["onboss"]:format(args.spellName), args.spellId)
		self:PlaySound(115911, "info")
	end
end

function mod:LightningFistsReversal(args)
	if not self:LFR() then
		self:Message(115911, "orange", L["shroud_can_interrupt"]:format(self:ColorName(args.destName), self:SpellName(116018)), args.spellId)
		self:Bar(115911, 20, CL["other"]:format(args.destName, args.spellName), args.spellId)
	end
end

function mod:Shroud(args)
	if not self:LFR() then
		self:TargetMessage(args.spellId, "orange", args.destName, L["shroud_message"])
	end
end

function mod:NullificationBarrier(args)
	self:Message(args.spellId, "orange", L["barrier_message"])
	self:Bar(args.spellId, 6, L["barrier_message"])
	if not self:LFR() then
		self:Bar(args.spellId, 55, L["barrier_cooldown"])
	end
	self:PlaySound(args.spellId, "info")
end

do
	local msgTbl = {
		[131788] = L["lash_message"],
		[116942] = L["spear_message"],
		[131790] = L["shock_message"],
		[131792] = L["burn_message"],
	}
	function mod:TankAlerts(args)
		local amount = args.amount or 1
		self:StackMessage("tank", "purple", args.destName, amount, 2, msgTbl[args.spellId], args.spellId)
		if amount > 1 then
			self:PlaySound("tank", "info")
		end
	end
end

function mod:PhaseChange(event, unit)
	local hp = self:GetHealth(unit)
	--a 5% warning is like forever away from the actual transition (especially in LFR, lol)
	if (hp < 68 and not p2) or (hp < 35) then --66/33
		self:Message("stages", "cyan", L["phase_message"], false)
		if not p2 then
			p2 = true
		else
			self:UnregisterUnitEvent(event, unit)
		end
		self:PlaySound("stages", "info")
	end
end

function mod:PhaseChangeHC(event, unit)
	local hp = self:GetHealth(unit)
	--a 5% warning is like forever away from the actual transition (especially in LFR, lol)
	if (hp < 77 and not p2) or (hp < 52 and not p3) or (hp < 27) then --75/50/25
		self:Message("stages", "cyan", L["phase_message"], false)
		if not p2 then
			p2 = true
		elseif not p3 then
			p3 = true
		else
			self:UnregisterUnitEvent(event, unit)
		end
		self:PlaySound("stages", "info")
	end
end

--------------------------------------------------------------------------------
-- LIGHTNING
--

function mod:LightningPhase()
	self:Message("stages", "cyan", L["phase_lightning"], 116363)
	self:Bar(116018, 18, CL.count:format(self:SpellName(116018), counter)) -- Epicenter
	self:Bar(116157, 12) -- Lightning Fists
end

function mod:LightningFists(args)
	self:Message(116157, "orange")
	self:Bar(116157, 13)
end

function mod:Epicenter(args)
	self:Message(args.spellId, "red", CL.count:format(args.spellName, counter))
	counter = counter + 1
	self:Bar(args.spellId, 30, CL.count:format(args.spellName, counter))
	self:PlaySound(args.spellId, "alarm")
end

--------------------------------------------------------------------------------
-- FLAME
--

function mod:FlamePhase()
	self:Message("stages", "cyan", L["phase_flame"], 116363)
	self:Bar(116711, 35, CL.count:format(self:SpellName(116711), counter)) -- Draw Flame
end

do
	local wildfire = mod:SpellName(116793)
	function mod:WildfireSparkApplied(args)
		self:TargetMessage(args.spellId, "orange", args.destName, wildfire)
		self:PrimaryIcon(args.spellId, args.destName)
		if self:Me(args.destGUID) then
			self:TargetBar(args.spellId, 5, args.destName, wildfire)
			self:Say(args.spellId, wildfire, nil, "Wildfire")
			self:SayCountdown(args.spellId, 5)
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
	function mod:WildfireSparkRemoved(args)
		self:PrimaryIcon(args.spellId)
		if self:Me(args.destGUID) then
			self:StopBar(wildfire, args.destName)
			self:CancelSayCountdown(args.spellId)
		end
	end
end

do
	local prev = 0
	function mod:WildfireDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:DrawFlame(args)
	self:Message(args.spellId, "red", CL.count:format(args.spellName, counter))
	counter = counter + 1
	self:Bar(args.spellId, 35, CL.count:format(args.spellName, counter))
	self:PlaySound(args.spellId, "alarm")
end

--------------------------------------------------------------------------------
-- ARCANE
--

function mod:ArcanePhase()
	self:Message("stages", "cyan", L["phase_arcane"], 116363)
	self:DelayedMessage(116364, 10, "yellow", CL.soon:format(self:SpellName(116364))) -- Arcane Velocity
end

do
	local playerList = {}
	local prev = 0
	local resonance = mod:SpellName(33657)

	function mod:ArcaneResonanceApplied(args)
		if args.time - prev > 5 then
			prev = args.time
			playerList = {}
			self:Bar(116417, 15.4, resonance)
		end

		local count = #playerList+1
		playerList[count] = args.destName
		playerList[args.destName] = count -- Set raid marker
		self:TargetsMessage(116417, "orange", playerList, 2, resonance)
		self:CustomIcon(arcaneResonanceMarker, args.destName, count)
		if self:Me(args.destGUID) then
			self:Say(116417, resonance, nil, "Resonance")
			self:PlaySound(116417, "warning", nil, args.destName)
		end
	end

	function mod:ArcaneResonanceRemoved(args)
		self:CustomIcon(arcaneResonanceMarker, args.destName)
	end
end

function mod:ArcaneVelocity(args)
	self:Message(args.spellId, "red", CL.count:format(args.spellName, counter))
	counter = counter + 1
	self:Bar(args.spellId, 28, CL.count:format(args.spellName, counter))
	self:DelayedMessage(args.spellId, 25.5, "yellow", CL.soon:format(CL.count:format(args.spellName, counter)))
	self:PlaySound(args.spellId, "alarm")
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
		self:Message(118071, "red", CL["count"]:format(spellName, counter))
		counter = counter + 1
		self:Bar(118071, 35, CL["count"]:format(spellName, counter))
		self:PlaySound(118071, "alarm")
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

