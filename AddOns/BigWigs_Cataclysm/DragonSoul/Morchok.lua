--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Morchok", 967, 311)
if not mod then return end
mod:RegisterEnableMob(55265)
mod:SetEncounterID(1292)
mod:SetRespawnTime(30)

local stompCount = 1
local stompSkip = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "You seek to halt an avalanche. I will bury you."

	L.stomp_boss = -3879 -- Stomp
	L.stomp_boss_icon = "INV_Misc_Apexis_Crystal"
	L.crystal_boss = -3876 -- Resonating Crystal
	L.crystal_boss_icon = "inv_chaos_orb"

	L.stomp_add = -3879 -- Stomp
	L.stomp_add_icon = "INV_Misc_Apexis_Crystal"
	L.crystal_add = -3876 -- Resonating Crystal
	L.crystal_add_icon = "inv_chaos_orb"

	L.crush = 103687 -- Crush Armor
	L.crush_desc = "Count the stacks of crush armor and show a duration bar."
	L.crush_icon = "Ability_Warrior_Sunder"

	L.blood = "Black Blood"

	L.explosion = "Explosion"
	L.crystal = "Crystal"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stomp_boss", "crystal_boss",
		"stomp_add", "crystal_add",
		109017, {103851, "FLASH"}, {"crush", "TANK"}, 103846, "berserk"
	}, {
		stomp_boss = self.displayName,
		stomp_add = -4262, -- Kohcrom
		[109017] = "general",
	}
end

function mod:OnBossEnable()
	--Heroic
	self:Log("SPELL_CAST_SUCCESS", "SummonKohcrom", 109017)

	--Normal
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "BloodOver", "boss1")
	self:Log("SPELL_CAST_START", "Stomp", 103414)
	self:Log("SPELL_CAST_START", "BlackBlood", 103851)
	self:Log("SPELL_CAST_SUCCESS", "EarthenVortex", 103821)
	self:Log("SPELL_AURA_APPLIED", "Furious", 103846)
	self:Log("SPELL_AURA_APPLIED", "Crush", 103687)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Crush", 103687)
	self:Log("SPELL_AURA_APPLIED", "BlackBloodStacks", 103785)
	self:Log("SPELL_AURA_APPLIED_DOSE", "BlackBloodStacks", 103785)
	self:Log("SPELL_SUMMON", "ResonatingCrystal", 103639)
end

function mod:OnEngage()
	self:Berserk(420) -- confirmed
	self:CDBar("stomp_boss", 12.5, L["stomp_boss"], L["stomp_boss_icon"])
	self:CDBar(103851, 57, L["blood"]) -- Black Blood, 57-64s
	stompCount = 1
	stompSkip = false
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:SummonKohcrom(args)
	local stompCooldown = self:BarTimeLeft(L["stomp_boss"]) < 6 and 6 or 12
	stompSkip = (stompCooldown == 6)
	self:CDBar("stomp_boss", stompCooldown, CL.other:format(self:SpellName(103414), self.displayName), L["stomp_boss_icon"]) -- Stomp, 6-12s
	self:MessageOld(args.spellId, "green")
	self:StopBar(L["stomp_boss"])
end

-- If we were to start bars at :BlackBlood then we are subject to BlackBlood duration changes
function mod:BloodOver(_, _, _, spellId)
	if spellId == 103851 then
		self:CDBar(spellId, 74, L["blood"])
		stompCount = 0
		if self:Heroic() then
			self:CDBar("stomp_boss", 18, CL.other:format(self:SpellName(103414), self.displayName), L["stomp_boss_icon"]) -- Stomp
		else
			self:CDBar("stomp_boss", 18, L["stomp_boss"], L["stomp_boss_icon"])
		end
	end
end

function mod:Stomp(args)
	if self:Heroic() and UnitExists("boss2") then -- Check if heroic and if kohcrom has spawned yet.
		if args.sourceName == self:SpellName(-4262) then -- Kohcrom
			self:MessageOld("stomp_add", "red", nil, CL.other:format(args.spellName, self:SpellName(-4262)), args.spellId) -- "Stomp: Kohcrom"
			self:StopBar(CL.other:format(args.spellName, self:SpellName(-4262))) -- "Stomp: Kohcrom"
		else -- Since we trigger bars off morchok casts, we gotta make sure kohcrom isn't caster to avoid bad timers.
			if not stompSkip then
				self:CDBar("stomp_add", 5, CL.other:format(args.spellName, self:SpellName(-4262)), args.spellId) -- "Stomp: Kohcrom"
			end
			stompSkip = false
			self:MessageOld("stomp_boss", "red", nil, CL.other:format(args.spellName, self.displayName), args.spellId) -- "Stomp: Morchok"
			stompCount = stompCount + 1
			if stompCount < 4 then
				self:CDBar("stomp_boss", 12, CL.other:format(args.spellName, self.displayName), args.spellId) -- "Stomp: Morchok"
			else
				self:StopBar(CL.other:format(args.spellName, self.displayName)) -- "Stomp: Morchok"
			end
		end
	else -- Not heroic, or Kohcrom isn't out yet, just do normal bar.
		self:MessageOld("stomp_boss", "red", nil, args.spellId)
		stompCount = stompCount + 1
		if stompCount < 4 then
			self:CDBar("stomp_boss", 12, args.spellId)
		else
			self:StopBar(args.spellId)
		end
	end
end

function mod:Furious(args)
	self:MessageOld(args.spellId, "green")
end

do
	local prev = 0
	function mod:BlackBlood(args)
		local t = GetTime()
		if t-prev > 5 then
			prev = t
			self:MessageOld(args.spellId, "blue", "long") -- not really personal, but we tend to associate personal with fns
			self:Bar(args.spellId, 17, CL["cast"]:format(L["blood"]))
		end
	end
end

do
	local prev = 0
	function mod:BlackBloodStacks(args)
		local t = GetTime()
		if t-prev > 2 and self:Me(args.destGUID) then
			prev = t
			self:Flash(103851)
			self:MessageOld(103851, "blue", "long", CL["underyou"]:format(L["blood"]), args.spellId)
		end
	end
end

function mod:EarthenVortex(args)
	self:StopBar(L["blood"]) -- Black Blood
end

function mod:ResonatingCrystal(args)
	if self:Heroic() then
		if args.sourceName == self:SpellName(-4262) then -- -4262 == Kohcrom
			self:MessageOld("crystal_add" , "orange", "alarm", CL.other:format(L["crystal"], self:SpellName(-4262)), args.spellId) -- "Crystal: Kohcrom"
			self:Bar("crystal_add", 12, CL.other:format(CL.explosion, self:SpellName(-4262)), args.spellId) -- "Explosion: Kohcrom"
		else -- if args.sourceName == self.displayName then
			self:MessageOld("crystal_boss", "orange", "alarm", CL.other:format(L["crystal"], self.displayName), args.spellId) -- "Crystal: Morchok"
			self:Bar("crystal_boss", 12, CL.other:format(CL.explosion, self.displayName), args.spellId) -- "Explosion: Morchok"
		end
	else
		self:MessageOld("crystal_boss", "orange", "alarm", args.spellId)
		self:Bar("crystal_boss", 12, L["explosion"], args.spellId)
	end
end

function mod:Crush(args)
	local buffStack = args.amount or 1
	self:TargetBar("crush", 20, args.destName, 50234, args.spellId) -- 50234 == Crush
	self:StackMessageOld("crush", args.destName, buffStack, "orange", buffStack > 2 and "info", 50234, args.spellId) -- 50234 == Crush
end

