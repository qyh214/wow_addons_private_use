--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lord Rhyolith", 720, 193)
if not mod then return end
mod:RegisterEnableMob(52577, 53087, 52558) -- Left foot, Right Foot, Lord Rhyolith

--------------------------------------------------------------------------------
-- Locals
--

local lastFragments = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.armor = "Obsidian Armor"
	L.armor_desc = "Warn when armor stacks are being removed from Rhyolith."
	L.armor_icon = 98632
	L.armor_message = "%d%% armor left"
	L.armor_gone_message = "Armor go bye-bye!"

	L.adds_header = "Adds"
	L.big_add_message = "Big add spawned!"
	L.small_adds_message = "Small adds inc!"

	L.phase2_warning = "Phase 2 soon!"

	L.molten_message = "%dx stacks on boss!"

	L.stomp_message = "Stomp! Stomp! Stomp!"
	L.stomp = "Stomp"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		98552, 98136,
		"armor", 97282, 98255, -2537, 101304
	}, {
		[98552] = L["adds_header"],
		["armor"] = "general"
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED_DOSE", "MoltenArmor", 98255)
	self:Log("SPELL_CAST_START", "Stomp", 97282)
	self:Log("SPELL_SUMMON", "Spark", 98552)
	self:Log("SPELL_SUMMON", "Fragments", 98136)
	self:Log("SPELL_AURA_REMOVED_DOSE", "ObsidianStack", 98632)
	self:Log("SPELL_AURA_REMOVED", "Obsidian", 98632)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 52558)
end

function mod:OnEngage()
	self:Berserk(self:Heroic() and 300 or 360, nil, nil, 101304)
	self:Bar(97282, 15, L["stomp"])
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
	lastFragments = GetTime()
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Obsidian(args)
	if self:MobId(args.destGUID) == 52558 then
		self:MessageOld("armor", "green", nil, L["armor_gone_message"], args.spellId)
	end
end

function mod:ObsidianStack(args)
	if args.amount % 20 == 0 and self:MobId(args.destGUID) == 52558 then -- Only warn every 20
		self:MessageOld("armor", "green", nil, L["armor_message"]:format(args.amount), args.spellId)
	end
end

function mod:Spark(args)
	self:MessageOld(args.spellId, "red", "alarm", L["big_add_message"])
end

function mod:Fragments(args)
	local t = GetTime()
	if lastFragments and t < (lastFragments + 5) then return end
	lastFragments = t
	self:MessageOld(args.spellId, "yellow", "info", L["small_adds_message"])
end

function mod:Stomp(args)
	self:MessageOld(args.spellId, "orange", "alert", L["stomp_message"])
	self:Bar(args.spellId, 30, L["stomp"])
	self:Bar(args.spellId, 3, CL["cast"]:format(L["stomp"]))
end

function mod:MoltenArmor(args)
	if args.amount > 3 and args.amount % 2 == 0 and self:MobId(args.destGUID) == 52558 then
		self:MessageOld(args.spellId, "yellow", nil, L["molten_message"]:format(args.amount))
	end
end

function mod:UNIT_HEALTH(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 30 then -- phase starts at 25
		self:MessageOld(-2537, "green", "info", L["phase2_warning"], 99846)
		self:UnregisterUnitEvent(event, unit)
		local _, stack = self:UnitBuff(unit, 98255) -- Molten Armor
		if stack then
			self:MessageOld(98255, "red", "alarm", L["molten_message"]:format(stack))
		end
	end
end

