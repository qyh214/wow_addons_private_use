
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Wind Lord Mel'jarak", 1009, 741)
if not mod then return end
mod:RegisterEnableMob(
	62397, 62408, 62402, 62405, -- Mel'jarak, Zar'thik Battle-Mender, Kor'thik Elite Blademaster, Sra'thik Amber-Trapper
	62452, 62447, 62451 -- The Zar'thik, The Kor'thik, The Sra'thik
)
--------------------------------------------------------------------------------
-- Locales
--

local korthikStrikeWarned = {}
local primaryAmberIcon, secondaryAmberIcon, phase = nil, nil, 0
local firstKorthikStrikeDone = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.recklessness = -6331
	L.recklessness_desc = ("%s\n{-6331}\n\n%s\n{-6555}"):format(CL.normal, CL.heroic) -- Same spell name with different EJ entries for normal/heroic
	L.recklessness_icon = 125873

	L.spear_removed = "Your Impaling Spear was removed!"

	L.mending = -6306
	L.mending_desc = "|cFFFF0000WARNING: Only the timer for your 'focus' target will show because all Zar'thik Battle-Menders have separate heal cooldowns.|r {-6306}"
	L.mending_warning = "Your focus is casting Mending!"
	L.mending_bar = "Focus: Mending"
	L.mending_icon = 122193
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-6554, {122064, "FLASH", "SAY"}, {122125, "FLASH"}, {121881, "SAY", "PROXIMITY", "ICON"}, 122055,
		122409,
		{122149, "DISPEL"}, "mending",
		122406, {122224, "FLASH"}, {121896, "FLASH"}, {131830, "SAY", "FLASH", "PROXIMITY"}, "recklessness",
		"stages", "berserk",
	}, {
		[-6554] = "heroic",
		[122064] = -6300,
		[122409] = -6334,
		[122149] = -6305,
		[122406] = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "AmberPrison", 121881) -- initial cast only
	self:Log("SPELL_AURA_REMOVED", "AmberPrisonRemoved", 121881) -- initial cast only
	self:Log("SPELL_AURA_REMOVED", "ResidueRemoved", 122055)
	self:Log("SPELL_AURA_APPLIED", "Resin", 122064)
	self:Log("SPELL_PERIODIC_DAMAGE", "ResinPoolDamage", 122125)
	self:Log("SPELL_PERIODIC_MISSED", "ResinPoolDamage", 122125)
	self:Log("SPELL_AURA_APPLIED", "Recklessness", 122354)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Recklessness", 122354)
	self:Log("SPELL_AURA_APPLIED", "RecklessnessHeroic", 125873)
	self:Log("SPELL_AURA_REMOVED", "RecklessnessHeroicRemoved", 125873)
	self:Log("SPELL_SUMMON", "WindBomb", 131814)
	self:Log("SPELL_CAST_START", "WhirlingBlade", 121896)
	self:Log("SPELL_AURA_APPLIED", "Quickening", 122149)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Quickening", 122149)
	self:Log("SPELL_CAST_START", "Mending", 122193)
	self:Log("SPELL_CAST_START", "RainOfBlades", 122406)
	self:Log("SPELL_AURA_APPLIED", "ImpalingSpear", 122224)
	self:Log("SPELL_AURA_REFRESH", "ImpalingSpear", 122224)
	self:Log("SPELL_AURA_REMOVED", "ImpalingSpearRemoved", 122224)

	self:Log("SPELL_DAMAGE", "WhirlingBladeDamage", 121898)
	self:Log("SPELL_MISSED", "WhirlingBladeDamage", 121898)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")

	self:Death("Win", 62397)
	self:Death("AddDeaths", 62452, 62447, 62451) -- The Zar'thik, The Kor'thik, The Sra'thik
end

function mod:OnEngage(diff)
	self:Bar(121896, 36) -- Whirling Blade
	self:Bar(122406, 60) -- Rain of Blades
	self:Bar(122409, 19) -- Korthik Strike
	self:Berserk(self:LFR() and 600 or 480)
	korthikStrikeWarned = {}
	primaryAmberIcon, secondaryAmberIcon, phase = nil, nil, 0
	firstKorthikStrikeDone = nil

	self:RegisterEvent("UNIT_AURA")
	self:RegisterUnitEvent("UNIT_HEALTH", "PhaseChange", "boss1", "boss2", "boss3", "boss4")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	self:CheckBossStatus()
	for i = 1, 5 do
		-- Random spawn, check for unit
		local guid = self:UnitGUID(("boss%d"):format(i))
		if guid and self:MobId(guid) == 62451 then -- The Sra'thik
			if phase == 2 then
				self:CloseProximity(131830)
			end
			self:OpenProximity(121881, 2)
			break
		end
	end
end

function mod:WhirlingBladeDamage(args)
	if not self:LFR() and self:Me(args.destGUID) then
		self:MessageOld(121896, "blue", "info", CL["you"]:format(args.spellName))
		self:Flash(121896) -- we flash on cast too, but some more can't hurt
	end
end

do
	local korthikStrike = mod:SpellName(122409)
	local function allowKorthikStrike(player)
		korthikStrikeWarned[player] = nil
	end
	function mod:UNIT_AURA(_, unitId)
		if self:UnitDebuff(unitId, korthikStrike, 123963) then -- difficulty 3
			local player = self:UnitName(unitId)
			if not korthikStrikeWarned[player] then
				korthikStrikeWarned[player] = true
				self:ScheduleTimer(allowKorthikStrike, 10, player)
				self:TargetMessageOld(122409, player, "orange", "alarm")
				self:Bar(122409, firstKorthikStrikeDone and 50 or 30) -- 2nd one ~30, then cooldown 50 sec
				firstKorthikStrikeDone = true
			end
		end
	end
end

function mod:ResidueRemoved(args)
	if self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "green", nil, CL["over"]:format(args.spellName))
	end
end

do
	local prisonList, scheduled = mod:NewTargetList(), nil
	local function warnPrison(spellId)
		mod:TargetMessageOld(spellId, prisonList, "red", "info")
		scheduled = nil
	end
	function mod:AmberPrison(args)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, nil, nil, "Amber Prison")
		end
		prisonList[#prisonList + 1] = args.destName
		if not scheduled then
			scheduled = self:ScheduleTimer(warnPrison, 0.1, args.spellId)
		end
		if self:LFR() then return end
		if not primaryAmberIcon then
			primaryAmberIcon = args.destName
			self:PrimaryIcon(args.spellId, primaryAmberIcon)
		elseif not secondaryAmberIcon then -- leave the icon on the second person hit
			secondaryAmberIcon = args.destName
			self:SecondaryIcon(args.spellId, secondaryAmberIcon)
		end
	end
end

function mod:AmberPrisonRemoved(args)
	if self:LFR() then return end
	if args.destName == primaryAmberIcon then
		self:PrimaryIcon(args.spellId)
		primaryAmberIcon = nil
	elseif args.destName == secondaryAmberIcon then
		self:SecondaryIcon(args.spellId)
		secondaryAmberIcon = nil
	end
end

function mod:RainOfBlades(args)
	self:MessageOld(args.spellId, "red", "alert")
	self:Bar(args.spellId, phase == 2 and 48 or 60)
end

do
	local prev = 0
	function mod:Quickening(args)
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			if self:Dispeller("magic", true, args.spellId) then
				self:MessageOld(args.spellId, "yellow", "alert")
			end
		end
	end
end

function mod:Mending(args)
	if self:UnitGUID("focus") == args.sourceGUID then
		self:MessageOld("mending", "blue", "alert", L["mending_warning"], args.spellId)
		self:Bar("mending", 37, L["mending_bar"], args.spellId)
	end
end

function mod:WhirlingBlade(args)
	self:MessageOld(args.spellId, "orange", "alarm")
	self:Bar(args.spellId, phase == 2 and 30 or 45)
	if not self:LFR() then
		self:Flash(args.spellId)
	end
end

function mod:WindBomb(args)
	if self:Me(args.sourceGUID) then
		self:Flash(131830)
		self:Say(131830, nil, nil, "Wind Bomb")
	end
	self:TargetMessageOld(131830, args.sourceName, "orange", "alarm")
end

function mod:Recklessness(args)
	self:MessageOld("recklessness", "yellow", nil, CL["count"]:format(args.spellName, args.amount or 1), args.spellId)
end

function mod:RecklessnessHeroic(args)
	self:MessageOld("recklessness", "yellow", nil, args.spellName, args.spellId)
	self:Bar("recklessness", 30, args.spellName, args.spellId)
end

function mod:RecklessnessHeroicRemoved(args)
	self:MessageOld("recklessness", "yellow", "info", CL["over"]:format(args.spellName), args.spellId)
end

do
	local prev = 0
	function mod:ResinPoolDamage(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

function mod:Resin(args)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Corrosive Resin")
		self:Flash(args.spellId)
		self:MessageOld(args.spellId, "blue", "info", CL["you"]:format(args.spellName))
	end
end

function mod:ImpalingSpear(args)
	if self:Me(args.sourceGUID) then
		self:Bar(args.spellId, 50)
	end
end

function mod:ImpalingSpearRemoved(args)
	if self:Me(args.sourceGUID) then
		self:StopBar(args.spellName)
		self:MessageOld(args.spellId, "blue", "info", L["spear_removed"])
		self:Flash(args.spellId)
	end
end

function mod:PhaseChange(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 62397 then
		local hp = self:GetHealth(unit)
		if hp < 79 and phase == 0 then -- phase starts at 75
			self:MessageOld("stages", "green", nil, CL["soon"]:format(CL["phase"]:format(2)), 131830)
			phase = 1
		elseif hp < 75.1 and phase ~= 2 then
			phase = 2
			self:MessageOld("stages", "green", "info", "75% - "..CL["phase"]:format(2), 131830)
			self:Bar(121896, 30) -- Whirling Blade (reset cd)
			self:StopBar(122406) -- Rain of Blades, first after p2 seems random
			self:UnregisterUnitEvent(event, "boss1", "boss2", "boss3", "boss4")
			for i = 1, 5 do
				local guid = self:UnitGUID(("boss%d"):format(i))
				if guid and self:MobId(guid) == 62451 then -- The Sra'thik
					return
				end
			end
			self:OpenProximity(131830, 5) -- Wind Bomb
		end
	end
end

function mod:AddDeaths(args)
	if args.mobId == 62451 then -- The Sra'thik
		self:CloseProximity(121881)
		if phase == 2 then
			self:OpenProximity(131830, 5) -- if in phase 2 open the wind bomb proximity meter back up
		end
	elseif args.mobId == 62452 then -- The Zar'thik
		self:StopBar(L["mending_bar"])
	elseif args.mobId == 62447 then -- The Kor'thik
		self:StopBar(122409) -- Kor'thik Strike
	end
	if self:Heroic() then
		self:Bar(-6554, 50, CL["other"]:format(self:SpellName(-6554), args.destName))
		self:DelayedMessage(-6554, 50, "yellow", CL["other"]:format(self:SpellName(-6554), args.destName), -6554)
	end
end

