--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Valithria Dreamwalker", 631, 1634)
if not mod then return end
mod:RegisterEnableMob(36789, 37868, 36791, 37934, 37886, 37950, 37985)
-- mod:SetEncounterID(1098)
-- mod:SetRespawnTime(30)
mod.toggleOptions = {69325, {71086, "FLASH"}, "suppresser", {"blazing", "ICON"}, "portal", "berserk"}
mod.optionHeaders = {
	[69325] = "normal",
	berserk = "heroic",
}

--------------------------------------------------------------------------------
-- Locals
--

local blazingTimers = {60, 51.5, 53.5, 41, 41, 35, 33}
local blazingCount, blazingRepeater, portalCount = 1, nil, 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "Intruders have breached the inner sanctum. Hasten the destruction of the green dragon!"

	L.portal = "Nightmare Portals"
	L.portal_desc = "Warns when Valithria opens portals."
	L.portal_message = "Portals up!"
	L.portal_bar = "Portals inc"
	L.portalcd_message = "Portals %d up in 14 sec!"
	L.portalcd_bar = "Next Portals %d"
	L.portal_trigger = "I have opened a portal into the Dream. Your salvation lies within, heroes..."

	L.suppresser = "Suppressers spawn"
	L.suppresser_desc = "Warns when a pack of Suppressers spawn."
	L.suppresser_message = "Suppressers"

	L.blazing = "Blazing Skeleton"
	L.blazing_desc = "Blazing Skeleton |cffff0000estimated|r respawn timer. This timer may be inaccurate, use only as a rough guide."
	L.blazing_warning = "Blazing Skeleton soon!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_DAMAGE", "ManaVoid", 71086, 71179)
	self:Log("SPELL_MISSED", "ManaVoid", 71086, 71179)

	self:Log("SPELL_AURA_APPLIED", "LayWaste", 69325)
	self:Log("SPELL_AURA_REMOVED", "LayWasteRemoved", 69325)
	self:Log("SPELL_CAST_START", "Win", 71189)

	self:BossYell("Portal", L["portal_trigger"])
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:BossYell("Engage", L["engage_trigger"])
end

do
	local function scanTarget()
		local unitId = mod:GetUnitIdByGUID(36791)
		if not unitId then return end
		mod:PrimaryIcon("blazing", unitId)
		mod:CancelTimer(blazingRepeater)
		blazingRepeater = nil
	end
	local function suppresserSpawn(time)
		mod:CDBar("suppresser", time, L["suppresser_message"], 70588)
		mod:ScheduleTimer(suppresserSpawn, time, time)
	end
	local function blazingSpawn()
		if not blazingTimers[blazingCount] then return end
		mod:Bar("blazing", blazingTimers[blazingCount], L["blazing"], 69325)
		mod:ScheduleTimer(blazingSpawn, blazingTimers[blazingCount])
		mod:DelayedMessage("blazing", blazingTimers[blazingCount] - 5, "green", L["blazing_warning"])
		blazingCount = blazingCount + 1
		if not blazingRepeater and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and bit.band(mod.db.profile.blazing, BigWigs.C.ICON) == BigWigs.C.ICON then
			blazingRepeater = mod:ScheduleRepeatingTimer(scanTarget, 0.5)
		end
	end
	function mod:OnEngage()
		portalCount = 1
		if self:Heroic() then
			self:CDBar("suppresser", 14, L["suppresser_message"], 70588)
			self:Bar("portal", 46, L["portalcd_bar"]:format(portalCount), 72482)
			self:ScheduleTimer(suppresserSpawn, 14, 31)
			self:Berserk(420)
		else
			self:CDBar("suppresser", 29, L["suppresser_message"], 70588)
			self:Bar("portal", 46, L["portalcd_bar"]:format(portalCount), 72482)
			self:ScheduleTimer(suppresserSpawn, 29, 58)
		end
		self:ScheduleTimer(blazingSpawn, 50)
		self:Bar("blazing", 50, L["blazing"], 69325)
		self:DelayedMessage("blazing", 45, "green", L["blazing_warning"])
		blazingCount = 1
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:LayWaste(args)
	self:MessageOld(69325, "yellow")
	self:Bar(69325, 12)
end

function mod:LayWasteRemoved(args)
	self:StopBar(args.spellName)
end

function mod:Portal()
	-- 46 sec cd until initial positioning, +14 sec until 'real' spawn.
	self:MessageOld("portal", "red", nil, L["portalcd_message"]:format(portalCount), false)
	self:Bar("portal", 14, L["portal_bar"], 72482)
	self:DelayedMessage("portal", 14, "red", L["portal_message"])
	portalCount = portalCount + 1
	self:Bar("portal", 46, L["portalcd_bar"]:format(portalCount), 72482)
end

do
	local prev = 0
	function mod:ManaVoid(args)
		local t = GetTime()
		if t-prev > 2 and self:Me(args.destGUID) and UnitPowerType("player") == 0 then
			prev = t
			self:MessageOld(71086, "blue", "alarm", CL["you"]:format(args.spellName))
			self:Flash(71086)
		end
	end
end

