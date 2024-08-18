--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lei Shen", 1098, 832)
if not mod then return end
mod:RegisterEnableMob(68397, 68398, 68696, 68697, 68698) -- Lei Shen, Static Shock Conduit, Diffusion Chain Conduit, Overcharge Conduit, Bouncing Bolt Conduit

--------------------------------------------------------------------------------
-- Locals
--

local phase = 1
local tooCloseForOvercharged = nil
local adds = {}
local markerTimer = nil
local diffusionTimer = nil
local ballLightningTimer = nil
local marksUsed = {}
local activeProximityAbilities = {}
local thunderstruckCounter = 1
local whipCounter = 1

local function isConduitAlive(mobId)
	for i=1, 5 do
		local boss = ("boss%d"):format(i)
		if mobId == mod:MobId(mod:UnitGUID(boss)) then
			return boss
		end
	end
end

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.custom_off_diffused_marker = "Diffused Lightning Marker"
	L.custom_off_diffused_marker_desc = "Mark the Diffused Lightning adds using all raid icons, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over all the adds is the fastest way to mark them.|r"

	L.shock_self = "Static Shock on YOU"
	L.shock_self_desc = "Show a duration bar for the Static Shock debuff on you."
	L.shock_self_icon = 135695

	L.overcharged_self = "Overcharged on YOU"
	L.overcharged_self_desc = "Show a duration bar for the Overcharged debuff on you."
	L.overcharged_self_icon = 136295

	L.last_inermission_ability = "Last intermission ability used!"
	L.safe_from_stun = "You're probably safe from Overcharge stuns"
	L.diffusion_add = "Diffusion add"
	L.shock = "Shock"
	L.static_shock_bar = "<Static Shock Split>"
	L.overcharge_bar = "<Overcharge Pulse>"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"custom_off_diffused_marker",
		{139011, "FLASH"},
		{134912, "TANK", "FLASH"}, 135095, {135150, "FLASH"},
		{136478, "TANK"}, {136543, "PROXIMITY"}, {136850, "FLASH"},
		{136914, "TANK"}, 136889,
		{135695, "PROXIMITY"}, {"shock_self", "SAY", "FLASH", "EMPHASIZE", "COUNTDOWN"}, {135991, "PROXIMITY"}, 136295, {"overcharged_self", "SAY"}, 136366,
		"stages", "berserk", "proximity",
	}, {
		["custom_off_diffused_marker"] = L.custom_off_diffused_marker,
		[139011] = "heroic",
		[134912] = -7178,
		[136478] = -7192,
		[136914] = -7209,
		[135695] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	-- Marking
	self:Log("SPELL_DAMAGE", "ChainLightning", 136018, 136019, 136021)
	self:Log("SPELL_SUMMON", "SummonSmallDiffusedLightning", 135992)

	-- Heroic
	self:Log("SPELL_AURA_APPLIED", "HelmOfCommand", 139011)
	-- Stage 3
	self:Log("SPELL_AURA_APPLIED_DOSE", "ElectricalShock", 136914)
	-- Stage 2
	self:Log("SPELL_CAST_START", "LightningWhip", 136850)
	self:Log("SPELL_PERIODIC_DAMAGE", "LightningWhipDamage", 136853)
	self:Log("SPELL_PERIODIC_MISSED", "LightningWhipDamage", 136853)
	self:Log("SPELL_CAST_SUCCESS", "SummonBallLightning", 136543)
	self:Log("SPELL_CAST_START", "FusionSlash", 136478)
	-- Intermission
	self:Emote("IntermissionEnd", "137176")
	self:Log("SPELL_CAST_START", "IntermissionStart", 137045)
	-- Stage 1
	self:Log("SPELL_PERIODIC_DAMAGE", "CrashingThunder", 135153)
	self:Log("SPELL_PERIODIC_MISSED", "CrashingThunder", 135153)
	self:Log("SPELL_CAST_START", "Thunderstruck", 135095)
	self:Log("SPELL_AURA_APPLIED", "Decapitate", 134912)
	-- Conduits: Overcharged -- Diffusion Chain -- Static Shock -- Bouncing Bolt
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")
	self:Log("SPELL_AURA_APPLIED", "Overcharged", 136295)
	self:Log("SPELL_CAST_SUCCESS", "DiffusionChain", 135991)
	self:Log("SPELL_DAMAGE", "DiffusionChainDamage", 135991) -- add spawn
	self:Log("SPELL_MISSED", "DiffusionChainDamage", 135991) -- add spawn
	self:Log("SPELL_AURA_REMOVED", "DiffusionChainRemoved", 135681)
	self:Log("SPELL_AURA_APPLIED", "DiffusionChainApplied", 135681)
	self:Log("SPELL_AURA_REMOVED", "StaticShockRemoved", 135695)
	self:Log("SPELL_AURA_APPLIED", "StaticShockApplied", 135695)

	self:Death("Win", 68397) -- Lei Shen
	self:Death("AddDeaths", 69014, 69013, 69012) -- Greater Diffused Lightning, Diffused Lightning, Lesser Diffused Lightning
end

function mod:OnEngage()
	self:Berserk(900) -- 15 on LFR, more than 14 on 10N. Berserk has only been seen on wowhead in LFR. Let's just go with 15 everywhere, but it might be more.
	markerTimer = nil
	diffusionTimer = nil
	ballLightningTimer = nil
	phase = 1
	tooCloseForOvercharged = nil
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
	self:Bar(134912, 40) -- Decapitate
	self:Bar(135095, 25) -- Thunderstruck
	adds = {}
	marksUsed = {}
	activeProximityAbilities = {}
	thunderstruckCounter = 1
	whipCounter = 1

	if self.db.profile.custom_off_diffused_marker then
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

local function updateProximity()
	if not activeProximityAbilities[1] then
		if activeProximityAbilities[2] then
			mod:OpenProximity("proximity", 8)
		elseif activeProximityAbilities[3] then
			mod:OpenProximity("proximity", 6)
		elseif activeProximityAbilities[4] then
			mod:OpenProximity("proximity", 3)
		else
			mod:CloseProximity("proximity")
		end
	end
end

local function stopConduitAbilityBars()
	mod:StopBar(135695)
	mod:StopBar(136295)
	mod:StopBar(135991)
	mod:StopBar(136366)
end

do
	-- Add Marking
	local function getMark()
		for i=8,1,-1 do
			if not marksUsed[i] then
				return i
			end
		end
		return false
	end

	function mod:UPDATE_MOUSEOVER_UNIT()
		local GUID = self:UnitGUID("mouseover")
		if not GUID then return end
		local mobId = self:MobId(GUID)
		if mobId == 69014 or mobId == 69012 or mobId == 69013 then
			if adds[GUID] ~= "marked" then
				adds[GUID] = "marked"
				local mark = getMark()
				if mark then
					self:CustomIcon(false, "mouseover", mark)
					marksUsed[mark] = GUID
				end
			end
		end
	end

	function mod:MarkCheck()
		for GUID in next, adds do
			if adds[GUID] ~= "marked" then
				local unitId = mod:GetUnitIdByGUID(GUID)
				local mark = getMark()
				if unitId and mark then
					adds[GUID] = "marked"
					self:CustomIcon(false, unitId, mark)
					marksUsed[mark] = GUID
				end
			end
		end
	end

	function mod:StopMarkCheck()
		self:CancelTimer(markerTimer)
		markerTimer = nil
	end

	function mod:ChainLightning(args)
		local mobId = self:MobId(args.sourceGUID)
		if mobId == 69014 or mobId == 69012 or mobId == 69013 then
			if not adds[args.sourceGUID] then
				adds[args.sourceGUID] = true
			end
		end
	end
	function mod:SummonSmallDiffusedLightning(args)
		local mobId = self:MobId(args.destGUID)
		if mobId == 69014 or mobId == 69012 or mobId == 69013 then
			if not adds[args.destGUID] then
				adds[args.destGUID] = true
			end
		end
		if self.db.profile.custom_off_diffused_marker and not markerTimer then
			markerTimer = self:ScheduleRepeatingTimer("MarkCheck", 0.2)
			self:ScheduleTimer("StopMarkCheck", 15) -- scan for 15 sec
		end
	end

	function mod:AddDeaths(args)
		for i=8,1,-1 do
			if marksUsed[i] == args.destGUID then
				marksUsed[i] = nil
				return
			end
		end
	end
end

----------------------------------------
-- Heroic
--

do
	local helmOfCommandList, scheduled = mod:NewTargetList(), nil
	local function warnHelmOfCommand(spellId)
		mod:TargetMessageOld(spellId, helmOfCommandList, "orange", "alert")
		scheduled = nil
	end
	function mod:HelmOfCommand(args)
		helmOfCommandList[#helmOfCommandList+1] = args.destName
		if self:Me(args.destGUID) then
			self:Flash(args.spellId)
		end
		self:Bar(args.spellId, 24)
		if not scheduled then
			scheduled = self:ScheduleTimer(warnHelmOfCommand, 0.1, args.spellId)
		end
	end
end


----------------------------------------
-- Stage 3
--

function mod:ElectricalShock(args)
	if args.amount % 5 == 0 then -- don't be too spammy, should be taunting when your debuff wears off (somewhere between 10 and 15)
		self:StackMessageOld(args.spellId, args.destName, args.amount, "red", "warning", L["shock"])
	end
end

----------------------------------------
-- Stage 2
--

do
	local function whipSoon(spellId, spellName)
		mod:MessageOld(spellId, "red", "warning", CL["soon"]:format(CL["count"]:format(spellName, whipCounter)))
		mod:Flash(spellId)
	end
	function mod:LightningWhip(args)
		if phase == 3 then
			self:MessageOld(args.spellId, "orange", "alert", CL["count"]:format(args.spellName, whipCounter))
			whipCounter = whipCounter + 1
			self:Bar(args.spellId, 30.3, CL["count"]:format(args.spellName, whipCounter))
			self:ScheduleTimer(whipSoon, 27, args.spellId, args.spellName)
		else
			self:MessageOld(args.spellId, "orange", "alert")
			self:Bar(args.spellId, 45.1)
		end
	end
end

do
	local prev = 0
	function mod:LightningWhipDamage(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(136850, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(136850)
		end
	end
end

do
	local prev = 0
	local function warnBallsSoon(spellId)
		mod:MessageOld(spellId, "yellow", nil, CL["soon"]:format(mod:SpellName(136620)))
		activeProximityAbilities[3] = true
		updateProximity()
		ballLightningTimer = nil
	end
	function mod:SummonBallLightning(args)
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			activeProximityAbilities[3] = nil
			if self:Heroic() then
				activeProximityAbilities[4] = true
				updateProximity()
			end
			ballLightningTimer = self:ScheduleTimer(warnBallsSoon, 41, args.spellId)-- reopen it when new balls are about to come
			self:Bar(args.spellId, 46, 136620)
			self:MessageOld(args.spellId, "yellow", nil, 136620)
		end
	end
end

function mod:FusionSlash(args)
	self:Bar(args.spellId, 42)
	self:MessageOld(args.spellId, "red", "warning")
end

----------------------------------------
-- Intermissions
--

local function warnDiffusionChainSoon(intermission)
	mod:MessageOld(135991, "red", intermission or not mod:Tank() and "warning", CL["soon"]:format(mod:SpellName(135991)))
	activeProximityAbilities[2] = true
	updateProximity()
end

function mod:IntermissionEnd(msg)
	self:StopBar(139011) -- Helm of Command -- heroic
	self:StopBar(136295) -- Overcharged
	self:StopBar(135695) -- Static Shock
	self:StopBar(136366) -- Bouncing Bolt
	self:StopBar(135991) -- Diffusion Chain
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1") -- just to be efficient

	-- stage 2
	activeProximityAbilities[2] = true
	updateProximity()
	if phase == 2 then
		self:Bar(136478, 46) -- Fusion Slash
		self:Bar(136850, 29) -- Lightning Whip
		if self:Heroic() then -- XXX these are probably not time based either and need to add abilities for all conduits
			if msg:find("135681") then -- Diffusion Adds
				self:Bar(135991, 14)
			elseif msg:find("135682") then -- Overcharged
				self:Bar(136295, 14)
			elseif msg:find("135683") then -- Bouncing Bolt
				self:Bar(136366, 14)
			elseif msg:find("135680") then -- Static Shock
				self:Bar(135695, 14)
			end
		end
	elseif phase == 3 then -- XXX should start bars for already disabled conduits too
		self:Bar(135095, 36, CL["count"]:format(self:SpellName(135095), thunderstruckCounter)) -- Thunderstruck
		self:Bar(136850, 22, CL["count"]:format(self:SpellName(136850), whipCounter)) -- Lightning Whip
		self:Bar(136889, 20) -- Violent Gale Winds
		if self:Heroic() then
			if msg:find("135681") then -- Diffusion Adds
				self:Bar(135991, 28)
			elseif msg:find("135682") then -- Overcharged
				self:Bar(136295, 28)
			elseif msg:find("135683") then -- Bouncing Bolt
				self:Bar(136366, 30)
			elseif msg:find("135680") then -- Static Shock
				self:Bar(135695, 28)
			end
		end
	end
	self:Bar(136543, (phase == 2) and 14 or 41, 136620) -- Ball Lightning

	self:MessageOld("stages", "cyan", "info", CL["phase"]:format(phase), false)
end

function mod:IntermissionStart(args)
	stopConduitAbilityBars()
	if diffusionTimer then
		self:CancelTimer(diffusionTimer)
		diffusionTimer = nil
	end
	if ballLightningTimer then
		self:CancelTimer(ballLightningTimer)
		ballLightningTimer = nil
	end
	self:StopBar(135150) -- Crashing Thunder
	self:StopBar(134912) -- Decapitate
	self:StopBar(135095) -- Thunderstruck
	self:StopBar(136850) -- Lightning Whip
	self:StopBar(136620) -- Ball Lightning
	self:StopBar(136478) -- Furious Slash
	self:UnregisterUnitEvent("UNIT_HEALTH", "boss1") -- just to be efficient
	activeProximityAbilities[4] = nil
	local diff = self:Difficulty()
	if diff == 3 or diff == 5 or diff == 7 then -- 10 mans and assume LFR too
		if isConduitAlive(68398) then self:Bar(135695, 18) end -- Static Shock
		if isConduitAlive(68697) then self:Bar(136295, 7) end -- Overcharged
		if isConduitAlive(68698) then self:Bar(136366, 8.5) end -- Bouncing Bolt
		if isConduitAlive(68696) then
			self:Bar(135991, 7)
			self:ScheduleTimer(warnDiffusionChainSoon, 2, true)
		end
	else -- 25 man
		if isConduitAlive(68398) then self:Bar(135695, 19) end -- Static Shock
		if isConduitAlive(68697) then self:Bar(136295, 7) end -- Overcharged
		if isConduitAlive(68698) then self:Bar(136366, 14) end -- Bouncing Bolt
		if isConduitAlive(68696) then
			self:Bar(135991, 6)
			self:ScheduleTimer(warnDiffusionChainSoon, 1, true)
		end
	end
	if self:Heroic() then
		self:Bar(139011, 14) -- Helm of Command
	end
	self:Bar("stages", 47, CL.intermission, args.spellId)
	self:MessageOld("stages", "cyan", "info", CL.intermission, false)
	self:DelayedMessage("stages", 40, "green", L["last_inermission_ability"])
end

function mod:UNIT_HEALTH(event, unit)
	local hp = self:GetHealth(unit)
	if phase == 1 and hp < 68 then
		self:MessageOld("stages", "cyan", "info", CL["soon"]:format(CL.intermission), false)
		phase = 2
	elseif phase == 2 and hp < 33 then
		self:MessageOld("stages", "cyan", "info", CL["soon"]:format(CL.intermission), false)
		self:UnregisterUnitEvent(event, unit)
		phase = 3
	end
end

----------------------------------------
-- Stage 1
--

do
	local prev = 0
	function mod:CrashingThunder(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 1 then
			prev = t
			self:MessageOld(135150, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(135150)
		end
	end
end

function mod:Thunderstruck(args)
	if phase == 3 then
		self:MessageOld(args.spellId, "yellow", "alert", CL["count"]:format(args.spellName, thunderstruckCounter))
		thunderstruckCounter = thunderstruckCounter + 1
		self:Bar(args.spellId, 30, CL["count"]:format(args.spellName, thunderstruckCounter))
	else
		self:Bar(args.spellId, 46)
		self:MessageOld(args.spellId, "yellow", "alert")
	end
end

function mod:Decapitate(args)
	self:Bar(args.spellId, 50)
	self:TargetMessageOld(args.spellId, args.destName, "blue", "warning", nil, nil, true)
	if self:Tank() then
		self:Flash(args.spellId)
	end
	self:TargetBar(args.spellId, 5, args.destName) -- usually another ~2s before damage due to travel time
end

----------------------------------------
-- Conduits
--

function mod:UNIT_SPELLCAST_SUCCEEDED(_, unit, _, spellId)
	if spellId == 136395 then -- Bouncing Bolt
		if not UnitExists(unit) then -- poor mans intermission check
			self:Bar(136366, 24)
		else
			if phase == 1 or not self:Heroic() then stopConduitAbilityBars() end
			self:Bar(136366, 40)
		end
		self:MessageOld(136366, "red", "long")
	elseif spellId == 136869 then -- Violent Gale Winds
		self:MessageOld(136889, "red", "long")
		self:Bar(136889, 30)
	elseif spellId == 135143 then -- Crashung Thunder
		self:MessageOld(135150, "yellow")
		self:Bar(135150, 30)
	elseif spellId == 139006 or spellId == 139007 or spellId == 139008 or spellId == 139009 then -- active quadrant
		if self:Heroic() and phase == 3 then
			self:MessageOld("stages", "yellow", nil, self:SpellName(spellId), 136913) -- probably shouldn't be linked to stages, but dunno anything better -- overwhelming power icon
		end
	end
end

do
	local overchargedList, overchargedOnMe, scheduled = mod:NewTargetList(), nil, nil
	local function warnOvercharged(spellId)
		if not UnitExists("boss1") then -- poor mans intermission check
			mod:Bar(spellId, 23)
		else
			if phase == 1 or not mod:Heroic() then stopConduitAbilityBars() end
			mod:Bar(spellId, 40)
		end

		mod:TargetMessageOld(spellId, overchargedList, "orange", "alarm", nil, nil, true)
		if not overchargedOnMe then
			mod:Bar(spellId, 6, L["overcharge_bar"])
		end
		if not tooCloseForOvercharged then
			mod:MessageOld(spellId, "green", nil, L["safe_from_stun"], false)
		end
		tooCloseForOvercharged = nil
		overchargedOnMe = nil
		scheduled = nil
	end
	function mod:Overcharged(args)
		if self:Me(args.destGUID) then
			self:Say("overcharged_self", args.spellId, nil, "Overcharged")
			self:TargetBar("overcharged_self", 6, args.destName, args.spellId)
			overchargedOnMe = true
		end
		-- XXX no range checking now
		--if self:Range(args.destName) < 50 then -- XXX verify range ( should be more than 40 )
			tooCloseForOvercharged = true
		--end
		overchargedList[#overchargedList+1] = args.destName
		if not scheduled then
			scheduled = self:ScheduleTimer(warnOvercharged, 0.2, args.spellId)
		end
	end
end

do
	local diffusionList = mod:NewTargetList()
	function mod:DiffusionChainDamage(args) -- XXX consider syncing, or figure out why sometimes the list is empty
		for i, player in next, diffusionList do -- can hit the same person multiple times apparently
			if player:find(args.destName, nil, true) then
				return
			end
		end
		diffusionList[#diffusionList+1] = args.destName
	end
	local function warnDiffusionAdds()
		local intermission = not UnitExists("boss1") -- poor mans intermission check
		if #diffusionList > 0 then
			mod:TargetMessageOld(135991, diffusionList, "red", intermission and "warning", L["diffusion_add"], nil, true)
		else -- no one in range
			mod:MessageOld(135991, "red", intermission and "warning")
		end
		if intermission then
			mod:Bar(135991, 25)
			diffusionTimer = mod:ScheduleTimer(warnDiffusionChainSoon, 20, true)
		else
			if phase == 1 or not mod:Heroic() then stopConduitAbilityBars() end
			mod:Bar(135991, 40)
			diffusionTimer = mod:ScheduleTimer(warnDiffusionChainSoon, 30)
		end
		activeProximityAbilities[2] = nil
		updateProximity()
	end
	function mod:DiffusionChain(args)
		diffusionList = mod:NewTargetList()
		self:ScheduleTimer(warnDiffusionAdds, 0.2)
		if self.db.profile.custom_off_diffused_marker and not markerTimer then
			markerTimer = self:ScheduleRepeatingTimer("MarkCheck", 0.2)
			self:ScheduleTimer("StopMarkCheck", 15) -- scan for 15 sec
		end
	end
	function mod:DiffusionChainRemoved() -- on conduit/lei shen
		if diffusionTimer then
			self:CancelTimer(diffusionTimer)
			diffusionTimer = nil
		end
		activeProximityAbilities[2] = nil
		updateProximity()
	end
end

function mod:DiffusionChainApplied(args)
	if self:MobId(args.destGUID) == 68696 then -- Diffusion Chain Conduit
		warnDiffusionChainSoon()
	end
end

function mod:StaticShockRemoved(args)
	self:CloseProximity(args.spellId)
	activeProximityAbilities[1] = nil -- static shock
	updateProximity()
end

do
	local staticShockList, staticShockOnMe, scheduled, coloredNames = {}, nil, nil, mod:NewTargetList()
	local function warnStaticShock(spellId)
		if not UnitExists("boss1") then -- poor mans intermission check
			mod:Bar(spellId, 20, spellId)
			-- ignore other quadrants during the intermission
			local closest, distance = nil, 200
			-- XXX no range checking now
			--for player in next, staticShockList do
			--	local playerDistance = mod:Range(player)
			--	if playerDistance < distance then
			--		distance = playerDistance
			--		closest = player
			--	end
			--end
			if distance < 40 then
				mod:CloseProximity("proximity")
				activeProximityAbilities[1] = true -- static shock
				if UnitIsUnit("player", closest) then
					mod:OpenProximity(spellId, 8) -- XXX not exactly the best choice, but this way at least you see people around you
				else
					mod:OpenProximity(spellId, 8, closest, true) -- open to closest static shock target
				end
			end
		else
			if phase == 1 or not mod:Heroic() then stopConduitAbilityBars() end
			mod:Bar(135695, 40)
		end
		mod:TargetMessageOld(spellId, coloredNames, "green", "info", nil, nil, true) -- green because everyone should be friendly and hug the person with it
		if not staticShockOnMe and not mod:Heroic() then
			mod:Bar(spellId, 8, L["static_shock_bar"])
		end
		scheduled = nil
		staticShockOnMe = nil
		staticShockList = {}
	end
	local timeLeft, timer = 8, nil
	local function staticShockSayCountdown()
		timeLeft = timeLeft - 1
		if timeLeft < 6 then
			mod:Say("shock_self", timeLeft, true)
			if timeLeft < 2 then
				mod:CancelTimer(timer)
			end
		end
	end
	function mod:StaticShockApplied(args)
		if self:Me(args.destGUID) then
			timeLeft = 8
			staticShockOnMe = true
			self:Flash("shock_self", args.spellId)
			self:Say("shock_self", args.spellId, nil, "Static Shock")
			self:TargetBar("shock_self", 8, args.destName, args.spellId)
			if not self:LFR() then -- Don't spam in LFR
				timer = self:ScheduleRepeatingTimer(staticShockSayCountdown, 1)
			end
		elseif self:Heroic() then
			self:TargetBar(args.spellId, 8, args.destName)
		end
		coloredNames[#coloredNames+1] = args.destName
		staticShockList[args.destName] = true
		if not scheduled then
			scheduled = self:ScheduleTimer(warnStaticShock, 0.1, args.spellId)
		end
	end
end

