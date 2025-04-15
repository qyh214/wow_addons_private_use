--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ignis the Furnace Master", 603, 1638)
if not mod then return end
mod:RegisterEnableMob(33118)
mod:SetEncounterID(BigWigsLoader.isWrath and 745 or 1136)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.brittle_message = "Construct is Brittle!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		62488, -- Activate Construct
		62382, -- Brittle
		63472, -- Flame Jets
		63474, -- Scorch
		62717, -- Slag Pot
		"berserk"
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "ActivateConstruct", 62488)
	self:Log("SPELL_CAST_SUCCESS", "ScorchCast", 63474)
	self:Log("SPELL_AURA_APPLIED", "SlagPot", 62717)
	self:Log("SPELL_CAST_START", "FlameJets", 63472)
	self:Log("SPELL_AURA_APPLIED", "Brittle", 62382)

	self:Log("SPELL_DAMAGE", "ScorchDamage", 63473, 63475) -- Seems to use 2 different spells
	self:Log("SPELL_MISSED", "ScorchDamage", 63473, 63475)
end

function mod:OnEngage()
	self:CDBar(63474, 10.9) -- Scorch
	self:CDBar(63472, 20.6) -- Flame Jets
	self:CDBar(62488, 17, CL.next_add, "INV_Misc_Statue_07") -- Activate Construct
	self:Berserk(660) -- Can vary between 654 and 663
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ActivateConstruct(args)
	self:MessageOld(args.spellId, "red", self:Tank() and "warning", CL.add_spawned, "INV_Misc_Statue_07")
	self:CDBar(args.spellId, 30.3, CL.next_add, "INV_Misc_Statue_07") -- Usually 30.3, sometimes 35/37
end

function mod:ScorchCast(args)
	self:MessageOld(args.spellId, "yellow")
	self:CDBar(args.spellId, 22)
end

function mod:SlagPot(args)
	self:TargetMessageOld(args.spellId, args.destName, "red", "alert", nil, nil, self:Healer())
	self:TargetBar(args.spellId, 10, args.destName)
end

function mod:FlameJets(args)
	self:MessageOld(args.spellId, "yellow", "long")
	self:CDBar(args.spellId, 24.3)
end

function mod:Brittle(args)
	self:MessageOld(args.spellId, "green", "info", L.brittle_message)
end

do
	local prev = 0
	function mod:ScorchDamage(args)
		if self:Me(args.destGUID) then
			local t = GetTime()
			if t-prev > 2 then
				prev = t
				self:MessageOld(63474, "blue", "alarm", CL.underyou:format(args.spellName))
			end
		end
	end
end
