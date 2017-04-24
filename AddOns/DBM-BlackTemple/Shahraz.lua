local mod	= DBM:NewMod("Shahraz", "DBM-BlackTemple")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 609 $"):sub(12, -3))
mod:SetCreatureID(22947)
mod:SetEncounterID(607)
mod:SetModelID(21252)
mod:SetZone()
mod:SetUsedIcons(1, 2, 3)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"RAID_BOSS_EMOTE",
	"SPELL_AURA_APPLIED 41001",
	"SPELL_AURA_REMOVED 41001",
	"SPELL_CAST_SUCCESS 40823",
	"UNIT_HEALTH boss1",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnFA			= mod:NewTargetAnnounce(41001, 4)
local warnShriek		= mod:NewSpellAnnounce(40823)
local warnEnrageSoon	= mod:NewSoonAnnounce(21340)--not actual spell id
local warnEnrage		= mod:NewSpellAnnounce(21340)

local specWarnFA		= mod:NewSpecialWarningYou(41001)

local timerAura			= mod:NewTimer(15, "timerAura", 22599)

mod:AddSetIconOption("FAIcons", 41001, false)

mod.vb.prewarn_enrage = false
mod.vb.enrage = false

local aura = {
	[40880] = true,
	[40882] = true,
	[40883] = true,
	[40891] = true,
	[40896] = true,
	[40897] = true
}

function mod:OnCombatStart(delay)
	self.vb.prewarn_enrage = false
	self.vb.enrage = false
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 41001 then
		warnFA:CombinedShow(1, args.destName)
		if args:IsPlayer() then
			specWarnFA:Show()
		end
		if self.Options.FAIcons then
			self:SetSortedIcon(1, args.destName, 1)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 41001 and self.FAIcons then
		self:SetIcon(args.destName, 0)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 40823 then
		warnShriek:Show()
	end
end

function mod:RAID_BOSS_EMOTE(msg, source)
	if not self.vb.enrage and (source or "") == L.name then
		self.vb.enrage = true
		warnEnrage:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if UnitHealth(uId) / UnitHealthMax(uId) <= 0.23 and self:GetUnitCreatureId(uId) == 22947 and not self.vb.prewarn_enrage then
		self.vb.prewarn_enrage = true
		warnEnrageSoon:Show()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, spellName, _, _, spellId)
	if aura[spellId] then
		timerAura:Start(spellName)
	end
end
