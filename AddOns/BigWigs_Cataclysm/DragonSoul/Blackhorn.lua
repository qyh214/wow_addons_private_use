--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Warmaster Blackhorn", 967, 332)
if not mod then return end
-- Goriona, Blackhorn, The Skyfire, Ka'anu Reevs, Sky Captain Swayze
mod:RegisterEnableMob(56781, 56427, 56598, 42288, 55870)

--------------------------------------------------------------------------------
-- Locales
--

local canEnable, warned = true, false
local onslaughtCounter = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.warmup = "Warmup"
	L.warmup_desc = "Time until combat starts."
	L.warmup_icon = "achievment_boss_blackhorn"

	L.sunder = "Sunder Armor"
	L.sunder_desc = "Count the stacks of sunder armor and show a duration bar."
	L.sunder_icon = 108043
	L.sunder_message = "%2$dx Sunder on %1$s"

	L.sapper_trigger = "A drake swoops down to drop a Twilight Sapper onto the deck!"
	L.sapper = "Sapper"
	L.sapper_desc = "Sapper dealing damage to the ship"
	L.sapper_icon = 73457

	L.stage2_trigger = "Looks like I'm doing this myself. Good!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions(CL)
	return {
		107588, "sapper",
		{"sunder", "TANK"}, {108046, "SAY", "FLASH"}, {108076, "SAY", "FLASH", "ICON"}, 108044,
		"warmup", "berserk",
	}, {
		[107588] = -4027,
		sunder = -4033,
		warmup = CL["general"],
	}
end

function mod:VerifyEnable()
	return canEnable
end

function mod:OnBossEnable()
	self:Log("SPELL_SUMMON", "TwilightFlames", 108076) -- did they just remove this?
	self:Log("SPELL_CAST_START", "TwilightOnslaught", 107588)
	self:Log("SPELL_CAST_START", "Shockwave", 108046)
	self:Log("SPELL_AURA_APPLIED", "Sunder", 108043)
	self:Log("SPELL_AURA_APPLIED", "PreStage2", 108040)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Sunder", 108043)
	self:Log("SPELL_CAST_SUCCESS", "Roar", 108044)
	self:Emote("Sapper", L["sapper_trigger"])
	self:BossYell("Stage2", L["stage2_trigger"])

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	self:Death("Win", 56427)
end

function mod:OnEngage()
	self:Bar(107588, 47) -- Twilight Onslaught
	if not self:LFR() then
		self:Bar("sapper", 70, L["sapper"], L["sapper_icon"])
	end
	onslaughtCounter = 1
	self:Bar("warmup", 20, _G["COMBAT"], L["warmup_icon"])
	self:DelayedMessage("warmup", 20, "green", CL["phase"]:format(1), L["warmup_icon"])
	warned = false
end

function mod:OnWin()
	canEnable = false
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Sapper()
	self:MessageOld("sapper", "red", "info", L["sapper"], L["sapper_icon"])
	if warned then return end
	self:Bar("sapper", 40, L["sapper"], L["sapper_icon"])
end

do
	function mod:PreStage2()
		if not warned then
			warned = true
			self:Bar("warmup", 9, self.displayName, L["warmup_icon"])
			self:MessageOld("warmup", "green", nil, CL["custom_sec"]:format(self.displayName, 9), L["warmup_icon"])
		end
	end
	function mod:Stage2()
		self:StopBar(107588) -- Twilight Onslaught
		self:StopBar(L["sapper"])
		self:CDBar(108046, 14) -- Shockwave
		self:MessageOld("warmup", "green", nil, CL["phase"]:format(2) .. ": " .. self.displayName, L["warmup_icon"])
		if not self:LFR() then
			self:Berserk(240, true)
		end
	end
end

do
	local function checkTarget(sGUID, spellId)
		local mobId = mod:GetUnitIdByGUID(sGUID)
		if mobId then
			local player = mod:UnitName(mobId.."target")
			if not player then return end
			if UnitIsUnit("player", player) then
				mod:Say(spellId, nil, nil, "Twilight Flames")
				mod:Flash(spellId)
				mod:MessageOld(spellId, "blue", "long") -- Twilight Flames
			end
			mod:PrimaryIcon(spellId, player)
		end
	end
	function mod:TwilightFlames(args)
		self:ScheduleTimer(checkTarget, 0.1, args.sourceGUID, args.spellId)
	end
end

function mod:TwilightOnslaught(args)
	self:MessageOld(args.spellId, "orange", "alarm")
	onslaughtCounter = onslaughtCounter + 1
	if warned then return end
	self:Bar(args.spellId, 35, ("%s (%d)"):format(args.spellName, onslaughtCounter))
end

do
	local function printTarget(self, name, guid)
		self:TargetMessageOld(108046, name, "yellow", "alarm")
		if self:Me(guid) then
			self:Flash(108046)
			self:Say(108046, nil, nil, "Shockwave")
		end
	end

	function mod:Shockwave(args)
		self:GetBossTarget(printTarget, 0.7, args.sourceGUID)
		self:CDBar(args.spellId, 23) -- 23-26
	end
end

function mod:Sunder(args)
	local buffStack = args.amount or 1
	self:StopBar(L["sunder_message"]:format(args.destName, buffStack - 1))
	self:Bar("sunder", 30, L["sunder_message"]:format(args.destName, buffStack), args.spellId)
	self:StackMessageOld("sunder", args.destName, buffStack, "orange", buffStack > 2 and "info", args.spellId)
end

function mod:Roar(args)
	self:CDBar(args.spellId, 20) -- 20-23
	self:MessageOld(args.spellId, "green", "alert")
end

