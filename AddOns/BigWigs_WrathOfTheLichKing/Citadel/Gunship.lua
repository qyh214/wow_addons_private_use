--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Icecrown Gunship Battle", 631, 1626)
if not mod then return end
mod:RegisterEnableMob(37184, 37540, 37215) -- Zafod Boombox, The Skybreaker, Orgrim's Hammer
mod:SetEncounterID(BigWigsLoader.isWrath and 847 or 1099)
-- mod:SetRespawnTime(30) -- Timer varies too much

--------------------------------------------------------------------------------
-- Locals
--

local killed = false
local addsTimer = nil
local firstMage = true
local allowMageDeath = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.warmup_icon = "achievement_dungeon_hordeairship"
	L.adds_icon = "spell_arcane_portaldalaran"
	L.adds_trigger_alliance = "Reavers, Sergeants, attack!"
	L.adds_trigger_horde = "Marines, Sergeants, attack!"

	L.mage = "Mage"
	L.mage_desc = "Warn when a mage spawns to freeze the gunship cannons."
	L.mage_icon = "spell_frost_frost"
	-- Alliance: We're taking hull damage, get a battle-mage out here to shut down those cannons!
	-- Horde: We're taking hull damage, get a sorcerer out here to shut down those cannons!
	L.mage_yell_trigger = "taking hull damage"

	L.warmup_trigger_alliance = "Fire up the engines"
	L.warmup_trigger_horde = "Rise up, sons and daughters"

	-- Keeping this around for now as retail ENCOUNTER events are iffy
	L.disable_trigger_alliance = "Onward, brothers and sisters"
	L.disable_trigger_horde = "Onward to the Lich King"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"warmup",
		"adds",
		"mage",
		69651, -- Wounding Strike
		69638, -- Battle Fury
	}
end

function mod:VerifyEnable()
	if not killed then return true end
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:Death("MageKilled", 37116, 37117) -- Skybreaker Sorcerer, Kor'kron Battle-Mage
	self:Log("SPELL_AURA_REMOVED", "BelowZeroRemoved", 69705)
	self:Log("SPELL_AURA_APPLIED", "WoundingStrikeApplied", 69651)
	self:Log("SPELL_AURA_APPLIED_DOSE", "BattleFuryApplied", 69638)
end

function mod:OnEngage()
	addsTimer = nil
	firstMage = true
	allowMageDeath = false
end

function mod:OnWin()
	addsTimer = nil
	killed = true
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.warmup_trigger_alliance, nil, true) or msg:find(L.warmup_trigger_horde, nil, true) then
		self:Bar("warmup", 45, CL.active, L.warmup_icon)
	elseif msg:find(L.disable_trigger_alliance, nil, true) or msg:find(L.disable_trigger_horde, nil, true) then
		self:Win()
	elseif msg:find(L.adds_trigger_alliance, nil, true) or msg:find(L.adds_trigger_horde, nil, true) then
		self:Bar("adds", 60, CL.adds, L.adds_icon)
		if addsTimer then
			self:CancelTimer(addsTimer)
			self:Message("adds", "cyan", CL.adds, L.adds_icon)
		else
			self:Message("adds", "cyan", CL.percent:format(90, CL.adds), L.adds_icon) -- First adds
		end
		addsTimer = self:ScheduleTimer("Bar", 65, "adds", 55, CL.adds, L.adds_icon) -- Fallback for unreliable yells
		self:PlaySound("adds", "info")
	elseif msg:find(L.mage_yell_trigger, nil, true) then
		if firstMage then
			firstMage = false
			self:Message("mage", "yellow", CL.percent:format(80, L.mage), L.mage_icon) -- First mage
		else
			self:Message("mage", "yellow", L.mage, L.mage_icon)
		end
		self:SimpleTimer(function() allowMageDeath = true end, 4) -- Attempt to filter other mage deaths
		self:PlaySound("mage", "alarm")
	end
end

function mod:MageKilled()
	if allowMageDeath then
		allowMageDeath = false
		self:Bar("mage", 30, L.mage, L.mage_icon) -- Might be the wrong mage death
	end
end

function mod:BelowZeroRemoved()
	allowMageDeath = false
	self:Bar("mage", 30, L.mage, L.mage_icon) -- Definitely the right mage death
end

function mod:WoundingStrikeApplied(args)
	self:TargetMessage(args.spellId, "red", args.destName)
end

function mod:BattleFuryApplied(args)
	if args.amount % 5 == 0 then
		self:StackMessage(args.spellId, "orange", args.destName, args.amount, 20)
	end
end
