--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Kaz'rogal", 534, 1579)
if not mod then return end
mod:RegisterEnableMob(17888)
if mod:Classic() then
	mod:SetEncounterID(620)
end

--------------------------------------------------------------------------------
-- Locals
--

local count = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.mark_bar = "Mark (%d)"
	L.mark_warn = "Mark in 5 sec!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{31447, "PROXIMITY", "FLASH"}
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "MarkCast", 31447)
	self:Log("SPELL_AURA_APPLIED", "Mark", 31447)
	self:Log("SPELL_AURA_REMOVED", "MarkRemoved", 31447)

	if self:Classic() then
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	else
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	end
	self:Death("Win", 17888)
end

function mod:OnEngage()
	count = 1
	self:Bar(31447, 45, L["mark_bar"]:format(count))
	self:DelayedMessage(31447, 40, "green", L["mark_warn"])
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MarkCast(args)
	local time = 45 - (count * 5)
	if time < 5 then time = 5 end
	self:MessageOld(args.spellId, "yellow", nil, ("%s (%d)"):format(args.spellName, count))
	count = count + 1
	self:Bar(args.spellId, time, L["mark_bar"]:format(count))
	self:DelayedMessage(args.spellId, time - 5, "green", L["mark_warn"])
end

function mod:Mark(args)
	if self:Me(args.destGUID) then
		local power = UnitPower("player", 0)
		if power > 0 and power < 4000 then
			self:OpenProximity(args.spellId, 15)
			self:Flash(args.spellId)
		end
	end
end

function mod:MarkRemoved(args)
	if self:Me(args.destGUID) then
		self:CloseProximity(args.spellId)
	end
end

