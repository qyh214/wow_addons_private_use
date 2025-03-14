--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ghamoo-ra Discovery", 48)
if not mod then return end
mod:RegisterEnableMob(201722) -- Ghamoo-ra Season of Discovery
mod:SetEncounterID(2697)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local isWeakened = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Ghamoo-ra"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		407095, -- Crunch Armor
		407025, -- Exposed
		407077, -- Triple Chomp
		{406970, "INFOBOX", "CASTBAR"}, -- Aqua Shell
	},nil,{
		[407025] = CL.weakened, -- Exposed (Weakened)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "CrunchArmorApplied", 407095)
	self:Log("SPELL_AURA_APPLIED_DOSE", "CrunchArmorApplied", 407095)
	self:Log("SPELL_AURA_APPLIED", "Exposed", 407025)
	self:Log("SPELL_AURA_REMOVED", "ExposedOver", 407025)
	self:Log("SPELL_AURA_APPLIED", "AquaShellApplied", 406970)
	self:Log("SPELL_AURA_REMOVED_DOSE", "AquaShellRemovedDose", 406970)
	self:Log("SPELL_CAST_START", "AquaShellCast", 414370)
	self:Log("SPELL_AURA_APPLIED", "TripleChomp", 407077)
end

function mod:OnEngage()
	isWeakened = false
	self:Bar(407077, 15.8) -- Triple Chomp
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CrunchArmorApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		self:StackMessage(args.spellId, "blue", args.destName, amount, 3)
		if amount >= 3 then
			self:PlaySound(args.spellId, "alert")
		end
	elseif args.amount and self:Player(args.destFlags) then -- Players, not pets
		local bossUnit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID, true)
		if bossUnit and targetUnit and self:Tanking(bossUnit, targetUnit) then
			self:StackMessage(args.spellId, "purple", args.destName, args.amount, 3)
			if args.amount >= 3 then
				self:PlaySound(args.spellId, "alert")
			end
		end
	end
end

function mod:Exposed(args)
	isWeakened = true
	self:CloseInfo(406970) -- Aqua Shell
	self:Message(args.spellId, "yellow", CL.duration:format(CL.weakened, 60))
	self:Bar(args.spellId, 60, CL.weakened)
	self:PlaySound(args.spellId, "long")
end

function mod:ExposedOver(args)
	isWeakened = false
	self:Message(args.spellId, "red", CL.over:format(CL.weakened))
	self:PlaySound(args.spellId, "info")
end

function mod:AquaShellApplied(args)
	self:OpenInfo(args.spellId, "BigWigs")
	self:SetInfo(args.spellId, 1, "|T134564:0:0:0:0:64:64:4:60:4:60|t".. args.spellName)
	self:SetInfoBar(args.spellId, 3, 1)
	self:SetInfo(args.spellId, 3, 100)
end

function mod:AquaShellRemovedDose(args)
	self:SetInfoBar(args.spellId, 3, args.amount/100)
	self:SetInfo(args.spellId, 3, args.amount)
end

function mod:AquaShellCast() -- Aqua shell being removed, Knockback incoming
	self:Message(406970, "orange", CL.incoming:format(CL.knockback))
	self:CastBar(406970, 4, CL.knockback)
	self:PlaySound(406970, "warning")
end

function mod:TripleChomp(args)
	self:Message(args.spellId, "purple")
	self:Bar(args.spellId, isWeakened and 11.3 or 16.2)
end
