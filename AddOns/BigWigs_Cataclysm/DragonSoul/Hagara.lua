--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Hagara the Stormbinder", 967, 317)
if not mod then return end
mod:RegisterEnableMob(55689)

--------------------------------------------------------------------------------
-- Locales
--

local playerTbl = mod:NewTargetList()
local nextPhase, nextPhaseIcon

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "You cross the Stormbinder! I'll slaughter you all."

	L.lightning_or_frost = "Lightning or Frost"
	L.ice_next = "Ice phase"
	L.lightning_next = "Lightning phase"

	L.nextphase = "Next Phase"
	L.nextphase_desc = "Warnings for next phase"
	L.nextphase_icon = 2139 -- random icon (counterspell)
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{104448, "FLASH"}, 105256, {105316, "PROXIMITY"}, {109325, "ICON", "FLASH", "PROXIMITY", "SAY"},
		105409,
		{-4159, "TANK_HEALER"}, 108934, "nextphase", "berserk"
	}, {
		[104448] = L["ice_next"],
		[105409] = L["lightning_next"],
		[-4159] = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "IceTombStart", 104448)
	self:Log("SPELL_AURA_APPLIED", "Assault", 107851)
	self:Log("SPELL_AURA_APPLIED", "IceTombApplied", 104451)
	self:Log("SPELL_AURA_APPLIED", "IceLanceApplied", 105285)
	self:Log("SPELL_AURA_REMOVED", "IceLanceRemoved", 105285)
	self:Log("SPELL_AURA_APPLIED", "Feedback", 108934)
	self:Log("SPELL_CAST_START", "FrozenTempest", 105256)
	self:Log("SPELL_CAST_START", "WaterShield", 105409)
	self:Log("SPELL_AURA_APPLIED", "FrostFlakeApplied", 109325)
	self:Log("SPELL_AURA_REMOVED", "FrostFlakeRemoved", 109325)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 55689)
end

function mod:OnEngage()
	self:Berserk(480) -- 10 man heroic confirmed
	-- need to find a way to determine which one is at first after engage
	-- apart from looking at her weapon enchants
	self:Bar("nextphase", 30, L["lightning_or_frost"], L["nextphase_icon"])
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Assault(args)
	self:MessageOld(-4159, "orange")
	self:CDBar(-4159, 15)
	self:Bar(-4159, 5, "<"..args.spellName..">")
end

function mod:FrostFlakeApplied(args)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "blue", "long", CL["you"]:format(args.spellName))
		self:Say(args.spellId, nil, nil, "Frostflake")
		self:Flash(args.spellId)
		self:OpenProximity(args.spellId, 10)
	end
end

function mod:FrostFlakeRemoved(args)
	self:PrimaryIcon(args.spellId)
	if self:Me(args.destGUID) then
		self:CloseProximity(args.spellId)
	end
end

function mod:WaterShield(args)
	self:StopBar(-4159) -- Focused Assault
	self:MessageOld(args.spellId, "yellow", nil, L["lightning_next"])
	nextPhase = L["ice_next"]
	nextPhaseIcon = 105256
end

function mod:FrozenTempest(args)
	self:StopBar(-4159) -- Focused Assault
	self:MessageOld(args.spellId, "yellow", nil, L["ice_next"])
	nextPhase = L["lightning_next"]
	nextPhaseIcon = 105409
end

function mod:Feedback(args)
	self:MessageOld(args.spellId, "yellow")
	self:Bar(args.spellId, 15)
	self:Bar("nextphase", 63, nextPhase, nextPhaseIcon)
	self:Bar(-4159, 20) -- Focused Assault
end

function mod:IceTombStart(args)
	self:MessageOld(args.spellId, "yellow")
	self:Bar(args.spellId, 8)
	self:Flash(args.spellId)
end

do
	local scheduled = nil
	local function iceTomb()
		mod:TargetMessageOld(104448, playerTbl, "red")
		scheduled = nil
	end
	function mod:IceTombApplied(args)
		playerTbl[#playerTbl + 1] = args.destName
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(iceTomb, 0.1)
		end
	end
end

do
	local scheduled = nil
	local function iceLance()
		mod:TargetMessageOld(105316, playerTbl, "orange", "info") -- Ice Lance
		scheduled = nil
	end
	function mod:IceLanceApplied(args)
		playerTbl[#playerTbl + 1] = args.destName
		if self:Me(args.destGUID) then
			self:OpenProximity(105316, 3)
		end
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(iceLance, 0.2)
		end
	end
end

function mod:IceLanceRemoved(args)
	if self:Me(args.destGUID) then
		self:CloseProximity(105316)
	end
end

