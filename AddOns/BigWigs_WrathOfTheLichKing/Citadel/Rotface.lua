--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Rotface", 631, 1630)
if not mod then return end
mod:RegisterEnableMob(36627)
-- mod:SetEncounterID(1104)
-- mod:SetRespawnTime(30)
mod.toggleOptions = {{69839, "FLASH"}, {69674, "FLASH", "ICON"}, 69508, "ooze", 72272, "berserk"}
mod.optionHeaders = {
	[69839] = "normal",
	[72272] = "heroic",
	berserk = "general",
}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "WEEEEEE!"

	L.infection_message = "Infection"

	L.ooze = "Ooze Merge"
	L.ooze_desc = "Warn when an ooze merges."
	L.ooze_message = "Ooze %dx"

	L.spray_bar = "Next Spray"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "VileGas", 72272)
	self:Log("SPELL_AURA_APPLIED", "Infection", 69674)
	self:Log("SPELL_AURA_REMOVED", "InfectionRemoved", 69674)
	self:Log("SPELL_CAST_START", "SlimeSpray", 69508)
	self:Log("SPELL_CAST_START", "Explode", 69839)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Ooze", 69558)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:BossYell("Engage", L["engage_trigger"])

	self:Death("Win", 36627)
end

function mod:OnEngage()
	self:Berserk(600, true)
	self:Bar(69508, 19, L["spray_bar"])
	if self:Heroic() then
		self:Bar(72272, 20)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Infection(args)
	self:TargetMessageOld(69674, args.destName, "blue", nil, L["infection_message"])
	self:TargetBar(69674, 12, args.destName, L["infection_message"])
	self:PrimaryIcon(69674, args.destName, "icon")
	if self:Me(args.destGUID) then
		self:Flash(69674)
	end
end

function mod:InfectionRemoved(args)
	self:StopBar(L["infection_message"], args.destName)
end

function mod:SlimeSpray(args)
	self:MessageOld(69508, "red", "alarm")
	self:Bar(69508, 21, L["spray_bar"])
end

do
	--The cast is sometimes pushed back
	local handle = nil
	local function explodeWarn()
		handle = nil
		mod:Flash(69839)
		mod:MessageOld(69839, "orange", "alert", 67729) -- Explode
	end
	function mod:Explode(args)
		self:Bar(69839, 4, 67729) -- "Explode"
		self:CancelTimer(handle)
		handle = self:ScheduleTimer(explodeWarn, 4)
	end
end

function mod:Ooze(args)
	if args.amount < 5 then
		self:MessageOld("ooze", "yellow", nil, L["ooze_message"]:format(args.amount), args.spellId)
	end
end

function mod:VileGas(args)
	self:Bar(72272, 30)
end

