--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Fankriss the Unyielding", 531, 1545)
if not mod then return end
mod:RegisterEnableMob(15510)
mod:SetEncounterID(712)

--------------------------------------------------------------------------------
-- Locals
--

local wormCount = 1

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

function mod:OnEngage()
	wormCount = 1
	if self:GetSeason() == 2 then
		self:CDBar(25832, 20, CL.count:format(self:SpellName(25832), wormCount), L["25832_icon"])
	end
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
	if self:GetSeason() == 2 then
		if args.spellId == 518 then
			local msg = CL.count:format(args.spellName, wormCount)
			self:StopBar(msg)
			self:Message(25832, "cyan", msg, L["25832_icon"])
			wormCount = wormCount + 1
			self:CDBar(25832, 30, CL.count:format(args.spellName, wormCount), L["25832_icon"])
			self:PlaySound(25832, "warning")
		end
	else
		self:Message(25832, "cyan", CL.count:format(args.spellName, wormCount), L["25832_icon"])
		wormCount = wormCount + 1
		self:PlaySound(25832, "warning")
	end
end

function mod:Entangle(args)
	if self:Player(args.destFlags) then -- Players, not pets
		self:TargetMessage(720, "red", args.destName)
		self:PlaySound(720, "alarm", nil, args.destName)
	end
end
