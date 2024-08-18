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
		28371, -- Enrage
		54378, -- Mortal Wound
		29306, -- Infected Wound
		{28375, "EMPHASIZE"}, -- Decimate
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Enrage", 28371, 54427) -- 10, 25
	self:Log("SPELL_DISPEL", "EnrageDispelled", "*")
	self:Log("SPELL_AURA_APPLIED_DOSE", "MortalWoundApplied", 54378)
	self:Log("SPELL_AURA_APPLIED_DOSE", "InfectedWoundApplied", 29306)
	self:Log("SPELL_DAMAGE", "Decimate", 28375)
	self:Log("SPELL_MISSED", "Decimate", 28375)
end

function mod:OnEngage()
	self:Berserk(self:Difficulty() == 3 and 480 or 420, true) -- 8min on 10, 7min on 25
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Enrage(args)
	self:Message(28371, "orange")
	if self:Dispeller("enrage", true) then
		self:PlaySound(28371, "alert")
	end
end

function mod:EnrageDispelled(args)
	if args.extraSpellId == 28371 or args.extraSpellId == 54427 then
		self:Message(28371, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
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
			self:PlaySound(args.spellId, "warning")
		end
	end
end
