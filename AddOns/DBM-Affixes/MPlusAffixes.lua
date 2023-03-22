local mod	= DBM:NewMod("MPlusAffixes", "DBM-Affixes")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230319211142")
--mod:SetModelID(47785)
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)--All of the S1 DF M+ Dungeons (2516, 2526, 2515, 2521, 1477, 1571, 1176, 960)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA",
	"LOADING_SCREEN_DISABLED"
)

--TODO, fine tune tank stacks/throttle?
--[[
(ability.id = 240446) and type = "begincast"
--]]
local warnExplosion							= mod:NewCastAnnounce(240446, 4)
local warnThunderingFades					= mod:NewFadesAnnounce(396363, 1, 396347)

local specWarnQuake							= mod:NewSpecialWarningMoveAway(240447, nil, nil, nil, 1, 2)
local specWarnSpitefulFixate				= mod:NewSpecialWarningYou(350209, nil, nil, nil, 1, 2)
local specWarnPositiveCharge				= mod:NewSpecialWarningYou(396369, nil, 391990, nil, 1, 13)--Short name is using Positive Charge instead of Mark of Lightning
local specWarnNegativeCharge				= mod:NewSpecialWarningYou(396364, nil, 391991, nil, 1, 13)--Short name is using Netative Charge instead of Mark of Winds
local yellThundering						= mod:NewIconRepeatYell(396363, DBM_CORE_L.AUTO_YELL_ANNOUNCE_TEXT.shortyell)--15-9
local yellThunderingFades					= mod:NewIconFadesYell(396363, nil, nil, nil, "YELL")--8 to 0
local specWarnGTFO							= mod:NewSpecialWarningGTFO(209862, nil, nil, nil, 1, 8)--Volcanic and Sanguine

local timerQuakingCD						= mod:NewNextTimer(20, 240447, nil, nil, nil, 3)
local timerThunderingCD						= mod:NewNextTimer(66, 396363, nil, nil, nil, 3, 396347, nil, nil, 2, 4)
local timerPositiveCharge					= mod:NewBuffFadesTimer(15, 396369, 391990, nil, 2, 5, nil, nil, nil, 1, 5)
local timerNegativeCharge					= mod:NewBuffFadesTimer(15, 396364, 391991, nil, 2, 5, nil, nil, nil, 1, 5)
mod:GroupSpells(396363, 396369, 396364)--Thundering with the two charge spells

mod:AddNamePlateOption("NPSanguine", 226510, "Tank")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 gtfo, 8 personal aggregated alert

local playerThundering = false
local thunderingCounting = false

local function yellRepeater(self, text, total)
	total = total + 1
	if total < 5 then
		yellThundering:Yell(text)
		self:Schedule(1.5, yellRepeater, self, text, total)
	end
end

local function checkThunderin(self)
	local thunderingNTotal, thunderingPTotal = 0, 0
	for uId in DBM:GetGroupMembers() do
		if DBM:UnitDebuff(uId, 396364) then
			thunderingNTotal = thunderingNTotal + 1
		end
		if DBM:UnitDebuff(uId, 396369) then
			thunderingPTotal = thunderingPTotal + 1
		end
	end
	--No possible clears left (ie only 1 or more debuff left of a single type). Force clear them all
	if (thunderingNTotal == 0 and thunderingPTotal >= 1) or (thunderingNTotal >= 1 and thunderingPTotal == 0) then
		if playerThundering then--Avoid double message from SAR clear
			warnThunderingFades:Show()
			playerThundering = false
			yellThundering:Yell(DBM_COMMON_L.CLEAR)
		end
		timerPositiveCharge:Stop()
		timerNegativeCharge:Stop()
		self:Unschedule(yellRepeater)
		yellThunderingFades:Cancel()
	else
		self:Schedule(1, checkThunderin, self)
	end
end

--UGLY function to detect this because there isn't a good API for this.
--player regen was very unreliable due to fact it only fires for self
--This wastes cpu time being an infinite loop though but probably no more so than any WA doing this
local function checkForCombat(self)
	local combatFound = false
	if IsEncounterInProgress() then
		combatFound = true
	end
	if not combatFound then
		for uId in DBM:GetGroupMembers() do
			if UnitAffectingCombat(uId) and not UnitIsDeadOrGhost(uId) then
				combatFound = true
				break
			end
		end
	end
	if combatFound and not thunderingCounting then
		thunderingCounting = true
		timerThunderingCD:Resume()
	elseif not combatFound and thunderingCounting then
		thunderingCounting = false
		timerThunderingCD:Pause()
	end
	self:Schedule(0.25, checkForCombat, self)
end

do
	local validZones
	if DBM:GetTOC() >= 100100 then--Season 2
		validZones = {[657]=true, [1841]=true, [1754]=true, [1458]=true, [2527]=true, [2519]=true, [2451]=true, [2520]=true}
	else--Season 1
		validZones = {[2516]=true, [2526]=true, [2515]=true, [2521]=true, [1477]=true, [1571]=true, [1176]=true, [960]=true}
	end
	local eventsRegistered = false
	local function delayedZoneCheck(self)
		local currentZone = DBM:GetCurrentArea() or 0
		if validZones[currentZone] and not eventsRegistered then
			eventsRegistered = true
			self:RegisterShortTermEvents(
				"SPELL_CAST_START 240446",
			--	"SPELL_CAST_SUCCESS",
				"SPELL_AURA_APPLIED 240447 226510 226512 350209 396369 396364",
			--	"SPELL_AURA_APPLIED_DOSE",
				"SPELL_AURA_REMOVED 396369 396364 226510",
				"SPELL_DAMAGE 209862",
				"SPELL_MISSED 209862",
				"CHALLENGE_MODE_COMPLETED"
			)
			if self.Options.NPSanguine then
				DBM:FireEvent("BossMod_EnableHostileNameplates")
			end
		elseif not validZones[currentZone] and eventsRegistered then
			eventsRegistered = false
			self:UnregisterShortTermEvents()
			self:Unschedule(checkForCombat)
			self:Stop()
			if self.Options.NPSanguine then
				DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
			end
		end
	end
	function mod:LOADING_SCREEN_DISABLED()
		self:Unschedule(delayedZoneCheck)
		self:Schedule(1, delayedZoneCheck, self)
		self:Schedule(3, delayedZoneCheck, self)
	end
	mod.OnInitialize = mod.LOADING_SCREEN_DISABLED
	mod.ZONE_CHANGED_NEW_AREA	= mod.LOADING_SCREEN_DISABLED
end

function mod:CHALLENGE_MODE_COMPLETED()
	self:Stop()--Stop M+ timers on completion as well
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 240446 and self:AntiSpam(3, "aff6") then
		warnExplosion:Show()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 373370 then
		timerNightmareCloudCD:Start(30.5, args.sourceGUID)
	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 240447 then
		if self:AntiSpam(3, "aff5") then
			timerQuakingCD:Start()
		end
		if args:IsPlayer() then
			specWarnQuake:Show()
			specWarnQuake:Play("range5")
		end
	elseif spellId == 226512 and args:IsPlayer() and self:AntiSpam(3, "aff7") then--Sanguine Ichor on player
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 226510 then--Sanguine Ichor on mob
		if self.Options.NPSanguine then
			DBM.Nameplate:Show(true, args.destGUID, spellId)
		end
	elseif spellId == 350209 and args:IsPlayer() and self:AntiSpam(3, "aff8") then
		specWarnSpitefulFixate:Show()
		specWarnSpitefulFixate:Play("targetyou")
	elseif spellId == 396369 or spellId == 396364 then
		if self:AntiSpam(20, "affseasonal") then
			playerThundering = false
			thunderingCounting = true
			timerThunderingCD:Start()
			self:Unschedule(checkThunderin)
			self:Schedule(1, checkThunderin, self)
			self:Unschedule(checkForCombat)
			checkForCombat(self)
		end
		if args:IsPlayer() then
			playerThundering = true
			self:Unschedule(yellRepeater)
			local icon
			if spellId == 396364 then
				specWarnNegativeCharge:Show()
				specWarnNegativeCharge:Play("negative")
				timerNegativeCharge:Start()
				icon = 7
			else
				specWarnPositiveCharge:Show()
				specWarnPositiveCharge:Play("positive")
				timerPositiveCharge:Start()
				icon = 6
			end
			local formatedIcon = DBM_CORE_L.AUTO_YELL_CUSTOM_POSITION:format(icon, "")
			yellRepeater(self, formatedIcon, 0)
			yellThunderingFades:Cancel()
			yellThunderingFades:Countdown(15, 8, icon)--Start icon spam with count at 8 remaining
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 396369 or spellId == 396364 then
		if args:IsPlayer() then
			if playerThundering then--Avoid double message from unit aura clear
				warnThunderingFades:Show()
				playerThundering = false
				yellThundering:Yell(DBM_COMMON_L.CLEAR)
			end
			timerPositiveCharge:Stop()
			timerNegativeCharge:Stop()
			self:Unschedule(yellRepeater)
			yellThunderingFades:Cancel()
		end
	elseif spellId == 226510 then--Sanguine Ichor on mob
		if self.Options.NPSanguine then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 209862 and destGUID == UnitGUID("player") and self:AntiSpam(3, "aff7") then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

--<610.64 01:20:34> [CHAT_MSG_MONSTER_YELL] Marked by lightning!#Raszageth###Global Affix Stalker##0#0##0#3611#nil#0#false#false#false#false", -- [3882]
--<614.44 01:20:38> [CLEU] SPELL_AURA_APPLIED#Creature-0-3023-1477-12533-199388-00007705B2#Raszageth#Player-3726-0C073FB8#Onlysummonz-Khaz'goroth#396364#Mark of Wind#DEBUFF#nil", -- [3912]
