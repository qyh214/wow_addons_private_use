local mod	= DBM:NewMod("Chromaggus", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200524145731")
mod:SetCreatureID(14020)
mod:SetEncounterID(616)
mod:SetModelID(14367)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 23309 23313 23189 23316 23312",
	"SPELL_AURA_APPLIED 23155 23169 23153 23154 23170 23128 23537",
--	"SPELL_AURA_REFRESH",
	"SPELL_AURA_REMOVED 23155 23169 23153 23154 23170 23128",
	"UNIT_HEALTH boss1"
)

--(ability.id = 23309 or ability.id = 23313 or ability.id = 23189 or ability.id = 23315 or ability.id = 23312) and type = "begincast"
local warnBreath		= mod:NewAnnounce("WarnBreath", 2, 23316)
local warnRed			= mod:NewSpellAnnounce(23155, 2, nil, false)
local warnGreen			= mod:NewSpellAnnounce(23169, 2, nil, false)
local warnBlue			= mod:NewSpellAnnounce(23153, 2, nil, false)
local warnBlack			= mod:NewSpellAnnounce(23154, 2, nil, false)
local warnFrenzy		= mod:NewSpellAnnounce(23128, 3, nil, "Tank|RemoveEnrage|Healer", 4)
local warnPhase2Soon	= mod:NewPrePhaseAnnounce(2, 1)
local warnPhase2		= mod:NewPhaseAnnounce(2)
local warnMutation		= mod:NewCountAnnounce(23174, 4)

local specWarnBronze	= mod:NewSpecialWarningYou(23170, nil, nil, nil, 1, 8)

local timerBreath		= mod:NewCastTimer(2, "TimerBreath", 23316, nil, nil, 3)
local timerBreathCD		= mod:NewTimer(60, "TimerBreathCD", 23316, nil, nil, 3)
local timerFrenzy		= mod:NewBuffActiveTimer(8, 23128, nil, "Tank|RemoveEnrage|Healer", 3, 5, nil, DBM_CORE_L.TANK_ICON..DBM_CORE_L.ENRAGE_ICON)
local timerVuln			= mod:NewTimer(17, "TimerVulnCD", 4166)-- seen 16.94 - 25.53, avg 21.8

mod.vb.phase = 1
local mydebuffs = 0

function mod:OnCombatStart(delay)
	timerBreathCD:Start(30-delay, L.Breath1)
	timerBreathCD:Start(-delay, L.Breath2)--60
	self.vb.phase = 1
	mydebuffs = 0
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(23309, 23313, 23189, 23316, 23312) then
		warnBreath:Show(args.spellName)
		timerBreath:Start(2, args.spellName)
		timerBreath:UpdateIcon(args.spellId)
		timerBreathCD:Start(args.spellName)
		timerBreathCD:UpdateIcon(args.spellId)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 23155 then
		if self:AntiSpam(3, 1) then
			warnRed:Show()
		end
		if args:IsPlayer() then
			mydebuffs = mydebuffs + 1
			if mydebuffs >= 3 then
				warnMutation:Show(mydebuffs.."/5")
			end
		end
	elseif args.spellId == 23169 then
		if self:AntiSpam(3, 2) then
			warnGreen:Show()
		end
		if args:IsPlayer() then
			mydebuffs = mydebuffs + 1
			if mydebuffs >= 3 then
				warnMutation:Show(mydebuffs.."/5")
			end
		end
	elseif args.spellId == 23153 then
		if self:AntiSpam(3, 3) then
			warnBlue:Show()
		end
		if args:IsPlayer() then
			mydebuffs = mydebuffs + 1
			if mydebuffs >= 3 then
				warnMutation:Show(mydebuffs.."/5")
			end
		end
	elseif args.spellId == 23154 then
		if self:AntiSpam(3, 4) then
			warnBlack:Show()
		end
		if args:IsPlayer() then
			mydebuffs = mydebuffs + 1
			if mydebuffs >= 3 then
				warnMutation:Show(mydebuffs.."/5")
			end
		end
	elseif args.spellId == 23170 and args:IsPlayer() then
		specWarnBronze:Show()
		specWarnBronze:Play("useitem")
		mydebuffs = mydebuffs + 1
		if mydebuffs >= 3 then
			warnMutation:Show(mydebuffs.."/5")
		end
	elseif args.spellId == 23128 then
		warnFrenzy:Show()
		timerFrenzy:Start()
	elseif args.spellId == 23537 then
		self.vb.phase = 2
		warnPhase2:Show()
	end
end
--Possibly needed hard to say.
--mod.SPELL_AURA_REFRESH = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 23155 then
		if args:IsPlayer() then
			mydebuffs = mydebuffs - 1
		end
	elseif args.spellId == 23169 then
		if args:IsPlayer() then
			mydebuffs = mydebuffs - 1
		end
	elseif args.spellId == 23153 then
		if args:IsPlayer() then
			mydebuffs = mydebuffs - 1
		end
	elseif args.spellId == 23154 then
		if args:IsPlayer() then
			mydebuffs = mydebuffs - 1
		end
	elseif args.spellId == 23170 and args:IsPlayer() then
		mydebuffs = mydebuffs - 1
	elseif args.spellId == 23128 then
		timerFrenzy:Stop()
	end
end

function mod:UNIT_HEALTH(uId)
	if UnitHealth(uId) / UnitHealthMax(uId) <= 0.25 and self:GetUnitCreatureId(uId) == 14020 and self.vb.phase == 1 then
		warnPhase2Soon:Show()
		self.vb.phase = 1.5
	end
end

function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if (msg == L.VulnEmote or msg:find(L.VulnEmote)) then
		self:SendSync("Vulnerable")
	end
end

function mod:OnSync(msg, Name)
	if not self:IsInCombat() then return end
	if msg == "Vulnerable" then
		timerVuln:Start()
	end
end
