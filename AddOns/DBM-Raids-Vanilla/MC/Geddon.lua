local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local isWrath = WOW_PROJECT_ID == (WOW_PROJECT_WRATH_CLASSIC or 11)
local catID
if isWrath then
	catID = 5
elseif isBCC or isClassic then
	catID = 6
else--retail or cataclysm classic and later
	catID = 4
end
local mod	= DBM:NewMod("Geddon", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525041212")
mod:SetCreatureID(12056)
mod:SetEncounterID(668)
mod:SetModelID(12129)
mod:SetUsedIcons(8)
mod:SetHotfixNoticeRev(20191122000000)--2019, 11, 22

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 20475 19659",
	"SPELL_AURA_REMOVED 20475",
	"SPELL_CAST_SUCCESS 19695 19659 20478 20475"
)

--[[
(ability.id = 19695 or ability.id = 19659 or ability.id = 20478) and type = "cast"
--]]
local warnInferno		= mod:NewSpellAnnounce(19695, 3)
local warnBomb			= mod:NewTargetNoFilterAnnounce(20475, 4)
local warnArmageddon	= mod:NewSpellAnnounce(20478, 3)

local specWarnBomb		= mod:NewSpecialWarningYou(20475, nil, nil, nil, 3, 2)
local yellBomb			= mod:NewYell(20475)
local yellBombFades		= mod:NewShortFadesYell(20475)
local specWarnInferno	= mod:NewSpecialWarningRun(19695, "Melee", nil, nil, 4, 2)
local specWarnIgnite	= mod:NewSpecialWarningDispel(19659, "RemoveMagic", nil, nil, 1, 2)
local specWarnGTFO		= mod:NewSpecialWarningGTFO(19698, nil, nil, nil, 1, 8)

local timerInfernoCD	= mod:NewCDTimer(21, 19695, nil, nil, nil, 2)--21-27.9
local timerInferno		= mod:NewBuffActiveTimer(8, 19695, nil, nil, nil, 2)
local timerIgniteManaCD	= mod:NewCDTimer(27, 19659, nil, nil, nil, 2)--27-33
local timerBombCD		= mod:NewCDTimer(13.3, 20475, nil, nil, nil, 3)--13.3-18.3
local timerBomb			= mod:NewTargetTimer(8, 20475, nil, nil, nil, 3)
local timerArmageddon	= mod:NewCastTimer(8, 20478, nil, nil, nil, 2)

mod:AddSetIconOption("SetIconOnBombTarget", 20475, false, false, {8})

function mod:OnCombatStart(delay)
	--timerIgniteManaCD:Start(7-delay)--7-19, too much variation for first
	timerBombCD:Start(11-delay)
	if not self:IsTank() and (self:IsEvent() or not self:IsTrivial()) then--Only want to warn if it's a threat
		self:RegisterShortTermEvents(
			"SPELL_DAMAGE 19698",
			"SPELL_MISSED 19698"
		)
	end
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 20475 then
		timerBomb:Start(args.destName)
		if self.Options.SetIconOnBombTarget then
			self:SetIcon(args.destName, 8)
		end
		if args:IsPlayer() then
			specWarnBomb:Show()
			specWarnBomb:Play("runout")
			if self:IsEvent() or not self:IsTrivial() then
				yellBomb:Yell()
				yellBombFades:Countdown(20475)
			end
		else
			warnBomb:Show(args.destName)
		end
	elseif args.spellId == 19659 and self:CheckDispelFilter() then
		specWarnIgnite:CombinedShow(0.3, args.destName)
		specWarnIgnite:ScheduleVoice(0.3, "helpdispel")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 20475 then
		timerBomb:Stop(args.destName)
		if self.Options.SetIconOnBombTarget then
			self:SetIcon(args.destName, 0)
		end
		if args:IsPlayer() then
			yellBombFades:Cancel()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 19695 then
		if self:IsEvent() or not self:IsTrivial() then
			specWarnInferno:Show()
			specWarnInferno:Play("aesoon")
		else
			warnInferno:Show()
		end
		timerInferno:Start()
		timerInfernoCD:Start()
	elseif spellId == 19659 then
		timerIgniteManaCD:Start()
	elseif spellId == 20478 then
		warnArmageddon:Show()
		timerArmageddon:Start()
	elseif args.spellId == 20475 then
		timerBombCD:Start()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, destName, _, _, spellId, spellName)
	if spellId == 19698 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE
