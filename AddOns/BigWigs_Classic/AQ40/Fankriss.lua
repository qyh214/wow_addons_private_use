--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Fankriss the Unyielding", 531, 1545)
if not mod then return end
mod:RegisterEnableMob(15510)
mod:SetEncounterID(712)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L["25832_icon"] = "inv_misc_monstertail_03"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		25646, -- Mortal Wound
		25832, -- Summon Worm
		720, -- Entangle
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED_DOSE", "MortalWound", 25646)
	self:Log("SPELL_CAST_SUCCESS", "SummonWorm", 518, 25831, 25832)
	self:Log("SPELL_AURA_APPLIED", "Entangle", 720, 731, 1121)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MortalWound(args)
	self:StackMessage(args.spellId, "purple", args.destName, args.amount, 5)
	self:TargetBar(args.spellId, 15, args.destName)
	if args.amount >= 5 then
		self:PlaySound(args.spellId, "alert", nil, args.destName)
	end
end

function mod:SummonWorm(args)
	self:Message(25832, "cyan", args.spellName, L["25832_icon"])
	self:PlaySound(25832, "warning")
end

function mod:Entangle(args)
	if self:Player(args.destFlags) then -- Players, not pets
		self:TargetMessage(720, "red", args.destName)
		self:PlaySound(720, "alarm", nil, args.destName)
	end
end
