local mod	= DBM:NewMod("YoggSaron", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 248 $"):sub(12, -3))
mod:SetCreatureID(33288)
mod:SetEncounterID(1143)
mod:SetModelID(28817)
mod:RegisterCombat("combat_yell", L.YellPull)
mod:SetUsedIcons(6, 7, 8)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 64059 64189 63138",
	"SPELL_CAST_SUCCESS 64144",
	"SPELL_SUMMON 62979",
	"SPELL_AURA_APPLIED 63802 63830 63881 64126 64125 63138 63894 64167 64163",
	"SPELL_AURA_REMOVED 63894 64167 64163 63830 63881",
	"SPELL_AURA_REMOVED_DOSE 63050"
)

--TODO, if blizzard writes a dungeon journal for ulduar in 7.3.5, convert more of these warnings to auto local
local warnMadness 					= mod:NewCastAnnounce(64059, 2)
local warnFervorCast 				= mod:NewCastAnnounce(63138, 3)
local warnSqueeze					= mod:NewTargetAnnounce(64125, 3)
local warnFervor					= mod:NewTargetAnnounce(63138, 4)
local warnDeafeningRoarSoon			= mod:NewPreWarnAnnounce(64189, 5, 3)
local warnGuardianSpawned 			= mod:NewAnnounce("WarningGuardianSpawned", 3, 62979)
local warnCrusherTentacleSpawned	= mod:NewAnnounce("WarningCrusherTentacleSpawned", 2, 93708)
local warnP2 						= mod:NewPhaseAnnounce(2, 2)
local warnP3 						= mod:NewPhaseAnnounce(3, 2)
local warnSanity 					= mod:NewAnnounce("WarningSanity", 3, 63050)
local warnBrainLink 				= mod:NewTargetAnnounce(63802, 3)
local warnBrainPortalSoon			= mod:NewAnnounce("WarnBrainPortalSoon", 2, 57687)
local warnEmpowerSoon				= mod:NewSoonAnnounce(64486, 4)

local specWarnBrainLink 			= mod:NewSpecialWarningYou(63802)
local specWarnSanity 				= mod:NewSpecialWarning("SpecWarnSanity")
local specWarnMadnessOutNow			= mod:NewSpecialWarning("SpecWarnMadnessOutNow")
local specWarnBrainPortalSoon		= mod:NewSpecialWarning("specWarnBrainPortalSoon", false)
local specWarnDeafeningRoar			= mod:NewSpecialWarningSpell(64189, nil, nil, nil, 1, 2)
local specWarnFervor				= mod:NewSpecialWarningYou(63138, nil, nil, nil, 1, 2)
local specWarnMalady				= mod:NewSpecialWarningYou(63830, nil, nil, nil, 1, 2)
local specWarnMaladyNear			= mod:NewSpecialWarningClose(63830, nil, nil, nil, 1, 2)
local yellSqueeze					= mod:NewYell(64125)

local enrageTimer					= mod:NewBerserkTimer(900)
local timerFervor					= mod:NewTargetTimer(15, 63138, nil, false, 2)
local timerMaladyCD					= mod:NewCDTimer(19, 63830, nil, nil, nil, 3)
local timerBrainLinkCD				= mod:NewCDTimer(32, 63802, nil, nil, nil, 3)
local brainportal					= mod:NewTimer(20, "NextPortal", 57687, nil, nil, 5)
local timerLunaricGaze				= mod:NewCastTimer(4, 64163, nil, nil, nil, 2)
local timerNextLunaricGaze			= mod:NewCDTimer(8.5, 64163, nil, nil, nil, 2)
local timerEmpower					= mod:NewCDTimer(46, 64465, nil, nil, nil, 3)
local timerEmpowerDuration			= mod:NewBuffActiveTimer(10, 64465, nil, nil, nil, 3)
local timerMadness 					= mod:NewCastTimer(60, 64059, nil, nil, nil, 5)
local timerCastDeafeningRoar		= mod:NewCastTimer(2.3, 64189, nil, nil, nil, 2)
local timerNextDeafeningRoar		= mod:NewNextTimer(30, 64189, nil, nil, nil, 2)
local timerAchieve					= mod:NewAchievementTimer(420, 3012, "TimerSpeedKill")

mod:AddBoolOption("ShowSaraHealth", false)
mod:AddBoolOption("SetIconOnFearTarget", true)
mod:AddBoolOption("SetIconOnFervorTarget", false)
mod:AddBoolOption("SetIconOnBrainLinkTarget", true)

mod.vb.phase = 1
local brainLinkTargets = {}
mod.vb.brainLinkIcon = 7
mod.vb.Guardians = 0
local numberOfPlayers = 1

function mod:OnCombatStart(delay)
	numberOfPlayers = DBM:GetNumRealGroupMembers()
	self.vb.Guardians = 0
	self.vb.phase = 1
	enrageTimer:Start()
	timerAchieve:Start()
	if self.Options.ShowSaraHealth and not DBM.BossHealth:IsShown() then
		DBM.BossHealth:Show(L.name)
	end
	if self.Options.ShowSaraHealth then
		DBM.BossHealth:AddBoss(33134, L.Sara)
	end
	table.wipe(brainLinkTargets)
end

function mod:FervorTarget()
	local targetname = self:GetBossTarget(33134)
	if not targetname then return end
	if targetname == UnitName("player") and self:AntiSpam(4, 1) then
		specWarnFervor:Show()
		specWarnFervor:Play("targetyou")
	end
end

function mod:warnBrainLink()
	warnBrainLink:Show(table.concat(brainLinkTargets, "<, >"))
	timerBrainLinkCD:Start()--VERIFY ME
	table.wipe(brainLinkTargets)
	self.vb.brainLinkIcon = 7
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 64059 then	-- Induce Madness
		timerMadness:Start()
		warnMadness:Show()
		brainportal:Schedule(60)
		warnBrainPortalSoon:Schedule(78)
		specWarnBrainPortalSoon:Schedule(78)
		specWarnMadnessOutNow:Schedule(55)
	elseif args.spellId == 64189 then		--Deafening Roar
		timerNextDeafeningRoar:Start()
		warnDeafeningRoarSoon:Schedule(55)
		timerCastDeafeningRoar:Start()
		specWarnDeafeningRoar:Show()
		specWarnDeafeningRoar:Play("silencesoon")
	elseif args.spellId == 63138 and not self:IsTrivial(85) then		--Sara's Fervor
		self:ScheduleMethod(0.2, "FervorTarget")
		warnFervorCast:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 64144 and self:GetUnitCreatureId(args.sourceGUID) == 33966 then 
		warnCrusherTentacleSpawned:Show()
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 62979 then
		self.vb.Guardians = self.vb.Guardians + 1
		warnGuardianSpawned:Show(self.vb.Guardians)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 63802 then		-- Brain Link
		self:UnscheduleMethod("warnBrainLink")
		brainLinkTargets[#brainLinkTargets + 1] = args.destName
		if self.Options.SetIconOnBrainLinkTarget then
			self:SetIcon(args.destName, self.vb.brainLinkIcon, 30)
		end
		self.vb.brainLinkIcon = self.vb.brainLinkIcon - 1
		if args:IsPlayer() then
			specWarnBrainLink:Show()
			specWarnBrainLink:Play("linegather")
		end
		self:ScheduleMethod(0.2, "warnBrainLink")
	elseif args:IsSpellID(63830, 63881) then   -- Malady of the Mind (Death Coil) 
		timerMaladyCD:Start()
		if self.Options.SetIconOnFearTarget then
			self:SetIcon(args.destName, 8) 
		end
		if args:IsPlayer() then
			specWarnMalady:Show()
			specWarnMalady:Play("targetyou")
		else
			local uId = DBM:GetRaidUnitId(args.destName) 
			if uId then 
				local inRange = CheckInteractDistance(uId, 2)
				if inRange then 
					specWarnMaladyNear:Show(args.destName)
					specWarnMaladyNear:Play("runaway")
				end
			end
		end 
	elseif args:IsSpellID(64126, 64125) then	-- Squeeze
		warnSqueeze:Show(args.destName)
		if args:IsPlayer() then
			yellSqueeze:Yell()
		end
	elseif args.spellId == 63138 then	-- Sara's Fervor
		warnFervor:Show(args.destName)
		timerFervor:Start(args.destName)
		if self.Options.SetIconOnFervorTarget then
			self:SetIcon(args.destName, 7, 15)
		end
		if args:IsPlayer() and self:AntiSpam(4, 1) then 
			specWarnFervor:Show()
			specWarnFervor:Play("targetyou")
		end
	elseif args.spellId == 63894 then	-- Shadowy Barrier of Yogg-Saron (this is happens when p2 starts)
		self.vb.phase = 2
		timerMaladyCD:Start(13)--VERIFY ME
		timerBrainLinkCD:Start(19)--VERIFY ME
		brainportal:Start(60)
		warnBrainPortalSoon:Schedule(57)
		specWarnBrainPortalSoon:Schedule(57)
		warnP2:Show()
		if self.Options.ShowSaraHealth then
			DBM.BossHealth:RemoveBoss(33134)
		end
		if not (self.Options.HealthFrame or DBM.Options.AlwaysShowHealthFrame) then
			DBM.BossHealth:Hide()
		end
	elseif args:IsSpellID(64167, 64163) then	-- Lunatic Gaze (reduces sanity)
		timerLunaricGaze:Start()
	elseif args.spellId == 64465 then
		timerEmpower:Start()
		timerEmpowerDuration:Start()
		warnEmpowerSoon:Schedule(40)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 63894 then		-- Shadowy Barrier removed from Yogg-Saron (start p3)
		self:SendSync("Phase3")			-- Sync this because you don't get it in your combat log if you are in brain room.
	elseif args:IsSpellID(64167, 64163) then	-- Lunatic Gaze
		timerNextLunaricGaze:Start()
	elseif args:IsSpellID(63830, 63881) and self.Options.SetIconOnFearTarget then   -- Malady of the Mind (Death Coil) 
		self:SetIcon(args.destName, 0) 
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	if args.spellId == 63050 and args.destGUID == UnitGUID("player") then
		if args.amount == 50 then
			warnSanity:Show(args.amount)
		elseif args.amount == 25 or args.amount == 15 or args.amount == 5 then
			warnSanity:Show(args.amount)
			specWarnSanity:Show(args.amount)
		end
	end
end

function mod:OnSync(msg)
	if msg == "Phase3" then
		self.vb.phase = 3
		brainportal:Cancel()
		warnBrainPortalSoon:Cancel()
		timerMaladyCD:Cancel()
		timerBrainLinkCD:Cancel()
		timerEmpower:Start()
		if numberOfPlayers == 1 then
			timerMadness:Cancel()
			specWarnMadnessOutNow:Cancel()
		end
		warnP3:Show()
		warnEmpowerSoon:Schedule(40)
		timerNextDeafeningRoar:Start(30)
		warnDeafeningRoarSoon:Schedule(25)
	end
end
