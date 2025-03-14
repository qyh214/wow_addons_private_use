
-- TODO: Mark bomb adds: Darkfuse Technician / Giga-Juiced Technician

--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Chrome King Gallywix", 2769, 2646)
if not mod then return end
mod:RegisterEnableMob(231075)
mod:SetEncounterID(3016)
mod:SetPrivateAuraSounds({
	466155, -- Sapper's Satchel
	466344, -- Fused Canisters
	{ -- Overloaded Rockets
		1214760, 1214749, 1214750, 1214757,
		1214758, 1214759, 1214761, 1214762,
		1214763, 1214764, 1214765, 1214766, 1214767
	},
	1219279, -- Gallybux Pest Eliminator
	1218550 -- Biggest Baddest Bomb Barrage
})
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local canistersCount = 1
local bombsCount = 1
local suppressionCount = 1
local ventingHeatCount = 1
local egoCheckCount = 1

local fullCanistersCount = 1
local fullBombsCount = 1
local fullSuppressionCount = 1
local fullVentingHeatCount = 1

local gigaCoilsCount = 1
local gigaBlastCount = 1

local encounterStart = 0
local spawnedDuds = 0

-- Rashanan style timers: Each Giga Coils starts a mini-phase
local timersNormal = {
	{ -- Phase 1
		[466340] = { 7.3, 18.9, 20.4, 21.0, 18.4, 22.9, 0 }, -- Scatterblast Canisters
		[465952] = { 22.3, 39.3, 39.3, 0 }, -- Big Bad Buncha Bombs
		[467182] = { 34.9, 43.2, 37.4, 0 }, -- Suppression
		[466751] = { 13.9, 28.7, 31.5, 30.6, 0 }, -- Venting Heat
	},
	{ -- Phase 2 (4:48 third coils)
		[469286] = { 9.0, 70.7, 70.7 }, -- Giga Coils
		[466341] = { -- Fused Canisters
			{ 12.7, 41.2, 0 },
			{ 34.0, 0 },
		},
		[465952] = { -- Big Bad Buncha Bombs
			{ 44.7, 0 },
			{ 46.3, 0 },
		},
		[467182] = { -- Suppression
			{ 29.9, 0 },
			{ 8.9, 43.7, 0 },
		},
		[466751] = { -- Venting Heat
			{ 25.5, 0 },
			{ 20.8, 0 },
		},
	},
	{ -- Phase 3
		[469286] = { 60.1, 59.5, 66.4, 54.5, 60.0, 67.8 }, -- Giga Coils
		[466342] = { -- Tick-Tock Canisters
			{ 22.0, 0 },
			{ 6.5, 35.0, 0 },
			{ 27.3, 0 },
			{ 6.0, 35.0, 0 },
			{ 31.6, 0 },
			{ 17.6, 37.0 },
		},
		[1214607] = { -- Bigger Badder Bomb Blast
			{ 8.0, 34.0, 0 },
			{ 28.5, 0 },
			{ 16.9, 37.0, 0 },
			{ 25.6, 0 },
			{ 34.0, 0 },
			{ 30.2 },
		},
		[467182] = { -- Suppression
			{ 33.0, 0 },
			{ 20.9, 0 },
			{ 7.3, 37.0, 0 },
			{ 31.6, 0 },
			{ 17.6, 0 },
			{ 5.2, 37.0 },
		},
		[466751] = { -- Venting Heat
			{ 18.0, 0 },
			{ 12.9, 36.0, 0 },
			{ 38.9, 0 },
			{ 22.1, 0 },
			{ 26.1, 0 },
			{ 14.2, 37.0 },
		},
	}
}
local timersHeroic = {
	{ -- Phase 1
		[466340] = { 6.5, 17.2, 18.4, 17.1, 18.3, 18.9, 0 }, -- Scatterblast Canisters
		[465952] = { 20.2, 35.5, 33.7, 0 }, -- Big Bad Buncha Bombs
		[467182] = { 31.6, 37.2, 33.7, 0 }, -- Suppression
		[466751] = { 12.6, 25.9, 26.7, 27.6, 0 }, -- Venting Heat
	},
	{ -- Phase 2
		[469286] = { 9.0, 57.7 }, -- Giga Coils
		[466341] = { -- Fused Canisters
			{ 10.2, 32.9, 0 },
			{ 27.7, 0 },
		},
		[465952] = { -- Big Bad Buncha Bombs
			{ 36.5, 0 },
			{ 37.8, 0 },
		},
		[467182] = { -- Suppression
			{ 24.0, 0 },
			{ 9.4, 35.2, 0 },
		},
		[466751] = { -- Venting Heat
			{ 20.5, 0 },
			{ 18.2, 0 },
		},
	},
	{ -- Phase 3
		[469286] = { 60.1, 60.4, 69.0 }, -- Giga Coils
		[466342] = { -- Tick-Tock Canisters
			{ 22.0, 0 },
			{ 6.9, 35.0, 0 },
			{ 27.9, 0 },
			{ 3.4 },
		},
		[1214607] = { -- Bigger Badder Bomb Blast
			{ 8.0, 36.0, 0 },
			{ 31.0, 0 },
			{ 18.5, 25.0, 0 }, -- XXX 19.0, 35.0 ???
			{ 23.3 },
		},
		[466958] = { -- Ego Check
			{ 14.1, 13.0, 15.0, 8.1, 0 },
			{ 15.4, 13.5, 8.1, 10.0, 0 },
			{ 16.5, 8.0, 9.0, 26.1, 0 },
			{ 10.6, 18.5, 11.0 },
		},
		[467182] = { -- Suppression
			{ 33.0, 0 },
			{ 20.0, 0 },
			{ 7.4, 37.0, 0 }, -- XXX 7.6, 43.0 ???
			{ 31.2 },
		},
		[466751] = { -- Venting Heat
			{ 18.0, 0 },
			{ 11.9, 37.1, 0 },
			{ 38.4, 0 },
			{ 19.6 },
		},
	}
}
local timers = mod:Easy() and timersNormal or timersHeroic

local function cd(spellId, count)
	-- not knowing the full fight sequence makes normal table lookups sketchy without metatables
	local coilCount = gigaCoilsCount
	local stage = mod:GetStage()
	if stage == 1 then
		return timers[stage][spellId][count]
	elseif stage == 2 then
		coilCount = coilCount - 1 -- there's no before the first coil phase like in p3
	end
	return timers[stage][spellId][coilCount] and timers[stage][spellId][coilCount][count]
end

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.scatterblast_canisters = "Cone Soak"
	L.fused_canisters = "Group Soaks"
	L.tick_tock_canisters = "Soaks"
	L.total_destruction = "DESTRUCTION!"

	L.duds = "Duds" -- Short for 1500-Pound "Dud"
	L.all_duds_detontated = "All Duds Detonated!"
	L.duds_remaining = "%d |4Dud remains:Duds remaining;" -- 1 Dud Remains | 2 Duds Remaining
	L.duds_soak = "Soak Duds (%d left)"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		1220761, -- Mechengineer's Canisters
			-- 474447, -- Canister Detonation
		465952, -- Big Bad Buncha Bombs
			466154, -- Blast Burns
			466153, -- Bad Belated Boom
			466165, -- 1500-Pound "Dud"
				466246, -- Focused Detonation
					1217292, -- Time-Release Crackle
			-- 466338, -- Zagging Zizzler
		467182, -- Suppression
		466751, -- Venting Heat
		1222831, -- Overloaded Coils

		-- Stage One: The House of Chrome
			466340, -- Scatterblast Canisters
			-- {1220290, "TANK"}, -- Trick Shots

		-- Stage Two: Mechanical Maniac
			469286, -- Giga Coils
				469327, -- Giga Blast
				-- 1219313, -- Overloaded Bolts (repeating swirl timer?)
			469362, -- Charged Giga Bomb
				469404, -- Giga BOOM! (fail damage)
				469795, -- Giga Bomb Detonation
					1220669, -- Sabotaged Controls
						1215209, -- Sabotage Zone
						-- 1220846, -- Control Meltdown
			{466341, "PRIVATE"}, -- Fused Canisters
		-- Darkfuse Cronies
			-- Darkfuse Technician
				-- -31482, -- Darkfuse Technician
				-- 471352, -- Juice It!
			-- Sharpshot Sentry
				466834, -- Shock Barrage
			-- Darkfuse Wrenchmonger
				{1216845, "NAMEPLATE"}, -- Wrench
				1216852, -- Lumbering Rage
		-- Intermission: Docked and Loaded
			1214229, -- Armageddon-class Plating
			-- 1219319, -- Radiant Electricity
			{1214369, "CASTBAR"}, -- TOTAL DESTRUCTION!!!
		-- Stage Three: What an Arsenal!
			1214607, -- Bigger Badder Bomb Blast
				{1214755, "PRIVATE"}, -- Overloaded Rockets
			466342, -- Tick-Tock Canisters
			1219333, -- Gallybux Finale Blast (Suppression Stage 3)
		-- Greedy Goblin's Armaments
			{466958, "TANK_HEALER"}, -- Ego Check
				-- 467064, -- Checked Ego
	},{
		[466340] = -30490, -- Stage One: The House of Chrome
		[469286] = -30497, -- Stage Two: Mechanical Maniac
		[1214229] = -31558, -- Intermission: Docked and Loaded
		[1214607] = -31445, -- Stage Three: What an Arsenal!
	},{
		[1220761] = CL.heal_absorb, -- Mechengineer's Canisters
		[466340] = L.scatterblast_canisters, -- Scatterblast Canisters (Cone Soak)
		[465952] = CL.bombs, -- Big Bad Buncha Bombs (Bombs)
		[466165] = L.duds, -- 1500-Pound "Dud" (Duds)
		[1217292] = CL.explosion, -- Time-Release Crackle (Explosion)
		[1214229] = CL.shield, -- Armageddon-class Plating (Shield)
		[466341] = L.fused_canisters, -- Fused Canisters (Group Soaks)
		[1214607] = CL.bombs, -- Bigger Badder Bomb Blast (Bombs)
		[466342] = L.tick_tock_canisters, -- Tick-Tock Canisters (Soaks)
	}
end

function mod:OnRegister()
	self:SetSpellRename(466340, L.scatterblast_canisters) -- Scatterblast Canisters (Cone Soak)
	self:SetSpellRename(465952, CL.bombs) -- Big Bad Buncha Bombs (Bombs)
	self:SetSpellRename(466341, L.fused_canisters) -- Fused Canisters (Group Soaks)
	self:SetSpellRename(1214607, CL.bombs) -- Bigger Badder Bomb Blast (Bombs)
	self:SetSpellRename(466342, L.tick_tock_canisters) -- Tick-Tock Canisters (Soaks)
end

function mod:OnBossEnable()
	if self:Story() then
		self:Log("SPELL_CAST_SUCCESS", "GigaBlastSuccess", 469327) -- mini phase
		self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1") -- phase 2
	end

	self:Log("SPELL_AURA_APPLIED", "GroundDamage", 1215209) -- Sabotage Zone
	self:Log("SPELL_PERIODIC_DAMAGE", "GroundDamage", 1215209)
	self:Log("SPELL_PERIODIC_MISSED", "GroundDamage", 1215209)

	self:Log("SPELL_AURA_APPLIED", "MechengineersCanistersApplied", 1220761)
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	-- self:Log("SPELL_CAST_START", "BigBadBunchaBombs", 465952) -- EMOTE
	self:Log("SPELL_AURA_APPLIED", "BlastBurnsApplied", 466154)
	self:Log("SPELL_AURA_APPLIED_DOSE", "BlastBurnsApplied", 466154)
	self:Log("SPELL_AURA_APPLIED", "FifteenHundredPoundDudApplied", 466165)
	self:Log("SPELL_AURA_REMOVED", "FifteenHundredPoundDudRemoved", 466165)
	self:Log("SPELL_AURA_APPLIED", "FocusedDetonationApplied", 466246)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FocusedDetonationApplied", 466246)
	self:Log("SPELL_AURA_REMOVED", "FocusedDetonationRemoved", 466246)
	self:Log("SPELL_CAST_START", "Suppression", 467182)
	self:Log("SPELL_CAST_START", "VentingHeat", 466751)
	-- self:Log("SPELL_AURA_APPLIED", "TrickShotsApplied", 1220290)
	-- self:Log("SPELL_AURA_APPLIED_DOSE", "TrickShotsApplied", 1220290)
	-- self:Log("SPELL_AURA_REMOVED", "TrickShotsRemoved", 1220290) -- XXX used as phase 2 start below

	-- Stage 1
	self:Log("SPELL_CAST_START", "ScatterblastCanisters", 466340)

	-- Stage 2
	self:Log("SPELL_AURA_REMOVED", "TrickShotsRemoved", 1220290)
	-- self:Log("SPELL_CAST_START", "GigaCoils", 469286) -- USCS 469286
	self:Log("SPELL_AURA_REMOVED", "GigaCoilsRemoved", 469293)
	self:Log("SPELL_CAST_START", "GigaBlast", 469327)
	self:Log("SPELL_AURA_APPLIED", "ChargedGigaBombApplied", 469362)
	self:Log("SPELL_AURA_APPLIED", "GigaBoomApplied", 469404)
	-- self:Log("SPELL_AURA_APPLIED_DOSE", "GigaBoomApplied", 469404)
	self:Log("SPELL_AURA_APPLIED", "GigaBombDetonationApplied", 469795)
	self:Log("SPELL_AURA_APPLIED", "SabotagedControlsApplied", 1220669)
	self:Log("SPELL_AURA_APPLIED_DOSE", "SabotagedControlsApplied", 1220669)
	self:Log("SPELL_CAST_START", "FusedCanisters", 466341)

	self:RegisterUnitEvent("UNIT_SPELLCAST_START", nil, "boss1") -- Giga Coils
	-- self:Log("SPELL_CAST_START", "JuiceIt", 471352)
	self:Log("SPELL_CAST_START", "ShockBarrage", 466834)
	self:Log("SPELL_CAST_START", "Wrench", 1216845)
	self:Log("SPELL_AURA_APPLIED", "WrenchApplied", 1216845)
	self:Log("SPELL_AURA_APPLIED_DOSE", "WrenchApplied", 1216845)
	self:Log("SPELL_AURA_APPLIED", "LumberingRageApplied", 1216852)
	self:Death("AddsDeath", 231978, 231939, 231977) -- Sharpshot Sentry, Darkfuse Wrenchmonger, Darkfuse Technician

	-- Intermission
	self:Log("SPELL_AURA_APPLIED", "ArmageddonClassPlatingApplied", 1214229)
	self:Log("SPELL_AURA_REMOVED", "ArmageddonClassPlatingRemoved", 1214229)
	self:Log("SPELL_CAST_START", "TotalDestruction", 1214369)
	self:Log("SPELL_INTERRUPT", "TotalDestructionInterrupted", 1214369)

	-- Stage 3
	self:Log("SPELL_CAST_START", "BiggerBadderBombBlast", 1214607)
	self:Log("SPELL_CAST_START", "TickTockCanisters", 466342)
	self:Log("SPELL_CAST_START", "EgoCheck", 466958)
	self:Log("SPELL_AURA_APPLIED", "EgoCheckApplied", 466958)
	self:Log("SPELL_AURA_APPLIED_DOSE", "EgoCheckApplied", 466958)
	self:Log("SPELL_CAST_START", "OverloadedCoils", 1222831)

	timers = self:Easy() and timersNormal or timersHeroic
end

function mod:OnEngage()
	self:SetStage(1)

	canistersCount = 1
	bombsCount = 1
	suppressionCount = 1
	ventingHeatCount = 1

	fullCanistersCount = 1
	fullBombsCount = 1
	fullSuppressionCount = 1
	fullVentingHeatCount = 1

	gigaCoilsCount = 1
	gigaBlastCount = 1

	encounterStart = GetTime()

	if not self:Story() then
		self:Bar(466340, cd(466340, 1), CL.count:format(L.scatterblast_canisters, canistersCount)) -- Scatterblast Canisters
		self:Bar(465952, cd(465952, 1) - 2.2, CL.count:format(CL.bombs, bombsCount)) -- Big Bad Buncha Bombs (emote is 2.2s earlier)
		self:Bar(467182, cd(467182, 1), CL.count:format(self:SpellName(467182), suppressionCount)) -- Suppression
		self:Bar(466751, cd(466751, 1), CL.count:format(self:SpellName(466751), ventingHeatCount)) -- Venting Heat
		self:Bar("stages", self:Easy() and 123.4 or 111.0, CL.stage:format(2), "ability_siege_engineer_magnetic_crush")
	-- else
	-- 	-- XXX Something affects energy gain (damage?), which causes the Giga Blast "phases" to vary,
	-- 	-- XXX which pushes around all the other timers. So I'm just going to leave the timers off for now.
	-- 	-- Bombs > Suppression > Bombs > Suppression > Giga Blast x3
	-- 	self:Bar(465952, 15.4 - 2.2, CL.count:format(self:SpellName(465952), fullBombsCount)) -- Big Bad Buncha Bombs (emote is 2.2s earlier)
	-- 	self:Bar(467182, 26.7, CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
	-- 	self:Bar(469327, 64, CL.count:format(self:SpellName(469327), gigaBlastCount)) -- Giga Blast
	end

	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_HEALTH(event, unit)
	if self:GetHealth(unit) < 53 then -- Intermission at ~50%
		self:UnregisterUnitEvent(event, unit)
		self:Message("stages", "cyan", CL.soon:format(CL.intermission), false)
		self:PlaySound("stages", "info")
	end
end

-- Story Mode

function mod:GigaBlastSuccess()
	if gigaBlastCount % 3 == 1 then
		bombsCount = 1
		suppressionCount = 1
		ventingHeatCount = 1

		-- local stage = self:GetStage()
		-- if stage == 1 then -- Venting Heat > Suppression > Bombs > Suppression > Giga Blast x3
		-- 	self:CDBar(466751, 15.6, CL.count:format(self:SpellName(466751), fullVentingHeatCount)) -- Venting Heat
		-- 	self:CDBar(467182, 28.2, CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
		-- 	self:CDBar(465952, 44.3, CL.count:format(self:SpellName(465952), fullBombsCount)) -- Big Bad Buncha Bombs
		-- 	self:CDBar(469327, 65.5, CL.count:format(self:SpellName(469327), gigaBlastCount)) -- Giga Blast
		-- elseif stage == 2 then -- Venting Heat > Bombs > Suppression > Venting Heat > Bombs > Suppression > Giga Blast x3
		-- 	self:CDBar(466751, 18.8, CL.count:format(self:SpellName(466751), fullVentingHeatCount)) -- Venting Heat
		-- 	self:CDBar(1214607, 22.3, CL.count:format(self:SpellName(1214607), fullBombsCount)) -- Bigger Badder Bomb Blast
		-- 	self:CDBar(467182, 28.8, CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
		-- 	self:CDBar(469327, 65.5, CL.count:format(self:SpellName(469327), gigaBlastCount)) -- Giga Blast
		-- end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, unit, _, spellId)
	if spellId == 45313 then -- Anchor Here
		self:StopBar(CL.count:format(self:SpellName(465952), fullBombsCount)) -- Big Bad Buncha Bombs
		self:StopBar(CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
		self:StopBar(CL.count:format(self:SpellName(466751), fullVentingHeatCount)) -- Venting Heat
		self:StopBar(CL.count:format(self:SpellName(469327), gigaBlastCount)) -- Giga Blast
		self:UnregisterEvent("UNIT_HEALTH", "boss1")

		self:Message("stages", "cyan", CL.stage:format(2), false)
		self:PlaySound("stages", "long")
		self:SetStage(2)

		bombsCount = 1
		suppressionCount = 1
		ventingHeatCount = 1

		fullBombsCount = 1
		fullSuppressionCount = 1
		fullVentingHeatCount = 1

		gigaBlastCount = 1

		-- Venting Heat > Bombs > Suppression > Venting Heat > Bombs > Suppression > Giga Blast x3
		-- self:Bar(466751, 15.5, CL.count:format(self:SpellName(466751), fullVentingHeatCount)) -- Venting Heat
		-- self:Bar(1214607, 19.0, CL.count:format(self:SpellName(1214607), fullBombsCount)) -- Bigger Badder Bomb Blast
		-- self:Bar(467182, 25.5, CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
		-- self:Bar(469327, 63.5, CL.count:format(self:SpellName(469327), gigaBlastCount)) -- Giga Blast

		if encounterStart > 0 then
			-- hard enrage at 9:37
			local enrageCD = 577.5 - (GetTime() - encounterStart)
			self:Bar(1222831, enrageCD) -- Overloaded Coils
		end
	end
end

-- General

do
	local prev = 0
	function mod:GroundDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PlaySound(args.spellId, "underyou")
			self:PersonalMessage(args.spellId, "underyou")
		end
	end
end

function mod:MechengineersCanistersApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, nil, CL.heal_absorb)
		self:PlaySound(args.spellId, "info") -- healing absorb
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
	-- [CHAT_MSG_RAID_BOSS_EMOTE] |TInterface\\ICONS\\Ships_ABILITY_Bombers.BLP:20|t %s begins to cast |cFFFF0000|Hspell:465952|h[Big Bad Buncha Bombs]|h|r!#Chrome King Gallywix
	if msg:find("spell:465952", nil, true) then
		-- a bit earlier than the cast
		self:StopBar(CL.count:format(CL.bombs, fullBombsCount))
		self:Message(465952, "red", CL.count:format(CL.bombs, fullBombsCount))
		self:PlaySound(465952, "alert")
		bombsCount = bombsCount + 1
		fullBombsCount = fullBombsCount + 1
		spawnedDuds = 0
		if not self:Story() then
			self:CDBar(465952, cd(465952, bombsCount), CL.count:format(CL.bombs, fullBombsCount))
			self:Bar(466153, 11.9) -- Bad Belated Boom
		-- elseif fullBombsCount == 2 then -- 1 per Giga Blast, except 2 before the first Giga Blast
		-- 	self:CDBar(465952, 25.1, CL.count:format(self:SpellName(465952), fullBombsCount))
		end
	end
end

-- function mod:BigBadBunchaBombs(args)
-- 	self:StopBar(CL.count:format(CL.bombs, fullBombsCount))
-- 	self:Message(args.spellId, "red", CL.count:format(CL.bombs, fullBombsCount))
-- 	self:PlaySound(args.spellId, "alert")
-- 	bombsCount = bombsCount + 1
-- 	fullBombsCount = fullBombsCount + 1
-- 	self:CDBar(args.spellId, cd(465952, bombsCount), CL.count:format(CL.bombs, fullBombsCount))

-- 	spawnedDuds = 0
-- 	self:Bar(466153, 9.7) -- Bad Belated Boom
-- end

do
	local stacksOnMe = 0
	local scheduled = nil
	local playerName = mod:UnitName("player")
	function mod:BlastBurnsStackMessage()
		local emphAt = 3
		self:StackMessage(466154, "blue", playerName, stacksOnMe, emphAt)
		if stacksOnMe >= emphAt then
			self:PlaySound(466154, "alarm") -- larger dot
		else
			self:PlaySound(466154, "info") -- small dot
		end
		scheduled = nil
	end

	function mod:BlastBurnsApplied(args)
		if self:Me(args.destGUID) then
			stacksOnMe = args.amount or 1
			if not scheduled then
				scheduled = self:ScheduleTimer("BlastBurnsStackMessage", 0.1)
			end
		end
	end
end

do
	local prev = 0
	function mod:FifteenHundredPoundDudApplied(args)
		-- self:StopBar(L.duds_soak:format(spawnedDuds))
		spawnedDuds = spawnedDuds + 1
		if args.time - prev > 2 then
			self:Bar(args.spellId, 15, L.duds)
		end
		-- if args.time - prev > 2 then
		-- 	prev = args.time
		-- 	self:Message(args.spellId, "red", CL.spawned:format(L.duds))
		-- 	self:Bar(args.spellId, 15, L.duds_soak:format(spawnedDuds))
		-- else
		-- 	local timeLeft = 15 - (args.time - prev)
		-- 	self:Bar(args.spellId, {timeLeft, 15}, L.duds_soak:format(spawnedDuds))
		-- end
	end

	function mod:FifteenHundredPoundDudRemoved(args)
		-- self:StopBar(L.duds_soak:format(spawnedDuds))
		self:StopBar(L.duds)
		spawnedDuds = spawnedDuds - 1
		-- self:Message(args.spellId, "green", L.duds_remaining:format(spawnedDuds))
		-- local timeLeft = 15 - (args.time - prev)
		-- if spawnedDuds > 0 and timeLeft > 0 then
		-- 	self:Bar(args.spellId, {timeLeft, 15}, L.duds_soak:format(spawnedDuds+1))
		if spawnedDuds <= 0 then
			self:StopBar(args.spellId) -- 1500-Pound "Dud"
			self:Message(args.spellId, "green", L.all_duds_detontated)
			self:PlaySound(args.spellId, "info")
		end
	end
end

function mod:FocusedDetonationApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "purple", args.destName, args.amount, 2)
		self:PlaySound(args.spellId, "info") -- soaked bomb
	end
	self:TargetBar(1217292, 10, args.destName, CL.explosion) -- Time-Release Crackle
end

function mod:FocusedDetonationRemoved(args)
	self:StopBar(1217292, args.destName) -- Time-Release Crackle
end

function mod:Suppression(args)
	self:StopBar(CL.count:format(args.spellName, fullSuppressionCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, fullSuppressionCount))
	self:PlaySound(args.spellId, "alarm") -- avoid
	if self:GetStage() == 3 and not self:Story() then
		self:Bar(1219333, 6) -- Gallybux Finale Blast
	end
	suppressionCount = suppressionCount + 1
	fullSuppressionCount = fullSuppressionCount + 1
	if not self:Story() then
		self:CDBar(args.spellId, cd(args.spellId, suppressionCount), CL.count:format(args.spellName, fullSuppressionCount))
	-- elseif suppressionCount % 2 == 0 then
	-- 	local cd = (self:GetStage() == 1 and (fullSuppressionCount - 2) % 4 == 0) and 23.9 or 25.5
	-- 	self:CDBar(args.spellId, cd, CL.count:format(args.spellName, fullSuppressionCount))
	end
end

function mod:VentingHeat(args)
	self:StopBar(CL.count:format(args.spellName, fullVentingHeatCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, fullVentingHeatCount))
	self:PlaySound(args.spellId, "alert") -- raid damage
	ventingHeatCount = ventingHeatCount + 1
	fullVentingHeatCount = fullVentingHeatCount + 1
	if not self:Story() then
		self:CDBar(args.spellId, cd(args.spellId, ventingHeatCount), CL.count:format(args.spellName, fullVentingHeatCount))
	-- elseif self:GetStage() == 2 and ventingHeatCount % 2 == 0 then
	-- 	self:CDBar(args.spellId, 25.0, CL.count:format(args.spellName, fullVentingHeatCount))
	end
end

-- do
-- 	local trickShotsAmount = 0
-- 	local emphAt = 7
-- 	function mod:TrickShotsApplied(args)
-- 		self:StopBar(CL.count:format(args.spellName, trickShotsAmount + 1))
-- 		trickShotsAmount = args.amount or 1
-- 		self:StackMessage(args.spellId, "purple", args.destName, trickShotsAmount, emphAt)
-- 		if trickShotsAmount >= emphAt then
-- 			self:PlaySound(args.spellId, "warning") -- big damage on swap or at 10
-- 		end
-- 		self:Bar(args.spellId, 4, CL.count:format(args.spellName, trickShotsAmount + 1))
-- 	end
-- 	function mod:TrickShotsRemoved(args)
-- 		self:StopBar(CL.count:format(args.spellName, trickShotsAmount + 1))
-- 		trickShotsAmount = 0
-- 	end
-- end

-- Stage One: The House of Chrome

function mod:ScatterblastCanisters(args)
	self:StopBar(CL.count:format(L.scatterblast_canisters, fullCanistersCount))
	self:Message(args.spellId, "orange", CL.count:format(L.scatterblast_canisters, fullCanistersCount))
	self:PlaySound(args.spellId, "alert") -- soak
	canistersCount = canistersCount + 1
	fullCanistersCount = fullCanistersCount + 1
	self:CDBar(args.spellId, cd(args.spellId, canistersCount), CL.count:format(L.scatterblast_canisters, fullCanistersCount))
end

-- Stage Two: Mechanical Maniac

function mod:TrickShotsRemoved()
	-- self:StopBar(CL.count:format(args.spellName, trickShotsAmount + 1))
	-- trickShotsAmount = 0
	if self:GetStage() == 1 then
		self:StopBar(CL.stage:format(2))
		self:StopBar(CL.count:format(L.scatterblast_canisters, fullCanistersCount)) -- Scatterblast Canisters
		self:StopBar(CL.count:format(CL.bombs, fullBombsCount)) -- Big Bad Buncha Bombs
		self:StopBar(CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
		self:StopBar(CL.count:format(self:SpellName(466751), fullVentingHeatCount)) -- Venting Heat

		self:SetStage(2)
		self:Message("stages", "cyan", CL.stage:format(2), false)
		self:PlaySound("stages", "info")

		fullCanistersCount = 1
		fullBombsCount = 1
		fullSuppressionCount = 1
		fullVentingHeatCount = 1

		gigaCoilsCount = 1
		gigaBlastCount = 1

		self:CDBar(469286, timers[2][469286][1], CL.count:format(self:SpellName(469286), gigaCoilsCount)) -- Giga Coils
	end
end

function mod:UNIT_SPELLCAST_START(_, unit, _, spellId)
	if spellId == 469286 then -- Giga Coils
		self:StopBar(CL.count:format(self:SpellName(469286), gigaCoilsCount)) -- Giga Coils
		self:StopBar(CL.count:format(L.scatterblast_canisters, fullCanistersCount)) -- Scatterblast Canisters
		self:StopBar(CL.count:format(L.fused_canisters, fullCanistersCount)) -- Fused Canisters
		self:StopBar(CL.count:format(L.tick_tock_canisters, fullCanistersCount)) -- Tick-Tock Canisters
		self:StopBar(CL.count:format(CL.bombs, fullBombsCount)) -- Big Bad Buncha Bombs/Bigger Badder Bomb Blast
		self:StopBar(CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
		self:StopBar(CL.count:format(self:SpellName(466751), fullVentingHeatCount)) -- Venting Heat
		self:StopBar(CL.count:format(self:SpellName(466958), egoCheckCount)) -- Ego Check

		self:Message(469286, "cyan", CL.count:format(self:SpellName(469286), gigaCoilsCount))
		self:PlaySound(469286, "long")

		gigaBlastCount = 1
	end
end

function mod:GigaCoilsRemoved()
	self:StopBar(CL.count:format(self:SpellName(469327), gigaBlastCount))

	self:Message(469286, "cyan", CL.over:format(CL.count:format(self:SpellName(469286), gigaCoilsCount)))
	self:PlaySound(469286, "long")
	gigaCoilsCount = gigaCoilsCount + 1

	canistersCount = 1 -- re-used for Fused Canisters
	bombsCount = 1
	suppressionCount = 1
	ventingHeatCount = 1
	egoCheckCount = 1

	local stage = self:GetStage()
	if stage == 2 then
		self:CDBar(466341, cd(466341, canistersCount), CL.count:format(L.fused_canisters, fullCanistersCount)) -- Fused Canisters
		self:CDBar(465952, cd(465952, bombsCount), CL.count:format(CL.bombs, fullBombsCount)) -- Big Bad Buncha Bombs
	elseif stage == 3 then
		if not self:Easy() then
			self:CDBar(466958, cd(466958, egoCheckCount), CL.count:format(self:SpellName(466958), egoCheckCount)) -- Ego Check
		end
		self:CDBar(466342, cd(466342, canistersCount), CL.count:format(L.tick_tock_canisters, fullCanistersCount)) -- Tick-Tock Canisters
		self:CDBar(1214607, cd(1214607, bombsCount), CL.count:format(CL.bombs, fullBombsCount)) -- Bigger Badder Bomb Blast
	end
	self:CDBar(467182, cd(467182, suppressionCount), CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
	self:CDBar(466751, cd(466751, ventingHeatCount), CL.count:format(self:SpellName(466751), fullVentingHeatCount)) -- Venting Heat

	local gigaCoilsCD = timers[stage][469286][gigaCoilsCount]
	if gigaCoilsCD then
		self:CDBar(469286, gigaCoilsCD - 3, CL.count:format(self:SpellName(469286), gigaCoilsCount)) -- Giga Coils (USCS is 3s earlier)
	end
end

function mod:GigaBlast(args)
	self:StopBar(CL.count:format(args.spellName, gigaBlastCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, gigaBlastCount))
	self:PlaySound(args.spellId, "alert") -- Watch beam?
	gigaBlastCount = gigaBlastCount + 1
	if not self:Story() then
		self:Bar(args.spellId, 6.5, CL.count:format(args.spellName, gigaBlastCount))
	elseif gigaBlastCount % 3 ~= 1 then
		self:Bar(args.spellId, 7.5, CL.count:format(args.spellName, gigaBlastCount))
	end
end

function mod:ChargedGigaBombApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:GigaBoomApplied(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "red")
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:GigaBombDetonationApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "info")
	end
end

function mod:SabotagedControlsApplied(args)
	-- XXX should this even exist?
	self:Message(args.spellId, "green", CL.count:format(args.spellName, args.amount or 1))
	-- self:PlaySound(args.spellId, "info")
	-- if not self:LFR() then
	-- 	self:Bar(1220846, self:Easy() and 60 or self:Mythic() and 15 or 20) -- Control Meltdown
	-- end
end

function mod:FusedCanisters(args)
	self:StopBar(CL.count:format(L.fused_canisters, fullCanistersCount))
	self:Message(args.spellId, "orange", CL.count:format(L.fused_canisters, fullCanistersCount))
	self:PlaySound(args.spellId, "alert") -- soak
	canistersCount = canistersCount + 1
	fullCanistersCount = fullCanistersCount + 1
	self:CDBar(args.spellId, cd(args.spellId, canistersCount), CL.count:format(L.fused_canisters, fullCanistersCount))
end

-- function mod:JuiceIt(args)
-- 	local unit = self:GetUnitIdByGUID(args.sourceGUID)
-- 	if unit then
-- 		if self:UnitWithinRange(unit, 10) then
-- 			self:Message(args.spellId, "orange")
-- 			self:PlaySound(args.spellId, "alarm") -- watch out
-- 		end
-- 	end
-- 	self:Nameplate(args.spellId, 20, args.sourceGUID)
-- end

function mod:ShockBarrage(args)
	local canDo, ready = self:Interrupter(args.sourceGUID)
	if canDo and ready then
		self:Message(args.spellId, "yellow")
		self:PlaySound(args.spellId, "alert")
	end
	-- self:Nameplate(466834, 2.5, args.sourceGUID) -- XXX 2.5 recast >.>
end

function mod:Wrench(args)
	self:Nameplate(1216845, 7.4, args.sourceGUID)
end

function mod:WrenchApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		if amount % 2 == 1 and (not self:Tank() or amount < 6) then -- don't spam tanks if there are a lot of them
			self:StackMessage(args.spellId, "blue", args.destName, amount, 3)
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

do
	local prev = 0
	function mod:LumberingRageApplied(args)
		if self:Dispeller("enrage", true) and args.time - prev > 2 then
			prev = args.time
			self:Message(args.spellId, "red")
			self:PlaySound(args.spellId, "warning") -- 200% damage increase and movement? DO IT
		end
	end
end

function mod:AddsDeath(args)
	self:ClearNameplate(args.destGUID)
end

-- Intermission: Docked and Loaded

do
	local appliedTime = 0
	function mod:ArmageddonClassPlatingApplied(args)
		self:UnregisterUnitEvent("UNIT_HEALTH", "boss1")
		self:StopBar(CL.count:format(CL.bombs, fullBombsCount)) -- Big Bad Buncha Bombs
		self:StopBar(CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
		self:StopBar(CL.count:format(self:SpellName(466751), fullVentingHeatCount)) -- Venting Heat
		self:StopBar(CL.count:format(L.scatterblast_canisters, fullCanistersCount)) -- Scatterblast Canisters
		self:StopBar(CL.count:format(self:SpellName(469286), gigaCoilsCount)) -- Giga Coils
		self:StopBar(CL.count:format(self:SpellName(469327), gigaBlastCount)) -- Giga Blast
		self:StopBar(CL.count:format(L.fused_canisters, fullCanistersCount)) -- Fused Canisters
		self:StopBar(CL.count:format(self:SpellName(466958), egoCheckCount)) -- Ego Check

		appliedTime = args.time

		self:SetStage(2.5)
		self:Message(args.spellId, "cyan", CL.onboss:format(CL.shield))
		self:PlaySound(args.spellId, "warning") -- immune

		self:CDBar(1214369, 9.6, L.total_destruction) -- TOTAL DESTRUCTION!!!
	end
	function mod:ArmageddonClassPlatingRemoved(args)
		if args.amount == 0 then
			self:Message(args.spellId, "green", CL.removed_after:format(CL.shield, args.time - appliedTime))
			self:PlaySound(args.spellId, "info")
		end
	end
end

function mod:TotalDestruction(args)
	self:StopBar(L.total_destruction)
	self:Message(args.spellId, "yellow", CL.casting:format(L.total_destruction))
	self:PlaySound(args.spellId, "alert")
	self:CastBar(args.spellId, 33, L.total_destruction)
end

function mod:TotalDestructionInterrupted(args)
	self:StopCastBar(L.total_destruction)
	-- self:Message(1214369, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))

	self:SetStage(3)
	self:Message("stages", "cyan", CL.stage:format(3), false)
	self:PlaySound("stages", "long") -- stage 3

	bombsCount = 1 -- re-used for Bigger Badder Bomb Blast
	canistersCount = 1 -- re-used for Tick-Tock Canisters
	suppressionCount = 1
	ventingHeatCount = 1
	egoCheckCount = 1

	fullCanistersCount = 1
	fullBombsCount = 1
	fullSuppressionCount = 1
	fullVentingHeatCount = 1

	gigaCoilsCount = 1
	gigaBlastCount = 1

	if not self:Easy() then
		self:CDBar(466958, cd(466958, egoCheckCount), CL.count:format(self:SpellName(466958), egoCheckCount)) -- Ego Check
	end
	self:CDBar(466342, cd(466342, canistersCount), CL.count:format(L.tick_tock_canisters, fullCanistersCount)) -- Tick-Tock Canisters
	self:CDBar(1214607, cd(1214607, bombsCount), CL.count:format(CL.bombs, fullBombsCount)) -- Bigger Badder Bomb Blast
	self:CDBar(467182, cd(467182, suppressionCount), CL.count:format(self:SpellName(467182), fullSuppressionCount)) -- Suppression
	self:CDBar(466751, cd(466751, ventingHeatCount), CL.count:format(self:SpellName(466751), fullVentingHeatCount)) -- Venting Heat
	self:CDBar(469286, timers[3][469286][gigaCoilsCount] - 3, CL.count:format(self:SpellName(469286), gigaCoilsCount)) -- Giga Coils

	if encounterStart > 0 and (self:Normal() or self:Heroic()) then
		-- hard enrage at 9:37
		local enrageCD = 577.5 - (GetTime() - encounterStart)
		self:Bar(1222831, enrageCD) -- Overloaded Coils
	end
end

-- Stage Three: What an Arsenal!

function mod:BiggerBadderBombBlast(args)
	self:StopBar(CL.count:format(CL.bombs, fullBombsCount))
	self:Message(args.spellId, "red", CL.count:format(CL.bombs, fullBombsCount))
	self:PlaySound(args.spellId, "warning") -- dodge
	bombsCount = bombsCount + 1
	fullBombsCount = fullBombsCount + 1
	spawnedDuds = 0
	if not self:Story() then
		self:Bar(args.spellId, cd(args.spellId, bombsCount), CL.count:format(CL.bombs, fullBombsCount))
		self:Bar(1214755, 11.7) -- Overloaded Rockets
		-- self:Bar(466153, 11.9) -- Bad Belated Boom (basically explode when the rockets fire)
	-- elseif bombsCount % 2 == 0 then
	-- 	self:Bar(args.spellId, 30.0, CL.count:format(args.spellName, fullBombsCount))
	end
end

function mod:TickTockCanisters(args)
	self:StopBar(CL.count:format(L.tick_tock_canisters, fullCanistersCount))
	self:Message(args.spellId, "orange", CL.count:format(L.tick_tock_canisters, fullCanistersCount))
	self:PlaySound(args.spellId, "alert") -- soak
	canistersCount = canistersCount + 1
	fullCanistersCount = fullCanistersCount + 1
	self:Bar(args.spellId, cd(args.spellId, canistersCount), CL.count:format(L.tick_tock_canisters, fullCanistersCount))
end

function mod:EgoCheck(args)
	self:StopBar(CL.count:format(args.spellName, egoCheckCount))
	self:Message(args.spellId, "purple", CL.count:format(args.spellName, egoCheckCount))
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and self:Tanking(unit) then
		self:PlaySound(args.spellId, "alarm") -- defensive
	end
	egoCheckCount = egoCheckCount + 1
	self:Bar(args.spellId, cd(args.spellId, egoCheckCount), CL.count:format(args.spellName, egoCheckCount))
end

function mod:EgoCheckApplied(args)
	self:StackMessage(466958, "purple", args.destName, args.amount, 2)
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and not self:Tanking(unit) then -- XXX Confirm swap on every cast?
		self:PlaySound(466958, "warning") -- tauntswap?
	end
end

function mod:OverloadedCoils(args)
	self:StopBar(args.spellId)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- enrage
	-- self:CastBar(args.spellId, 10)
end
