local mod	= DBM:NewMod("MPlusAffixes", "DBM-Affixes")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230606100810")
--mod:SetModelID(47785)
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)--Stays active in all zones for zone change handlers, but registers events based on dungeon ids

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA",
	"LOADING_SCREEN_DISABLED"
)

--TODO, fine tune tank stacks/throttle?
--[[
(ability.id = 240446 or ability.id = 409492) and type = "begincast"
 or (ability.id = 408556 or ability.id = 408801) and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp) and (source.name = "Afflicted Soul") or (target.type = "NPC" and target.firstSeen = timestamp) and (target.name = "Afflicted Soul")
--]]
local warnExplosion							= mod:NewCastAnnounce(240446, 4)
local warnIncorporeal						= mod:NewCastAnnounce(408801, 4)
local warnAfflictedCry						= mod:NewCastAnnounce(409492, 4, nil, nil, nil, nil, nil, 14)--spellId, color, castTime, icon, optionDefault, optionName, _, soundOption
local warnDestabalize						= mod:NewCastAnnounce(408805, 4, nil, nil, false)
local warnSpitefulFixate					= mod:NewYouAnnounce(350209, 4)

local specWarnQuake							= mod:NewSpecialWarningMoveAway(240447, nil, nil, nil, 1, 2)
local specWarnSpitefulFixate				= mod:NewSpecialWarningYou(350209, false, nil, 2, 1, 2)
local specWarnEntangled						= mod:NewSpecialWarningYou(408556, nil, nil, nil, 1, 14)

local specWarnGTFO							= mod:NewSpecialWarningGTFO(209862, nil, nil, nil, 1, 8)--Volcanic and Sanguine

local timerQuakingCD						= mod:NewNextTimer(20, 240447, nil, nil, nil, 3)
local timerEntangledCD						= mod:NewCDTimer(30, 408556, nil, nil, nil, 3, 396347, nil, nil, 2, 3, nil, nil, nil, true)
local timerAfflictedCD						= mod:NewCDTimer(30, 409492, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON, nil, 3, 3)
local timerIncorporealCD					= mod:NewCDTimer(45, 408801, nil, nil, nil, 5, nil, nil, nil, 3, 3)

mod:AddNamePlateOption("NPSanguine", 226510, "Tank")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 gtfo, 8 personal aggregated alert

local incorporealCounting = false
local incorpDetected = false
local afflictedCounting = false
local afflictedDetected = false

local function checkEntangled(self)
	if timerEntangledCD:GetRemaining() > 0 then
		--Timer exists, do nothing
		return
	end
	timerEntangledCD:Start(25)
	self:Schedule(30, checkEntangled, self)
end

local function checkAfflicted(self)
	if timerAfflictedCD:GetRemaining() > 0 then
		--Timer exists, do nothing
		return
	end
	timerAfflictedCD:Start(25)
	self:Schedule(30, checkAfflicted, self)
end

local function checkIncorp(self)
	if timerIncorporealCD:GetRemaining() > 0 then
		--Timer exists, do nothing
		return
	end
	timerIncorporealCD:Start(40)
	self:Schedule(45, checkIncorp, self)
end

--UGLY function to detect this because there isn't a good API for this.
--player regen was very unreliable due to fact it only fires for self
--This wastes cpu time being an infinite loop though but probably no more so than any WA doing this
local function checkForCombat(self)
	local combatFound = self:GroupInCombat()
	if incorpDetected then
		if combatFound and not incorporealCounting then
			incorporealCounting = true
			timerIncorporealCD:Resume()
			if DBM.Options.DebugMode then
				local incorpRemaining = timerIncorporealCD:GetRemaining()
				local afflictRemaining = timerAfflictedCD:GetRemaining()
				if incorpRemaining and incorpRemaining > 0 then--Shouldn't be 0, unless a player clicked it off, in which case we can't reschedule
					self:Unschedule(checkIncorp)
					self:Schedule(incorpRemaining+5, checkIncorp, self)
					DBM:Debug("Experimental reschedule of checkIncorp running because you're in debug mode")
				end
			end
		elseif not combatFound and incorporealCounting then
			incorporealCounting = false
			timerIncorporealCD:Pause()
			self:Unschedule(checkIncorp)--Soon as a pause happens this can no longer be trusted
		end
	end
	if afflictedDetected then
		if combatFound and not afflictedCounting then
			afflictedCounting = true
			timerAfflictedCD:Resume()
			if DBM.Options.DebugMode then
				local afflictRemaining = timerAfflictedCD:GetRemaining()
				if afflictRemaining and afflictRemaining > 0 then--Shouldn't be 0, unless a player clicked it off, in which case we can't reschedule
					self:Unschedule(checkAfflicted)
					self:Schedule(afflictRemaining+5, checkAfflicted, self)
					DBM:Debug("Experimental reschedule of checkAfflicted running because you're in debug mode")
				end
			end
		elseif not combatFound and afflictedCounting then
			afflictedCounting = false
			timerAfflictedCD:Pause()
			self:Unschedule(checkAfflicted)--Soon as a pause happens this can no longer be trusted
		end
	end
	self:Schedule(0.25, checkForCombat, self)
end

do
	local validZones
	if (C_MythicPlus.GetCurrentSeason() or 0) == 10 then--DF Season 2
		--657, 1841, 1754, 1458, 2527, 2519, 2451, 2520
		validZones = {[657]=true, [1841]=true, [1754]=true, [1458]=true, [2527]=true, [2519]=true, [2451]=true, [2520]=true}
	else--Season 1
		--2516, 2526, 2515, 2521, 1477, 1571, 1176, 960
		validZones = {[2516]=true, [2526]=true, [2515]=true, [2521]=true, [1477]=true, [1571]=true, [1176]=true, [960]=true}
	end
	local eventsRegistered = false
	local function delayedZoneCheck(self)
		local currentZone = DBM:GetCurrentArea() or 0
		if validZones[currentZone] and not eventsRegistered then
			eventsRegistered = true
			self:RegisterShortTermEvents(
				"SPELL_CAST_START 240446 409492 408805",
			--	"SPELL_CAST_SUCCESS",
				"SPELL_AURA_APPLIED 240447 226510 226512 350209 408556 408801",
			--	"SPELL_AURA_APPLIED_DOSE",
				"SPELL_AURA_REMOVED 226510",
--				"SPELL_DAMAGE 209862",
--				"SPELL_MISSED 209862",
				"CHALLENGE_MODE_COMPLETED"
			)
			if self.Options.NPSanguine then
				DBM:FireEvent("BossMod_EnableHostileNameplates")
			end
		elseif not validZones[currentZone] and eventsRegistered then
			eventsRegistered = false
			afflictedCounting = false
			incorporealCounting = false
			incorpDetected = false
			afflictedDetected = false
			self:UnregisterShortTermEvents()
			self:Unschedule(checkForCombat)
			self:Unschedule(checkEntangled)
			self:Unschedule(checkAfflicted)
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
	afflictedCounting = false
	incorporealCounting = false
	incorpDetected = false
	afflictedDetected = false
	self:UnregisterShortTermEvents()
	self:Unschedule(checkForCombat)
	self:Unschedule(checkEntangled)
	self:Unschedule(checkAfflicted)
	self:Stop()--Stop M+ timers on completion as well
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 240446 and self:AntiSpam(3, "aff1") then
		warnExplosion:Show()
	elseif spellId == 409492 and self:AntiSpam(3, "aff2") then
		warnAfflictedCry:Show()
		warnAfflictedCry:Play("helpspirit")
		if not afflictedDetected then
			afflictedDetected = true
		end
		--This one is interesting cause it runs every 30 seconds, sometimes skips a cast and goes 60, but also pauses out of combat
		afflictedCounting = true
		timerAfflictedCD:Start()
		self:Unschedule(checkForCombat)
		self:Unschedule(checkAfflicted)
		checkForCombat(self)
		self:Schedule(35, checkAfflicted, self)
	elseif spellId == 408805 and self:AntiSpam(3, "aff3") then
		warnDestabalize:Show()
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
	elseif spellId == 226512 and args:IsPlayer() and self:AntiSpam(3, "aff4") then--Sanguine Ichor on player
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 226510 then--Sanguine Ichor on mob
		if self.Options.NPSanguine then
			DBM.Nameplate:Show(true, args.destGUID, spellId)
		end
	elseif spellId == 350209 and args:IsPlayer() and self:AntiSpam(3, "aff5") then
		if self.Options.Specwarn350209you then
			specWarnSpitefulFixate:Show()
			specWarnSpitefulFixate:Play("targetyou")
		else
			warnSpitefulFixate:Show()
		end
	elseif spellId == 408556 then
		if self:AntiSpam(20, "aff6") then
			timerEntangledCD:Start(30)
			--Entangled check runs every 30 seconds, and if conditions aren't met for it activating it skips and goes into next 30 second CD
			--This checks if it was cast (by seeing if timer exists) if not, it starts next timer for next possible cast
			self:Unschedule(checkEntangled)
			self:Schedule(35, checkEntangled, self)
		end
		if args:IsPlayer() then
			specWarnEntangled:Show()
			specWarnEntangled:Play("breakvine")--breakvine
		end
	elseif spellId == 408801 and self:AntiSpam(20, "aff7") then
		if not incorpDetected then
			incorpDetected = true
		end
		--This one is interesting cause it runs every 45 seconds, sometimes skips a cast and goes 90, but also pauses out of combat
		incorporealCounting = true
		timerIncorporealCD:Start()
		self:Unschedule(checkForCombat)
		self:Unschedule(checkIncorp)
		checkForCombat(self)
		self:Schedule(50, checkIncorp, self)
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 226510 then--Sanguine Ichor on mob
		if self.Options.NPSanguine then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	end
end

--[[
function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 209862 and destGUID == UnitGUID("player") and self:AntiSpam(3, "aff7") then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE
--]]

--<610.64 01:20:34> [CHAT_MSG_MONSTER_YELL] Marked by lightning!#Raszageth###Global Affix Stalker##0#0##0#3611#nil#0#false#false#false#false", -- [3882]
--<614.44 01:20:38> [CLEU] SPELL_AURA_APPLIED#Creature-0-3023-1477-12533-199388-00007705B2#Raszageth#Player-3726-0C073FB8#Onlysummonz-Khaz'goroth#396364#Mark of Wind#DEBUFF#nil", -- [3912]
