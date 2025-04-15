--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Hodir", 603, 1644)
if not mod then return end
mod:RegisterEnableMob(32845)
mod:SetEncounterID(BigWigsLoader.isWrath and 751 or 1135)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local flashFreezed = mod:NewTargetList()
local lastCold = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.hardmode = "Hard mode"
	L.hardmode_desc = "Show timer for hard mode."
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		62039, -- Biting Cold
		{65133, "ICON"}, -- Storm Cloud
		{61968, "CASTBAR"}, -- Flash Freeze
		63512, -- Frozen Blows
		"hardmode",
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "FlashFreezeCast", 61968)
	self:Log("SPELL_AURA_APPLIED", "FlashFreeze", 61969)
	self:Log("SPELL_AURA_APPLIED", "FrozenBlows", 63512)
	self:Log("SPELL_AURA_APPLIED", "StormCloud", 65133)
	self:Log("SPELL_AURA_REMOVED", "StormCloudRemoved", 65133)

	self:RegisterUnitEvent("UNIT_AURA", nil, "player")
end

function mod:OnEngage()
	lastCold = 0
	self:Bar(61968, 35) -- Flash Freeze
	self:Bar("hardmode", self:Classic() and 121 or 150, CL.hard, 27578) -- ability_warrior_battleshout / Battle Shout / icon 132333
	self:Berserk(480)
end

function mod:VerifyEnable(unit)
	return (UnitIsEnemy(unit, "player") and UnitHealth(unit) > 100) and true or false
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:StormCloud(args)
	self:TargetMessageOld(args.spellId, args.destName, "green", "info")
	self:TargetBar(args.spellId, 30, args.destName)
	self:PrimaryIcon(args.spellId, args.destName)
end

function mod:StormCloudRemoved(args)
	self:StopBar(args.spellName, args.destName)
	self:PrimaryIcon(args.spellId)
end

function mod:FlashFreezeCast(args)
	self:MessageOld(args.spellId, "yellow", "long", CL.casting:format(args.spellName))
	self:CastBar(args.spellId, 9)
	self:Bar(args.spellId, 35)
	self:DelayedMessage(args.spellId, 30, "yellow", CL.custom_sec:format(args.spellName, 5))
end

function mod:FlashFreeze(args)
	if args.destGUID:find("Player", nil, true) then -- Applies to NPCs
		flashFreezed[#flashFreezed + 1] = args.destName
		if #flashFreezed == 1 then
			self:ScheduleTimer("TargetMessageOld", 0.3, 61968, flashFreezed, "orange", "alert")
		end
	end
end

function mod:FrozenBlows(args)
	self:MessageOld(args.spellId, "red")
	self:Bar(args.spellId, 20)
end

function mod:UNIT_AURA(_, unit)
	local name, stack = self:UnitDebuff(unit, 62039) -- Biting Cold
	if stack and stack ~= lastCold then
		if stack > 1 then
			self:PersonalMessage(62039, nil, CL.count:format(name, stack))
			self:PlaySound(62039, "alert")
		end
		lastCold = stack
	end
end
