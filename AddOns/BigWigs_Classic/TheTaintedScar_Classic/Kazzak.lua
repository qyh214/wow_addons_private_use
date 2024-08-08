--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lord Kazzak Season of Discovery", 2789)
if not mod then return end
mod:RegisterEnableMob(230302)
mod:SetEncounterID(3026)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Lord Kazzak"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		21056, -- Mark of Kazzak
		21063, -- Twisted Reflection
		"berserk",
	},nil,{
		[21056] = CL.curse, -- Mark of Kazzak (Curse)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "MarkOfKazzakApplied", 21056)
	self:Log("SPELL_AURA_REMOVED", "MarkOfKazzakRemoved", 21056)
	self:Log("SPELL_CAST_SUCCESS", "CaptureSoul", 21054)
	self:Log("SPELL_AURA_APPLIED", "TwistedReflectionApplied", 21063)
	self:Log("SPELL_AURA_REMOVED", "TwistedReflectionRemoved", 21063)
	self:Log("SPELL_DISPEL", "Dispels", "*")
end

function mod:OnEngage()
	self:Berserk(180) -- Actual spell is Frenzy (21340)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MarkOfKazzakApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.curse)
	self:TargetBar(args.spellId, 60, args.destName, CL.curse)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	elseif self:Dispeller("curse") then
		self:PlaySound(args.spellId, "warning")
	end
end

do
	local prevRemoved = nil
	function mod:MarkOfKazzakRemoved(args)
		prevRemoved = args.destName
		self:StopBar(CL.curse, args.destName)
	end

	function mod:CaptureSoul() -- Huge heal when someone explodes
		self:TargetMessage(21056, "red", prevRemoved, CL.explosion)
		self:PlaySound(21056, "long")
	end
end

function mod:TwistedReflectionApplied(args)
	self:TargetMessage(args.spellId, "orange", args.destName)
	self:TargetBar(args.spellId, 45, args.destName)
	if self:Dispeller("magic") then
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:TwistedReflectionRemoved(args)
	self:StopBar(args.spellName, args.destName)
end

function mod:Dispels(args)
	if args.extraSpellName == self:SpellName(21056) then
		self:Message(21056, "green", CL.removed_by:format(CL.curse, self:ColorName(args.sourceName)))
	elseif args.extraSpellName == self:SpellName(21063) then
		self:Message(21063, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end
