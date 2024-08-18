
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("General Nazgrim", 1136, 850)
if not mod then return end
mod:RegisterEnableMob(71515, 71715, 71516, 71517, 71518, 71519) -- General Nazgrim, Orgrimmar Faithful, Kor'kron Ironblade, Kor'kron Arcweaver, Kor'kron Assassin, Kor'kron Warshaman
mod.engageId = 1603

--------------------------------------------------------------------------------
-- Locals
--

local marksUsed = {}
local addWaveCounter = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.custom_off_bonecracker_marks = "Bonecracker marker"
	L.custom_off_bonecracker_marks_desc = "To help healing assignments, mark the people who have Bonecracker on them with {rt1}{rt2}{rt3}{rt4}{rt5}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
	L.custom_off_bonecracker_marks_icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_1"

	L.stance_bar = "%s(NOW:%s)"
	-- shorten stances so they fit on the bars
	L.battle = "Battle"
	L.berserker = "Berserker"
	L.defensive = "Defensive"

	L.adds_trigger1 = "Defend the gate!"
	L.adds_trigger2 = "Rally the forces!"
	L.adds_trigger3 = "Next squad, to the front!"
	L.adds_trigger4 = "Warriors, on the double!"
	L.adds_trigger5 = "Kor'kron, at my side!"
	L.adds_trigger_extra_wave = "All Kor'kron... under my command... kill them... NOW!"
	L.adds_trigger_extra_wave_demonic = "Kar AzgAlada revos xi amanare maev raka ZAR"
	L.extra_adds = "Extra adds"
	L.final_wave = "Final Wave"
	L.add_wave = "%s (%s): %s"
	L.mage = "|cFF69CCF0"..LOCALIZED_CLASS_NAMES_MALE.MAGE.."|r"
	L.rogue = "|cFFFFF569"..LOCALIZED_CLASS_NAMES_MALE.ROGUE.."|r"
	L.shaman = "|cFF0070DE"..LOCALIZED_CLASS_NAMES_MALE.SHAMAN.."|r"
	L.warrior = "|cFFC79C6E"..LOCALIZED_CLASS_NAMES_MALE.WARRIOR.."|r"
	L.hunter = "|cFFABD473"..LOCALIZED_CLASS_NAMES_MALE.HUNTER.."|r"

	L.chain_heal = -7935 -- Empowered Chain Heal
	L.chain_heal_desc = "{focus}{-7935}"
	L.chain_heal_icon = "spell_nature_healingwavegreater"
	L.chain_heal_message = "Your focus is casting Chain Heal!"

	L.arcane_shock = -7928 -- Arcane Shock
	L.arcane_shock_desc = "{focus}{-7928}"
	L.arcane_shock_icon = "spell_arcane_invocation"
	L.arcane_shock_message = "Your focus is casting Arcane Shock!"
end
L = mod:GetLocale()

local stances = {
	[143589] = L.battle,
	[143594] = L.berserker,
	[143593] = L.defensive,
}

local addsNormal = { -- shaman 2, 4, 5, 7, 8, 9
	L.warrior.." - "..L.mage,
	L.shaman.." - "..L.rogue,
	L.rogue.." - "..L.warrior,
	L.shaman.." - "..L.mage,
	L.warrior.." - "..L.shaman,
	L.rogue.." - "..L.mage,
	L.warrior.." - "..L.rogue.." - "..L.shaman,
	L.mage.." - "..L.shaman.." - "..L.warrior,
	L.rogue.." - "..L.shaman.." - "..L.mage,
	L.mage.." - "..L.warrior.." - "..L.rogue,
}
local addsMythic = { -- shaman 2, 3, 5, 6, 8, 9
	L.mage.." - "..L.rogue.." - "..L.warrior,
	L.rogue.." - "..L.hunter.." - "..L.shaman,
	L.mage.." - "..L.shaman.." - "..L.warrior,
	L.mage.." - "..L.hunter.." - "..L.rogue,
	L.shaman.." - "..L.rogue.." - "..L.warrior,
	L.mage.." - "..L.shaman.." - "..L.hunter,
	L.warrior..", "..L.hunter.." - "..L.rogue,
	L.shaman.." - "..L.rogue.." - "..L.mage,
	L.hunter.." - "..L.warrior.." - "..L.shaman,
	L.hunter.." - "..L.mage.." - "..L.warrior,
}

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{143502, "TANK_HEALER", "FLASH"}, {-7947, "FLASH", "ICON"},
		143484, {143716, "FLASH"}, 143536, {143872, "FLASH", "SAY"}, 143503,
		"custom_off_bonecracker_marks",
		-7920, {-7933, "FLASH"}, {143475, "FLASH", "ICON"}, "chain_heal", 143474, {143431, "DISPEL"}, "arcane_shock",
		{143494, "TANK_HEALER"}, {143638, "HEALER"}, -7915, "proximity", "berserk",
	}, {
		[143502] = "mythic",
		[143484] = -7909,
		["custom_off_bonecracker_marks"] = L.custom_off_bonecracker_marks,
		[-7920] = -7920,
		[143494] = "general",
	}
end

function mod:OnBossEnable()
	-- Mythic
	self:Log("SPELL_AURA_APPLIED", "HuntersMark", 143882)
	self:Log("SPELL_CAST_START", "Execute", 143502)
	-- Adds
	self:Log("SPELL_CAST_START", "ArcaneShock", 143432)
	self:Log("SPELL_AURA_APPLIED", "Magistrike", 143431)
	self:Log("SPELL_CAST_SUCCESS", "HealingTideTotem", 143474)
	self:Log("SPELL_CAST_START", "ChainHeal", 143473)
	self:Log("SPELL_CAST_SUCCESS", "EarthShield", 143475)
	self:Log("SPELL_AURA_APPLIED", "Fixate", 143480)
	self:BossYell("Adds", L.adds_trigger1, L.adds_trigger2, L.adds_trigger3, L.adds_trigger4, L.adds_trigger5)
	self:BossYell("ExtraAdds", L.adds_trigger_extra_wave, L.adds_trigger_extra_wave_demonic)
	-- Boss
	self:Log("SPELL_CAST_START", "WarSong", 143503)
	self:Log("SPELL_CAST_SUCCESS", "Ravager", 143872) -- _START has no destName but boss has target, so that could be better, but since this can target pets, and it takes 2 sec before any damage is done after _SUCCESS I guess we can live with using _SUCCESS over _START here
	self:Log("SPELL_SUMMON", "Banner", 143501)
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "HeroicShockwave", "boss1") -- faster than _SUCCESS
	self:Log("SPELL_AURA_APPLIED", "CoolingOff", 143484)
	self:Log("SPELL_AURA_APPLIED", "Stances", 143589, 143594, 143593) -- Battle, Berserker, Defensive
	self:Log("SPELL_AURA_APPLIED", "BoneCrackerApplied", 143638)
	self:Log("SPELL_AURA_REMOVED", "BoneCrackerRemoved", 143638)
	self:Log("SPELL_CAST_START", "BoneCracker", 143638)
	self:Log("SPELL_AURA_APPLIED", "SunderingBlow", 143494)
	self:Log("SPELL_AURA_APPLIED_DOSE", "SunderingBlow", 143494)
end

function mod:OnEngage()
	self:Berserk(600)
	marksUsed = {}
	self:Bar(143494, 10) -- Sundering Blow
	self:Bar(143638, 15.5) -- Bonecracker
	addWaveCounter = 1
	self:Bar(-7920, 46, CL.count:format(CL.adds, addWaveCounter), "achievement_guildperk_everybodysfriend") -- adds
	if not self:LFR() then
		self:OpenProximity("proximity", 10) -- Heroic Shockwave , Magistrike is 8 yard
		self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Mythic
function mod:HuntersMark(args)
	self:PrimaryIcon(-7947, args.destName)
	if self:Me(args.destGUID) then
		self:Flash(-7947)
	end
	self:TargetMessageOld(-7947, args.destName, "yellow", "alarm")
end

function mod:Execute(args)
	self:MessageOld(args.spellId, "red", "warning", CL.casting:format(args.spellName))
	self:Bar(args.spellId, 18) -- varies a bit due to ability casts
	if UnitIsUnit("player", "boss1target") then -- poor mans target check
		self:Flash(args.spellId)
	end
end

-- Adds
function mod:ArcaneShock(args)
	if self:UnitGUID("focus") == args.sourceGUID then
		self:MessageOld("arcane_shock", "blue", "alert", L.arcane_shock_message, args.spellId)
	end
end

do
	local prev = 0
	function mod:Magistrike(args)
		local t = GetTime()
		if t-prev > 3 and self:Dispeller("magic", nil, args.spellId) then -- don't spam
			prev = t
			self:MessageOld(args.spellId, "red", "alarm", args.spellName, args.spellId)
		end
	end
end

function mod:HealingTideTotem(args)
	self:MessageOld(args.spellId, "yellow")
end

function mod:ChainHeal(args)
	if self:UnitGUID("focus") == args.sourceGUID then
		self:MessageOld("chain_heal", "blue", "alert", L.chain_heal_message, args.spellId)
	end
end

function mod:EarthShield(args)
	local isPlayerEvent = bit.band(args.destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
	if isPlayerEvent then return end -- spell steal
	local offensiveDispeller = self:Dispeller("magic", true)
	local target = self:GetUnitIdByGUID(args.destGUID)
	if UnitExists(target) then
		self:SecondaryIcon(args.spellId, target) -- try to mark earth shield target, not really trying too hard tho
	end
	self:TargetMessageOld(args.spellId, args.destName, "green", offensiveDispeller and "warning")
	if offensiveDispeller then
		self:Flash(args.spellId) -- for pulse (best would be pulse only no flash :S)
	end
end

function mod:Fixate(args)
	self:TargetMessageOld(-7933, args.destName, "yellow", "info")
	if self:Me(args.destGUID) then
		self:Flash(-7933)
	end
end

function mod:UNIT_HEALTH(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 17 then
		self:MessageOld(-7920, "cyan", "info", CL.soon:format(L.extra_adds), false)
		self:UnregisterUnitEvent(event, unit)
	end
end

function mod:ExtraAdds()
	self:MessageOld(-7920, "cyan", "long", "10% - ".. L.extra_adds, false)
end

function mod:Adds()
	local mobs = self:Mythic() and addsMythic[addWaveCounter] or addsNormal[addWaveCounter]
	if addWaveCounter == 10 then
		self:MessageOld(-7920, "cyan", "long", L.add_wave:format(L.final_wave, addWaveCounter, mobs), false)
	else
		self:MessageOld(-7920, "cyan", "long", L.add_wave:format(CL.adds, addWaveCounter, mobs), false)
	end

	addWaveCounter = addWaveCounter + 1
	if addWaveCounter < 11 then
		self:Bar(-7920, 46, CL.count:format(CL.adds, addWaveCounter), "achievement_guildperk_everybodysfriend")
	end
end

-- Boss

function mod:WarSong(args)
	self:Bar(args.spellId, 3, CL.cast:format(args.spellName))
	self:MessageOld(args.spellId, "red", "warning")
end

function mod:Ravager(args)
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
		self:Say(args.spellId, nil, nil, "Ravager")
	end
	self:TargetMessageOld(args.spellId, args.destName, "orange", "alarm")
end

function mod:Banner(args)
	self:MessageOld(143536, "yellow", "alert")
end

do
	local function warnShockwave(self, player, guid)
		if self:Me(guid) then
			self:Flash(143716)
		end
		self:TargetMessageOld(143716, player, "orange", "alarm")
	end
	function mod:HeroicShockwave(_, unit, _, spellId)
		if spellId == 143500 then -- Heroic Shockwave
			self:GetBossTarget(warnShockwave, 0.2, self:UnitGUID(unit))
		end
	end
end

function mod:CoolingOff(args)
	self:Bar(args.spellId, 15)
end

function mod:Stances(args)
	self:MessageOld(-7915, "green", args.spellId == 143593 and "alert", args.spellName, args.spellId) -- Play sound if he switches to defensive -- this might conflich with War Song
	local nextStance
	if args.spellId == 143589 then -- battle
		nextStance = 143594 -- berserker
	elseif args.spellId == 143594 then -- berserker
		nextStance = 143593 -- defensive
		self:DelayedMessage(-7915, 55, "green", CL.custom_sec:format(self:SpellName(nextStance), 5), nextStance, "alert")
		self:DelayedMessage(-7915, 57, "green", CL.custom_sec:format(self:SpellName(nextStance), 3), nextStance, "alert")
		self:DelayedMessage(-7915, 59, "green", CL.custom_sec:format(self:SpellName(nextStance), 1), nextStance, "alert")
	elseif args.spellId == 143593 then -- defensive
		nextStance = 143589 -- battle
	end
	self:Bar(-7915, 60, L.stance_bar:format(stances[nextStance], stances[args.spellId]), nextStance)
end

do
	function mod:BoneCrackerRemoved(args)
		if self.db.profile.custom_off_bonecracker_marks then
			for i = 1, 7 do
				if marksUsed[i] == args.destName then
					marksUsed[i] = false
					self:CustomIcon(false, args.destName, 0)
				end
			end
		end
	end

	local function markBonecrackers(destName)
		for i = 1, 7 do
			if not marksUsed[i] then
				mod:CustomIcon(false, destName, i)
				marksUsed[i] = destName
				return
			end
		end
	end
	function mod:BoneCrackerApplied(args)
		if self:Me(args.destGUID) then
			self:TargetMessageOld(args.spellId, args.destName, "blue", "info") -- so you know to be extra careful since your max hp is halved
		end
		if self.db.profile.custom_off_bonecracker_marks then
			markBonecrackers(args.destName)
		end
	end
end

function mod:BoneCracker(args)
	self:MessageOld(args.spellId, "orange")
	self:Bar(args.spellId, 32)
end

function mod:SunderingBlow(args)
	self:StackMessageOld(args.spellId, args.destName, args.amount, "yellow", "info")
	self:Bar(args.spellId, 8)
end

