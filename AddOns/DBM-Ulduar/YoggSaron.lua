local mod	= DBM:NewMod("YoggSaron", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230414072734")
mod:SetCreatureID(33288)
if not mod:IsClassic() then
	mod:SetEncounterID(1143)
else
	mod:SetEncounterID(756)
end
mod:SetModelID(28817)
mod:RegisterCombat("combat_yell", L.YellPull)
mod:SetUsedIcons(8, 7, 6, 2, 1)
mod:SetHotfixNoticeRev(20230122000000)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 64059 64189 63138",
	"SPELL_CAST_SUCCESS 64144 64465 64167 64163",
	"SPELL_SUMMON 62979",
	"SPELL_AURA_APPLIED 63802 63830 63881 64126 64125 63138 63894 64465 63042",
	"SPELL_AURA_REMOVED 63802 63894 64167 64163 63830 63138 63881 64465",
	"SPELL_AURA_REMOVED_DOSE 63050"
)

--TODO, add Dominate Mind casts by guardians to classic wrath
--TODO, add drain life timer to wrath classic
--The cast frequency of Drain Life cast by Immortal Guardians and Marked Immortal guardians has been reduced from 20-30 seconds to 10 seconds
local warnMadness 					= mod:NewCastAnnounce(64059, 2)
local warnSqueeze					= mod:NewTargetNoFilterAnnounce(64125, 3)
local warnFervor					= mod:NewTargetAnnounce(63138, 4)
local warnDeafeningRoarSoon			= mod:NewPreWarnAnnounce(64189, 5, 3)
local warnGuardianSpawned 			= mod:NewAnnounce("WarningGuardianSpawned", 3, 62979)
local warnCrusherTentacleSpawned	= mod:NewAnnounce("WarningCrusherTentacleSpawned", 2, 93708)
local warnP2 						= mod:NewPhaseAnnounce(2, 2)
local warnP3 						= mod:NewPhaseAnnounce(3, 2)
local warnSanity 					= mod:NewAnnounce("WarningSanity", 3, 63050, nil, nil, nil, 63050)
local warnBrainLink 				= mod:NewTargetAnnounce(63802, 3)
local warnBrainPortalSoon			= mod:NewAnnounce("WarnBrainPortalSoon", 2, 57687)
local warnEmpowerSoon				= mod:NewSoonAnnounce(64465, 4)
local warnDominateMind				= mod:NewTargetNoFilterAnnounce(63042, 3)--Pre nerf mind control

local specWarnBrainLink 			= mod:NewSpecialWarningYou(63802, nil, nil, nil, 1, 2)
local specWarnSanity 				= mod:NewSpecialWarning("SpecWarnSanity", nil, nil, nil, 1, nil, nil, nil, 63050)--Warning, no voice pack support
local specWarnMadnessOutNow			= mod:NewSpecialWarning("SpecWarnMadnessOutNow", nil, nil, nil, 1, nil, nil, nil, 64059)--Warning, no voice pack support
local specWarnDeafeningRoar			= mod:NewSpecialWarningSpell(64189, nil, nil, nil, 1, 2)
local specWarnFervor				= mod:NewSpecialWarningYou(63138, nil, nil, nil, 1, 2)
local specWarnMalady				= mod:NewSpecialWarningYou(63830, nil, nil, nil, 1, 2)
local specWarnMaladyNear			= mod:NewSpecialWarningClose(63830, nil, nil, nil, 1, 2)
local yellMalady					= mod:NewYell(63830)
local yellSqueeze					= mod:NewYell(64125)

local enrageTimer					= mod:NewBerserkTimer(900)
local timerFervor					= mod:NewTargetTimer(15, 63138, nil, false, 2)
--local timerMaladyCD				= mod:NewCDTimer(18.1, 63830, nil, nil, nil, 3)
--local timerBrainLinkCD			= mod:NewCDTimer(32, 63802, nil, nil, nil, 3)
local brainportal					= mod:NewTimer(20, "NextPortal", 57687, nil, nil, 5)
local timerLunaricGaze				= mod:NewCastTimer(4, 64163, nil, nil, 2, 5)
local timerNextLunaricGaze			= mod:NewCDTimer(8.5, 64163, nil, nil, nil, 2)
local timerShadowBeaconCD			= mod:NewCDTimer(46, 64465, nil, nil, nil, 3)
local timerShadowBeacon				= mod:NewBuffActiveTimer(10, 64465, nil, nil, nil, 3)
local timerMadness 					= mod:NewCastTimer(60, 64059, nil, nil, nil, 5)
local timerCastDeafeningRoar		= mod:NewCastTimer(2.3, 64189, nil, nil, 2, 5)
local timerNextDeafeningRoar		= mod:NewNextTimer(30, 64189, nil, nil, nil, 2)
local timerAchieve
if WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1) then
	timerAchieve					= mod:NewAchievementTimer(420, 12396)
else
	timerAchieve					= mod:NewAchievementTimer(420, 3012)
end

mod:AddSetIconOption("SetIconOnFearTarget", 63830, true, false, {6})
mod:AddSetIconOption("SetIconOnFervorTarget", 63138, false, false, {7})
mod:AddSetIconOption("SetIconOnBrainLinkTarget", 63802, true, false, {1, 2})
mod:AddSetIconOption("SetIconOnBeacon", 64465, true, true, {1, 2, 3, 4, 5, 6, 7, 8})
mod:AddInfoFrameOption(63050)
mod:AddNamePlateOption("NPAuraOnBeacon", 64465, true)

local brainLinkTargets = {}
local SanityBuff = DBM:GetSpellInfo(63050)
mod.vb.brainLinkIcon = 2
mod.vb.beaconIcon = 8
mod.vb.Guardians = 0
mod.vb.numberOfPlayers = 1

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.numberOfPlayers = DBM:GetNumRealGroupMembers()
	self.vb.brainLinkIcon = 2
	self.vb.beaconIcon = 8
	self.vb.Guardians = 0
	enrageTimer:Start()
	timerAchieve:Start()
	table.wipe(brainLinkTargets)
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(SanityBuff)
		DBM.InfoFrame:Show(30, "playerdebuffstacks", 63050, 2)--Sorted lowest first (highest first is default of arg not given)
	end
	if self.Options.NPAuraOnBeacon then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
	if self.Options.NPAuraOnBeacon then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end


function mod:OnTimerRecovery()
	self.vb.numberOfPlayers = DBM:GetNumRealGroupMembers()
end

function mod:FervorTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") and self:AntiSpam(4, 1) then
		specWarnFervor:Show()
		specWarnFervor:Play("targetyou")
	end
end

local function warnBrainLinkWarning(self)
	warnBrainLink:Show(table.concat(brainLinkTargets, "<, >"))
	--timerBrainLinkCD:Start()--VERIFY ME
	table.wipe(brainLinkTargets)
	self.vb.brainLinkIcon = 2
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 64059 then	-- Induce Madness
		timerMadness:Start()
		warnMadness:Show()
		specWarnMadnessOutNow:Schedule(55)
	elseif args.spellId == 64189 then		--Deafening Roar
		timerNextDeafeningRoar:Start()
		warnDeafeningRoarSoon:Schedule(55)
		timerCastDeafeningRoar:Start()
		specWarnDeafeningRoar:Show()
		specWarnDeafeningRoar:Play("silencesoon")
	elseif args.spellId == 63138 and not self:IsTrivial() then		--Sara's Fervor
		self:BossTargetScanner(args.sourceGUID, "FervorTarget", 0.1, 12, true, nil, nil, nil, true)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 64144 and self:GetUnitCreatureId(args.sourceGUID) == 33966 then
		warnCrusherTentacleSpawned:Show()
	elseif args.spellId == 64465 and self:AntiSpam(3, 4) then
		timerShadowBeaconCD:Start()
		timerShadowBeacon:Start()
		warnEmpowerSoon:Schedule(40)
	elseif args:IsSpellID(64167, 64163) and self:AntiSpam(3, 3) then	-- Lunatic Gaze
		--In stages less than 3, it can be used to detect brain portals withoute emote because skulls in brain room cast this on spawn
		if self:GetStage(3, 1) then
			if self:IsClassic() then
				brainportal:Start(90)
				warnBrainPortalSoon:Schedule(80)
			else
				brainportal:Start(60)
				warnBrainPortalSoon:Schedule(50)
			end
		else--P3 yogg casts
			timerLunaricGaze:Start()
		end
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
		self:Unschedule(warnBrainLinkWarning)
		brainLinkTargets[#brainLinkTargets + 1] = args.destName
		if self.Options.SetIconOnBrainLinkTarget then
			self:SetIcon(args.destName, self.vb.brainLinkIcon)
		end
		self.vb.brainLinkIcon = self.vb.brainLinkIcon - 1
		if args:IsPlayer() then
			specWarnBrainLink:Show()
			specWarnBrainLink:Play("linegather")
		end
		if #brainLinkTargets == 2 then
			warnBrainLinkWarning(self)
		else
			self:Schedule(0.5, warnBrainLinkWarning, self)
		end
	elseif args:IsSpellID(63830, 63881) then   -- Malady of the Mind (Death Coil)
		--timerMaladyCD:Start()
		if self.Options.SetIconOnFearTarget then
			self:SetIcon(args.destName, 6)
		end
		if args:IsPlayer() then
			specWarnMalady:Show()
			specWarnMalady:Play("targetyou")
			yellMalady:Yell()
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
			self:SetIcon(args.destName, 7)
		end
		if args:IsPlayer() and self:AntiSpam(4, 1) then
			specWarnFervor:Show()
			specWarnFervor:Play("targetyou")
		end
	elseif args.spellId == 63894 and self:GetStage(2, 1) then	-- Shadowy Barrier of Yogg-Saron (this is happens when p2 starts)
		self:SetStage(2)
		--timerMaladyCD:Start(13)--VERIFY ME
		--timerBrainLinkCD:Start(19)--VERIFY ME
		if self:IsClassic() then
			brainportal:Start(60)
			warnBrainPortalSoon:Schedule(50)
		else
			brainportal:Start(10.5)
			warnBrainPortalSoon:Schedule(0.5)
		end
		warnP2:Show()
	elseif args.spellId == 64465 then
		if self:AntiSpam(5, 5) then
			self.vb.beaconIcon = 8
		end
		if self.Options.SetIconOnBeacon then
			self:ScanForMobs(args.destGUID, 2, self.vb.beaconIcon, 1, nil, 8, "SetIconOnBeacon", true, nil, nil, true)
		end
		self.vb.beaconIcon = self.vb.beaconIcon - 1
		if self.Options.NPAuraOnBeacon then
			DBM.Nameplate:Show(true, args.destGUID, args.spellId, nil, 10)
		end
	elseif args.spellId == 63042 then
		warnDominateMind:CombinedShow(1, args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 63802 and self.Options.SetIconOnBrainLinkTarget then		-- Brain Link
		self:SetIcon(args.destName, 0)
	elseif args.spellId == 63138 and self.Options.SetIconOnFervorTarget then	-- Sara's Fervor
		self:SetIcon(args.destName, 0)
	elseif args.spellId == 63894 then		-- Shadowy Barrier removed from Yogg-Saron (start p3)
		self:SendSync("Phase3")			-- Sync this because you don't get it in your combat log if you are in brain room.
	elseif args:IsSpellID(64167, 64163) and self:AntiSpam(3, 2) and self:GetStage(3) then	-- Lunatic Gaze
		timerNextLunaricGaze:Start()
	elseif args:IsSpellID(63830, 63881) and self.Options.SetIconOnFearTarget then   -- Malady of the Mind (Death Coil)
		self:SetIcon(args.destName, 0)
	elseif args.spellId == 64465 then
		if self.Options.SetIconOnBeacon then
			self:ScanForMobs(args.destGUID, 2, 0, 1, nil, 8, "SetIconOnBeacon", true, nil, nil, true)
		end
		if self.Options.NPAuraOnBeacon then
			DBM.Nameplate:Hide(true, args.destGUID, args.spellId)
		end
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	if args.spellId == 63050 and args.destGUID == UnitGUID("player") then
		if args.amount == 50 then
			warnSanity:Show(args.amount)
		elseif args.amount == 35 or args.amount == 25 or args.amount == 15 then
			specWarnSanity:Show(args.amount)
		end
	end
end

function mod:OnSync(msg)
	if msg == "Phase3" and self:GetStage(3, 1) then
		self:SetStage(3)
		brainportal:Cancel()
		warnBrainPortalSoon:Cancel()
		--timerMaladyCD:Cancel()
		--timerBrainLinkCD:Cancel()
--		timerShadowBeaconCD:Start()--Cast on phasing, even though no mobs up yet, starting initial CD that way
--		if self.vb.numberOfPlayers == 1 then
			timerMadness:Cancel()
			specWarnMadnessOutNow:Cancel()
--		end
		warnP3:Show()
		warnEmpowerSoon:Schedule(40)
		timerNextDeafeningRoar:Start(30)
		warnDeafeningRoarSoon:Schedule(25)
	end
end
