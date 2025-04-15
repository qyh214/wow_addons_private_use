--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Solistrasza", 2856)
if not mod then return end
mod:RegisterEnableMob(238954)
mod:SetEncounterID(3186)
mod:SetRespawnTime(10)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Solistrasza"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		"adds",
		1231993, -- Tarnished Breath
		1227696, -- Hallowed Dive
		1228063, -- Cremation
		"berserk",
	},nil,{
		[1228063] = CL.interruptible, -- Cremation (Interruptible)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "TarnishedBreathApplied", 1231993)
	self:Log("SPELL_AURA_APPLIED_DOSE", "TarnishedBreathApplied", 1231993)
	self:Log("SPELL_CAST_START", "Lightforge", 1227520)
	self:Log("SPELL_CAST_START", "HallowedDive", 1227696)
	self:Log("SPELL_CAST_SUCCESS", "AberrantBloat", 1232333)
	self:Log("SPELL_CAST_START", "Cremation", 1228044)
	self:Log("SPELL_INTERRUPT", "CremationInterrupted", "*")
	self:Log("SPELL_AURA_APPLIED", "CremationDamage", 1228063)
	self:Log("SPELL_PERIODIC_DAMAGE", "CremationDamage", 1228063)
	self:Log("SPELL_PERIODIC_MISSED", "CremationDamage", 1228063)
end

function mod:OnEngage()
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:Berserk(480, true) -- No engage message
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:TarnishedBreathApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		self:StackMessage(args.spellId, "blue", args.destName, amount, 2)
		if amount >= 2 then
			self:PlaySound(args.spellId, "alert")
		end
	elseif self:Player(args.destFlags) then -- Players, not pets
		local bossUnit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID)
		if bossUnit and targetUnit and self:Tanking(bossUnit, targetUnit) then
			self:StackMessage(args.spellId, "purple", args.destName, args.amount, 2)
		end
	end
end

function mod:Lightforge(args)
	local stage = self:GetStage() + 1
	self:SetStage(stage)
	self:Message("stages", "cyan", CL.percent:format(20, CL.stage:format(stage)), false)
	self:PlaySound("stages", "long")
end

function mod:HallowedDive(args)
	self:Message(args.spellId, "red", CL.incoming:format(args.spellName))
	self:PlaySound(args.spellId, "alarm")
end

do
	local prev = 0
	function mod:AberrantBloat(args)
		if args.time - prev > 10 and self:IsEngaged() then -- Cast by trash
			prev = args.time
			self:Message("adds", "cyan", CL.adds_spawned, false)
			self:PlaySound("adds", "info")
		end
	end
end

function mod:Cremation(args)
	self:Message(1228063, "yellow", CL.extra:format(args.spellName, CL.interruptible))
	self:PlaySound(1228063, "warning")
end

function mod:CremationInterrupted(args)
	if args.extraSpellName == self:SpellName(1228044) then
		self:Message(1228063, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

do
	local prev = 0
	function mod:CremationDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
