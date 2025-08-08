
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Shadow-Lord Iskar", 1448, 1433)
if not mod then return end
mod:RegisterEnableMob(90316)
mod.engageId = 1788
mod.respawnTime = 20

--------------------------------------------------------------------------------
-- Locals
--

local shadowEscapeCount = 0
local bindingsRemoved = 0
local nextPhase, nextPhaseSoon = 70, 75.5
local windTargets = {}
local eyeTarget = nil
local remainingWinds, remainingWounds, remainingChakram, remainingRiposte = 0, 0, 0, 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.custom_off_wind_marker = "Phantasmal Winds marker"
	L.custom_off_wind_marker_desc = "Marks Phantasmal Winds targets with {rt1}{rt2}{rt3}{rt4}{rt5}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
	L.custom_off_wind_marker_icon = 1

	L.bindings_removed = "Bindings removed (%d/3)"
	L.custom_off_binding_marker = "Dark Bindings marker"
	L.custom_off_binding_marker_desc = "Mark the Dark Bindings targets with {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
	L.custom_off_binding_marker_icon = 1
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		--[[ Phase 1 ]]--
		{182200, "SAY", "FLASH"}, -- Fel Chakram
		181956, -- Phantasmal Winds
		"custom_off_wind_marker",
		{182323, "HEALER"}, -- Phantasmal Wounds
		185345, -- Shadow Riposte
		--[[ Phase 2 ]]--
		{181912, "FLASH"}, -- Focused Blast
		{181753, "SAY"}, -- Fel Bomb
		181827, -- Fel Conduit
		{181824, "SAY", "PROXIMITY"}, -- Phantasmal Corruption
		{185510, "SAY"}, -- Dark Bindings
		"custom_off_binding_marker",
		--[[ General ]]--
		{179202, "FLASH"}, -- Eye of Anzu
		{182582, "SAY"}, -- Fel Incineration
		"stages",
		"berserk",
	}, {
		[182200] = CL.phase:format(1),
		[181912] = CL.phase:format(2),
		[179202] = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "EyeOfAnzu", 179202)
	self:Log("SPELL_CAST_SUCCESS", "PhantasmalWinds", 181956)
	self:Log("SPELL_AURA_APPLIED", "PhantasmalWindsApplied", 185757, 181957)
	self:Log("SPELL_AURA_REMOVED", "PhantasmalWindsRemoved", 185757, 181957)
	self:Log("SPELL_AURA_APPLIED", "PhantasmalWounds", 182325)
	self:Log("SPELL_AURA_APPLIED", "PhantasmalCorruption", 181824, 187990)
	self:Log("SPELL_AURA_REMOVED", "PhantasmalCorruptionRemoved", 181824, 187990)
	self:Log("SPELL_AURA_APPLIED", "FelBomb", 181753)
	self:Log("SPELL_CAST_START", "FocusedBlast", 181912)
	self:Log("SPELL_CAST_START", "FelConduit", 181827, 187998)
	self:Log("SPELL_AURA_APPLIED", "FelChakram", 182200, 182178)
	self:Log("SPELL_CAST_START", "DarkBindingsCast", 185456) -- Chains of Despair
	self:Log("SPELL_AURA_APPLIED", "DarkBindings", 185510)
	self:Log("SPELL_AURA_REMOVED", "DarkBindingsRemoved", 185510)
	self:Log("SPELL_CAST_START", "Stage2", 181873) -- Shadow Escape
	self:Log("SPELL_CAST_START", "ShadowRiposte", 185345)
	self:Log("SPELL_AURA_APPLIED", "FelFireDamage", 182600)
	self:Log("SPELL_PERIODIC_DAMAGE", "FelFireDamage", 182600)
	self:Log("SPELL_PERIODIC_MISSED", "FelFireDamage", 182600)

	self:RegisterEvent("RAID_BOSS_WHISPER")

	self:Death("TalonpriestDeath", 91543, 93985) -- Bossfight, Trash
	self:Death("WardenDeath", 91541, 93968) -- Bossfight, Trash
	self:Death("RavenDeath", 91539, 93952) -- Bossfight, Trash
	self:Death("ResonanceDeath", 93625) -- Phantasmal Resonance
end

function mod:OnEngage()
	shadowEscapeCount = 0
	nextPhase, nextPhaseSoon = 70, 75.5
	eyeTarget = nil
	windTargets = {}

	if not self:LFR() then
		self:Berserk(self:Heroic() and 540 or 480)
	end
	if self:Mythic() then
		self:CDBar(185345, 9.5) -- Shadow Riposte
	end
	-- normal modifier 1.25 for all CDs?
	self:CDBar(182200, self:Easy() and 6.3 or 5.5) -- Fel Chakram
	self:CDBar(181956, self:Easy() and 21 or 17) -- Phantasmal Winds
	self:CDBar(182323, self:Easy() and 34 or 25) -- Phantasmal Wounds
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:TalonpriestDeath() -- Corrupted Talonpriest
	self:StopBar(181753) -- Fel Bomb
end

function mod:WardenDeath() -- Shadowfel Warden
	self:StopBar(181827) -- Fel Conduit
end

function mod:RavenDeath() -- Fel Raven
	self:StopBar(181824) -- Phantasmal Corruption
end

function mod:ResonanceDeath() -- Phantasmal Resonance
	self:StopBar(185510) -- Dark Bindings
end

function mod:EyeOfAnzu(args)
	eyeTarget = args.destGUID
	--self:TargetMessageOld(args.spellId, args.destName, "green") -- XXX info display instead?
	if self:Me(args.destGUID) then
		self:TargetMessageOld(args.spellId, args.destName, "blue", #windTargets > 0 and "warning" or "info")
		self:Flash(args.spellId)
	end
end

do
	local function printTarget(self, name)
		self:TargetMessageOld(185345, name, "red", "long") -- Warning is used in Eye+Winds events, so Long here to be distinct
	end
	function mod:ShadowRiposte(args)
		if self:MobId(args.sourceGUID) == 90316 then -- prevent Dark Simulacrum from messing with the cd
			self:GetBossTarget(printTarget, 0.3, args.sourceGUID)
			self:CDBar(args.spellId, 27)
		end
	end
end

function mod:PhantasmalWinds(args)
	windTargets = {}
end

do
	local isOnMe = nil
	local function warn(self)
		if isOnMe then
			self:TargetMessageOld(181956, isOnMe, "blue" , "alarm")
		else
			self:MessageOld(181956, "yellow", self:UnitBuff("player", self:SpellName(179202)) and "warning") -- Warning if you have the Eye
		end
		isOnMe = nil
	end
	function mod:PhantasmalWindsApplied(args)
		windTargets[#windTargets + 1] = args.destName
		if #windTargets == 1 then
			self:ScheduleTimer(warn, 0.3, self)
			self:CDBar(181956, self:Easy() and 45 or 36)
		end
		if self:Me(args.destGUID) then
			isOnMe = args.destName
		end
		if self:GetOption("custom_off_wind_marker") then
			self:CustomIcon(false, args.destName, #windTargets)
		end
	end
end

function mod:PhantasmalWindsRemoved(args)
	if self:GetOption("custom_off_wind_marker") then
		self:CustomIcon(false, args.destName)
	end
	self:DeleteFromTable(windTargets, args.destName)
end

do
	local prev = 0
	function mod:PhantasmalWounds(args)
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(182323, "orange")
			self:CDBar(182323, self:Easy() and 40 or 33)
		end
	end
end

function mod:PhantasmalCorruption(args)
	if args.destGUID ~= eyeTarget then
		self:TargetBar(181824, 10, args.destName)
		self:TargetMessageOld(181824, args.destName, "orange", "warning", nil, nil, true)
		if self:Me(args.destGUID) then
			self:Say(181824, nil, nil, "Phantasmal Corruption")
			self:OpenProximity(181824, 15) -- Range discovered from LFR testing
		end
	end
	self:CDBar(181824, self:Easy() and 18 or 16)
end

function mod:PhantasmalCorruptionRemoved(args)
	if self:Me(args.destGUID) then
		self:CloseProximity(181824)
	end
	self:StopBar(181824, args.destName)
end

function mod:FelBomb(args)
	self:TargetMessageOld(args.spellId, args.destName, "red", self:Dispeller("magic") and "alert")
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Fel Bomb")
	end
	self:Bar(args.spellId, self:Easy() and 23 or 18.4)
end

function mod:FocusedBlast(args)
	self:MessageOld(args.spellId, "red", nil, CL.casting:format(args.spellName))
	self:Bar(args.spellId, 12)
	self:DelayedMessage(args.spellId, 9, "red", CL.incoming:format(args.spellName), nil, "long")
	self:ScheduleTimer("Flash", 9, args.spellId)
end

function mod:FelConduit(args)
	self:MessageOld(181827, "orange", "alert")
	self:CDBar(181827, self:Easy() and 19.3 or 15.9)
end

function mod:RAID_BOSS_WHISPER(_, msg)
	if msg:find(182582) then -- Fel Incineration
		self:MessageOld(182582, "blue", "alarm", CL.you:format(self:SpellName(182582)))
		self:Say(182582, nil, nil, "Fel Incineration")
	end
end

do
	local list = mod:NewTargetList()
	function mod:FelChakram(args)
		list[#list+1] = args.destName
		if #list == 1 then
			self:ScheduleTimer("TargetMessageOld", 0.3, 182200, list, "yellow", "alert")
			self:CDBar(182200, 34)
		end
		if self:Me(args.destGUID) then
			self:Say(182200, nil, nil, "Fel Chakram")
			self:Flash(182200)
		end
	end
end

function mod:DarkBindingsCast()
	bindingsRemoved = 0
	self:MessageOld(185510, "orange", "info", CL.casting:format(self:SpellName(185510))) -- Dark Bindings, actual cast is called "Chains of Despair"
	self:Bar(185510, 30)
end

do
	local list = mod:NewTargetList()
	function mod:DarkBindings(args)
		list[#list+1] = args.destName
		if #list == 1 then
			self:ScheduleTimer("TargetMessageOld", 0.3, args.spellId, list, "yellow")
		end
		if self:Me(args.destGUID) then
			self:Say(args.spellId, nil, nil, "Dark Bindings")
		end
		if self:GetOption("custom_off_binding_marker") then
			self:CustomIcon(false, args.destName, #list)
		end
	end

	function mod:DarkBindingsRemoved(args)
		bindingsRemoved = bindingsRemoved + 1
		if self:GetOption("custom_off_binding_marker") then
			self:CustomIcon(false, args.destName)
		end
		if bindingsRemoved % 2 == 0 then -- 2 events per pair of bindings removed (player a and player b)
			self:MessageOld(args.spellId, "cyan", nil, L.bindings_removed:format(bindingsRemoved/2))
		end
	end
end

function mod:Stage2() -- Shadow Escape
	remainingRiposte = self:BarTimeLeft(185345)
	remainingWinds = self:BarTimeLeft(181956)
	remainingChakram = self:BarTimeLeft(182200)
	remainingWounds = self:BarTimeLeft(182323)
	self:StopBar(185345) -- Shadow Riposte
	self:StopBar(181956) -- Phantasmal Winds
	self:StopBar(182200) -- Fel Chakram
	self:StopBar(182323) -- Phantasmal Wounds
	shadowEscapeCount = shadowEscapeCount + 1

	self:MessageOld("stages", "cyan", "info", ("%d%% - %s"):format(nextPhase, CL.phase:format(2)), false)
	nextPhase = nextPhase - 25
	self:ScheduleTimer("Stage1", self:Easy() and 50 or 40) -- event for when Iskar is attackable again?
	self:Bar("stages", self:Easy() and 50 or 40, CL.phase:format(1), "achievement_boss_hellfire_felarakkoa")
	self:Bar(181912, 20) -- Focused Blast
	self:CDBar(181753, self:Easy() and 18.6 or 15.5) -- Fel Bomb, 15.5-17.4
	if shadowEscapeCount > 1 then -- Fel Warden
		self:CDBar(181827, self:Easy() and 7 or 6) -- Fel Conduit
	end
	if shadowEscapeCount > 2 then -- Fel Raven
		self:CDBar(181824, self:Easy() and 26 or 22) -- Phantasmal Corruption
	end
	if self:Mythic() then
		self:Bar(185510, 21) -- Dark Bindings
	end
end

function mod:Stage1() -- Shadow Escape over
	self:StopBar(181912) -- Focused Blast
	self:MessageOld("stages", "cyan", "info", CL.phase:format(1), false)
	if self:Mythic() then
		self:CDBar(185345, remainingRiposte) -- Shadow Riposte
	end
	self:CDBar(182200, remainingChakram) -- Fel Chakram, very inconsistent
	self:CDBar(181956, remainingWinds) -- Phantasmal Winds
	self:CDBar(182323, remainingWounds) -- Phantasmal Wounds
end

do
	local prev = 0
	function mod:FelFireDamage(args)
		local t = GetTime()
		if self:Me(args.destGUID) and t-prev > 1.5 then
			prev = t
			self:MessageOld(182582, "blue", "alert", CL.underyou:format(args.spellName))
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	local hp = self:GetHealth(unit)
	if hp < nextPhaseSoon then
		nextPhaseSoon = nextPhaseSoon - 25
		if nextPhaseSoon < 20 then
			self:UnregisterUnitEvent(event, unit)
		end
		self:MessageOld("stages", "cyan", nil, CL.soon:format(CL.phase:format(2)), false)
	end
end

