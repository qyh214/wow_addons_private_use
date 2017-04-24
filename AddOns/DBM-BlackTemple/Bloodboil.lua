local mod	= DBM:NewMod("Bloodboil", "DBM-BlackTemple")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 609 $"):sub(12, -3))
mod:SetCreatureID(22948)
mod:SetEncounterID(605)
mod:SetModelID(21443)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 42005 40481 40491 40604",
	"SPELL_AURA_APPLIED_DOSE 40481 42005"
)

--TODO, voice pack support
--TODO, move timers to SUCCESS events
local warnBlood			= mod:NewTargetAnnounce(42005, 3)
local warnWound			= mod:NewStackAnnounce(40481, 2)
local warnStrike		= mod:NewTargetAnnounce(40491, 3)
local warnRage			= mod:NewTargetAnnounce(40604, 4)
local warnRageSoon		= mod:NewSoonAnnounce(40604, 3)
local warnRageEnd		= mod:NewEndAnnounce(40604, 4)

local specWarnBlood		= mod:NewSpecialWarningYou(42005)
local specWarnRage		= mod:NewSpecialWarningYou(40604)

local timerBlood		= mod:NewCDTimer(10, 42005, nil, nil, nil, 5)
local timerWound		= mod:NewTargetTimer(60, 40481, nil, false)
local timerStrikeCD		= mod:NewCDTimer(30, 40491)
local timerRage			= mod:NewCDTimer(52, 40604, nil, nil, nil, 3)
local timerRageEnd		= mod:NewBuffActiveTimer(28, 40604)

local berserkTimer		= mod:NewBerserkTimer(600)

mod.vb.rage = false

local function nextRage(self)
	self.vb.rage = false
	warnRageEnd:Show()
	timerRage:Start()
	warnRageSoon:Schedule(47)
	timerBlood:Start(11.5)
end

function mod:OnCombatStart(delay)
	self.vb.rage = false
	berserkTimer:Start(-delay)
	warnRageSoon:Schedule(47-delay)
	timerBlood:Start(11.5-delay)
	timerStrikeCD:Start(37-delay)
	timerRage:Start(-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 42005 then
		warnBlood:CombinedShow(0.8, args.destName)
		if self:AntiSpam(2, 1) then
			timerBlood:Start()
		end
		if args:IsPlayer() then
			specWarnBlood:Show()
		end
	elseif args.spellId == 40481 and not self.vb.rage then
		local amount = args.amount or 1
		if (amount == 1) or (amount % 3 == 0) then
			warnWound:Show(args.destName, amount)
			timerWound:Start(args.destName)
		end
	elseif args.spellId == 40491 then
		warnStrike:Show(args.destName)
		timerStrikeCD:Start()
	elseif args.spellId == 40604 then
		self.vb.rage = true
		warnRage:Show(args.destName)
		timerBlood:Cancel()
		timerRageEnd:Start()
		self:Schedule(28, nextRage, self)
		if args:IsPlayer() then
			specWarnRage:Show()
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
