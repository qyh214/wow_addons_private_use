--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Jammal'an and Ogom Discovery", 109)
if not mod then return end
mod:RegisterEnableMob(218721, 218718) -- Jammal'an the Prophet, Ogom the Wretched
mod:SetEncounterID(2957)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local curseCount = 0
local curseTime = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Jammal'an and Ogom"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		437817, -- Holy Nova
		437809, -- Holy Fire
		437868, -- Agonizing Weakness
		437847, -- Mortal Lash
		437927, -- Shadow Sermon: Pain
		437921, -- Mass Penance
		437930, -- Power Word: Shield
		437928, -- Psychic Scream
	},nil,{
		[437868] = CL.curse, -- Agonizing Weakness (Curse)
		[437928] = CL.fear, -- Psychic Scream (Fear)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "HolyNovaStart", 437817)
	self:Log("SPELL_CAST_SUCCESS", "HolyFire", 437809)
	self:Log("SPELL_CAST_SUCCESS", "AgonizingWeakness", 437868)
	self:Log("SPELL_AURA_APPLIED", "AgonizingWeaknessApplied", 437868)
	self:Log("SPELL_AURA_REMOVED", "AgonizingWeaknessRemoved", 437868)
	self:Log("SPELL_CAST_SUCCESS", "MortalLash", 437847)

	self:Log("SPELL_CAST_START", "DrainingStart", 437995)
	self:Log("SPELL_CAST_SUCCESS", "Draining", 437995)

	self:Log("SPELL_CAST_SUCCESS", "ShadowSermonPain", 437927)
	self:Log("SPELL_CAST_START", "MassPenanceStart", 437921)
	self:Log("SPELL_CAST_SUCCESS", "PowerWordShield", 437930)
	self:Log("SPELL_DISPEL", "PowerWordShieldDispelled", "*")
	self:Log("SPELL_CAST_START", "PsychicScreamStart", 437928)
end

function mod:OnEngage()
	curseCount = 0
	curseTime = 0
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:CDBar(437817, 8) -- Holy Nova
	self:CDBar(437809, 7.4) -- Holy Fire
	self:CDBar(437868, 14.9, CL.curse) -- Agonizing Weakness
	self:CDBar(437847, 6.4) -- Mortal Lash
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:HolyNovaStart(args)
	self:Message(args.spellId, "red", CL.incoming:format(args.spellName))
	self:CDBar(args.spellId, 17.8)
	self:PlaySound(args.spellId, "warning")
end

function mod:HolyFire(args)
	self:Message(args.spellId, "yellow", CL.on_group:format(args.spellName))
	self:CDBar(args.spellId, 14.6)
	self:PlaySound(args.spellId, "alarm")
end

function mod:AgonizingWeakness(args)
	curseCount = 0
	curseTime = args.time
	self:Message(args.spellId, "red", CL.on_group:format(CL.curse))
	self:Bar(args.spellId, 27.5, CL.curse)
	self:PlaySound(args.spellId, "alert")
end

function mod:AgonizingWeaknessApplied()
	curseCount = curseCount + 1
end

function mod:AgonizingWeaknessRemoved(args)
	curseCount = curseCount - 1
	if curseCount == 0 then
		self:Message(args.spellId, "green", CL.removed_after:format(CL.curse, args.time-curseTime))
	end
end

function mod:MortalLash(args)
	self:TargetMessage(args.spellId, "orange", args.destName)
	self:Bar(args.spellId, 25.9)
	self:PlaySound(args.spellId, "info", nil, args.destName)
end

function mod:DrainingStart(args)
	self:StopBar(437817) -- Holy Nova
	self:StopBar(437809) -- Holy Fire
	self:StopBar(CL.curse) -- Agonizing Weakness
	self:StopBar(437847) -- Mortal Lash
	self:Message("stages", "cyan", CL.intermission, args.spellId)
	self:Bar("stages", 6, CL.intermission, args.spellId)
	self:PlaySound("stages", "long")
end

function mod:Draining()
	self:SetStage(2)
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:CDBar(437927, 12.1) -- Shadow Sermon: Pain
	self:CDBar(437921, 23.1) -- Mass Penance
	self:CDBar(437930, 19.8) -- Power Word: Shield
	self:CDBar(437928, 16.6, CL.fear) -- Psychic Scream
end

function mod:ShadowSermonPain(args)
	self:Message(args.spellId, "red")
	self:CDBar(args.spellId, 22.6)
	self:PlaySound(args.spellId, "alarm")
end

function mod:MassPenanceStart(args)
	self:Message(args.spellId, "orange")
	self:CDBar(args.spellId, 21)
	self:PlaySound(args.spellId, "alert")
end

function mod:PowerWordShield(args)
	self:Message(args.spellId, "yellow", CL.onboss:format(args.spellName))
	self:CDBar(args.spellId, 16.1)
	self:PlaySound(args.spellId, "warning")
end

function mod:PowerWordShieldDispelled(args)
	if args.extraSpellName == self:SpellName(437930) then
		self:Message(437930, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:PsychicScreamStart(args)
	self:Message(args.spellId, "yellow", CL.fear)
	self:CDBar(args.spellId, 43.6, CL.fear)
	self:PlaySound(args.spellId, "long")
end
