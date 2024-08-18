
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Galakras", 1136, 868)
if not mod then return end
mod:RegisterEnableMob(
	72249, 72358, -- Galakras, Kor'kron Cannon
	72560, 72561, 73909, -- Horde: Lor'themar Theron, Lady Sylvanas Windrunner, Archmage Aethas Sunreaver
	72311, 72302, 73910 -- Alliance: King Varian Wrynn, Lady Jaina Proudmoore, Vereesa Windrunner
)
mod.engageId = 1622

--------------------------------------------------------------------------------
-- Locals
--

local towerAddTimer = nil
local addsCounter = 0
local prevMarkedMob = nil
local prevWin = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.start_trigger_alliance = "Well done! Landing parties, form up! Footmen to the front!"
	L.start_trigger_horde = "Well done. The first brigade has made landfall."

	L.demolisher = -8533 -- Kor'kron Demolisher
	L.demolisher_message = "Demolisher"
	L.demolisher_icon = 125914

	L.towers = "Towers"
	L.towers_desc = "Warnings for when the towers are breached."
	L.towers_icon = "achievement_bg_winsoa"
	L.south_tower_trigger = "The door barring the South Tower has been breached!"
	L.south_tower = "South Tower"
	L.north_tower_trigger = "The door barring the North Tower has been breached!"
	L.north_tower = "North Tower"
	L.tower_defender = "Tower defender"

	L.adds = CL.adds
	L.adds_desc = "Timers for when a new set of adds enter the fight."
	L.adds_icon = "achievement_character_orc_female" -- female since Zaela is calling them (and to be not the same as tower add icon)
	L.warlord_zaela = "Warlord Zaela"

	L.drakes = "Proto-Drakes"
	L.drakes_desc = -8586
	L.drakes_icon = "ability_mount_drake_proto"

	L.custom_off_shaman_marker = "Shaman marker"
	L.custom_off_shaman_marker_desc = "To help interrupt assignments, mark the Dragonmaw Tidal Shamans with {rt8}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over the shamans is the fastest way to mark them.|r"
	L.custom_off_shaman_marker_icon = 8
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"towers", 146769, 146849, 147705, -8443, -- Ranking Officials
		"adds", "drakes", "demolisher", 147328, 146765, 146757, -8489, 146899, -- Foot Soldiers
		"custom_off_shaman_marker",
		{147068, "ICON", "FLASH", "PROXIMITY"},-- Galakras
		"stages", {"warmup", "COUNTDOWN"},
	}, {
		["towers"] = -8421, -- Ranking Officials
		["adds"] = -8427, -- Foot Soldiers
		["custom_off_shaman_marker"] = L.custom_off_shaman_marker,
		[147068] = -8418, -- Galakras
		["stages"] = "general",
	}
end

function mod:VerifyEnable()
	return (GetTime() - prevWin) > 180
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY", "Warmup")
	self:RegisterEvent("RAID_BOSS_WHISPER")

	-- Foot Soldiers
	self:Log("SPELL_CAST_START", "ChainHeal", 146757, 146728)
	self:Log("SPELL_CAST_SUCCESS", "HealingTotem", 146753, 146722)
	self:Log("SPELL_PERIODIC_DAMAGE", "FlameArrows", 146765)
	self:Log("SPELL_PERIODIC_MISSED", "FlameArrows", 146765)
	self:Log("SPELL_AURA_APPLIED", "FlameArrows", 146765)
	self:Log("SPELL_AURA_APPLIED", "Warbanner", 147328)
	self:Log("SPELL_AURA_APPLIED", "Fracture", 146899, 147200)
	self:Emote("Demolisher", "116040")
	-- Ranking Officials
	self:Log("SPELL_CAST_SUCCESS", "CurseOfVenom", 147711)
	self:Log("SPELL_PERIODIC_DAMAGE", "PoisonCloud", 147705)
	self:Log("SPELL_PERIODIC_MISSED", "PoisonCloud", 147705)
	self:Log("SPELL_AURA_APPLIED", "PoisonCloud", 147705)
	self:Log("SPELL_CAST_START", "CrushersCall", 146769)
	self:Log("SPELL_CAST_SUCCESS", "ShatteringCleave", 146849)
	self:Emote("SouthTower", L.south_tower_trigger)
	self:Emote("NorthTower", L.north_tower_trigger)
	-- Galakras
	self:Log("SPELL_AURA_APPLIED_DOSE", "FlamesOfGalakrondStacking", 147029)
	self:Log("SPELL_AURA_APPLIED", "FlamesOfGalakrondApplied", 147068)
	self:Log("SPELL_AURA_REMOVED", "FlamesOfGalakrondRemoved", 147068)
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "LastPhase", "boss1", "boss2", "boss3", "boss4")
end

local function warnTowerAdds()
	mod:MessageOld("towers", "yellow", nil, L.tower_defender, 85214)
	mod:Bar("towers", 60, L.tower_defender, 85214) -- random orc icon
end

local function firstTowerAdd()
	warnTowerAdds()
	if not towerAddTimer then
		towerAddTimer = mod:ScheduleRepeatingTimer(warnTowerAdds, 60)
	end
end

function mod:Warmup(_, msg)
	if msg == L.start_trigger_alliance then -- 34.5
		self:Bar("warmup", 34.5, COMBAT, "achievement_boss_galakras")
	elseif msg == L.start_trigger_horde then -- 30.5
		self:Bar("warmup", 30.5, COMBAT, "achievement_boss_galakras")
	end
end

function mod:OnEngage()
	if self:Mythic() then
		self:Bar("towers", 6, L.tower_defender, 85214) -- random orc icon
		self:ScheduleTimer(firstTowerAdd, 6)
	else
		self:Bar("towers", 116, L.south_tower, L.towers_icon)
	end

	addsCounter = 0
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Adds")

	if self.db.profile.custom_off_shaman_marker then
		prevMarkedMob = nil
		self:RegisterTargetEvents("ShamanMarker")
	end
end

function mod:OnWin()
	prevWin = GetTime()
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:RAID_BOSS_WHISPER(_, msg)
	-- RAID_BOSS_WHISPER#Galakras is hit! Nice shot!#Anti-Air Turret#0#true
	self:MessageOld("stages", "blue", nil, msg, "achievement_boss_galakras")
end

--Galakras
function mod:FlamesOfGalakrondStacking(args)
	if args.amount > 2 then
		if self:Me(args.destGUID) or (self:Tank() and self:Tank(args.destName)) then
			self:StackMessageOld(147068, args.destName, args.amount, "yellow", nil, 71393, args.spellId) -- 71393 = "Flames"
		end
	end
end

function mod:FlamesOfGalakrondRemoved(args)
	self:PrimaryIcon(args.spellId)
	if self:Me(args.destGUID) then
		self:CloseProximity(args.spellId)
	end
end

function mod:FlamesOfGalakrondApplied(args)
	self:PrimaryIcon(args.spellId, args.destName)
	self:TargetMessageOld(args.spellId, args.destName, "red", "warning", 88986, args.spellId) -- 88986 = "Fireball"
	if self:Me(args.destGUID) then
		self:OpenProximity(args.spellId, 8)
		self:Flash(args.spellId)
	end
end

function mod:LastPhase(_, unitId, _, spellId)
	if spellId == 50630 then -- Eject All Passengers
		self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
		self:MessageOld("stages", "cyan", "warning", CL.incoming:format(self:UnitName(unitId)), "ability_mount_drake_proto")
		self:StopBar(L.adds)
		self:StopBar(L.drakes)
		self:CancelDelayedMessage(CL.incoming:format(L.drakes))
	end
end

-- Ranking Officials
do
	local prev = 0
	function mod:PoisonCloud(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL.underyou:format(args.spellName))
		end
	end
end

function mod:CurseOfVenom(args)
	self:MessageOld(-8443, "orange", "alert")
end

function mod:CrushersCall(args)
	self:Bar(args.spellId, 48)
	self:MessageOld(args.spellId, "orange", "alert")
end

function mod:ShatteringCleave(args)
	self:Bar(args.spellId, 7)
end

function mod:Demolisher()
	self:MessageOld("demolisher", "yellow", nil, L.demolisher_message, L.demolisher_icon)
end

function mod:SouthTower()
	self:StopBar(L.south_tower)
	self:MessageOld("towers", "cyan", "long", L.south_tower, L.towers_icon)
	self:Bar("demolisher", 20, L.demolisher_message, L.demolisher_icon)

	if self:Mythic() then
		self:CancelTimer(towerAddTimer)
		towerAddTimer = nil
		self:Bar("towers", 35, L.tower_defender, 85214) -- random orc icon
		self:ScheduleTimer(firstTowerAdd, 35)
	else
		self:Bar("towers", 150, L.north_tower, L.towers_icon) -- Mythic one seems random
	end
end

function mod:NorthTower()
	self:StopBar(L.north_tower)
	self:MessageOld("towers", "cyan", "long", L.north_tower, L.towers_icon)
	self:Bar("demolisher", 20, L.demolisher_message, L.demolisher_icon)

	if self:Mythic() then
		self:CancelTimer(towerAddTimer)
		towerAddTimer = nil
		self:StopBar(L.tower_defender)
	end
end

-- Foot Soldiers
function mod:ChainHeal(args)
	self:MessageOld(146757, "red", "warning")
end

function mod:HealingTotem(args)
	self:MessageOld(-8489, "orange", "warning")
end

do
	local prev = 0
	function mod:FlameArrows(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", nil, CL.underyou:format(args.spellName))
		end
	end
end

function mod:Warbanner(args)
	self:MessageOld(args.spellId, "orange")
end

function mod:Fracture(args)
	self:TargetMessageOld(146899, args.destName, "orange", "alarm", nil, nil, true)
end

function mod:Adds(_, _, unit, _, _, target)
	if unit == L.warlord_zaela then
		if addsCounter == 0 then
			self:Bar("adds", 59, L.adds, L.adds_icon)
			self:Bar("drakes", 168, L.drakes, L.drakes_icon)
			addsCounter = 1
		elseif UnitIsPlayer(target) then
			self:MessageOld("adds", "yellow", "info", CL.incoming:format(L.adds), L.adds_icon)
			addsCounter = addsCounter + 1
			if (addsCounter + 1) % 4 == 0 then
				self:DelayedMessage("drakes", 55, "yellow", CL.incoming:format(L.drakes), L.drakes_icon, "info")
				self:Bar("adds", 110, L.adds, L.adds_icon)
			else
				if addsCounter % 4 == 0 then -- start the drakes timer on the wave after drakes
					self:Bar("drakes", 220, L.drakes, L.drakes_icon)
				end
				self:Bar("adds", 55, L.adds, L.adds_icon)
			end
		end
	end
end

function mod:ShamanMarker(_, unit)
	local guid = self:UnitGUID(unit)
	if guid and guid ~= prevMarkedMob and self:MobId(guid) == 72958 then
		prevMarkedMob = guid
		self:CustomIcon(false, unit, 8)
	end
end

