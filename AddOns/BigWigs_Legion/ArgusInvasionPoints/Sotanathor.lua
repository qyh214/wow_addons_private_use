
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Sothanar", 1779, 2014)
if not mod then return end
mod:RegisterEnableMob(124555)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		247698, -- Silence
		{247410, "TANK"}, -- Soul Cleave
		247416, -- Cavitation
		{247437, "SAY", "SAY_COUNTDOWN", "FLASH"}, -- Seed of Destruction
	}
end

function mod:OnBossEnable()
	self:ScheduleTimer("CheckForEngage", 1)

	self:Log("SPELL_CAST_START", "Silence", 247698)
	self:Log("SPELL_CAST_START", "SoulCleave", 247410)
	self:Log("SPELL_AURA_APPLIED", "ClovenSoul", 247444)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ClovenSoul", 247444)
	self:Log("SPELL_CAST_SUCCESS", "Cavitation", 247416)
	self:Log("SPELL_CAST_SUCCESS", "SeedOfDestruction", 247437)
	self:Log("SPELL_AURA_APPLIED", "SeedOfDestructionApplied", 247437)
	self:Log("SPELL_AURA_REMOVED", "SeedOfDestructionRemoved", 247437)

	self:Death("Win", 124555)
end

function mod:OnEngage()
	self:CheckForWipe()
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Silence(args)
	self:MessageOld(args.spellId, "yellow", "long", CL.casting:format(args.spellName))
	self:CDBar(args.spellId, 25)
end

function mod:SoulCleave(args)
	self:MessageOld(args.spellId, "red", "alarm")
	self:CDBar(args.spellId, 25)
end

function mod:ClovenSoul(args)
	local amount = args.amount or 1
	self:StackMessageOld(247410, args.destName, amount, "cyan", amount > 1 and "warning" or "info", args.spellId)
end

function mod:Cavitation(args)
	self:MessageOld(args.spellId, "yellow", "alert")
	self:CDBar(args.spellId, 25)
end

function mod:SeedOfDestruction(args)
	self:CDBar(args.spellId, 18)
end

do
	local playerList = mod:NewTargetList()
	function mod:SeedOfDestructionApplied(args)
		playerList[#playerList+1] = args.destName
		if self:Me(args.destGUID) then
			self:Flash(args.spellId)
			self:Say(args.spellId, nil, nil, "Seed of Destruction")
			self:SayCountdown(args.spellId, 4)
		end
		if #playerList == 1 then
			self:ScheduleTimer("TargetMessageOld", 0.3, args.spellId, playerList, "orange", "warning", nil, nil, true)
		end
	end

	function mod:SeedOfDestructionRemoved(args)
		if self:Me(args.destGUID) then
			self:CancelSayCountdown(args.spellId)
		end
	end
end
