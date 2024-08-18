
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Icecrown Citadel Trash", 631)
if not mod then return end
mod.displayName = CL.trash
mod:RegisterEnableMob(
	37007, -- Deathbound Ward
	36805, 36807, 36808, 36811, 36829, -- Deathspeaker Servant, Disciple, Zealot, Attendant, Deathspeaker High Priest
	37217, 37025 -- Precious, Stinky
)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.deathbound_ward = "Deathbound Ward"
	L.deathspeaker_high_priest = "Deathspeaker High Priest" -- NPC ID 36829
	L.putricide_dogs = "Precious & Stinky"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		--[[ Deathbound Ward ]]--
		71022, -- Disrupting Shout
		--[[ Deathspeaker High Priest ]]--
		{69483, "ICON", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Dark Reckoning
		--[[ Putricide Dogs ]]--
		{71127, "TANK"}, -- Mortal Wound
	}, {
		[71022] = L.deathbound_ward,
		[69483] = L.deathspeaker_high_priest,
		[71127] = L.putricide_dogs,
	}
end

function mod:OnBossEnable()
	--[[ General ]]--
	self:RegisterMessage("BigWigs_OnBossEngage", "Disable")

	--[[ Deathbound Ward ]]--
	self:Log("SPELL_CAST_START", "DisruptingShout", 71022)

	--[[ Deathspeaker High Priest ]]--
	self:Log("SPELL_AURA_APPLIED", "DarkReckoningApplied", 69483)
	self:Log("SPELL_AURA_REMOVED", "DarkReckoningRemoved", 69483)

	--[[ Putricide Dogs ]]--
	self:Log("SPELL_AURA_APPLIED_DOSE", "MortalWound", 71127)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

--[[ Deathbound Ward ]]--
function mod:DisruptingShout(args)
	self:Message(71022, "red")
	self:PlaySound(71022, "alarm")
	self:Bar(71022, 3)
end

--[[ Deathspeaker High Priest ]]--
function mod:DarkReckoningApplied(args)
	self:TargetMessage(args.spellId, "red", args.destName)
	self:TargetBar(args.spellId, 8, args.destName)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Dark Reckoning")
		self:SayCountdown(args.spellId, 8)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:DarkReckoningRemoved(args)
	self:StopBar(args.spellName, args.destName)
	self:PrimaryIcon(args.spellId)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

--[[ Putricide Dogs ]]--
function mod:MortalWound(args)
	if args.amount % 2 == 0 or args.amount > 5 then
		self:StackMessage(71127, "purple", args.destName, args.amount, 6)
		if self:Tank() and args.amount > 5 then
			self:PlaySound(71127, "warning")
		end
	end
end
