local mod	= DBM:NewMod("Akama", "DBM-BlackTemple")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 585 $"):sub(12, -3))
mod:SetCreatureID(23421, 22841, 23215, 23216)
mod:SetModelID(21357)
mod:SetZone()

mod:RegisterCombat("combat")
mod:SetWipeTime(30)

mod:RegisterEvents(
	"SPELL_AURA_REMOVED 34189"
)

mod:RegisterEventsInCombat(
	"UNIT_DIED"
)

local warnPhase2	= mod:NewPhaseAnnounce(2)

mod.vb.phase = 1

function mod:OnCombatStart(delay)
	self.vb.phase = 1
	self:RegisterShortTermEvents(
		"SWING_DAMAGE",
		"SWING_MISSED",
		"UNIT_SPELLCAST_SUCCEEDED"
	)
	if DBM.BossHealth:IsShown() then
		DBM.BossHealth:Clear()
		DBM.BossHealth:Show(L.name)
		DBM.BossHealth:AddBoss(22841, L.name)
	end
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 34189 and args:GetDestCreatureID() == 23191 then--Coming out of stealth (he's been activated)
		DBM:StartCombat(self, 0)
	end
end

function mod:SWING_DAMAGE(_, sourceName)
	if sourceName == L.name and self.vb.phase == 1 then
		self:UnregisterShortTermEvents()
		self.vb.phase = 2
		warnPhase2:Show()
	end
end
mod.SWING_MISSED = mod.SWING_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if (spellId == 40607 or spellId == 40955) and self.vb.phase == 1 then--Fixate/Summon Shade of Akama Trigger
		self:UnregisterShortTermEvents()
		self.vb.phase = 2
		warnPhase2:Show()
	end
end

function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 22841 then
		DBM:EndCombat(self)
	end
end
