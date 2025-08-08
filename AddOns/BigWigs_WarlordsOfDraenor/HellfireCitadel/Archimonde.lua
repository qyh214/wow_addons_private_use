
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Archimonde", 1448, 1438)
if not mod then return end
mod:RegisterEnableMob(91331)
mod.engageId = 1799
mod.respawnTime = 30

--------------------------------------------------------------------------------
-- Locals
--

local phase = 1
local nextPhaseSoon = 0
local currentTorment, maxTorment = 0, 0
local tormentCount = 1
local shadowsCount = 1
local burstCount, burstTimer = 1, nil
local banished = nil
local feedbackSoon, feedbackTimer = nil, nil
local mythicChaosMsg, mythicChaosBar = nil, nil
local p3Start = 0
local conduitCount = 0
local markOfTheLegionCount = 1
local infernalAmount = 3
local timers = {
	["dc"] = {9.6,11.5,13.5,132.5,134.5,136.5,227.5,229.5,231.5,283.5,285.5,287.5,335.5,337.6,339.5},
	["infernals"] = {35,36,37,98,99,100,161,162,163,164,216,217,218,219,284,286,288,290,325,326,327,328,329},
	["marks"] = {21.5,84.5,144.5,204.5,252.5,298.5,345.5},
	["seething"] = {62.5,120.5,172.5,242.5,272.5,313.5},
	["chaos"] = {51,109,185,263},
	["twisted"] = {76.5,154.5,196.5,236.5,308.5},
}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.torment_removed = "Torment removed (%d/%d)"
	L.chaos_bar = "%s -> %s"
	L.chaos_from = "%s from %s"
	L.chaos_to = "%s to %s"
	L.infernal_count = "%s (%d/%d)"

	L.overfiend = -11603
	L.overfiend_desc = 186662
	L.overfiend_icon = 186662

	L.custom_off_torment_marker = "Shackled Torment marker"
	L.custom_off_torment_marker_desc = "Mark the Shackled Torment targets with {rt1}{rt2}{rt3}, requires promoted or leader."
	L.custom_off_torment_marker_icon = 1

	L.markofthelegion_self = "Mark of the Legion on you"
	L.markofthelegion_self_desc = "Special countdown when Mark of the Legion is on you."
	L.markofthelegion_self_icon = "spell_warlock_demonbolt"
	L.markofthelegion_self_bar = "You explode!"

	L.custom_off_legion_marker = "Mark of the Legion marker"
	L.custom_off_legion_marker_desc = "Mark the Mark of the Legion targets with {rt1}{rt2}{rt3}{rt4}, requires promoted or leader."
	L.custom_off_legion_marker_icon = 1

	L.custom_off_infernal_marker = "Infernal marker"
	L.custom_off_infernal_marker_desc = "Mark the Infernals spawned by Rain of Chaos with {rt1}{rt2}{rt3}{rt4}{rt5}, requires promoted or leader."
	L.custom_off_infernal_marker_icon = 1

	L.chaos_helper_message = "Your Chaos position: %d"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- P1
		{182826, "ICON", "SAY"}, -- Doomfire
		{183817, "PROXIMITY"}, -- Shadowfel Burst
		185590, -- Desecrate
		183963, -- Light of the Naaru
		-- P2
		{184964, "SAY", "FLASH"}, -- Shackled Torment
		"custom_off_torment_marker",
		{186123, "ICON", "SAY"}, -- Wrought Chaos
		183865, -- Demonic Havoc
		"overfiend",
		-- P3
		{187180, "PROXIMITY"}, -- Demonic Feedback
		{186961, "ICON", "SAY", "PROXIMITY"}, -- Nether Banish
		{189894, "SAY", "PROXIMITY"}, -- Void Star Fixate
		{187255, "FLASH"}, -- Nether Storm
		182225, -- Rain of Chaos
		"custom_off_infernal_marker",
		190050, -- Touch of Shadows
		-- P3 (mythic)
		190394, -- Dark Conduit
		{187050, "SAY", "FLASH", "PROXIMITY"}, -- Mark of the Legion
		{"markofthelegion_self", "SAY", "COUNTDOWN"},
		"custom_off_legion_marker",
		190703, -- Source Of Chaos
		190506, -- Seething Corruption
		190821, -- Twisted Darkness
		-- General
		183254, -- Allure of Flames
		183828, -- Death Brand
		{183864, "TANK"}, -- Shadow Blast
		"stages",
	}, {
		[182826] = -11577,
		[184964] = -11590,
		[187180] = -11599,
		[190394] = "mythic",
		[183254] = "general",
	}
end

function mod:OnBossEnable()
	-- P1
	self:Log("SPELL_AURA_APPLIED", "LightOfTheNaaru", 183963)
	self:Log("SPELL_AURA_REFRESH", "LightOfTheNaaru", 183963)
	self:Log("SPELL_CAST_START", "AllureOfFlamesCast", 183254)
	self:Log("SPELL_CAST_SUCCESS", "AllureOfFlames", 183254)
	self:Log("SPELL_CAST_START", "DeathBrandCast", 183828)
	self:Log("SPELL_AURA_APPLIED", "DeathBrand", 183828)
	self:Log("SPELL_AURA_APPLIED", "ShadowBlast", 183864)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ShadowBlast", 183864)
	self:Log("SPELL_SUMMON", "Doomfire", 182826)
	self:Log("SPELL_AURA_APPLIED", "DoomfireDamage", 183586)
	self:Log("SPELL_AURA_APPLIED_DOSE", "DoomfireDamage", 183586)
	self:Log("SPELL_AURA_APPLIED", "DoomfireFixate", 182879)
	self:Log("SPELL_AURA_REMOVED", "DoomfireFixateRemoved", 182879)
	self:Log("SPELL_CAST_START", "ShadowfelBurst", 183817)
	self:Log("SPELL_AURA_APPLIED", "ShadowfelBurstApplied", 183634)
	self:Log("SPELL_CAST_START", "Desecrate", 185590)
	self:Log("SPELL_CAST_SUCCESS", "Desecration", 183969) -- could also use something else, but i want to make sure it works so im copy pasting from wa
	-- P2
	self:Log("SPELL_AURA_APPLIED", "ShackledTorment", 184964)
	self:Log("SPELL_AURA_REMOVED", "ShackledTormentRemoved", 184964)
	self:Log("SPELL_CAST_SUCCESS", "WroughtChaosCast", 184265)
	self:Log("SPELL_AURA_APPLIED", "FocusedChaos", 185014)
	self:Log("SPELL_AURA_REMOVED", "FocusedChaosRemoved", 185014)
	self:Log("SPELL_AURA_APPLIED", "DemonicHavoc", 183865)
	self:Log("SPELL_AURA_APPLIED", "HeartOfArgus", 186662) -- Overfiend spawned (phase warning)
	-- P3
	self:Log("SPELL_AURA_APPLIED", "VoidStarFixate", 189895)
	self:Log("SPELL_AURA_REMOVED", "VoidStarFixateRemoved", 189895)
	-- P3 (non mythic)
	self:Log("SPELL_CAST_START", "DemonicFeedback", 187180)
	self:Log("SPELL_CAST_START", "TouchOfShadows", 190050)
	self:Log("SPELL_AURA_APPLIED", "TankNetherBanish", 186961)
	self:Log("SPELL_AURA_REMOVED", "TankNetherBanishRemoved", 186961)
	self:Log("SPELL_AURA_APPLIED", "NetherBanishApplied", 186952)
	self:Log("SPELL_AURA_REMOVED", "NetherBanishRemoved", 186952)
	self:Log("SPELL_CAST_SUCCESS", "RainOfChaos", 182225)
	-- P3 (mythic)
	self:Log("SPELL_SUMMON", "InfernalSpawn", 187108)
	self:Log("SPELL_CAST_SUCCESS", "TwistedDarkness", 190821)
	self:Log("SPELL_CAST_SUCCESS", "SeethingCorruption", 190506)
	self:Log("SPELL_CAST_SUCCESS", "SummonSourceOfChaos", 190686)
	self:Log("SPELL_CAST_SUCCESS", "MarkOfTheLegionCast", 188514)
	self:Log("SPELL_AURA_APPLIED", "MarkOfTheLegion", 187050)
	self:Log("SPELL_AURA_REMOVED", "MarkOfTheLegionRemoved", 187050)
	self:Log("SPELL_CAST_SUCCESS", "DarkConduit", 190394)
	-- General
	self:Log("SPELL_PERIODIC_DAMAGE", "NetherStormDamage", 187255)
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "Phases", "boss1")
end

function mod:OnEngage()
	currentTorment, maxTorment = 0, 0
	burstCount = 1
	tormentCount = 1
	phase = 1
	nextPhaseSoon = 88
	banished = nil
	feedbackSoon = nil
	p3Start = 0
	conduitCount = 0
	self:Bar(182826, 6) -- Doomfire
	self:Bar(183828, 15.5) -- Death Brand
	self:Bar(183254, 30) -- Allure of Flames
	self:Bar(183817, 43) -- Shadowfel Burst
	burstTimer = self:ScheduleTimer("ShadowfelBurstSoon", 33)
	-- Desecrate initial cast is at 85%
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Phases(_, _, _, spellId)
	if spellId == 190117 then -- Allow Phase 2 Spells
		self:StopBar(182826) -- Doomfire
		self:StopBar(183817) -- Shadowfel Burst
		self:StopBar(185590) -- Desecrate
		self:StopBar(183963) -- Light of the Naaru
		self:CloseProximity(183817) -- Shadowfel Burst
		self:CancelTimer(burstTimer)

		phase = 2
		self:MessageOld("stages", "cyan", "long", "70% - " .. CL.phase:format(2), false)
		self:CDBar(186123, 7) -- Wrought Chaos
		self:CDBar(184964, 27, CL.count:format(self:SpellName(184964), tormentCount)) -- Shackled Torment
		self:CDBar(183828, 38) -- Death Brand
		self:CDBar(183254, 44) -- Allure of Flames
	elseif spellId == 190118 then -- Allow Phase 3 Spells
		self:StopBar(183254) -- Allure of Flames
		self:StopBar(183828) -- Death Brand
		self:StopBar(L.overfiend) -- Felborne Overfiend

		phase = 3
		self:MessageOld("stages", "cyan", "long", "40% - " .. CL.phase:format(3), false)
		self:CDBar(186961, 13) -- Nether Banish
		self:CDBar(186123, 27) -- Wrought Chaos
		self:CDBar(187180, 35) -- Demonic Feedback
		self:CDBar(184964, 57.5, CL.count:format(self:SpellName(184964), tormentCount)) -- Shackled Torment
		feedbackTimer = self:ScheduleTimer("DemonicFeedbackSoon", 24)
	elseif spellId == 190310 then -- Mythic Phase Combat Channel
		phase = 3
		markOfTheLegionCount = 1
		infernalAmount = 3
		p3Start = GetTime()

		self:StopBar(183254) -- Allure of Flames
		self:StopBar(183828) -- Death Brand
		self:StopBar(CL.count:format(self:SpellName(184964), tormentCount)) -- Shackled Torment
		self:StopBar(186123) -- Wrought Chaos
		self:StopBar(CL.cast:format(self:SpellName(186123))) -- Wrought Chaos
		self:CancelTimer(mythicChaosMsg)
		self:CancelTimer(mythicChaosBar)
		mythicChaosMsg, mythicChaosBar = nil, nil
		self:StopBar(L.overfiend) -- Felborne Overfiend
		self:UnregisterUnitEvent("UNIT_HEALTH", "boss1") -- Ignore 40%, 25% warnings inside mythic P3 (50%->0%)

		self:MessageOld("stages", "cyan", "long", CL.phase:format(3), false)
		self:Bar(190394, 9.5) -- Dark Conduit
		self:Bar(187050, 21.5, CL.count:format(self:SpellName(187050), markOfTheLegionCount)) -- Mark of the Legion
		self:Bar(182225, 35, L.infernal_count:format(self:SpellName(182225), markOfTheLegionCount, infernalAmount)) -- Rain of Chaos
		self:Bar(190703, 53) -- Source of Chaos
		self:Bar(190506, 62.5) -- Seething Corruption
		self:Bar(190821, 76.5) -- Twisted Darkness
	end
end

do
	-- 3% seems to be about 20 seconds
	local phaseMessage = {
		[88] = mod:SpellName(185590), -- 85% Desecrate
		[73] = CL.phase:format(2), -- 70%
		[58] = CL.adds, -- 55% Vanguard of the Legion
		[43] = CL.phase:format(3), -- 40%
		[28] = mod:SpellName(182225), -- 25% Rain of Chaos
	}
	function mod:UNIT_HEALTH(event, unit)
		local hp = self:GetHealth(unit)
		if hp < nextPhaseSoon then
			self:MessageOld("stages", "cyan", "info", CL.soon:format(phaseMessage[nextPhaseSoon]), false)
			nextPhaseSoon = nextPhaseSoon - 15
			if nextPhaseSoon < 30 then
				self:UnregisterUnitEvent(event, unit)
			end
		end
	end
end

do
	local prev = 0
	function mod:LightOfTheNaaru(args)
		local t = GetTime()
		if t-prev > 5 and self:Me(args.destGUID) then
			prev = t
			self:TargetMessageOld(args.spellId, args.destName, "blue", self:Tank() and "info")
		end
	end
end

function mod:AllureOfFlamesCast(args)
	self:MessageOld(args.spellId, "orange", nil, CL.incoming:format(args.spellName))
	self:CDBar(args.spellId, 48) -- Min: 47.5/Avg: 49.8/Max: 54.1
end

function mod:AllureOfFlames(args)
	self:MessageOld(args.spellId, "orange", "alert")
end

function mod:DeathBrandCast(args)
	if self:Tank() then
		self:MessageOld(args.spellId, "yellow", "warning", CL.casting:format(args.spellName))
	end
	self:CDBar(args.spellId, 43)
end

function mod:DeathBrand(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow")
	if self:Tank() and not self:Me(args.destGUID) and not self:Tanking("boss1") then -- second taunt warning for other tank
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:ShadowBlast(args)
	self:StackMessageOld(args.spellId, args.destName, args.amount, "yellow")
end

-- Phase 1

function mod:Doomfire(args)
	self:CDBar(args.spellId, 42) -- seems to be either 42 46 42 or 42 42 49 depending on Desecrate
end

function mod:DoomfireFixate(args)
	self:TargetMessageOld(182826, args.destName, "red", "alarm")
	self:PrimaryIcon(182826, args.destName)
	self:TargetBar(182826, 10, args.destName)
	if self:Me(args.destGUID) then
		self:Say(182826, nil, nil, "Doomfire")
	end
end

function mod:DoomfireFixateRemoved(args)
	self:PrimaryIcon(182826)
	self:StopBar(182826, args.destName)
end

do
	local prev = 0
	function mod:DoomfireDamage(args)
		local t = GetTime()
		if t-prev > 2 and self:Me(args.destGUID) then
			prev = t
			self:MessageOld(182826, "blue", "alarm", CL.underyou:format(args.spellName))
		end
	end
end

function mod:ShadowfelBurstSoon()
	burstTimer = nil
	self:MessageOld(183817, "orange", nil, CL.soon:format(self:SpellName(183817)))
	if self:Ranged() then
		self:OpenProximity(183817, 9) -- 8+1 safety
	end
end

do
	local proxList, isOnMe = {}, nil
	function mod:ShadowfelBurst(args)
		burstCount = burstCount + 1
		if self:Ranged() then
			isOnMe = nil
			proxList = {}
			self:OpenProximity(args.spellId, 9) -- 8+1 safety
		end
		self:MessageOld(args.spellId, "orange", "warning")
		if burstTimer then
			self:CancelTimer(burstTimer)
		end
		burstTimer = self:ScheduleTimer("ShadowfelBurstSoon", (self:Mythic() and 44) or (burstCount == 2 and 53) or 48)
	end

	local list = mod:NewTargetList()
	function mod:ShadowfelBurstApplied(args)
		list[#list+1] = args.destName
		if #list == 1 then
			self:ScheduleTimer("TargetMessageOld", 0.3, 183817, list, "orange")
			self:Bar(183817, (self:Mythic() and 52) or (burstCount == 2 and 61) or 56)
			if self:Ranged() then
				self:ScheduleTimer("CloseProximity", 6, 183817)
			end
		end
		if self:Ranged() then
			proxList[#proxList+1] = args.destName
			if self:Me(args.destGUID) then
				isOnMe = true
				self:OpenProximity(183817, 8, nil, true)
			elseif not isOnMe then
				self:OpenProximity(183817, 8, proxList, true)
			end
		end
	end
end

function mod:Desecrate(args)
	self:MessageOld(args.spellId, "yellow", "alarm")
	self:CDBar(args.spellId, 27) -- Min: 26.8/Avg: 29.2/Max: 33.4
end

function mod:Desecration(args)
	self:Bar(183963, 10) -- Light of the Naaru
end

-- Phase 2

do
	local list, isOnMe, timer = {}, nil, nil
	local function tormentSay(self, spellId)
		timer = nil
		sort(list)
		for i = 1, #list do
			local target = list[i]
			if target == isOnMe then
				local torment = CL.count:format(self:SpellName(187553), i) -- 187553 = "Torment"
				self:Say(spellId, torment, nil, ("Torment (%d)"):format(i))
				self:Flash(spellId)
				self:TargetMessageOld(spellId, target, "blue", "alarm", torment)
			end
			if self:GetOption("custom_off_torment_marker") then
				self:CustomIcon(false, target, i)
			end
			list[i] = self:ColorName(target)
		end
		if not isOnMe and not banished then
			self:TargetMessageOld(spellId, list, "yellow", nil, CL.count:format(self:SpellName(spellId), tormentCount))
			if self:Mythic() then
				self:PlaySound(spellId, "alarm")
			end
		else
			list = {}
		end
		tormentCount = tormentCount + 1
	end

	function mod:ShackledTorment(args)
		if self:Me(args.destGUID) then
			isOnMe = args.destName
		end

		currentTorment = currentTorment + 1
		if currentTorment > maxTorment then
			maxTorment = currentTorment
		end

		list[#list + 1] = args.destName
		if #list == 1 then
			self:CDBar(args.spellId, 32, CL.count:format(args.spellName, tormentCount+1)) -- p2 40.1, 36.5.. p2.5 31.6 ?
			timer = self:ScheduleTimer(tormentSay, 0.4, self, args.spellId)
		elseif timer and #list == 3 then
			self:CancelTimer(timer)
			tormentSay(self, args.spellId)
		end
	end

	function mod:ShackledTormentRemoved(args)
		if self:GetOption("custom_off_torment_marker") then
			self:CustomIcon(false, args.destName)
		end

		currentTorment = currentTorment - 1 -- Compensates for a shackle not being broken before the next 3 arrive (count the current total)
		if not banished then
			self:TargetMessageOld(args.spellId, args.destName, "cyan", isOnMe and "info", L.torment_removed:format(maxTorment - currentTorment, maxTorment))
		end
		if currentTorment == 0 then
			maxTorment = 0
		end

		if self:Me(args.destGUID) then
			isOnMe = nil
		end
	end
end

do
	local list = mod:NewTargetList()
	function mod:DemonicHavoc(args)
		list[#list+1] = args.destName
		if #list == 1 then
			self:ScheduleTimer("TargetMessageOld", 0.3, args.spellId, list, "yellow", self:Dispeller("magic") and "alert", nil, nil, true)
		end
	end
end

do
	local chaosFrom, chaosTo = 0, 0
	local function MythicChaos(self)
		local wroughtChaos = self:SpellName(186123) -- Wrought Chaos
		local focusedChaos = self:SpellName(185014) -- Focused Chaos
		for unit in self:IterateGroup() do
			if self:UnitDebuff(unit, wroughtChaos) then
				chaosFrom = chaosFrom + 1
				if UnitIsUnit("player", unit) then
					self:MessageOld(186123, "green", "info", L.chaos_helper_message:format(chaosFrom))
					self:Say(186123, chaosFrom, true)
					return
				end
			elseif self:UnitDebuff(unit, focusedChaos) then -- if an odd number of players is alive on cast you do not get a debuff at all
				chaosTo = chaosTo + 1
				if UnitIsUnit("player", unit) then
					self:MessageOld(186123, "green", "info", L.chaos_helper_message:format(chaosTo + 10))
					self:Say(186123, chaosTo + 10, true)
					return
				end
			end
		end
	end

	local chaosCount = 0
	function mod:WroughtChaosCast(args)
		chaosCount = 0
		if self:Mythic() then
			chaosFrom = 0
			chaosTo = 0
			self:ScheduleTimer(MythicChaos, 0.2, self)
			self:Bar(186123, 18, CL.cast:format(args.spellName))
			mythicChaosMsg = self:ScheduleTimer("MessageOld", 18, 186123, "blue", nil, CL.over:format(args.spellName))
			mythicChaosBar = self:ScheduleTimer("CDBar", 18, 186123, 34)
		end
	end

	function mod:FocusedChaos(args)
		if self:Mythic() then return end -- Mythic static position tactic handled in WroughtChaosCast

		local isOnMe = nil
		chaosCount = chaosCount + 1

		if self:Me(args.sourceGUID) then -- Wrought Chaos (1) to PLAYER
			--local spell = CL.count:format(self:SpellName(186123), chaosCount)
			self:TargetMessageOld(186123, args.sourceName, "blue", "info", L.chaos_to:format(self:SpellName(186123), self:ColorName(args.destName)))
			if not self:Mythic() then
				self:Say(186123, nil, nil, "Wrought Chaos")
			end
			isOnMe = true
		end
		if self:Me(args.destGUID) then -- Focused Chaos (1) from PLAYER
			--local spell = CL.count:format(args.spellName, chaosCount)
			self:TargetMessageOld(186123, args.destName, "green", "alarm", L.chaos_from:format(args.spellName, self:ColorName(args.sourceName)), args.spellId)
			if not self:Mythic() then
				self:Say(186123, args.spellName, nil, "Focused Chaos")
				--self:Flash(186123, args.spellId)
			end
			isOnMe = true
		end
		if isOnMe then
			self:Bar(186123, self:Mythic() and 6 or 5, ("(%d) %s"):format(chaosCount, L.chaos_bar:format(args.sourceName:gsub("%-.+", "*"), args.destName:gsub("%-.+", "*"))), "spell_shadow_soulleech_1") -- (1) Player -> Player
		end

		if not self:Mythic() then
			-- Always clear before setting
			self:SecondaryIcon(186123)
			self:PrimaryIcon(186123)
			-- Delay for potential latency with clearing the icons
			self:ScheduleTimer("SecondaryIcon", 0.3, 186123, args.sourceName)
			self:ScheduleTimer("PrimaryIcon", 0.3, 186123, args.destName)

			if not banished and not isOnMe and not self:CheckOption(186123, "ME_ONLY") then
				local spell = CL.count:format(self:SpellName(186123), chaosCount)
				self:MessageOld(186123, "red", nil, CL.other:format(spell, L.chaos_bar:format(self:ColorName(args.sourceName), self:ColorName(args.destName)))) -- Wrought Chaos (1): Player -> Player
				self:Bar(186123, 5, ("(%d) %s"):format(chaosCount, L.chaos_bar:format(args.sourceName:gsub("%-.+", "*"), args.destName:gsub("%-.+", "*"))), "spell_shadow_soulleech_1") -- (1) Player -> Player
			end
		end
	end

	function mod:FocusedChaosRemoved(args)
		if not self:Mythic() and chaosCount == 4 then
			self:SecondaryIcon(186123)
			self:PrimaryIcon(186123)
			if self:UnitDebuff("player", self:SpellName(184964)) then -- Shackled Torment
				self:MessageOld(186123, "green", "info", CL.over:format(self:SpellName(186123))) -- Wrought Chaos
			end
			self:CDBar(186123, 32) -- 52s - 20s of tossing
		end
	end
end

function mod:HeartOfArgus(args)
	self:MessageOld("overfiend", "green", "alert", CL.spawned:format(self:SpellName(L.overfiend)), false)
	if phase < 3 then -- they can spawn just before the transition happens then jump down and gain the buff after
		self:Bar("overfiend", 45, L.overfiend, L.overfiend_icon)
	end
end

-- Phase 3

function mod:RainOfChaos(args)
	if not banished then
		self:MessageOld(args.spellId, "orange", "alert")
	end
	self:Bar(args.spellId, 62)
end

-- Phase 3 (non mythic)

function mod:TouchOfShadows(args)
	if banished then
		if self:Interrupter(args.sourceGUID) then
			self:MessageOld(args.spellId, "yellow", "long", CL.count:format(args.spellName, shadowsCount))
		end
		shadowsCount = shadowsCount + 1
		if shadowsCount == 3 then
			shadowsCount = 1
		end
		self:CDBar(args.spellId, 11, CL.count:format(args.spellName, shadowsCount))
	end
end

do
	local timeLeft, countTimer = 7, nil
	local function countdown(self, spellId)
		timeLeft = timeLeft - 1
		if timeLeft < 4 then
			self:Say(spellId, timeLeft, true)
			if timeLeft < 2 then
				self:CancelTimer(countTimer)
				countTimer = nil
			end
		end
	end

	function mod:TankNetherBanish(args)
		self:CDBar(args.spellId, 62)
		self:TargetMessageOld(args.spellId, args.destName, "orange", "warning", nil, nil, true)
		self:TargetBar(args.spellId, 7, args.destName)
		self:PrimaryIcon(args.spellId, args.destName)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, nil, nil, "Nether Banish")
			self:OpenProximity(args.spellId, 8, nil, true)

			timeLeft = 7
			if countTimer then self:CancelTimer(countTimer) end
			countTimer = self:ScheduleRepeatingTimer(countdown, 1, self, args.spellId)
		end
	end

	function mod:TankNetherBanishRemoved(args)
		self:StopBar(args.spellName, args.destName)
		self:PrimaryIcon(args.spellId)
		if self:Me(args.destGUID) then
			if countTimer then self:CancelTimer(countTimer) end
			self:CloseProximity(args.spellId)
		end
	end
end

function mod:NetherBanishApplied(args)
	if self:Me(args.destGUID) then
		banished = true
		shadowsCount = 1
		if feedbackSoon then
			self:CloseProximity(187180) -- Demonic Feedback
		end
	end
end

function mod:NetherBanishRemoved(args)
	if self:Me(args.destGUID) then
		banished = nil
		self:StopBar(189894) -- Void Star
		self:StopBar(CL.count:format(self:SpellName(190050), shadowsCount)) -- Touch of Shadows
		if feedbackSoon then
			self:ScheduleTimer("MessageOld", 1, 187180, "yellow", "info", CL.soon:format(self:SpellName(187180))) -- loading screen delay
			self:OpenProximity(187180, 7) -- Demonic Feedback
		end
	end
end

do
	local prev = 0
	function mod:NetherStormDamage(args)
		local t = GetTime()
		if self:Me(args.destGUID) and t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL.underyou:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

function mod:VoidStarFixate(args)
	if banished then
		self:TargetMessageOld(189894, args.destName, "blue", "alarm")
		self:Bar(189894, 15.8)
	end
	if self:Me(args.destGUID) then
		self:Say(189894, nil, nil, "Void Star")
		self:OpenProximity(189894, 15)
	end
end

function mod:VoidStarFixateRemoved(args)
	if self:Me(args.destGUID) then
		self:CloseProximity(189894)
	end
end

function mod:DemonicFeedbackSoon()
	feedbackSoon = true
	if not banished then
		self:MessageOld(187180, "yellow", "info", CL.soon:format(self:SpellName(187180)))
		self:OpenProximity(187180, 7)
	end
end

function mod:DemonicFeedback(args)
	feedbackSoon = nil
	if not banished then
		self:MessageOld(args.spellId, "yellow", "warning")
		self:OpenProximity(187180, 7)
		self:ScheduleTimer("CloseProximity", 2, 187180)
	end
	self:CDBar(args.spellId, 37) -- Rain of Chaos really messes with timers

	self:CancelTimer(feedbackTimer)
	feedbackTimer = self:ScheduleTimer("DemonicFeedbackSoon", 28)
end

-- Phase 3 (mythic)

do
	local prev, count, infernals = 0, 1, {}
	function mod:UNIT_TARGET(_, firedUnit)
		local unit = firedUnit and firedUnit.."target" or "mouseover"
		local guid = self:UnitGUID(unit)
		if infernals[guid] then
			self:CustomIcon(false, unit, infernals[guid])
			infernals[guid] = nil
			if not next(infernals) then
				self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
				self:UnregisterEvent("UNIT_TARGET")
			end
		end
	end

	function mod:InfernalSpawn(args)
		local t = GetTime()
		if t-prev > 30 then
			count = 1
			prev = t
			infernals = {}
		end
		if self:GetOption("custom_off_infernal_marker") then
			infernals[args.destGUID] = count
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "UNIT_TARGET")
			self:RegisterEvent("UNIT_TARGET")
		end

		if self:Mythic() then
			local barTime = 61
			local p3Duration = t - p3Start
			self:MessageOld(182225, "orange", "alert", L.infernal_count:format(self:SpellName(182225), count, infernalAmount))

			for i = 1, #timers.infernals do
				local v = timers.infernals[i]
				if v > p3Duration + 0.5 then
					barTime = v - p3Duration
					if v > 110 and v < 320 then
						infernalAmount = 4
					elseif v > 320 then
						infernalAmount = 5
					end
					break
				end
			end

			count = barTime > 30 and 1 or count + 1
			self:Bar(182225, barTime, L.infernal_count:format(self:SpellName(182225), count, infernalAmount))
		else
			count = count + 1
		end
	end
end

function mod:DarkConduit(args)
	conduitCount = (conduitCount % 3) + 1
	self:MessageOld(args.spellId, "green", "alert", CL.count:format(args.spellName, conduitCount))
	local time = 60
	local p3Duration = GetTime() - p3Start
	for _,v in ipairs(timers.dc) do
		if v > p3Duration+0.5 then
			time = v-p3Duration
			break
		end
	end
	self:Bar(args.spellId, time)
end

function mod:TwistedDarkness(args)
	self:MessageOld(args.spellId, "yellow", "alarm")
	local time = 42
	local p3Duration = GetTime() - p3Start
	for _,v in ipairs(timers.twisted) do
		if v > p3Duration+5 then
			time = v-p3Duration
			break
		end
	end
	self:Bar(args.spellId, time)
end

function mod:SummonSourceOfChaos(args)
	self:MessageOld(190703, "yellow", "alarm")
	local time = 58
	local p3Duration = GetTime() - p3Start
	for _,v in ipairs(timers.chaos) do
		if v > p3Duration+5 then
			time = v-p3Duration
			break
		end
	end
	self:Bar(190703, time)
end

function mod:SeethingCorruption(args)
	self:MessageOld(args.spellId, "orange", "alert")
	local time = 58
	local p3Duration = GetTime() - p3Start
	for _,v in ipairs(timers.seething) do
		if v > p3Duration+5 then
			time = v-p3Duration
			break
		end
	end
	self:Bar(args.spellId, time)
	self:Bar(args.spellId, 12, CL.cast:format(args.spellName))
end

function mod:MarkOfTheLegionCast(args)
	local time = 60
	local p3Duration = GetTime() - p3Start
	for _,v in ipairs(timers.marks) do
		if v > p3Duration+5 then
			time = v-p3Duration
			break
		end
	end
	markOfTheLegionCount = markOfTheLegionCount + 1
	self:Bar(187050, time, CL.count:format(args.spellName, markOfTheLegionCount))
end

do
	local list, proxList, isOnMe, timer = {}, {}, nil, nil
	local function legionSay(self, spellId)
		-- APPLIED should alawys be in debuff remaining order, manually sort by debuff remaining if any issues show up
		timer = nil
		proxList = {}
		for i = 1, #list do
			local target = list[i]
			if target == isOnMe then
				self:Say(spellId, CL.count_rticon:format(CL.mark, i, i), nil, ("Mark (%d{rt%d})"):format(i, i))
				self:Flash(spellId)
				self:OpenProximity(spellId, 10, nil, true)
				self:TargetMessageOld(spellId, target, "blue", "alarm", CL.count_icon:format(CL.mark, i, i))
			end
			if self:GetOption("custom_off_legion_marker") then
				self:CustomIcon(false, target, i)
			end
			proxList[i] = target
			list[i] = self:ColorName(target)
		end
		if not isOnMe then
			self:TargetMessageOld(spellId, list, "yellow", nil, CL.count:format(self:SpellName(spellId), markOfTheLegionCount-1))
			self:OpenProximity(spellId, 10, proxList, true)
		else
			list = {}
		end
	end

	local timeLeft, countTimer = 5, nil
	local function countdown(self)
		timeLeft = timeLeft - 1
		if timeLeft < 4 then
			self:Say("markofthelegion_self", timeLeft, true)
			if timeLeft < 2 then
				self:CancelTimer(countTimer)
				countTimer = nil
			end
		end
	end

	local function startCountdown(self)
		if countTimer then self:CancelTimer(countTimer) end
		countTimer = self:ScheduleRepeatingTimer(countdown, 1, self)
	end

	function mod:MarkOfTheLegion(args)
		if self:Me(args.destGUID) then
			isOnMe = args.destName
			timeLeft = 5
			local t = GetTime()
			local _, _, _, expires = self:UnitDebuff("player", args.spellName, 187050)
			if expires and expires > 0 then
				timeLeft = expires - t
			end
			self:Bar("markofthelegion_self", timeLeft, L.markofthelegion_self_bar, args.spellId)
			local flr = floor(timeLeft)
			self:ScheduleTimer(startCountdown, timeLeft-flr, self)
			timeLeft = flr
		end

		list[#list + 1] = args.destName
		if #list == 1 then
			timer = self:ScheduleTimer(legionSay, 0.4, self, args.spellId)
		elseif timer and #list == 4 then
			self:CancelTimer(timer)
			legionSay(self, args.spellId)
		end
	end

	function mod:MarkOfTheLegionRemoved(args)
		if self:GetOption("custom_off_legion_marker") then
			self:CustomIcon(false, args.destName)
		end

		self:DeleteFromTable(proxList, args.destName)
		if isOnMe then
			if self:Me(args.destGUID) then
				isOnMe = nil
				if countTimer then self:CancelTimer(countTimer) countTimer = nil end
				if #proxList == 0 then
					self:CloseProximity(args.spellId)
				else
					self:OpenProximity(args.spellId, 10, proxList, true)
				end
			end
		else
			if #proxList == 0 then
				self:CloseProximity(args.spellId)
			else
				self:OpenProximity(args.spellId, 10, proxList, true)
			end
		end
	end
end

