--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Alizabal", 757, 339)
if not mod then return end
mod:RegisterEnableMob(55869)

local firstAbility = nil
local danceCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.first_ability = "Skewer or Hate"
	L.dance_message = "Blade Dance %d of 3"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {105067, 104936, 105784, "berserk"}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Hate", 105067)
	self:Log("SPELL_AURA_APPLIED", "Skewer", 104936)
	self:Log("SPELL_AURA_APPLIED", "BladeDance", 105784)
	self:Log("SPELL_AURA_REMOVED", "BladeDanceOver", 105784)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 55869)
end

function mod:OnEngage()
	self:Berserk(300)
	self:Bar(104936, 7, L["first_ability"])
	self:Bar(105784, 35) -- Blade Dance
	firstAbility = nil
	danceCount = 0
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Hate(args)
	if not firstAbility then
		firstAbility = true
		self:Bar(104936, 8) -- Skewer
	end
	self:Bar(args.spellId, 20)
	self:TargetMessageOld(args.spellId, args.destName, "red")
end

function mod:Skewer(args)
	if not firstAbility then
		firstAbility = true
		self:Bar(105067, 8) -- Seething Hate
	end
	self:Bar(args.spellId, 20)
	self:TargetMessageOld(args.spellId, args.destName, "yellow")
end

function mod:BladeDance(args)
	danceCount = danceCount + 1
	self:MessageOld(args.spellId, "orange", "info", L["dance_message"]:format(danceCount))
	self:Bar(args.spellId, 4, CL["cast"]:format(args.spellName))
	if danceCount == 1 then
		firstAbility = nil
		-- XXX Fix this up instead of just cancelling the bars
		self:StopBar(104936) -- Skewer
		self:StopBar(105067) -- Seething Hate
		self:Bar(args.spellId, 60)
	end
end

function mod:BladeDanceOver()
	if danceCount == 3 then
		self:Bar(104936, 8, L["first_ability"])
		danceCount = 0
	end
end

