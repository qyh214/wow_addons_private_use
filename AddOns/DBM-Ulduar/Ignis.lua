local mod	= DBM:NewMod("Ignis", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 247 $"):sub(12, -3))
mod:SetCreatureID(33118)
mod:SetEncounterID(1136)
mod:SetModelID(29185)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 62680 63472",
	"SPELL_CAST_SUCCESS 62548 63474",
	"SPELL_AURA_APPLIED 62717 63477",
	"SPELL_AURA_REMOVED 62717 63477"
)

local announceSlagPot			= mod:NewTargetAnnounce(63477, 3)

local warnFlameJetsCast			= mod:NewSpecialWarningCast(63472, "SpellCaster")

local timerFlameJetsCast		= mod:NewCastTimer(2.7, 63472)
local timerFlameJetsCooldown	= mod:NewCDTimer(35, 63472, nil, nil, nil, 2)
local timerScorchCooldown		= mod:NewNextTimer(25, 63473, nil, nil, nil, 5)
local timerSlagPot				= mod:NewTargetTimer(10, 63477, nil, nil, nil, 3)
local timerAchieve				= mod:NewAchievementTimer(240, 2930, "TimerSpeedKill")

local voiceFlameJetsCast		= mod:NewVoice(63472, "SpellCaster")--stopcast

mod:AddBoolOption("SlagPotIcon", false)

function mod:OnCombatStart(delay)
	timerAchieve:Start()
	timerScorchCooldown:Start(12-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62680, 63472) then		-- Flame Jets
		timerFlameJetsCast:Start()
		warnFlameJetsCast:Show()
		voiceFlameJetsCast:Play("stopcast")
		timerFlameJetsCooldown:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(62548, 63474) then	-- Scorch
		timerScorchCooldown:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62717, 63477) then		-- Slag Pot
		announceSlagPot:Show(args.destName)
		timerSlagPot:Start(args.destName)
		if self.Options.SlagPotIcon then
			self:SetIcon(args.destName, 8, 10)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(62717, 63477) then		-- Slag Pot
		if self.Options.SlagPotIcon then
			self:SetIcon(args.destName, 0)
		end
	end
end
