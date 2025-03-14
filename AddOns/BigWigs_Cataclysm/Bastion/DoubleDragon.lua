--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Valiona and Theralion", 671, 157)
if not mod then return end
mod:RegisterEnableMob(45992, 45993) -- Valiona, Theralion
mod:SetEncounterID(1032)
mod:SetRespawnTime(35)

--------------------------------------------------------------------------------
-- Locals
--

local phaseCount = 0
local emTargets = mod:NewTargetList()
local markWarned = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.phase_switch = "Phase Switch"
	L.phase_switch_desc = "Warning for phase switches."

	L.phase_bar = "%s landing"
	L.breath_message = "Deep Breaths incoming!"
	L.dazzling_message = "Swirly zones incoming!"

	L.blast_message = "Falling Blast" -- Sounds better and makes more sense than Twilight Blast (the user instantly knows something is coming from the sky at them)
	L.engulfingmagic_say = "Engulf"

	L.valiona_trigger = "Theralion, I will engulf the hallway. Cover their escape!"

	L.twilight_shift = "Shift"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{86788, "ICON", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Blackout
		88518, -- Twilight Meteorite
		86059, -- Deep Breath
		86840, -- Devouring Flames
		{86622, "SAY"}, -- Engulfing Magic
		86408, -- Dazzling Destruction
		86369, -- Twilight Blast
		86505, -- Fabulous Flames
		93051, -- Twilight Shift
		"stages",
		"berserk",
	},{
		[86788] = -2985, -- Valiona
		[86622] = -2994, -- Theralion
		[93051] = "heroic",
		["stages"] = "general",
	},{
		[86369] = L.blast_message, -- Twilight Blast (Falling Blast)
		[86505] = CL.underyou:format(CL.fire), -- Fabulous Flames (Fire under YOU)
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	-- Heroic
	self:Log("SPELL_AURA_APPLIED_DOSE", "TwilightShift", 93051)

	-- Phase Switch -- should be able to do this easier once we get Transcriptor logs
	self:Log("SPELL_CAST_START", "DazzlingDestruction", 86408)

	self:Log("SPELL_AURA_APPLIED", "BlackoutApplied", 86788)
	self:Log("SPELL_AURA_REMOVED", "BlackoutRemoved", 86788)
	self:Log("SPELL_CAST_START", "DevouringFlames", 86840)

	self:Log("SPELL_AURA_APPLIED", "EngulfingMagicApplied", 86622)
	self:Log("SPELL_AURA_REMOVED", "EngulfingMagicRemoved", 86622)

	self:Log("SPELL_CAST_START", "TwilightBlast", 86369)

	self:RegisterUnitEvent("UNIT_AURA", "MeteorCheck", "player")

	self:Log("SPELL_DAMAGE", "FabulousFlamesDamage", 86505)
	self:Log("SPELL_MISSED", "FabulousFlamesDamage", 86505)
end

function mod:OnEngage()
	markWarned = false
	self:CDBar(86840, 25)
	self:Bar(86788, 11) -- Blackout
	self:Bar("stages", 103, self:SpellName(-2994), 60639) -- Theralion
	self:Berserk(600)
	phaseCount = 0
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
	if msg:find("86059", nil, true) then -- Deep Breath
		-- She emotes 3 times, every time she does a breath
		phaseCount = phaseCount + 1
		self:Message(86059, "red", CL.incoming:format(self:SpellName(86059)), "inv_misc_head_dragon_blue")
		if phaseCount == 3 then
			self:Bar("stages", 105, self:SpellName(-2994), 60639) -- Theralion
			phaseCount = 0
		end
		self:PlaySound(86059, "alarm")
	end
end

do
	local function valionaHasLanded()
		mod:StopBar(86622) -- Engulfing Magic
		mod:Message("stages", "cyan", CL.landing:format(mod:SpellName(-2985)), 60639) -- Valiona
		mod:CDBar(86840, 26) -- Devouring Flames
		mod:Bar(86788, 11) -- Blackout
	end
	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if msg:find(L.valiona_trigger, nil, true) then
			-- Valiona does this when she fires the first deep breath and begins the landing phase
			-- It only triggers once from her yell, not 3 times.
			self:Bar("stages", 40, self:SpellName(-2985), 60639) -- Valiona
			self:ScheduleTimer(valionaHasLanded, 40)
		end
	end
end

do
	local function printTarget(self, name, guid)
		if self:Me(guid) then
			self:PersonalMessage(86369, "you", L.blast_message)
			self:PlaySound(86369, "warning", nil, name)
		end
	end
	function mod:TwilightBlast(args)
		self:GetUnitTarget(printTarget, 0.7, args.sourceGUID)
	end
end

local function theralionHasLanded()
	mod:StopBar(86788) -- Blackout
	mod:StopBar(86840) -- Devouring Flames
	mod:Bar("stages", 129, mod:SpellName(-2985), 60639) -- Valiona
end

function mod:TwilightShift(args)
	self:Bar(args.spellId, 20)
	if args.amount > 3 then
		self:StackMessageOld(args.spellId, args.destName, args.amount, "red", nil, L["twilight_shift"])
	end
end

-- When Theralion is landing he casts DD 3 times, with a 5 second interval.
function mod:DazzlingDestruction(args)
	phaseCount = phaseCount + 1
	if phaseCount == 1 then
		self:MessageOld(args.spellId, "red", "alarm", L["dazzling_message"])
	elseif phaseCount == 3 then
		self:ScheduleTimer(theralionHasLanded, 6)
		self:Message("stages", "cyan", CL.landing:format(self:SpellName(-2994)), 60639) -- Theralion
		phaseCount = 0
	end
end

function mod:BlackoutApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:Bar(args.spellId, 45)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Yell(args.spellId, nil, nil, "Blackout")
		self:YellCountdown(args.spellId, 15)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	else
		self:PlaySound(args.spellId, "alert", nil, args.destName)
	end
end

function mod:BlackoutRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelYellCountdown(args.spellId)
	end
	self:PrimaryIcon(args.spellId)
end

do
	local function markRemoved()
		markWarned = false
	end

	local marked = mod:SpellName(88518)
	function mod:MeteorCheck(_, unit)
		if not markWarned and self:UnitDebuff(unit, marked, 88518) then
			--self:Flash(88518)
			self:MessageOld(88518, "blue", "long", CL["you"]:format(marked))
			markWarned = true
			self:SimpleTimer(markRemoved, 7)
		end
	end
end

function mod:DevouringFlames(args)
	self:CDBar(args.spellId, 42) -- make sure to remove bar when it takes off
	self:MessageOld(args.spellId, "red", "alert")
end

do
	local scheduled = nil
	local function emWarn(spellId)
		mod:TargetMessageOld(spellId, emTargets, "orange", "alarm")
		scheduled = nil
	end
	function mod:EngulfingMagicApplied(args)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, nil, nil, "Engulfing Magic")
			--self:Flash(args.spellId)
		end
		emTargets[#emTargets + 1] = args.destName
		if not scheduled then
			scheduled = true
			self:CDBar(args.spellId, 37)
			self:ScheduleTimer(emWarn, 0.3, args.spellId)
		end
	end
end

function mod:EngulfingMagicRemoved(args)
	--if self:Me(args.destGUID) then
		--self:CloseProximity()
	--end
end

do
	local prev = 0
	function mod:FabulousFlamesDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou", CL.fire)
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
