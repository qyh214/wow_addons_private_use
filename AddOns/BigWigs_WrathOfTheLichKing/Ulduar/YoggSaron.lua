--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Yogg-Saron", 603, 1649)
if not mod then return end
mod:RegisterEnableMob(33288, 33134, 33890) -- Yogg-Saron, Sara, Brain of Yogg-Saron
mod:SetEncounterID(BigWigsLoader.isWrath and 756 or 1143)
mod:SetRespawnTime(46)

--------------------------------------------------------------------------------
-- Locals
--

local guardianCount = 1
local crusherCount = 1
local smallTentacleCount = 1
local portalCount = 1
local warnedForSanity = false
local shadowBeaconTbl = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "^The time to"
	L.phase2_trigger = "^I am the lucid dream"
	L.phase3_trigger = "^Look upon the true face"

	L.portal = "Portal"
	L.portal_desc = "Warn for Portals."
	L.portal_message = "Portals open!"
	L.portal_bar = "Next portals"

	L.fervor_message = "Fervor on %s!"

	L.sanity_message = "You're going insane!"

	L.weakened = "Stunned"
	L.weakened_desc = "Warn when Yogg-saron becomes stunned."
	L.weakened_message = "%s is stunned!"

	L.madness_warning = "Madness in 10 sec!"

	L.malady_message = "Malady"

	L.tentacle = "Crusher Tentacle"
	L.tentacle_desc = "Warn for Crusher Tentacle spawn."
	L.tentacle_message = "Crusher %d!"

	L.small_tentacles = "Small Tentacles"
	L.small_tentacles_desc = "Warn for Corruptor Tentacle and Constrictor Tentacle spawns."

	L.link_warning = "You are linked!"

	L.guardian_message = "Guardian %d!"

	L.roar_warning = "Roar in 5sec!"
	L.roar_bar = "Next Roar"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

local shadowBeaconMarker = mod:AddMarkerOption(true, "npc", 8, 64465, 8, 7, 6, 5, 4) -- Shadow Beacon
function mod:GetOptions()
	return {
		62979, -- Summon Guardian
		{63138, "FLASH"}, -- Sara's Fervor
		"tentacle",
		"small_tentacles",
		{63830, "ICON", "ME_ONLY", "SAY"}, -- Malady of the Mind
		{63802, "ME_ONLY_EMPHASIZE"}, -- Brain Link
		64126, -- Squeeze
		"portal",
		"weakened",
		{64059, "COUNTDOWN", "EMPHASIZE"}, -- Induce Madness
		64465, -- Shadow Beacon
		shadowBeaconMarker,
		{64163, "CASTBAR"}, -- Lunatic Gaze
		64189, -- Deafening Roar
		"stages",
		{63050, "FLASH"}, -- Sanity
		63120, -- Insane
		"berserk",
	},{
		[62979] = CL.stage:format(1),
		tentacle = CL.stage:format(2),
		[64465] = CL.stage:format(3),
		[64189] = "hard",
		stages = "general",
	},{
		[63802] = CL.link, -- Brain Link (Link)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "SarasFervorCast", 63138)
	self:Log("SPELL_AURA_APPLIED", "SarasFervor", 63138)
	self:Log("SPELL_CAST_START", "DeafeningRoar", 64189)
	self:Log("SPELL_CAST_START", "InduceMadness", 64059)
	self:Log("SPELL_AURA_APPLIED", "IllusionRoom", 63988)
	self:Log("SPELL_AURA_REMOVED", "IllusionRoomExit", 63988)
	self:Log("SPELL_CAST_SUCCESS", "ShadowBeacon", 64465)
	self:Log("SPELL_AURA_APPLIED", "ShadowBeaconApplied", 64465)
	self:Log("SPELL_AURA_REMOVED", "ShadowBeaconRemoved", 64465)
	self:Log("SPELL_CAST_SUCCESS", "TentacleSpawn", 64144) -- Erupt
	self:Log("SPELL_AURA_APPLIED", "Squeeze", 64126)
	self:Log("SPELL_AURA_APPLIED", "BrainLink", 63802)
	self:Log("SPELL_AURA_REMOVED", "LunaticGazeOver", 64163)
	self:Log("SPELL_AURA_APPLIED", "LunaticGaze", 64163)
	self:Log("SPELL_AURA_APPLIED", "MaladyOfTheMind", 63830)
	self:Log("SPELL_AURA_REMOVED", "MaladyOfTheMindRemoved", 63830)
	self:Log("SPELL_AURA_APPLIED", "Insane", 63120)
	self:Log("SPELL_AURA_REMOVED_DOSE", "SanityDecrease", 63050)
	self:Log("SPELL_AURA_APPLIED_DOSE", "SanityIncrease", 63050)
	self:Log("SPELL_SUMMON", "SummonGuardian", 62979)
	self:Log("SPELL_CAST_SUCCESS", "PortalsOpen", 64167) -- Lunatic Gaze
	self:Log("SPELL_CAST_SUCCESS", "BrainStunned", 64173) -- Shattered Illusion

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end

function mod:OnEngage()
	guardianCount = 1
	crusherCount = 1
	smallTentacleCount = 1
	portalCount = 1
	warnedForSanity = false
	shadowBeaconTbl = {}
	self:Berserk(900)
end

function mod:VerifyEnable(_, _, mapArtID)
	return mapArtID == 150 -- Floor 4, The Prison of Yogg-Saron
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function printTarget(self, name, guid)
		self:TargetMessageOld(63138, name, "orange", "alert")
	end

	function mod:SarasFervorCast(args)
		self:GetUnitTarget(printTarget, 0.5, args.sourceGUID)
	end
end

function mod:SarasFervor(args)
	self:Bar(args.spellId, 15, L.fervor_message:format(self:ColorName(args.destName)))
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
	end
end

function mod:SanityIncrease(args)
	if self:Me(args.destGUID) and warnedForSanity and args.amount > 40 then
		warnedForSanity = false
	end
end

function mod:SanityDecrease(args)
	if self:Me(args.destGUID) and not warnedForSanity and args.amount < 41 then
		warnedForSanity = true
		self:MessageOld(args.spellId, "blue", nil, L.sanity_message)
		self:Flash(args.spellId)
	end
end

function mod:SummonGuardian(args)
	self:MessageOld(args.spellId, "green", nil, L.guardian_message:format(guardianCount))
	guardianCount = guardianCount + 1
end

function mod:Insane(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow")
end

function mod:TentacleSpawn(args)
	-- Crusher Tentacle (33966) 55 sec
	-- Corruptor Tentacle (33985) 25 sec
	-- Constrictor Tentacle (33983) 25 sec
	if self:MobId(args.sourceGUID) == 33966 then
		self:MessageOld("tentacle", "red", nil, L.tentacle_message:format(crusherCount), 64139)
		crusherCount = crusherCount + 1
		self:Bar("tentacle", 55, L.tentacle_message:format(crusherCount), 64139)
	elseif self:MobId(args.sourceGUID) == 33985 then -- Corruptor & Constrictor at the same time
		self:MessageOld("small_tentacles", "red", nil, CL.count:format(L.small_tentacles, smallTentacleCount), 64139)
		smallTentacleCount = smallTentacleCount + 1
		self:Bar("small_tentacles", 25, CL.count:format(L.small_tentacles, smallTentacleCount), 64139)
	end
end

function mod:DeafeningRoar(args)
	self:MessageOld(args.spellId, "yellow")
	self:Bar(args.spellId, 60, L.roar_bar)
	self:DelayedMessage(args.spellId, 55, "yellow", L.roar_warning)
end

function mod:MaladyOfTheMind(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow", "alert", L.malady_message)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, L.malady_message, nil, "Malady")
	end
	self:PrimaryIcon(args.spellId, args.destName)
end

function mod:MaladyOfTheMindRemoved(args)
	self:PrimaryIcon(args.spellId)
end

function mod:Squeeze(args)
	self:TargetMessageOld(args.spellId, args.destName, "green")
end

function mod:BrainLink(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, false, L.link_warning)
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:LunaticGazeOver(args)
	self:CDBar(args.spellId, 9)
end

function mod:LunaticGaze(args)
	self:MessageOld(args.spellId, "red", "warning")
	self:CastBar(args.spellId, 4)
end

do
	local madnessCastStartTime = 0
	function mod:InduceMadness(args)
		madnessCastStartTime = args.time
	end

	function mod:IllusionRoom(args)
		-- Induce Madness
		if self:Me(args.destGUID) then
			local timeSinceCastStart = args.time - madnessCastStartTime
			local remainingTime = (self:Classic() and 60 or 55) - timeSinceCastStart
			if remainingTime > 0 then -- XXX we should start a minimum timer when madnessCastStartTime is 0, instead of no timer at all
				self:Bar(64059, remainingTime)
				self:DelayedMessage(64059, remainingTime - 10, "orange", L.madness_warning, false, "warning")
			end
		end
	end

	function mod:IllusionRoomExit(args)
		-- Induce Madness
		if self:Me(args.destGUID) then
			self:StopBar(64059)
			self:CancelDelayedMessage(L.madness_warning)
		end
	end
end

function mod:ShadowBeacon(args)
	shadowBeaconTbl = {}
	self:CDBar(args.spellId, 46)
	self:Message(args.spellId, "red")
end

function mod:MarkShadowBeacon(event, unit, guid)
	if shadowBeaconTbl[guid] then
		self:CustomIcon(false, unit, shadowBeaconTbl[guid])
	end
end

function mod:ShadowBeaconApplied(args)
	if self:GetOption(shadowBeaconMarker) then
		if not shadowBeaconTbl.count then
			shadowBeaconTbl.count = 8
		else
			shadowBeaconTbl.count = shadowBeaconTbl.count - 1
		end
		shadowBeaconTbl[args.destGUID] = shadowBeaconTbl.count

		local unitId = self:GetUnitIdByGUID(args.destGUID)
		if unitId then
			self:CustomIcon(false, unitId, shadowBeaconTbl.count)
		end
		self:RegisterTargetEvents("MarkShadowBeacon")
	end
end

do
	local prev = 0
	function mod:ShadowBeaconRemoved(args)
		local t = args.time
		if t-prev > 5 then
			prev = t
			self:Message(args.spellId, "green", CL.removed:format(args.spellName))
		end

		if self:GetOption(shadowBeaconMarker) then
			if shadowBeaconTbl[args.destGUID] then
				shadowBeaconTbl[args.destGUID] = 0
				local unitId = self:GetUnitIdByGUID(args.destGUID)
				if unitId then
					self:CustomIcon(false, unitId, 0)
				end
			end
		end
	end
end

do
	local prev = 0
	function mod:PortalsOpen(args) -- Laughing Skulls above portals all gain Lunatic Gaze
		local t = args.time
		if t-prev > 10 then
			prev = t
			self:MessageOld("portal", "green", nil, CL.count:format(L.portal_message, portalCount), 35717)
			portalCount = portalCount + 1
			self:Bar("portal", self:Classic() and 90 or 61, CL.count:format(L.portal_bar, portalCount), 35717)
		end
	end
end

function mod:BrainStunned(args) -- Shattered Illusion
	self:MessageOld("weakened", "green", "long", L.weakened_message:format(self.displayName), 50661) -- 50661 / Weakened Resolve / spell_shadow_brainwash / icon 136125
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.phase2_trigger) then
		crusherCount = 1
		self:MessageOld("stages", "yellow", nil, CL.stage:format(2), false)
		self:Bar("portal", self:Classic() and 75 or 25, CL.count:format(L.portal_bar, portalCount), 35717)
	elseif msg:find(L.phase3_trigger) then
		self:CancelDelayedMessage(L.madness_warning)

		self:StopBar(64059) -- Induce Madness
		self:StopBar(L.tentacle_message:format(crusherCount))
		self:StopBar(CL.count:format(L.portal_bar, portalCount))

		self:MessageOld("stages", "red", "alarm", CL.stage:format(3), false)
		self:Bar(64465, 46) -- Shadow Beacon
	elseif msg:find(L.engage_trigger) and not self.isEngaged then
		self:Engage() -- Remove if Sara is added to boss frames on engage
	end
end
