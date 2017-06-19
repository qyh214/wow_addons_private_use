local mod	= DBM:NewMod("TeronGorefiend", "DBM-BlackTemple")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 615 $"):sub(12, -3))
mod:SetCreatureID(22871)
mod:SetEncounterID(604)
mod:SetModelID(21254)
mod:SetZone()
mod:SetUsedIcons(4, 5, 6, 7, 8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 40243 40251",
	"SPELL_AURA_REMOVED 40243 40251",
	"SPELL_CAST_SUCCESS 40239"
)

--Incinerate useful?
local warnCrushed			= mod:NewTargetAnnounce(40243, 3)
local warnIncinerate		= mod:NewSpellAnnounce(40239, 3)
local warnDeath				= mod:NewTargetAnnounce(40251, 3)

local specWarnDeath			= mod:NewSpecialWarningYou(40251, nil, nil, nil, 1, 2)
local specWarnDeathEnding	= mod:NewSpecialWarningMoveAway(40251, nil, nil, nil, 3, 2)

local timerCrushed			= mod:NewBuffActiveTimer(15, 40243, nil, nil, nil, 5, nil, DBM_CORE_HEALER_ICON)
local timerDeath			= mod:NewTargetTimer(55, 40251, nil, nil, nil, 3)
local timerVengefulSpirit	= mod:NewTimer(60, "TimerVengefulSpirit", 40325, nil, nil, 1)

local voiceDeath			= mod:NewVoice(40251)--targetyou/runout

mod:AddBoolOption("CrushIcon", false)

local warnCrushedTargets = {}
mod.vb.crushIcon = 8

local function showCrushedTargets(self)
	warnCrushed:Show(table.concat(warnCrushedTargets, "<, >"))
	table.wipe(warnCrushedTargets)
	self.vb.crushIcon = 8
end

function mod:OnCombatStart(delay)
	table.wipe(warnCrushedTargets)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 40243 then
		warnCrushedTargets[#warnCrushedTargets + 1] = args.destName
		timerCrushed:Start()
		self:Unschedule(showCrushedTargets)
		if self.Options.CrushIcon then
			self:SetIcon(args.destName, self.vb.crushIcon, 15)
			self.vb.crushIcon = self.vb.crushIcon - 1
		end
		if #warnCrushedTargets >= 5 then
			showCrushedTargets()
		else
			self:Schedule(0.5, showCrushedTargets, self)
		end
	elseif args.spellId == 40251 then
		timerDeath:Start(args.destName)
		if args:IsPlayer() then
			specWarnDeath:Show()
			voiceDeath:Play("targetyou")
			specWarnDeathEnding:Schedule(50)
			voiceDeath:Schedule(50, "runout")
		else
			warnDeath:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 40243 then
		if self.Options.CrushIcon then
			self:SetIcon(args.destName, 0)
		end
	elseif args.spellId == 40251 then
		timerDeath:Stop(args.destName)
		timerVengefulSpirit:Start(args.destName)
		if args:IsPlayer() then
			specWarnDeathEnding:Cancel()
			voiceDeath:Cancel()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 40239 then
		warnIncinerate:Show()
	end
end
