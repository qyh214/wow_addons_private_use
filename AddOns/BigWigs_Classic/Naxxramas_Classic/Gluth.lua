--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Gluth", 533, 1612)
if not mod then return end
mod:RegisterEnableMob(15932)
mod:SetEncounterID(1108)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L["28375_icon"] = "spell_nature_purge"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		28371, -- Frenzy
		29685, -- Terrifying Roar
		25646, -- Mortal Wound
		29306, -- Infected Wound
		{28375, "EMPHASIZE"}, -- Decimate
		"berserk",
	},nil,{
		[29685] = CL.fear, -- Terrifying Roar (Fear)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Frenzy", 28371)
	self:Log("SPELL_DISPEL", "FrenzyDispelled", "*")
	self:Log("SPELL_CAST_SUCCESS", "TerrifyingRoar", 29685)
	self:Log("SPELL_AURA_APPLIED_DOSE", "MortalWoundApplied", 25646)
	self:Log("SPELL_AURA_APPLIED_DOSE", "InfectedWoundApplied", 29306)
	self:Log("SPELL_DAMAGE", "Decimate", 28375)
	self:Log("SPELL_MISSED", "Decimate", 28375)
end

function mod:OnEngage()
	self:Berserk(360, true)
	self:CDBar(29685, 18, CL.fear) -- Terrifying Roar
	self:CDBar(28375, 105, self:SpellName(28375), L["28375_icon"]) -- Decimate
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Frenzy(args)
	self:Message(args.spellId, "orange")
	self:Bar(args.spellId, 9.7)
	if self:Dispeller("enrage", true) then
		self:PlaySound(args.spellId, "alert")
	end
end

function mod:FrenzyDispelled(args)
	if args.extraSpellName == self:SpellName(28371) then
		self:Message(28371, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:TerrifyingRoar(args)
	self:Message(args.spellId, "yellow", CL.fear)
	self:CDBar(args.spellId, 18, CL.fear)
	self:PlaySound(args.spellId, "long")
end

function mod:MortalWoundApplied(args)
	if args.amount >= 4 and args.amount % 2 == 0 then
		self:StackMessage(args.spellId, "purple", args.destName, args.amount, 6)
		if args.amount >= 6 then
			self:PlaySound(args.spellId, "info")
		end
	end
end

function mod:InfectedWoundApplied(args)
	if self:Me(args.destGUID) and args.amount % 3 == 0 then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 9)
	end
end

do
	local prev = 0
	function mod:Decimate(args)
		if args.time - prev > 5 then
			prev = args.time
			self:Message(args.spellId, "red", args.spellName, L["28375_icon"])
			self:CDBar(args.spellId, 105, args.spellName, L["28375_icon"])
			self:PlaySound(args.spellId, "warning")
		end
	end
end
