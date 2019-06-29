local mod	= DBM:NewMod("Magtheridon", "DBM-Outlands")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 164 $"):sub(12, -3))
mod:SetCreatureID(17257)
mod:SetEncounterID(651)
mod:SetModelID(18527)
mod:RegisterCombat("combat_emote", L.DBM_MAG_EMOTE_PULL)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 30528 30616",
	"SPELL_CAST_SUCCESS 30511",
	"CHAT_MSG_MONSTER_YELL"
)

local warningHeal			= mod:NewSpellAnnounce(30528, 3)
local warningInfernal		= mod:NewSpellAnnounce(30511, 2)
local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnPhase3			= mod:NewPhaseAnnounce(3)

local specWarnBlastNova		= mod:NewSpecialWarningInterrupt(30616, nil, nil, nil, 3, 2)
local specWarnHeal			= mod:NewSpecialWarningInterrupt(30528, "HasInterrupt", nil, nil, 1, 2)

local timerHeal				= mod:NewCastTimer(2, 30528, nil, nil, nil, 4)
local timerPhase2			= mod:NewTimer(120, "timerP2", "135566", nil, nil, 6)
local timerBlastNovaCD		= mod:NewCDTimer(54, 30616, nil, nil, nil, 2)
local timerDebris			= mod:NewNextTimer(15, 36449, nil, nil, nil, 2)--Only happens once per fight, after the phase 3 yell.

mod.vb.phase = 1

function mod:OnCombatStart(delay)
	self.vb.phase = 1
	timerPhase2:Start(-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 30528 then
		if self:CheckInterruptFilter(args.sourceGUID) then
			specWarnHeal:Show(args.sourceName)
			specWarnHeal:Play("kickcast")
			timerHeal:Start()
		else
			warningHeal:Show()
		end
	elseif args.spellId == 30616 then
		specWarnBlastNova:Show(L.name)
		specWarnBlastNova:Play("kickcast")
		timerBlastNovaCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 30511 then
		warningInfernal:Show()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.DBM_MAG_YELL_PHASE2 or msg:find(L.DBM_MAG_YELL_PHASE2) then
		self.vb.phase = 2
		warnPhase2:Show()
		timerBlastNovaCD:Start()
		timerPhase2:Cancel()
	elseif msg == L.DBM_MAG_YELL_PHASE3 or msg:find(L.DBM_MAG_YELL_PHASE3) then
		self.vb.phase = 3
		warnPhase3:Show()
		timerDebris:Start()
	end
end
