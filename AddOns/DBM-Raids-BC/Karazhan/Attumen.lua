local mod	= DBM:NewMod("Attumen", "DBM-Raids-BC", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230523061139")
mod:SetCreatureID(16151, 16152)--15550
mod:SetEncounterID(652, 2444)
mod:SetModelID(16416)
mod:SetBossHPInfoToHighest()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 29711 29833",
	"SPELL_SUMMON 29714 29799",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_DIED"
)

local warnKnockdown	= mod:NewSpellAnnounce(29711, 4)
local warningCurse	= mod:NewSpellAnnounce(29833, 4)
local warnPhase2	= mod:NewPhaseAnnounce(2)

local timerCurseCD	= mod:NewCDTimer(27, 29833, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)

function mod:OnCombatStart(delay)
	self:SetStage(1)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 29711 then
		warnKnockdown:Show()
	elseif args.spellId == 29833 then
		warningCurse:Show()
		timerCurseCD:Start(self.vb.phase == 2 and 30.5 or 27)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.DBM_ATH_YELL_1 and self:GetStage(1) then
		self:SetStage(2)
		warnPhase2:Show()
		timerCurseCD:Start(25)
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 29799 and self:GetStage(1) then
		self:SetStage(2)
		warnPhase2:Show()
		timerCurseCD:Start(20.2)
	-- elseif args.spellId == 29714 then -- when attument arrives
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 16152 then
		DBM:EndCombat(self)
	end
end
