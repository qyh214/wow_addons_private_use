--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Sinestra", 671, 168)
if not mod then return end
mod:RegisterEnableMob(45213)
mod:SetEncounterID(mod:Retail() and 1083 or 1082)
mod:SetRespawnTime(40)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.whelps = "Whelps"
	L.whelps_desc = "Warning for the whelp waves."

	L.slicer_message = "Possible Orb targets"

	L.egg_vulnerable = "Omelet time!"

	L.whelps_trigger = "Feed, children!" -- Feed, children!  Take your fill from their meaty husks!
	L.omelet_trigger = "You mistake this for weakness?" -- You mistake this for weakness?  Fool!

	L.phase13 = "Phase 1 and 3"
	L.phase = "Phase"
	L.phase_desc = "Warning for phase changes."
end

--------------------------------------------------------------------------------
-- Locals
--

local eggs = 0
local orbList = {}
local orbOnMe = false
local orbWarned = nil
local whelpGUIDs = {}

local function isTargetableByOrb(unit, bossUnit)
	-- check tanks
	if mod:Tank(unit) then return false end
	-- check sinestra's target too
	if bossUnit and mod:ThreatTarget(unit, bossUnit) then return false end
	-- and maybe do a check for whelp targets
	for k in next, whelpGUIDs do
		local whelp = mod:GetUnitIdByGUID(k)
		if whelp and mod:ThreatTarget(unit, whelp) then
			return false
		end
	end
	return true
end

local function populateOrbList()
	orbList = {}
	orbOnMe = false
	local bossUnit = mod:GetUnitIdByGUID(45213) -- Sinestra
	for unit in mod:IterateGroup() do
		-- Tanking something, but not a tank (aka not tanking Sinestra or Whelps)
		if mod:ThreatTarget(unit) and isTargetableByOrb(unit, bossUnit) then
			orbList[#orbList + 1] = mod:UnitName(unit)
			if mod:Me(mod:UnitGUID(unit)) then
				orbOnMe = true
			end
		end
	end
end

local function ResetOrbWarning()
	orbWarned = nil
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions(CL)
	return {
	-- Phase 1 and 3
		90125, -- Breath
		{92852, "ICON"}, -- Twilight Slicer
		86227, -- Extinction
		"whelps",

	-- Phase 2
		87654, -- Omelet Time
		90045, -- Indomitable

	-- General
		"phase",
	}, {
		[90125] = CL.plus:format(CL.stage:format(1), CL.stage:format(3)),
		[87654] = CL.stage:format(2),
		phase = "general",
	}
end

function mod:OnBossEnable()
	if self:Retail() then
		if self:Difficulty() == 6 then
			self:SetEncounterID(1083)
		else
			self:SetEncounterID(1082)
		end
	end

	self:Log("SPELL_DAMAGE", "OrbDamage", 92852, 92958) -- twilight slicer, twilight pulse [May be wrong since MoP id changes]
	self:Log("SPELL_MISSED", "OrbDamage", 92852, 92958) -- twilight slicer, twilight pulse [May be wrong since MoP id changes]

	self:Log("SWING_DAMAGE", "WhelpWatcher", "*")
	self:Log("SWING_MISSED", "WhelpWatcher", "*")
	self:Death("TwilightWhelpDeaths", 47265, 48047, 48048, 48049, 48050) -- Twilight Whelp
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")

	self:Log("SPELL_CAST_START", "Breath", 90125)

	self:Log("SPELL_AURA_REMOVED", "Egg", 87654)
	self:Log("SPELL_AURA_APPLIED", "Indomitable", 90045)
	self:Log("SPELL_CAST_START", "Extinction", 86227)

	self:BossYell("EggTrigger", L["omelet_trigger"])
	self:BossYell("Whelps", L["whelps_trigger"])

	self:Death("TwilightEggDeaths", 46842) -- Pulsing Twilight Egg
end

function mod:OnEngage()
	whelpGUIDs = {}
	orbWarned = nil
	eggs = 0
	self:CDBar(90125, 23) -- Breath
	self:CDBar(92852, 29) -- Slicer
	self:Bar("whelps", 16, L["whelps"], 69005) -- whelp like icon
	self:ScheduleTimer("NextOrbSpawned", 30)
	self:RegisterUnitEvent("UNIT_HEALTH", "PhaseWarn", "boss1")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local whelpIds = {
		[47265] = true,
		[48047] = true,
		[48048] = true,
		[48049] = true,
		[48050] = true,
	}
	function mod:WhelpWatcher(args)
		local mobId = self:MobId(args.sourceGUID)
		if whelpIds[mobId] then
			whelpGUIDs[args.sourceGUID] = true
		else
			mobId = self:MobId(args.destGUID)
			if whelpIds[mobId] then
				whelpGUIDs[args.destGUID] = true
			end
		end
	end
	function mod:TwilightWhelpDeaths(args)
		whelpGUIDs[args.destGUID] = nil
	end
	function mod:NAME_PLATE_UNIT_ADDED(_, unit)
		local guid = self:UnitGUID(unit)
		if whelpIds[self:MobId(guid)] then
			whelpGUIDs[guid] = true
		end
	end
end

local repeatCount = 0
function mod:OrbWarning(source)
	if orbList[1] then mod:PrimaryIcon(92852, orbList[1]) end
	if orbList[2] then mod:SecondaryIcon(92852, orbList[2]) end

	if source == "spawn" then
		if #orbList > 0 then
			mod:TargetsMessage(92852, "yellow", orbList, #orbList, L.slicer_message)
			if #orbList == 1 and repeatCount == 0 then
				repeatCount = 1
				self:SimpleTimer(function()
					populateOrbList()
					self:OrbWarning("spawn")
				end, 1)
			end
			if orbOnMe then
				self:PlaySound(92852, "warning")
			end
		else
			repeatCount = repeatCount + 1
			if repeatCount <= 6 then
				self:SimpleTimer(function()
					populateOrbList()
					self:OrbWarning("spawn")
				end, 1)
			end
		end
	elseif source == "damage" then
		mod:TargetsMessage(92852, "yellow", orbList, #orbList, L.slicer_message)
		mod:SimpleTimer(ResetOrbWarning, 10) -- might need to adjust this
		if orbOnMe then
			self:PlaySound(92852, "warning")
		end
	end
end

-- this gets run every 30 sec
-- need to change it once there is a proper trigger for orbs
function mod:NextOrbSpawned()
	repeatCount = 0
	self:CDBar(92852, 28.5)
	self:MessageOld(92852, "blue")
	populateOrbList()
	self:OrbWarning("spawn")
	self:ScheduleTimer("NextOrbSpawned", 28.5)
end

function mod:OrbDamage()
	repeatCount = 99
	populateOrbList()
	if orbWarned then return end
	orbWarned = true
	self:OrbWarning("damage")
end

function mod:Whelps()
	self:Bar("whelps", 50, L["whelps"], 69005)
	self:MessageOld("whelps", "red", nil, L["whelps"], 69005)
end

function mod:Extinction(args)
	self:Bar(args.spellId, 15)
end

do
	local scheduled = nil
	local function EggMessage(spellId)
		mod:MessageOld(spellId, "red", "alert", L["egg_vulnerable"])
		mod:Bar(spellId, 30, L["egg_vulnerable"])
		scheduled = nil
	end
	function mod:Egg(args)
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(EggMessage, 0.1, args.spellId)
		end
	end
end

function mod:EggTrigger()
	self:Bar(87654, 5, L["egg_vulnerable"], 87654)
end

function mod:Indomitable(args)
	self:MessageOld(args.spellId, "orange")
	if self:Dispeller("enrage", true) then
		self:PlaySound(args.spellId, "info")
		--self:Flash(args.spellId)
	end
end

function mod:PhaseWarn(event, unit)
	local hp = self:GetHealth(unit)
	if hp <= 30.5 then
		self:MessageOld("phase", "green", "info", CL["phase"]:format(2), 86226)
		self:UnregisterUnitEvent(event, unit)
		self:CancelAllTimers()
		self:StopBar(92852) -- Slicer
		self:StopBar(90125) -- Breath
	end
end

function mod:Breath(args)
	self:CDBar(args.spellId, 24)
	self:MessageOld(args.spellId, "orange")
end

function mod:TwilightEggDeaths()
	eggs = eggs + 1
	if eggs == 2 then
		self:MessageOld("phase", "green", "info", CL["phase"]:format(3), 51070) -- broken egg icon
		self:Bar("whelps", 50, L["whelps"], 69005)
		self:CDBar(92852, 29) -- Slicer
		self:CDBar(90125, 24) -- Breath
		self:ScheduleTimer("NextOrbSpawned", 29)
	end
end

