local mod	= DBM:NewMod("Moroes", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20190417010011")
mod:SetCreatureID(15687)--Moroes
mod:SetEncounterID(653)
mod:SetModelID(16540)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 29405 35096 29562",
	"SPELL_AURA_APPLIED 29448 29425 34694 29572 37023 37066",
	"SPELL_AURA_REMOVED 34694 29425"
)

local warningVanish			= mod:NewSpellAnnounce(29448, 4)
local warningGarrote		= mod:NewTargetAnnounce(37066, 2)
local warningGouge			= mod:NewTargetAnnounce(29425, 4)
local warningBlind			= mod:NewTargetAnnounce(34694, 3)
local warningMortalStrike	= mod:NewTargetAnnounce(29572, 1)
local warningFrenzy			= mod:NewSpellAnnounce(37023, 4)
local warningManaBurn		= mod:NewCastAnnounce(29405, 3, nil, false)
local warningGreaterHeal	= mod:NewCastAnnounce(35096, 3, nil, false)
local warningHolyLight		= mod:NewCastAnnounce(29562, 3, nil, false)

local timerVanishCD			= mod:NewCDTimer(31, 29448, nil, nil, nil, 6)
local timerGouge			= mod:NewTargetTimer(6, 29425, nil, nil, nil, 3)
local timerBlind			= mod:NewTargetTimer(10, 34694, nil, nil, nil, 3)
local timerMortalStrike		= mod:NewTargetTimer(5, 29572, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
	timerVanishCD:Start(-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 29405 then
		warningManaBurn:Show()
	elseif args.spellId == 35096 then
		warningGreaterHeal:Show()
	elseif args.spellId == 29562 then
		warningHolyLight:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 29448 then
		warningVanish:Show()
		self:AntiSpam(20, 1)
	elseif args.spellId == 29425 then
		warningGouge:Show(args.destName)
		timerGouge:Show(args.destName)
	elseif args.spellId == 34694 then
		warningBlind:Show(args.destName)
		timerBlind:Show(args.destName)
	elseif args.spellId == 29572 then
		warningMortalStrike:Show(args.destName)
		timerMortalStrike:Show(args.destName)
	elseif args.spellId == 37023 then--Frenzy, he's no longer going to vanish.
		warningFrenzy:Show()
		timerVanishCD:Cancel()
	elseif args.spellId == 37066 then
		warningGarrote:Show(args.destName)
		if self:AntiSpam(20, 1) then--firing this event here instead, since he does garrote as soon as he comes out of vanish.
			timerVanishCD:Start()
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 34694 then
		timerBlind:Stop(args.destName)
	elseif args.spellId == 29425 then
		timerGouge:Stop(args.destName)
	end
end
