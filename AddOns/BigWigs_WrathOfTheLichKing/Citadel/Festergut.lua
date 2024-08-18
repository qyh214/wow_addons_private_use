--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Festergut", 631, 1629)
if not mod then return end
mod:RegisterEnableMob(36626)
-- mod:SetEncounterID(1097)
-- mod:SetRespawnTime(30)
mod.toggleOptions = {{69279, "FLASH"}, 69165, 69195, 72219, 69240, 72295, "proximity", "berserk"}
mod.optionHeaders = {
	[69279] = "normal",
	[72295] = "heroic",
	proximity = "general",
}

--------------------------------------------------------------------------------
-- Locals
--

local count = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "Fun time?"

	L.inhale_bar = "Inhale (%d)"
	L.blight_warning = "Pungent Blight in ~5sec!"
	L.ball_message = "Goo ball incoming!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "InhaleCD", 69165)
	self:Log("SPELL_CAST_START", "Blight", 69195)
	self:Log("SPELL_CAST_SUCCESS", "VileGas", 69240)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Bloat", 72219)
	self:Death("Win", 36626)

	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:BossYell("Engage", L["engage_trigger"])

	self:Log("SPELL_AURA_APPLIED", "Spores", 69279)
end

function mod:OnEngage()
	count = 1
	self:Berserk(300, true)
	self:CDBar(69279, 20) -- Gas Spore
	self:Bar(69165, 33.5, L["inhale_bar"]:format(count))
	self:OpenProximity("proximity", 9)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local sporeTargets, scheduled = mod:NewTargetList(), nil
	local function sporeWarn()
		mod:TargetMessageOld(69279, sporeTargets, "orange", "alert")
		scheduled = nil
	end
	function mod:Spores(args)
		sporeTargets[#sporeTargets + 1] = args.destName
		if self:Me(args.destGUID) then
			self:Flash(69279)
		end
		if not scheduled then
			scheduled = self:ScheduleTimer(sporeWarn, 0.2, args.spellName)
			self:ScheduleTimer("CDBar", 12, 69279, 28) -- Gas Spore
			self:Bar(69279, 12, 67729) -- Explode
		end
	end
end

function mod:InhaleCD(args)
	self:MessageOld(69165, "yellow", nil, CL["count"]:format(args.spellName, count))
	count = count + 1
	if count == 4 then
		self:DelayedMessage(69195, 28.5, "yellow", L["blight_warning"])
		self:Bar(69195, 33.5)
	else
		self:Bar(69165, 33.5, L["inhale_bar"]:format(count))
	end
end

function mod:Blight(args)
	count = 1
	self:MessageOld(69195, "yellow")
	self:Bar(69165, 33.5, L["inhale_bar"]:format(count))
end

function mod:Bloat(args)
	if args.amount > 5 then
		self:StackMessageOld(72219, args.destName, args.amount, "green")
		self:CDBar(72219, 10)
	end
end

do
	local t = 0
	function mod:VileGas(args)
		local time = GetTime()
		if (time - t) > 2 then
			t = time
			self:MessageOld(69240, "red")
		end
	end
end

do
	local prev = 0
	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castId, spellId)
		if spellId == 72299 and castId ~= prev then
			prev = castId
			self:MessageOld(72295, "red", nil, L["ball_message"])
		end
	end
end
