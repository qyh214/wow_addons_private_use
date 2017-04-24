local mod	= DBM:NewMod("Illidan", "DBM-BlackTemple")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 609 $"):sub(12, -3))
mod:SetCreatureID(22917)
mod:SetEncounterID(609)
mod:SetModelID(21135)
mod:SetUsedIcons(8)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 41917 41914 40585 40932 41083 40683 40695",
	"SPELL_CAST_START 40904",
	"SPELL_CAST_SUCCESS 39855",
	"SPELL_DAMAGE 41131",
	"SPELL_MISSED 41131",
	"UNIT_HEALTH boss1",
	"UNIT_DIED"
)

local warnParasite			= mod:NewTargetAnnounce(41917, 3)
local warnDrawSoul			= mod:NewSpellAnnounce(40904, 3)
local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnPhase2Soon		= mod:NewPrePhaseAnnounce(2, 3)
local warnEyebeam			= mod:NewSpellAnnounce(40018, 3)
local warnBarrage			= mod:NewTargetAnnounce(40585, 3)
local warnPhase3			= mod:NewPhaseAnnounce(3)
local warnDemon				= mod:NewAnnounce("WarnDemon", 3 , 2457)
local warnHuman				= mod:NewAnnounce("WarnHuman", 3 , 2457)
local warnFlame				= mod:NewTargetAnnounce(40932, 3)
local warnFlameBurst		= mod:NewSpellAnnounce(41131, 3)
local warnShadowDemon		= mod:NewTargetAnnounce(41117, 3)
local warnPhase4			= mod:NewPhaseAnnounce(4)
local warnPhase4Soon		= mod:NewPrePhaseAnnounce(4, 3)
local warnEnrage			= mod:NewSpellAnnounce(40683, 3)
local warnCaged				= mod:NewSpellAnnounce(40695, 3)

local specWarnParasite		= mod:NewSpecialWarningYou(41917)
local specWarnBarrage		= mod:NewSpecialWarningYou(40585)
local specWarnFlame			= mod:NewSpecialWarningYou(40932)

local timerParasite			= mod:NewTargetTimer(10, 41917)
local timerBarrage			= mod:NewTargetTimer(10, 40585)
local timerNextBarrage		= mod:NewCDTimer(44, 40585)
local timerFlame			= mod:NewTargetTimer(60, 40932)
local timerNextFlameBurst	= mod:NewCDTimer(20, 41131)
local timerShadowDemon		= mod:NewCDTimer(34, 41117)
local timerNextHuman		= mod:NewTimer(74, "TimerNextHuman", "Interface\\Icons\\ability_warrior_offensivestance", nil, nil, 6)
local timerNextDemon		= mod:NewTimer(60, "TimerNextDemon", "Interface\\Icons\\ability_warrior_offensivestance", nil, nil, 6)
local timerEnrage			= mod:NewBuffActiveTimer(10, 40683)
local timerNextEnrage		= mod:NewCDTimer(40, 40683)
local timerCaged			= mod:NewBuffActiveTimer(15, 40695)
local timerPhase4			= mod:NewPhaseTimer(30)

local timerCombatStart		= mod:NewCombatTimer(36)
local berserkTimer			= mod:NewBerserkTimer(1500)

mod:AddBoolOption("RangeFrame")
mod:AddSetIconOption("ParasiteIcon", 41917)

mod.vb.flamesDown = 0
mod.vb.flameBursts = 0
mod.vb.warned_preP2 = false
mod.vb.warned_preP4 = false
mod.vb.phase = 1

local function humanForms(self)
	warnHuman:Show()
	timerNextFlameBurst:Cancel()
	timerNextDemon:Start()
	if self.vb.phase == 4 then
		timerEnrage:Start()
	end
end

function mod:OnCombatStart(delay)
	self.vb.phase = 1
	self.vb.flamesDown = 0
	self.vb.flameBursts = 0
	self.vb.warned_preP2 = false
	self.vb.warned_preP4 = false
	berserkTimer:Start(-delay)
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end 

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 41917 or args.spellId == 41914 then
		warnParasite:Show(args.destName)
		timerParasite:Start(args.destName)
		if args:IsPlayer() then
			specWarnParasite:Show()
		end
		if self.Options.ParasiteIcon then
			self:SetIcon(args.destName, 8)
		end
	elseif args.spellId == 40585 then
		warnBarrage:Show(args.destName)
		timerBarrage:Start(args.destName)
		timerNextBarrage:Start()
		if args:IsPlayer() then
			specWarnBarrage:Show()
		end
	elseif args.spellId == 40932 then
		warnFlame:CombinedShow(0.3, args.destName)
		if args:IsPlayer() and not self:IsTrivial(85) then
			specWarnFlame:Show()
		end
		timerFlame:Start(args.destName)
	elseif args.spellId == 41083 then
		warnShadowDemon:CombinedShow(1, args.destName)
	elseif args.spellId == 40683 then
		warnEnrage:Show()
		timerEnrage:Start()
	elseif args.spellId == 40695 then
		warnCaged:Show()
		timerCaged:Start()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 40904 then
		warnDrawSoul:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 39855 and self:AntiSpam(4, 1) then
		self.vb.phase = 2
		self.vb.flamesDown = 0
		self.vb.warned_preP2 = true
		warnPhase2:Show()
		timerNextBarrage:Start(81)
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, _, _, _, _, spellId)
	if spellId == 41131 and self:AntiSpam(4, 2) then
		warnFlameBurst:Show()
		self.vb.flameBursts = self.vb.flameBursts + 1
		if self.vb.flameBursts < 3 then
			timerNextFlameBurst:Start()
		end
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 22997 then
		self.vb.flamesDown = self.vb.flamesDown + 1
		if self.vb.flamesDown >= 2 then
			self.vb.phase = 3
			if self.Options.RangeFrame then
				DBM.RangeCheck:Show()
			end
			timerNextBarrage:Cancel()
			warnPhase3:Show()
			timerNextDemon:Start(76)
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Pull or msg:find(L.Pull) then
		timerCombatStart:Start()
	elseif msg == L.Eyebeam or msg:find(L.Eyebeam) then
		warnEyebeam:Show()
	elseif msg == L.Demon or msg:find(L.Demon) then
		self.vb.flameBursts = 0
		warnDemon:Show()
		timerNextHuman:Start()
		timerNextFlameBurst:Start()
		timerShadowDemon:Start()
		self:Schedule(74, humanForms, self)
	elseif msg == L.Phase4 or msg:find(L.Phase4) then
		self.vb.phase = 4
		self.vb.warned_preP4 = true
		self:Unschedule(humanForms)
		timerParasite:Cancel()
		timerFlame:Cancel()
		timerNextFlameBurst:Cancel()
		timerShadowDemon:Cancel()
		timerNextHuman:Cancel()
		timerNextDemon:Cancel()
		timerPhase4:Show()
		warnPhase4:Schedule(30)
		timerNextDemon:Start(92)
	end
end

function mod:UNIT_HEALTH(uId)
	local cid = self:GetUnitCreatureId(uId)
	if not self.vb.warned_preP2 and cid == 22917 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.75 then
		self.vb.warned_preP2 = true
		warnPhase2Soon:Show()
	elseif not self.vb.warned_preP4 and cid == 22917 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.35 then
		self.vb.warned_preP4 = true
		warnPhase4Soon:Show()
	end
end
