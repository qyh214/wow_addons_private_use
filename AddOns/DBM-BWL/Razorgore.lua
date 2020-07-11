local mod	= DBM:NewMod("Razorgore", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200524145731")
mod:SetCreatureID(12435, 99999)--Bogus detection to prevent invalid kill detection if razorgore happens to die in phase 1
mod:SetEncounterID(610)--BOSS_KILL is valid, but ENCOUNTER_END is not
mod:DisableEEKillDetection()--So disable only EE
mod:SetModelID(10115)
mod:SetMinSyncRevision(168)
mod:SetHotfixNoticeRev(20200320000000)--2020, March, 20th
mod:SetMinSyncRevision(20200320000000)--2020, March, 20th

mod:RegisterCombat("yell", L.YellPull)
mod:SetWipeTime(180)--guesswork

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 22425",
	"SPELL_CAST_SUCCESS 23040 19873",
	"SPELL_AURA_APPLIED 23023",
	"SPELL_AURA_REMOVED 23023",
	"CHAT_MSG_MONSTER_EMOTE",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_DIED"
)

--ability.id = 22425 and type = "begincast" or (ability.id = 23040 or ability.id = 19873) and type = "cast"
local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnFireballVolley	= mod:NewCastAnnounce(22425, 3)
local warnConflagration		= mod:NewTargetAnnounce(23023, 2)
local warnEggsLeft			= mod:NewCountAnnounce(19873, 1)

local specWarnFireballVolley= mod:NewSpecialWarningMoveTo(22425, false, nil, nil, 2, 2)

local timerConflagration	= mod:NewTargetTimer(10, 23023, nil, nil, nil, 3)
local timerAddsSpawn		= mod:NewTimer(47, "TimerAddsSpawn", 19879, nil, nil, 1)--Only for start of adds, not adds after the adds.

mod.vb.phase = 1
mod.vb.eggsLeft = 30

function mod:OnCombatStart(delay)
	timerAddsSpawn:Start()
	self.vb.phase = 1
	self.vb.eggsLeft = 30
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 22425 then
		if self.Options.SpecWarn22425moveto then
			specWarnFireballVolley:Show(DBM_CORE_L.BREAK_LOS)
			specWarnFireballVolley:Play("findshelter")
		else
			warnFireballVolley:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 23040 and self.vb.phase < 2 then
		self:SendSync("Phase2")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 23023 and args:IsDestTypePlayer() then
		warnConflagration:Show(args.destName)
		timerConflagration:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 23023 then
		timerConflagration:Stop(args.destName)
	end
end

--For some reason this no longer works
function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if (msg == L.Phase2Emote or msg:find(L.Phase2Emote)) and self.vb.phase < 2 then
		self:SendSync("Phase2")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if ((msg == L.YellEgg1 or msg:find(L.YellEgg1))
	or (msg == L.YellEgg2 or msg:find(L.YellEgg2))
	or (msg == L.YellEgg3) or msg:find(L.YellEgg3))
	and self.vb.phase < 2 then
		self.vb.eggsLeft = self.vb.eggsLeft - 2
		warnEggsLeft:Show(string.format("%d/%d",30-self.vb.eggsLeft,30))
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 12435 then
		if self.vb.phase == 2 then--Only trigger kill for unit_died if he dies in phase 2, otherwise it's an auto wipe.
			DBM:EndCombat(self)
		else
			DBM:EndCombat(self, true)--Pass wipe arg end combat
		end
	end
end

function mod:OnSync(msg)
	if not self:IsInCombat() then return end
	if msg == "Phase2" and self.vb.phase < 2 then
		warnPhase2:Show()
		self.vb.phase = 2
	end
end
