--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("C'Thun", 531, 1551)
if not mod then return end
mod:RegisterEnableMob(15727, 15589, 15802) -- C'Thun, Eye of C'Thun, Flesh Tentacle
mod:SetEncounterID(717)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local digestiveAcidList = {}
local digestiveAcidListTokens = {}
local healthList = {}
local deaths = 0
local UpdateInfoBoxList

local timeP1GlareStart = 48 -- delay for first dark glare from engage onwards
local timeP1Glare = 86 -- interval for dark glare
local timeP1GlareDuration = 40 -- duration of dark glare

local firstGlare = false
local firstWarning = false
local lastKnownCThunTarget = nil

local timerDarkGlare = nil
local timerGroupWarning = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.claw_tentacle = "Claw Tentacle"
	L.claw_tentacle_desc = "Timers for the claw tentacle."
	L.claw_tentacle_icon = "inv_misc_monstertail_06"

	L.giant_claw_tentacle = "Giant Claw"
	L.giant_claw_tentacle_desc = "Timers for the giant claw tentacle."
	L.giant_claw_tentacle_icon = "inv_misc_monstertail_06"

	L.eye_tentacles = "Eye Tentacles"
	L.eye_tentacles_desc = "Timers for the 8 eye tentacles."
	L.eye_tentacles_icon = "spell_shadow_siphonmana"

	L.giant_eye_tentacle = "Giant Eye"
	L.giant_eye_tentacle_desc = "Timers for the giant eye tentacle."
	L.giant_eye_tentacle_icon = "spell_shadow_evileye"

	L.weakened = CL.weakened
	L.weakened_desc = "Warn for Weakened state."
	L.weakened_icon = "ability_rogue_findweakness"

	L.dark_glare_message = "%s: %s (Group %s)" -- Dark Glare: PLAYER_NAME (Group 1)
	L.stomach = "Stomach"
	L.tentacle = "Tentacle (%d)"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		"eye_tentacles",
		{26029, "CASTBAR"}, -- Dark Glare
		"claw_tentacle",
		{26134, "ICON", "SAY", "ME_ONLY_EMPHASIZE"}, -- Eye Beam
		26476, -- Digestive Acid
		"giant_claw_tentacle",
		"giant_eye_tentacle",
		{"weakened", "COUNTDOWN", "EMPHASIZE"},
		"infobox",
	},{
		[26029] = CL.stage:format(1),
		[26476] = CL.stage:format(2),
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Birth", 26586)
	self:Log("SPELL_CAST_START", "EyeBeam", 26134)
	if not self:Vanilla() then
		self:Log("SPELL_CAST_START", "EyeBeam", 32950)
	end
	if not self:Retail() then
		self:Log("SPELL_CAST_START", "EyeBeam", 341722)
	end
	self:Log("SPELL_AURA_APPLIED", "DigestiveAcidApplied", 26476)
	self:Log("SPELL_AURA_APPLIED_DOSE", "DigestiveAcidAppliedDose", 26476)
	self:Log("SPELL_AURA_REMOVED", "DigestiveAcidRemoved", 26476)

	self:Death("EyeOfCThunKilled", 15589)
	self:Death("GiantEyeTentacleKilled", 15334)
	self:Death("FleshTentacleKilled", 15802)
end

function mod:OnEngage()
	lastKnownCThunTarget = nil
	firstGlare = true
	firstWarning = true
	digestiveAcidList = {}
	digestiveAcidListTokens = {}
	self:SetStage(1)

	self:Message("stages", "cyan", CL.stage:format(1), false)

	local darkGlare = self:SpellName(26029)
	self:Bar(26029, timeP1GlareStart, darkGlare) -- Dark Glare
	self:DelayedMessage(26029, timeP1GlareStart - 5, "orange", CL.custom_sec:format(darkGlare, 5)) -- Dark Glare in 5 sec
	self:DelayedMessage(26029, timeP1GlareStart, "red", darkGlare, 26029) -- Dark Glare

	timerDarkGlare = self:ScheduleTimer("DarkGlare", timeP1GlareStart)
	timerGroupWarning = self:ScheduleTimer("GroupWarning", timeP1GlareStart - 3)

	self:Bar("claw_tentacle", 8, L.claw_tentacle, L.claw_tentacle_icon)
	self:Bar("eye_tentacles", 45, L.eye_tentacles, L.eye_tentacles_icon)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:Birth(args)
		local npcId = self:MobId(args.sourceGUID)
		if npcId == 15725 then -- Claw Tentacle
			self:Bar("claw_tentacle", 8, L.claw_tentacle, L.claw_tentacle_icon)
		elseif npcId == 15726 and args.time-prev > 5 then -- Eye Tentacles
			prev = args.time
			self:Bar("eye_tentacles", self:GetStage() == 2 and 30 or 45, L.eye_tentacles, L.eye_tentacles_icon)
			self:Message("eye_tentacles", "red", L.eye_tentacles, L.eye_tentacles_icon)
			self:PlaySound("eye_tentacles", "alarm")
		elseif npcId == 15728 then -- Giant Claw Tentacle
			self:Bar("giant_claw_tentacle", 60, L.giant_claw_tentacle, L.giant_claw_tentacle_icon)
			self:Message("giant_claw_tentacle", "red", L.giant_claw_tentacle, L.giant_claw_tentacle_icon)
			self:PlaySound("giant_claw_tentacle", "alert")
		elseif npcId == 15334 then -- Giant Eye Tentacle
			self:Bar("giant_eye_tentacle", 60, L.giant_eye_tentacle, L.giant_eye_tentacle_icon)
			self:Message("giant_eye_tentacle", "red", L.giant_eye_tentacle, L.giant_eye_tentacle_icon)
			self:PlaySound("giant_eye_tentacle", "warning")
		end
	end
end

do
	local function printTarget(self, name, guid)
		lastKnownCThunTarget = guid
		self:PrimaryIcon(26134, name)
		if self:Me(guid) then
			self:PersonalMessage(26134)
			self:Say(26134, nil, nil, "Eye Beam")
			self:PlaySound(26134, "warning", nil, name)
		end
	end

	function mod:EyeBeam(args) -- Cast by Eye of C'Thun and the Giant Eye Tentacle
		self:GetUnitTarget(printTarget, 0.1, args.sourceGUID)
	end
end

function mod:EyeOfCThunKilled()
	deaths = 0
	healthList = {}
	if self:Retail() and not self:IsEngaged() then
		self:Engage("NoEngage") -- XXX temp until the eye has a boss frame
	end
	self:SetStage(2)

	self:StopBar(L.claw_tentacle)
	self:PrimaryIcon(26134) -- Clear icon

	local darkGlare = self:SpellName(26029)
	self:StopBar(darkGlare) -- Dark Glare
	self:StopBar(CL.cast:format(darkGlare)) -- Cast: Dark Glare
	self:CancelDelayedMessage(darkGlare) -- Dark Glare
	self:CancelDelayedMessage(CL.custom_sec:format(darkGlare, 5)) -- Dark Glare in 5 sec
	self:CancelDelayedMessage(CL.over:format(darkGlare)) -- Dark Glare Over

	-- cancel the repeaters
	self:CancelTimer(timerDarkGlare)
	self:CancelTimer(timerGroupWarning)

	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:Bar("giant_claw_tentacle", 12.3, L.giant_claw_tentacle, L.giant_claw_tentacle_icon)
	self:Bar("eye_tentacles", 41.3, L.eye_tentacles, L.eye_tentacles_icon)
	self:Bar("giant_eye_tentacle", 43.1, L.giant_eye_tentacle, L.giant_eye_tentacle_icon)

	self:OpenInfo("infobox", CL.other:format("BigWigs", L.stomach))
	self:SetInfo("infobox", 1, L.tentacle:format(1))
	self:SetInfoBar("infobox", 1, 1)
	self:SetInfo("infobox", 2, "100%")
	self:SetInfo("infobox", 3, L.tentacle:format(2))
	self:SetInfoBar("infobox", 3, 1)
	self:SetInfo("infobox", 4, "100%")
	self:SimpleTimer(UpdateInfoBoxList, 0.5)

	self:PlaySound("stages", "long")
end

function mod:GiantEyeTentacleKilled()
	-- Just in case it managed to get a cast of Eye Beam off
	self:PrimaryIcon(26134) -- Clear icon
end

do
	local function ResetInfoHealth(self)
		self:SetInfoBar("infobox", 1, 1)
		self:SetInfo("infobox", 2, "100%")
		self:SetInfoBar("infobox", 3, 1)
		self:SetInfo("infobox", 4, "100%")
	end
	function mod:CThunWeakened()
		deaths = 0
		healthList = {}
		self:Message("weakened", "green", CL.weakened, L.weakened_icon)
		self:Bar("weakened", 45, CL.weakened, L.weakened_icon)

		self:Bar("giant_claw_tentacle", 51, L.giant_claw_tentacle, L.giant_claw_tentacle_icon)
		self:Bar("eye_tentacles", 81, L.eye_tentacles, L.eye_tentacles_icon)
		self:Bar("giant_eye_tentacle", 82, L.giant_eye_tentacle, L.giant_eye_tentacle_icon)

		self:SetInfoBar("infobox", 1, 0)
		self:SetInfo("infobox", 2, CL.dead)
		self:SetInfoBar("infobox", 3, 0)
		self:SetInfo("infobox", 4, CL.dead)

		self:ScheduleTimer(ResetInfoHealth, 44, self)
		self:PlaySound("weakened", "long")
	end
end

function mod:GroupWarning()
	if firstWarning then
		firstWarning = false
		timerGroupWarning = self:ScheduleRepeatingTimer("GroupWarning", timeP1Glare)
	end
	if lastKnownCThunTarget then
		for unit in self:IterateGroup() do
			local guid = self:UnitGUID(unit)
			if lastKnownCThunTarget == guid then
				local name = self:UnitName(unit)
				if not IsInRaid() then
					self:Message(26029, "red", L.dark_glare_message:format(self:SpellName(26029), self:ColorName(name), 1), 26029)
					self:PlaySound("stages", "alert")
				else
					for i = 1, 40 do
						local n, _, group = GetRaidRosterInfo(i)
						if name == n then
							self:Message(26029, "red", L.dark_glare_message:format(self:SpellName(26029), self:ColorName(name), group), 26029)
							self:PlaySound("stages", "alert")
							break
						end
					end
				end
				break
			end
		end
	end
end

function mod:DarkGlare()
	if firstGlare then
		firstGlare = false
		timerDarkGlare = self:ScheduleRepeatingTimer("DarkGlare", timeP1Glare)
	end
	local darkGlare = self:SpellName(26029)
	self:CastBar(26029, timeP1GlareDuration, darkGlare)
	self:Bar(26029, timeP1Glare, darkGlare) -- Dark Glare
	self:DelayedMessage(26029, timeP1Glare - .1, "red", darkGlare, 26029) -- Dark Glare
	self:DelayedMessage(26029, timeP1Glare - 5, "orange", CL.custom_sec:format(darkGlare, 5)) -- Dark Glare in 5 sec
	self:DelayedMessage(26029, timeP1GlareDuration, "red", CL.over:format(darkGlare)) -- Dark Glare Over
end

function mod:DigestiveAcidApplied(args)
	digestiveAcidList[args.destName] = 1
	for unit in self:IterateGroup() do
		local guid = self:UnitGUID(unit)
		if args.destGUID == guid then
			digestiveAcidListTokens[args.destName] = unit
			break
		end
	end
	self:SetInfoByTable("infobox", digestiveAcidList, 3, 5)
end

function mod:DigestiveAcidAppliedDose(args)
	if self:Me(args.destGUID) and (args.amount % 2 == 0 or args.amount > 6) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 6)
		if args.amount >= 6 then
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
	digestiveAcidList[args.destName] = args.amount
	self:SetInfoByTable("infobox", digestiveAcidList, 3, 5)
end

function mod:DigestiveAcidRemoved(args)
	digestiveAcidList[args.destName] = nil
	digestiveAcidListTokens[args.destName] = nil
	self:SetInfoByTable("infobox", digestiveAcidList, 3, 5)
end

function mod:FleshTentacleKilled(args) -- Stomach Tentacle
	deaths = deaths + 1

	local line = healthList[args.destGUID]
	if not line then
		line = next(healthList) and 3 or 1
		healthList[args.destGUID] = line
	end
	self:SetInfoBar("infobox", line, 0)
	self:SetInfo("infobox", line + 1, CL.dead)

	self:Message("stages", "cyan", CL.mob_killed:format(args.destName, deaths, 2), false)

	if deaths == 2 then
		self:CThunWeakened()
	end
end

function UpdateInfoBoxList()
	if not mod:IsEngaged() then return end
	mod:SimpleTimer(UpdateInfoBoxList, 0.5)

	for playerName, unitToken in next, digestiveAcidListTokens do
		local unitTarget = unitToken .. "target"
		local guid = mod:UnitGUID(unitTarget)
		if mod:MobId(guid) == 15802 then
			local line = healthList[guid]
			if not line then
				line = next(healthList) and 3 or 1
				healthList[guid] = line
			end
			local currentHealthPercent = math.floor(mod:GetHealth(unitTarget))
			mod:SetInfoBar("infobox", line, currentHealthPercent/100)
			if currentHealthPercent > 0 then
				mod:SetInfo("infobox", line + 1, ("%d%%"):format(currentHealthPercent))
			end
		end
	end
end
