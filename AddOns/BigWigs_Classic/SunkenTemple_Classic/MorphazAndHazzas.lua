--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Morphaz and Hazzas Discovery", 109)
if not mod then return end
mod:RegisterEnableMob(221943, 221942) -- Hazzas, Morphaz
mod:SetEncounterID(2958)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local dreamingOnMe = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Morphaz and Hazzas"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		446489, -- Backfire
		446468, -- Dreamer's Lament
		445158, -- Lucid Dreaming
		446487, -- Corrupted Breath
		446661, -- Animate Flame
	},nil,{
		[446489] = CL.knockback, -- Backfire (Knockback)
		[445158] = CL.you_die, -- Lucid Dreaming (You die)
		[446661] = CL.adds, -- Animate Flame (Adds)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "BackfireStart", 446489)
	self:Log("SPELL_CAST_SUCCESS", "DreamersLament", 446468)
	self:Log("SPELL_AURA_APPLIED", "LucidDreamingApplied", 445158)
	self:Log("SPELL_AURA_REMOVED", "LucidDreamingRemoved", 445158)
	self:Log("SPELL_CAST_START", "EternalSlumberStart", 446034)
	self:Log("SPELL_AURA_APPLIED", "CorruptedBreathApplied", 446487)
	self:Log("SPELL_AURA_APPLIED_DOSE", "CorruptedBreathApplied", 446487)
	self:Log("SPELL_CAST_START", "AnimateFlameStart", 446661)
end

function mod:OnEngage()
	dreamingOnMe = false
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:BackfireStart(args)
	self:Message(args.spellId, "red", CL.knockback)
	self:PlaySound(args.spellId, "alarm")
end

function mod:DreamersLament(args)
	self:Message(args.spellId, "orange", CL.on_group:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
end

function mod:LucidDreamingApplied(args)
	if self:Me(args.destGUID) then
		dreamingOnMe = true
	end
end

function mod:LucidDreamingRemoved(args)
	if self:Me(args.destGUID) then
		dreamingOnMe = false
		self:StopBar(CL.you_die)
	end
end

function mod:EternalSlumberStart(args)
	if dreamingOnMe then
		self:Bar(445158, 30, CL.you_die)
	end
end

function mod:CorruptedBreathApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 2)
		if args.amount then
			self:PlaySound(args.spellId, "alert")
		end
	else
		local bossUnit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID, true)
		if bossUnit and targetUnit and self:Tanking(bossUnit, targetUnit) then
			self:StackMessage(args.spellId, "purple", args.destName, args.amount, 2)
			if args.amount then
				self:PlaySound(args.spellId, "alert")
			end
		end
	end
end

function mod:AnimateFlameStart(args)
	self:Message(args.spellId, "cyan", CL.adds)
	self:PlaySound(args.spellId, "info")
end
