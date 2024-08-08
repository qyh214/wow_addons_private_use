--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Madness of Deathwing", 967, 333)
if not mod then return end
-- Thrall, Deathwing, Arm Tentacle, Arm Tentacle, Wing Tentacle, Mutated Corruption
mod:RegisterEnableMob(56103, 56173, 56167, 56846, 56168, 56471)

local canEnable = true
local curPercent = 100
local paraCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "You have done NOTHING. I will tear your world APART."

	L.impale = -4114 -- Impale
	L.impale_icon = "Ability_SearingArrow"

	L.last_phase = 106708 -- Slump
	L.last_phase_desc = -4046
	L.last_phase_icon = "Spell_DeathKnight_BloodBoil"

	L.bigtentacle = -4112 -- Mutated Corruption
	L.bigtentacle_icon = "ability_deathwing_grasping_tendrils"

	L.smalltentacles = -4103 -- Blistering Tentacle
	-- Copy & Paste from Encounter Journal with correct health percentages (type '/dump (C_EncounterJournal.GetSectionInfo(4103)).title' in the game)
	L.smalltentacles_desc = "At 70% and 40% remaining health the Limb Tentacle sprouts several Blistering Tentacles that are immune to Area of Effect abilities."
	L.smalltentacles_icon = "Ability_Warrior_BloodNova"

	L.hemorrhage = -4108 -- Hemorrhage
	L.hemorrhage_icon = "spell_fire_moltenblood"

	L.fragment = -4115 -- Elementium Fragment
	L.fragment_icon = "ability_deathwing_grasping_tendrils"

	L.terror = -4117 -- Elementium Terror
	L.terror_icon = "ability_tetanus"

	L.bolt_explode = "<Bolt Explodes>"
	L.parasite = "Parasite"
	L.blobs_soon = "%d%% - Congealing Blood soon!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"bigtentacle", "impale", "smalltentacles", {105651, "FLASH"}, "hemorrhage", 106523,
		"last_phase", "fragment", {106794, "FLASH"}, "terror",
		{-4347, "FLASH", "ICON", "PROXIMITY", "SAY"}, -4351,
		"berserk"
	}, {
		bigtentacle = -4040, -- Stage One: The Final Assault
		last_phase = -4046, -- Stage Two: The Last Stand
		[-4347] = "heroic",
		berserk = "general",
	}
end

function mod:VerifyEnable()
	return canEnable
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1", "boss2", "boss3", "boss4")
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Log("SPELL_CAST_SUCCESS", "ElementiumBolt", 105651)
	self:Log("SPELL_CAST_SUCCESS", "Impale", 106400)
	self:Log("SPELL_CAST_SUCCESS", "AgonizingPain", 106548)
	self:Log("SPELL_CAST_START", "AssaultAspects", 107018)
	self:Log("SPELL_CAST_START", "Cataclysm", 106523)
	self:Log("SPELL_AURA_APPLIED", "LastPhase", 106834) -- Phase 2: Corrupted Blood
	self:Log("SPELL_AURA_APPLIED", "Shrapnel", 106794)
	self:Log("SPELL_AURA_APPLIED", "Parasite", 108649)
	self:Log("SPELL_AURA_REMOVED", "ParasiteRemoved", 108649)

	self:BossYell("Engage", L["engage_trigger"])
	self:Log("SPELL_CAST_SUCCESS", "Win", 110063) -- Astral Recall
	self:Death("TentacleKilled", 56471)
end

function mod:OnEngage()
	curPercent = 100
	self:Berserk(900)
end

function mod:OnWin()
	canEnable = false
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Impale(args)
	self:MessageOld("impale", "orange", "alarm", args.spellId)
	self:Bar("impale", 35, args.spellId)
end

function mod:TentacleKilled()
	self:StopBar(106400) -- Impale
	self:StopBar(L["parasite"])
end

-- XXX BROKEN CHECKS FIXME
function mod:UNIT_SPELLCAST_SUCCEEDED(_, unit, _, spellId)
	if spellId == self:SpellName(105863) then -- hemorrhage
		self:MessageOld("hemorrhage", "orange", "alarm", spellId, L["hemorrhage_icon"])
	elseif spellId == self:SpellName(106775) then -- fragment
		self:MessageOld("fragment", "orange", "alarm", L["fragment"], L["fragment_icon"])
		self:Bar("fragment", 90, L["fragment"], L["fragment_icon"])
	elseif spellId == 105551 then
		local hp = self:GetHealth(unit)
		self:MessageOld("smalltentacles", "orange", "alarm", ("%d%% - %s"):format(hp > 50 and 70 or 40, self:SpellName(L.smalltentacles)), L.smalltentacles_icon)
	elseif spellId == 106765 then
		self:MessageOld("terror", "red", nil, L["terror"], L["terror_icon"])
		self:Bar("terror", 90, L["terror"], L["terror_icon"])
	end
end

function mod:LastPhase(args)
	self:MessageOld("last_phase", "yellow", nil, -4046, args.spellId) -- Stage 2: The Last Stand
	self:Bar("fragment", 10.5, L["fragment"], L["fragment_icon"])
	self:Bar("terror", 35.5, L["terror"], L["terror_icon"])
	if self:Heroic() then
		self:RegisterUnitEvent("UNIT_HEALTH", "BlobsWarn", "boss1")
	end
end

function mod:AssaultAspects()
	paraCount = 0
	if curPercent == 100 then
		curPercent = 20
		self:Bar("impale", 22, 106400) -- Impale
		self:Bar(105651, 40.5) -- Elementium Bolt
		if self:Heroic() then
			self:Bar("hemorrhage", 55.5, 105863) -- Hemorrhage
			self:Bar(-4347, 11, L["parasite"], 108649)
		else
			self:Bar("hemorrhage", 85.5, 105863) -- Hemorrhage
		end
		self:Bar(106523, 175) -- Cataclysm
		self:Bar("bigtentacle", 11.2, L["bigtentacle"], L["bigtentacle_icon"])
		self:DelayedMessage("bigtentacle", 11.2, "orange", L["bigtentacle"], L["bigtentacle_icon"], "alert")
	else
		self:Bar("impale", 27.5, 106400) -- Impale
		self:Bar(105651, 55.5) -- Elementium Bolt
		if self:Heroic() then
			self:Bar("hemorrhage", 70.5, 105863) -- Hemorrhage
			self:Bar(-4347, 22.5, L["parasite"], 108649)
		else
			self:Bar("hemorrhage", 100.5, 105863) -- Hemorrhage
		end
		self:Bar(106523, 190) -- Cataclysm
		self:Bar("bigtentacle", 16.7, L["bigtentacle"], L["bigtentacle_icon"])
		self:DelayedMessage("bigtentacle", 16.7, "orange", L["bigtentacle"], L["bigtentacle_icon"], "alert")
	end
end

function mod:ElementiumBolt(args)
	self:Flash(args.spellId)
	self:MessageOld(args.spellId, "red", "long")
	self:Bar(args.spellId, self:UnitBuff("player", self:SpellName(110628)) and 18 or 8, L["bolt_explode"])
end

function mod:Cataclysm(args)
	self:MessageOld(args.spellId, "yellow")
	self:StopBar(args.spellName)
	self:Bar(args.spellId, 60, CL["cast"]:format(args.spellName))
end

function mod:AgonizingPain()
	self:StopBar(CL["cast"]:format(self:SpellName(106523)))
end

function mod:Shrapnel(args)
	if self:Me(args.destGUID) then
		local you = CL["you"]:format(args.spellName)
		self:MessageOld(args.spellId, "red", "long", you)
		self:Flash(args.spellId)
		self:Bar(args.spellId, 7, you)
	end
end

function mod:Parasite(args)
	paraCount = paraCount + 1
	self:TargetMessageOld(-4347, args.destName, "orange", nil, L["parasite"], args.spellId)
	self:TargetBar(-4347, 10, args.destName, L["parasite"], args.spellId)
	self:PrimaryIcon(-4347, args.destName)
	if self:Me(args.destGUID) then
		self:Flash(-4347)
		self:OpenProximity(-4347, 10)
		self:Say(-4347, L["parasite"], nil, "Parasite")
	end
	if paraCount < 2 then
		self:Bar(-4347, 60, L["parasite"], 108649)
	end
end

function mod:ParasiteRemoved(args)
	self:PrimaryIcon(-4347)
	if self:Me(args.destGUID) then
		self:CloseProximity(-4347)
	end
end

function mod:BlobsWarn(event, unit)
	local hp = self:GetHealth(unit)
	if hp > 14.9 and hp < 16 and curPercent == 20 then
		self:MessageOld(-4351, "green", "info", L["blobs_soon"]:format(15), "ability_deathwing_bloodcorruption_earth")
		curPercent = 15
	elseif hp > 9.9 and hp < 11 and curPercent == 15 then
		self:MessageOld(-4351, "green", "info", L["blobs_soon"]:format(10), "ability_deathwing_bloodcorruption_earth")
		curPercent = 10
	elseif hp > 4.9 and hp < 6 and curPercent == 10 then
		self:MessageOld(-4351, "green", "info", L["blobs_soon"]:format(5), "ability_deathwing_bloodcorruption_earth")
		curPercent = 5
		self:UnregisterUnitEvent(event, unit)
	end
end

