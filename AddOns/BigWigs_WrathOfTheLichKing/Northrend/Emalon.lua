--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Emalon the Storm Watcher", 624, 1598)
if not mod then return end
mod:RegisterEnableMob(33993)
-- mod:SetEncounterID(1127)
-- mod:SetRespawnTime(30)
mod.toggleOptions = {64216, 64218, "custom_on_overcharge_mark", "proximity", "berserk"}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.overcharge_message = "A minion is overcharged!"
	L.overcharge_bar = "Explosion"

	L.custom_on_overcharge_mark = "Overcharge marker"
	L.custom_on_overcharge_mark_desc = "Place the {rt8} marker on the overcharged minion, requires promoted or leader."
	L.custom_on_overcharge_mark_icon = 8
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Nova", 64216, 65279)
	self:Log("SPELL_CAST_SUCCESS", "Overcharge", 64218)
	self:Log("SPELL_HEAL", "OverchargeIcon", 64218)
	self:Death("Win", 33993)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
end

function mod:OnEngage()
	self:OpenProximity("proximity", 5)
	self:CDBar(64218, 45) -- Overcharge
	self:Berserk(360)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Nova(args)
	self:MessageOld(64216, "yellow")
	self:Bar(64216, 5, CL["cast"]:format(args.spellName))
	self:CDBar(64216, 25)
end

function mod:Overcharge(args)
	self:MessageOld(args.spellId, "green", nil, L["overcharge_message"])
	self:Bar(args.spellId, 20, L["overcharge_bar"])
	self:CDBar(args.spellId, 45)
end

do
	local timer = nil
	local function scanTarget(self, destGUID)
		local unitId = self:GetUnitIdByGUID(destGUID)
		if not unitId then return end
		self:CustomIcon(false, unitId, 8)
		self:CancelTimer(timer)
		timer = nil
	end

	function mod:OverchargeIcon(args)
		if not timer and self:GetOption("custom_on_overcharge_mark") and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
			timer = self:ScheduleRepeatingTimer(scanTarget, 0.2, self, args.destGUID)
		end
	end
end

