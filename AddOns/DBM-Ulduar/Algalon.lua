local mod	= DBM:NewMod("Algalon", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 240 $"):sub(12, -3))
mod:SetCreatureID(32871)
mod:SetEncounterID(1130)
mod:SetMinSyncRevision(234)
mod:SetModelID(28641)
mod:SetModelSound("Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_Aggro01.ogg", "Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_Slay02.ogg")
mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.YellKill)
mod:SetWipeTime(60)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 64584 64443",
	"SPELL_CAST_SUCCESS 65108 64122 64598 62301",
	"SPELL_AURA_APPLIED 64412",
	"SPELL_AURA_APPLIED_DOSE 64412",
	"SPELL_AURA_REMOVED 64412",
	"RAID_BOSS_EMOTE",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_HEALTH boss1"
)

local announceBigBang			= mod:NewSpellAnnounce(64584, 4)
local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnPhase2Soon			= mod:NewAnnounce("WarnPhase2Soon", 2)
local announcePreBigBang		= mod:NewPreWarnAnnounce(64584, 10, 3)
local announceBlackHole			= mod:NewSpellAnnounce(65108, 2)
local announceCosmicSmash		= mod:NewSpellAnnounce(64596, 4)
local announcePhasePunch		= mod:NewStackAnnounce(65108, 4, nil, "Tank|Healer")

local specwarnStarLow			= mod:NewSpecialWarning("warnStarLow", "Tank|Healer")
local specWarnPhasePunch		= mod:NewSpecialWarningStack(64412, nil, 4)
local specWarnBigBang			= mod:NewSpecialWarningSpell(64584)
local specWarnCosmicSmash		= mod:NewSpecialWarningSpell(64596)

local enrageTimer				= mod:NewBerserkTimer(360)
local timerNextBigBang			= mod:NewNextTimer(90.5, 64584, nil, nil, nil, 2)
local timerBigBangCast			= mod:NewCastTimer(8, 64584, nil, nil, nil, 2)
local timerNextCollapsingStar	= mod:NewTimer(15, "NextCollapsingStar", 227161)
local timerCDCosmicSmash		= mod:NewCDTimer(25, 64596, nil, nil, nil, 3)
local timerCastCosmicSmash		= mod:NewCastTimer(4.5, 64596)
local timerPhasePunch			= mod:NewTargetTimer(45, 64412, nil, "Tank", 2, 5)
local timerNextPhasePunch		= mod:NewNextTimer(16, 64412, nil, "Tank", 2, 5)

local sentLowHP = {}
local warnedLowHP = {}
local warned_preP2 = false
local warned_star = false

function mod:OnCombatStart(delay)
	warned_preP2 = false
	warned_star = false
	enrageTimer:Start(360-delay)--All timers +8 for combat start RP
	timerNextBigBang:Start(90-delay)
	announcePreBigBang:Schedule(80-delay)
	timerCDCosmicSmash:Start(25-delay)
	timerNextCollapsingStar:Start(15-delay)
	table.wipe(sentLowHP)
	table.wipe(warnedLowHP)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(64584, 64443) then 	-- Big Bang
		timerBigBangCast:Start()
		timerNextBigBang:Start()
		announceBigBang:Show()
		announcePreBigBang:Schedule(80)
		specWarnBigBang:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(65108, 64122) then 	-- Black Hole Explosion
		announceBlackHole:Show()
		warned_star = false
	elseif args:IsSpellID(64598, 62301) then	-- Cosmic Smash
		timerCastCosmicSmash:Start()
		timerCDCosmicSmash:Start()
		announceCosmicSmash:Show()
		specWarnCosmicSmash:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 64412 then
		timerNextPhasePunch:Start()
		local amount = args.amount or 1
		if args:IsPlayer() and amount >= 4 then
			specWarnPhasePunch:Show(args.amount)
		end
		timerPhasePunch:Start(args.destName)
		announcePhasePunch:Show(args.destName, amount)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 64412 then
		timerPhasePunch:Cancel(args.destName)
	end
end

function mod:RAID_BOSS_EMOTE(msg)
	if msg == L.Emote_CollapsingStar or msg:find(L.Emote_CollapsingStar) then
		timerNextCollapsingStar:Start()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Phase2 or msg:find(L.Phase2) then
		timerNextCollapsingStar:Cancel()
		warnPhase2:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	local cid = self:GetUnitCreatureId(uId)
	local guid = UnitGUID(uId)
	if cid == 32871 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.23 and not warned_preP2 then
		warned_preP2 = true
		warnPhase2Soon:Show()
	elseif cid == 32955 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.25 and not sentLowHP[guid] then
		sentLowHP[guid] = true
		self:SendSync("lowhealth", guid)
	end
end

function mod:OnSync(msg, guid)
	if msg == "lowhealth" and guid and not warnedLowHP[guid] then
		warnedLowHP[guid] = true
		specwarnStarLow:Show()
	end
end
