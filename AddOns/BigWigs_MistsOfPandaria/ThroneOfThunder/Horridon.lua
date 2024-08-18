--[[
TODO:
	I assume pushing horridon below 30% before all doors open does not actually prevent new doors from opening
]]--

--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Horridon", 1098, 819)
if not mod then return end
mod:RegisterEnableMob(68476, 69374) -- Horridon, War-God Jalak

--------------------------------------------------------------------------------
-- Locals
--

local doorCounter = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.charge_trigger = "sets his eyes" -- Horridon sets his eyes on PLAYERNAME and stamps his tail!
	L.door_trigger = "pour" -- Farraki forces pour from the Farraki Tribal Door!
	L.orb_trigger = "charge" -- PLAYERNAME forces Horridon to charge the Farraki door!


	L.chain_lightning = -7124
	L.chain_lightning_desc = "|cffff0000Focus target alerts only.|r {-7124}"
	L.chain_lightning_icon = 136480
	L.chain_lightning_message = "Your focus is casting Chain Lightning!"
	L.chain_lightning_bar = "Focus: Chain Lightning"

	L.fireball = -7122
	L.fireball_desc = "|cffff0000Focus target alerts only.|r {-7122}"
	L.fireball_icon = 136465
	L.fireball_message = "Your focus is casting Fireball!"
	L.fireball_bar = "Focus: Fireball"

	L.venom_bolt_volley = -7112
	L.venom_bolt_volley_desc = "|cffff0000Focus target alerts only.|r {-7112}"
	L.venom_bolt_volley_icon = 136587
	L.venom_bolt_volley_message = "Your focus is casting Volley!"
	L.venom_bolt_volley_bar = "Focus: Volley"

	L.adds = "Adds spawning"
	L.adds_desc = "Warnings for when the Farraki, the Gurubashi, the Drakkari, the Amani, and War-God Jalak spawn."
	L.adds_icon = "inv_misc_head_troll_01"

	L.door_opened = "Door opened!"
	L.door_bar = "Next door (%d)"
	L.balcony_adds = "Balcony adds"
	L.orb_message = "Orb of Control dropped!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		137458, {-7868, "FLASH"},
		-7086, -7090, -7092,
		{-7109, "DISPEL"}, {136723, "FLASH"}, -- Farraki
		{"venom_bolt_volley", "FLASH"}, {136646, "FLASH"}, -- Gurubashi
		{-7119, "DISPEL"}, {-7120, "HEALER"}, {136573, "FLASH"}, -- Drakkari
		"fireball", "chain_lightning", {-7125, "DISPEL"}, {136490, "FLASH"}, -- Amani
		136817, 136821, -- War-God Jalak
		{-7078, "TANK_HEALER"}, 136741, {-7080, "FLASH", "SAY"}, 137240, "adds", "berserk",
	}, {
		[137458] = "heroic",
		[-7086] = -7086,
		[-7109] = -7081,
		["venom_bolt_volley"] = -7082,
		[-7119] = -7083,
		["fireball"] = -7084,
		[136817] = -7087,
		[-7078] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "BossEngage")
	-- The Zandalari
	self:Log("SPELL_AURA_APPLIED", "Rampage", 136821)
	self:Log("SPELL_CAST_SUCCESS", "BestialCry", 136817)
	self:Log("SPELL_AURA_APPLIED", "CrackedShell", 137240)
	self:Log("SPELL_AURA_APPLIED_DOSE", "CrackedShell", 137240)
	self:Log("SPELL_AURA_APPLIED", "DinoForm", 137237)
	self:Log("SPELL_CAST_SUCCESS", "DinoMending", 136797)
	self:Log("SPELL_INTERRUPT", "DinoMendingInterrupt", "*")
	-- The Amani
	self:Log("SPELL_DAMAGE", "LightningNova", 136490)
	self:Log("SPELL_AURA_APPLIED", "Hex", 136512)
	self:Log("SPELL_CAST_START", "ChainLightning", 136480)
	self:Log("SPELL_CAST_START", "Fireball", 136465)
	-- The Drakkari
	self:Log("SPELL_DAMAGE", "FrozenOrb", 136573)
	self:Log("SPELL_AURA_REMOVED", "MortalStrikeRemoved", 136670)
	self:Log("SPELL_AURA_APPLIED", "MortalStrike", 136670)
	self:Log("SPELL_AURA_APPLIED", "DeadlyPlague", 136710)
	self:Log("SPELL_AURA_APPLIED_DOSE", "DeadlyPlague", 136710)
	-- The Gurubashi
	self:Log("SPELL_DAMAGE", "LivingPoison", 136646)
	self:Log("SPELL_AURA_APPLIED", "VenomBoltVolleyDispell", 136587)
	self:Log("SPELL_AURA_APPLIED_DOSE", "VenomBoltVolleyDispell", 136587)
	self:Log("SPELL_CAST_START", "VenomBoltVolley", 136587)
	-- The Farraki
	self:Log("SPELL_DAMAGE", "SandTrap", 136723)
	self:Log("SPELL_CAST_START", "BlazingSunlight", 136719)
	-- General
	self:Log("SPELL_AURA_APPLIED", "Puncture", 136767)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Puncture", 136767)
	self:Log("SPELL_CAST_START", "Swipe", 136741, 136770) -- 136770 is only after charge
	self:Emote("Charge", L["charge_trigger"])
	self:Emote("Doors", L["door_trigger"])
	self:Emote("ControlOrb", L["orb_trigger"])
	self:Log("SPELL_CAST_START", "DireCall", 137458)
	self:Log("SPELL_AURA_APPLIED", "DireFixation", 140946)

	self:Death("Win", 68476)
end

function mod:OnEngage()
	doorCounter = 1
	self:Berserk(720)
	self:Bar("adds", 22, L["door_bar"]:format(doorCounter), "inv_shield_11")
	self:Bar(-7078, 10) -- Triple Puncture
	self:Bar(-7080, 33) -- Charge
	if self:Heroic() then
		self:Bar(137458, 61) -- Dire Call
	end
	self:RegisterUnitEvent("UNIT_HEALTH", "LastPhase", "boss1")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- The Zandalari

function mod:BossEngage()
	self:CheckBossStatus()
	if self:MobId(self:UnitGUID("boss2")) == 69374 then -- War-God Jalak
		self:StopBar(-7087)
		self:MessageOld("adds", "cyan", "info", -7087, false) -- War-God Jalak
		self:UnregisterUnitEvent("UNIT_HEALTH", "boss1")
		self:Bar(136817, 5) -- Bestial Cry
	end
end

function mod:Rampage(args)
	self:MessageOld(args.spellId, "red", "long")
end

function mod:BestialCry(args)
	self:Bar(args.spellId, 11) -- might help to pop personal cooldowns
end

function mod:CrackedShell(args)
	self:MessageOld(args.spellId, "green", nil, args.spellName) -- 10s stun timer, too, maybe?
end

function mod:ControlOrb(msg, _, _, _, player)
	self:MessageOld(137240, "green", nil, msg)
end

function mod:LastPhase(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 35 then -- phase starts at 30, except if the boss is already there
		self:MessageOld("adds", "cyan", "info", CL["soon"]:format(self:SpellName(-7087)), "achievement_boss_trollgore") -- War-God Jalak
		self:UnregisterUnitEvent(event, unit)
	end
end

function mod:DinoForm(args)
	-- tie it to this event, this is when you can use the orb
	self:MessageOld(-7092, "green", nil, L["orb_message"])
end

function mod:DinoMending(args)
	self:MessageOld(-7090, "red", "long")
	self:Bar(-7090, 8) -- to help interrupters keep track
end

function mod:DinoMendingInterrupt(args)
	if args.extraSpellId == 136797 then
		self:StopBar(-7090)
		self:MessageOld(-7090, "green", nil, CL["interrupted"]:format(self:SpellName(-7090)))
	end
end

-- The Amani
do
	local prev = 0
	function mod:LightningNova(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

do
	local hexTargets, scheduled = mod:NewTargetList(), nil
	local function warnHex()
		scheduled = nil
		mod:TargetMessageOld(-7125, hexTargets, "red", "alarm")
	end
	function mod:Hex(args)
		if self:Dispeller("curse", nil, -7125) then
			hexTargets[#hexTargets+1] = args.destName
			if not scheduled then
				scheduled = self:ScheduleTimer(warnHex, 0.2)
			end
		elseif self:Me(args.destGUID) then
			self:TargetMessageOld(-7125, args.destName, "red", "alarm")
		end
	end
end

do
	local prev = 0
	function mod:ChainLightning(args)
		local t = GetTime()
		if t-prev > 3 and self:UnitGUID("focus") == args.sourceGUID then -- don't spam
			prev = t
			self:MessageOld("chain_lightning", "blue", "alert", L["chain_lightning_message"], args.spellId)
		end
	end
end

do
	local prev = 0
	function mod:Fireball(args)
		local t = GetTime()
		if t-prev > 3 and self:UnitGUID("focus") == args.sourceGUID then -- don't spam
			prev = t
			self:MessageOld("fireball", "blue", "alert", L["fireball_message"], args.spellId)
		end
	end
end

-- The Drakkari

do
	local prev = 0
	function mod:FrozenOrb(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL["underyou"]:format(args.spellName)) -- not exactly under you
			self:Flash(args.spellId)
		end
	end
end

function mod:MortalStrike(args)
	self:TargetMessageOld(-7120, args.destName, "orange")
	self:TargetBar(-7120, 8, args.destName)
end

function mod:MortalStrikeRemoved(args)
	self:StopBar(-7120, args.destName)
end

do
	local prev = 0
	function mod:DeadlyPlague(args)
		local t = GetTime()
		if t-prev > 3 and self:Dispeller("disease", nil, -7119) then -- don't spam
			prev = t
			self:MessageOld(-7119, "red", "alarm", args.spellName, args.spellId)
		end
	end
end

-- The Gurubashi

do
	local prev = 0
	function mod:LivingPoison(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

do
	local prev = 0
	function mod:VenomBoltVolleyDispell(args)
		local t = GetTime()
		if t-prev > 3 and self:Dispeller("poison") then -- don't spam
			prev = t
			self:MessageOld("venom_bolt_volley", "red", "alarm", args.spellName, args.spellId)
		end
	end
end

function mod:VenomBoltVolley(args)
	if self:UnitGUID("focus") == args.sourceGUID then
		self:MessageOld("venom_bolt_volley", "blue", "alert", L["venom_bolt_volley_message"], args.spellId)
		self:Bar("venom_bolt_volley", 16, L["venom_bolt_volley_bar"], args.spellId)
	end
end

-- The Farraki

do
	local prev = 0
	function mod:SandTrap(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL["underyou"]:format(args.spellName), args.spellId)
			self:Flash(args.spellId)
		end
	end
end

do
	local prev = 0
	function mod:BlazingSunlight(args)
		local t = GetTime()
		if t-prev > 3 and self:Dispeller("magic", nil, -7109) then -- don't spam
			prev = t
			self:MessageOld(-7109, "red", "alarm", args.spellName, args.spellId)
		end
	end
end

-- General

function mod:Charge(msg, _, _, _, player)
	self:TargetMessageOld(-7080, player, "yellow", "warning", nil, nil, true)
	self:Bar(-7080, 51)
	if UnitIsUnit("player", player) then
		self:Flash(-7080)
		self:Say(-7080, nil, nil, "Charge")
	end
end

function mod:Doors(msg)
	self:DelayedMessage("adds", 5, "cyan", L["door_opened"], "inv_shield_11")
	doorCounter = doorCounter + 1
	-- next door
	if doorCounter < 5 then
		self:ScheduleTimer("Bar", 5, "adds", 114, L["door_bar"]:format(doorCounter), "inv_shield_11") -- door like icon
	else
		self:Bar("adds", 143, -7087, "achievement_boss_trollgore") -- War-God Jalak
	end

	-- 1st wave jumps down
	self:Bar("adds", 20, L["balcony_adds"], L.adds_icon)
	self:DelayedMessage("adds", 20, "cyan", CL["count"]:format(L["balcony_adds"], 1), L.adds_icon)

	-- 2nd wave jumps down
	self:ScheduleTimer("Bar", 20, "adds", 19, L["balcony_adds"], L.adds_icon)
	self:DelayedMessage("adds", 39, "cyan", CL["count"]:format(L["balcony_adds"], 2), L.adds_icon)

	-- dinomancer jumps down
	self:Bar(-7086, 58, nil, "ability_hunter_beastwithin") -- Zandalari Dinomancer (Dino Form icon)
	self:DelayedMessage(-7086, 58, "cyan", nil, "ability_hunter_beastwithin")
end

function mod:Swipe(args)
	self:MessageOld(136741, "orange", "long")
	local timer = (args.spellId == 136770) and 11 or 19 -- after charge swipe is ~10 sec, then ~19 till next charge ( 10 H ptr )
	self:Bar(136741, self:LFR() and 16 or timer) -- someone needs to verify LFR timer
end

function mod:Puncture(args)
	self:StackMessageOld(-7078, args.destName, args.amount, "orange")
	self:Bar(-7078, 10.9)
end

function mod:DireCall(args)
	self:MessageOld(args.spellId, "orange")
	self:Bar(args.spellId, 63)
end

function mod:DireFixation(args)
	if self:Me(args.destGUID) then
		self:MessageOld(-7868, "blue", "info", CL["you"]:format(args.spellName))
		self:Flash(-7868)
	end
end
